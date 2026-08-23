#!/usr/bin/env python3
"""
Tubature Automated Visual & UI/UX QA Runner
Runs automated interactive playability and UI inspection tests against localhost:8765.
"""

import json
import base64
import time
import os
import sys
import subprocess
import urllib.request
from websocket import create_connection

SCREENSHOT_DIR = "/tmp/tubature_qa"
os.makedirs(SCREENSHOT_DIR, exist_ok=True)

class QARunner:
    def __init__(self, url="http://localhost:8765", port=9222):
        self.url = url
        self.port = port
        self.proc = None
        self.ws = None
        self.findings = []
        self.screenshots = {}

    def start_chrome(self):
        subprocess.run(["pkill", "-9", "-f", "Chrome.*9222"], stderr=subprocess.DEVNULL)
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
        time.sleep(5)

        pages = json.loads(urllib.request.urlopen(f'http://localhost:{self.port}/json').read())
        ws_url = pages[0]['webSocketDebuggerUrl']
        for p in pages:
            if '8765' in p.get('url', ''):
                ws_url = p['webSocketDebuggerUrl']
                break
        self.ws = create_connection(ws_url)
        time.sleep(1)

    def capture_screenshot(self, name):
        self.ws.send(json.dumps({'id': 100, 'method': 'Page.captureScreenshot', 'params': {'format': 'png'}}))
        r = json.loads(self.ws.recv())
        data = base64.b64decode(r['result']['data'])
        path = os.path.join(SCREENSHOT_DIR, f"{name}.png")
        with open(path, 'wb') as f:
            f.write(data)
        self.screenshots[name] = path
        print(f"  📸 Screenshot saved: {name}.png ({len(data)} bytes)")
        return path

    def click(self, x, y, count=1, delay=0.1):
        for _ in range(count):
            self.ws.send(json.dumps({'id': 1, 'method': 'Input.dispatchMouseEvent',
                'params': {'type': 'mousePressed', 'x': x, 'y': y, 'button': 'left', 'clickCount': 1}}))
            self.ws.recv()
            time.sleep(delay)
            self.ws.send(json.dumps({'id': 2, 'method': 'Input.dispatchMouseEvent',
                'params': {'type': 'mouseReleased', 'x': x, 'y': y, 'button': 'left', 'clickCount': 1}}))
            self.ws.recv()
            time.sleep(delay)

    def run_tests(self):
        print("🚀 Starting Tubature Visual & UI/UX QA Suite...")
        self.start_chrome()

        # 1. Home Screen Initial State
        print("\n--- Test 1: Home Screen (Initial) ---")
        self.capture_screenshot("01_home_initial")

        # 2. Test Difficulty Selector Chips
        print("\n--- Test 2: Difficulty Selection ---")
        # Approximate chip coordinates (on 450x850 window, centered horizontally around x=225, y=360-400)
        # Easy chip: left-center (~x=165, y=380)
        print("  Tapping 'Easy' chip...")
        self.click(165, 380)
        time.sleep(0.5)
        self.capture_screenshot("02_home_easy_selected")

        # Medium chip: center-right (~x=245, y=380)
        print("  Tapping 'Medium' chip...")
        self.click(245, 380)
        time.sleep(0.5)
        self.capture_screenshot("03_home_medium_selected")

        # Hard chip: right (~x=325, y=380)
        print("  Tapping 'Hard' chip...")
        self.click(325, 380)
        time.sleep(0.5)
        self.capture_screenshot("04_home_hard_selected")

        # 3. Start Game
        print("\n--- Test 3: Gameplay & Board Rendering ---")
        print("  Tapping PLAY button (~x=225, y=470)...")
        self.click(225, 470)
        time.sleep(2.5)
        self.capture_screenshot("05_game_board_initial")

        # 4. Rotate Tiles
        print("\n--- Test 4: Tile Rotation & Interaction ---")
        # Click tile at row 2, col 2 (~x=180, y=350)
        print("  Rotating tile (2,2)...")
        self.click(180, 350)
        time.sleep(0.5)
        self.capture_screenshot("06_tile_rotated_once")

        print("  Rotating tile (2,2) again...")
        self.click(180, 350)
        time.sleep(0.5)
        self.capture_screenshot("07_tile_rotated_twice")

        # 5. Hint & Reset buttons
        print("\n--- Test 5: Bottom Controls ---")
        # Reset button (~x=245, y=780)
        print("  Testing Reset button...")
        self.click(245, 780)
        time.sleep(0.5)
        self.capture_screenshot("08_after_reset")

        print("\n✅ QA Run Complete!")

    def cleanup(self):
        if self.ws:
            self.ws.close()
        if self.proc:
            self.proc.terminate()
        subprocess.run(["pkill", "-9", "-f", "Chrome.*9222"], stderr=subprocess.DEVNULL)

if __name__ == "__main__":
    runner = QARunner()
    try:
        runner.run_tests()
    finally:
        runner.cleanup()
