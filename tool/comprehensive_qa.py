import json, base64, time, os, subprocess, urllib.request
from websocket import create_connection

SCREENSHOT_DIR = '/tmp/tubature_qa'
os.makedirs(SCREENSHOT_DIR, exist_ok=True)

class ComprehensiveQARunner:
    def __init__(self, url='http://localhost:8765', port=9222):
        self.url = url
        self.port = port
        self.proc = None
        self.ws = None
        self.cmd_id = 100

    def send_cdp(self, method, params=None):
        self.cmd_id += 1
        payload = {'id': self.cmd_id, 'method': method}
        if params:
            payload['params'] = params
        self.ws.send(json.dumps(payload))
        while True:
            resp = json.loads(self.ws.recv())
            if resp.get('id') == self.cmd_id:
                return resp

    def start_chrome(self):
        subprocess.run(['pkill', '-9', '-f', 'Chrome.*9222'], stderr=subprocess.DEVNULL)
        time.sleep(1)
        self.proc = subprocess.Popen([
            '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
            f'--remote-debugging-port={self.port}',
            '--remote-allow-origins=*',
            '--headless',
            '--disable-gpu',
            '--no-first-run',
            '--no-default-browser-check',
            '--window-size=450,850',
            self.url
        ], stderr=subprocess.DEVNULL, stdout=subprocess.DEVNULL)
        time.sleep(4)

        pages = json.loads(urllib.request.urlopen(f'http://localhost:{self.port}/json').read())
        ws_url = pages[0]['webSocketDebuggerUrl']
        for p in pages:
            if '8765' in p.get('url', ''):
                ws_url = p['webSocketDebuggerUrl']
                break
        self.ws = create_connection(ws_url)
        time.sleep(1)

    def capture_screenshot(self, name):
        r = self.send_cdp('Page.captureScreenshot', {'format': 'png'})
        data = base64.b64decode(r['result']['data'])
        path = os.path.join(SCREENSHOT_DIR, f'{name}.png')
        with open(path, 'wb') as f:
            f.write(data)
        print(f'  [Screenshot] {name}.png ({len(data)} bytes)')
        return path

    def click(self, x, y, count=1, delay=0.1):
        for _ in range(count):
            self.send_cdp('Input.dispatchMouseEvent', {
                'type': 'mousePressed', 'x': x, 'y': y, 'button': 'left', 'clickCount': 1
            })
            time.sleep(delay)
            self.send_cdp('Input.dispatchMouseEvent', {
                'type': 'mouseReleased', 'x': x, 'y': y, 'button': 'left', 'clickCount': 1
            })
            time.sleep(delay)

    def run_all(self):
        print('Starting Tubature Comprehensive QA Runner...')
        self.start_chrome()

        print('--- 1. Home Screen (Auto) ---')
        time.sleep(1)
        self.capture_screenshot('01_home_auto')

        print('--- 2. Home Screen (Easy Selected) ---')
        self.click(180, 395)
        time.sleep(0.6)
        self.capture_screenshot('02_home_easy_selected')

        print('--- 3. Home Screen (Medium Selected) ---')
        self.click(260, 395)
        time.sleep(0.6)
        self.capture_screenshot('03_home_medium_selected')

        print('--- 4. Home Screen (Hard Selected) ---')
        self.click(345, 395)
        time.sleep(0.6)
        self.capture_screenshot('04_home_hard_selected')

        print('--- 5. Tutorial Navigation ---')
        self.click(225, 600)
        time.sleep(2)
        self.capture_screenshot('05_tutorial_level1')

        print('  Navigating back to Home from Tutorial...')
        self.click(30, 25)
        time.sleep(1)
        self.capture_screenshot('06_back_to_home')

        print('--- 6. Start Game (Auto / Progressive) ---')
        self.click(95, 395)
        time.sleep(0.5)
        self.click(225, 490)
        time.sleep(2)
        self.capture_screenshot('07_game_auto_initial')

        print('--- 7. Tile Interaction & Rotation ---')
        self.click(180, 360)
        time.sleep(0.5)
        self.capture_screenshot('08_game_tile_rotated_1')

        self.click(180, 360)
        time.sleep(0.5)
        self.capture_screenshot('09_game_tile_rotated_2')

        print('--- 8. Hint Button ---')
        self.click(195, 755)
        time.sleep(0.5)
        self.capture_screenshot('10_game_hint_snack')

        print('--- 9. Reset Button ---')
        self.click(255, 755)
        time.sleep(0.5)
        self.capture_screenshot('11_game_reset_clicked')

        print('--- 10. Start Hard Difficulty ---')
        self.click(30, 25)
        time.sleep(1)
        self.click(345, 395)
        time.sleep(0.5)
        self.click(225, 490)
        time.sleep(2)
        self.capture_screenshot('12_game_hard_initial')

        print('Comprehensive QA Run Finished Successfully!')

    def cleanup(self):
        if self.ws:
            self.ws.close()
        if self.proc:
            self.proc.terminate()
        subprocess.run(['pkill', '-9', '-f', 'Chrome.*9222'], stderr=subprocess.DEVNULL)

if __name__ == '__main__':
    runner = ComprehensiveQARunner()
    try:
        runner.run_all()
    finally:
        runner.cleanup()
