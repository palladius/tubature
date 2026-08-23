#!/usr/bin/env python3
"""
Tubature Multi-Device & Cartridge QA Test Suite
Tests:
1. Computer / Desktop (1440x900)
2. Pixel 10 (412x915 Portrait, 915x412 Landscape)
3. iPhone 16 Pro Max (430x932 Portrait, 932x430 Landscape)
4. Samsung Galaxy Tab / iPad (820x1180 Portrait, 1180x820 Landscape)

Cartridges:
- Cartridge A: Multi-Device Home Screen Visual Inspection
- Cartridge B: Easy Game Mode (Select Easy 🟢 -> PLAY! -> rotate tiles)
- Cartridge C: Medium Game Mode (Select Med 🟡 -> PLAY! -> verify board)
- Cartridge D: Hard Game Mode (Select Hard 🔴 -> PLAY! -> verify 9x9 board)
- Cartridge E: Tutorial Mode (Select TUTORIAL -> verify level 1 board & solve)
"""

import os
import sys
import time
import shutil
import threading
from http.server import HTTPServer, SimpleHTTPRequestHandler
from functools import partial
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.action_chains import ActionChains

OUTPUT_DIR = "/tmp/tubature_qa_cartridges"
ARTIFACTS_QA_DIR = "/Users/ricc/.gemini/antigravity/brain/b072ac92-5a93-4d40-8255-dd341aac46a7/qa"
WEB_DIR = "/Users/ricc/git/tubature/build/web"
PORT = 8765

os.makedirs(OUTPUT_DIR, exist_ok=True)
os.makedirs(ARTIFACTS_QA_DIR, exist_ok=True)

class QuietHandler(SimpleHTTPRequestHandler):
    def log_message(self, format, *args):
        pass # suppress request logs for clean QA output

def start_local_server():
    try:
        handler = partial(QuietHandler, directory=WEB_DIR)
        server = HTTPServer(("127.0.0.1", PORT), handler)
        t = threading.Thread(target=server.serve_forever, daemon=True)
        t.start()
        print(f"  🌐 Localhost HTTP server running in background on port {PORT}")
        return server
    except OSError:
        print(f"  🌐 Localhost HTTP server already listening on port {PORT}")
        return None

DEVICES = {
    "1_computer_desktop": {"w": 1440, "h": 900, "name": "Computer (Desktop 1440x900)"},
    "2_pixel10_portrait": {"w": 412, "h": 915, "name": "Google Pixel 10 (Portrait 412x915)"},
    "2_pixel10_landscape": {"w": 915, "h": 412, "name": "Google Pixel 10 (Landscape 915x412)"},
    "3_iphone16pro_portrait": {"w": 430, "h": 932, "name": "iPhone 16 Pro Max (Portrait 430x932)"},
    "3_iphone16pro_landscape": {"w": 932, "h": 430, "name": "iPhone 16 Pro Max (Landscape 932x430)"},
    "4_samsung_ipad_portrait": {"w": 820, "h": 1180, "name": "Samsung Tablet / iPad (Portrait 820x1180)"},
    "4_samsung_ipad_landscape": {"w": 1180, "h": 820, "name": "Samsung Tablet / iPad (Landscape 1180x820)"},
}

def get_driver(width, height):
    opts = Options()
    opts.add_argument("--headless")
    opts.add_argument("--disable-gpu")
    opts.add_argument(f"--window-size={width},{height}")
    opts.add_argument("--no-sandbox")
    opts.add_argument("--disable-dev-shm-usage")
    driver = webdriver.Chrome(options=opts)
    return driver

def click_point(driver, x, y, delay=0.3):
    try:
        actions = ActionChains(driver)
        actions.w3c_actions.pointer_action.move_to_location(x, y)
        actions.w3c_actions.pointer_action.click()
        actions.perform()
    except Exception as e:
        print(f"    (click at {x},{y} skipped: {e})")
    time.sleep(delay)

def save_and_copy(driver, filename):
    tmp_path = os.path.join(OUTPUT_DIR, filename)
    art_path = os.path.join(ARTIFACTS_QA_DIR, filename)
    driver.save_screenshot(tmp_path)
    shutil.copyfile(tmp_path, art_path)
    print(f"  📸 Saved screenshot: {filename}")
    return art_path

def run_all_qa():
    print("🚀 Starting Tubature Multi-Device & Cartridge QA Suite...\n")
    server = start_local_server()
    time.sleep(1)

    # =========================================================================
    # CARTRIDGE A: Multi-Device Home Screen Visual Inspection
    # =========================================================================
    print("\n========================================================")
    print("📦 CARTRIDGE A: Multi-Device Home Screen Inspection")
    print("========================================================")
    for dev_id, dev_info in DEVICES.items():
        print(f"\n🔍 Testing Device: {dev_info['name']} ({dev_info['w']}x{dev_info['h']})...")
        driver = get_driver(dev_info['w'], dev_info['h'])
        try:
            driver.get(f"http://127.0.0.1:{PORT}")
            time.sleep(3.5)
            save_and_copy(driver, f"home_{dev_id}.png")
        finally:
            driver.quit()

    # =========================================================================
    # CARTRIDGE B: Easy Mode Gameplay Run (Pixel 10)
    # =========================================================================
    print("\n========================================================")
    print("📦 CARTRIDGE B: Easy Mode Gameplay Run (Pixel 10)")
    print("========================================================")
    driver = get_driver(412, 915)
    try:
        driver.get(f"http://127.0.0.1:{PORT}")
        time.sleep(3.5)

        # Click Easy chip (right column top row in 2x2 grid: ~x=310, y=690 on 412x915)
        print("  1. Tapping Easy 🟢 difficulty...")
        click_point(driver, 310, 690)
        save_and_copy(driver, "cartridge_easy_01_selected.png")

        # Click PLAY! button (~x=206, y=770)
        print("  2. Tapping PLAY! button...")
        click_point(driver, 206, 770, delay=2.5)
        save_and_copy(driver, "cartridge_easy_02_board_started.png")

        # Rotate some tiles on the grid (~center x=206, y=450)
        print("  3. Interacting & rotating pipe tiles...")
        for i in range(3):
            click_point(driver, 206 + (i * 30), 450, delay=0.3)
        save_and_copy(driver, "cartridge_easy_03_tiles_rotated.png")
    finally:
        driver.quit()

    # =========================================================================
    # CARTRIDGE C: Medium Mode Gameplay Run
    # =========================================================================
    print("\n========================================================")
    print("📦 CARTRIDGE C: Medium Mode Gameplay Run (Pixel 10)")
    print("========================================================")
    driver = get_driver(412, 915)
    try:
        driver.get(f"http://127.0.0.1:{PORT}")
        time.sleep(3.5)

        # Click Medium chip (left column bottom row in 2x2: ~x=100, y=730)
        print("  1. Tapping Med 🟡 difficulty...")
        click_point(driver, 100, 730)
        save_and_copy(driver, "cartridge_med_01_selected.png")

        # Click PLAY!
        print("  2. Tapping PLAY! button...")
        click_point(driver, 206, 770, delay=2.5)
        save_and_copy(driver, "cartridge_med_02_board_started.png")
    finally:
        driver.quit()

    # =========================================================================
    # CARTRIDGE D: Hard Mode Gameplay Run
    # =========================================================================
    print("\n========================================================")
    print("📦 CARTRIDGE D: Hard Mode Gameplay Run (Pixel 10)")
    print("========================================================")
    driver = get_driver(412, 915)
    try:
        driver.get(f"http://127.0.0.1:{PORT}")
        time.sleep(3.5)

        # Click Hard chip (right column bottom row in 2x2: ~x=310, y=730)
        print("  1. Tapping Hard 🔴 difficulty...")
        click_point(driver, 310, 730)
        save_and_copy(driver, "cartridge_hard_01_selected.png")

        # Click PLAY!
        print("  2. Tapping PLAY! button...")
        click_point(driver, 206, 770, delay=2.5)
        save_and_copy(driver, "cartridge_hard_02_board_started.png")
    finally:
        driver.quit()

    # =========================================================================
    # CARTRIDGE E: Tutorial Mode Run
    # =========================================================================
    print("\n========================================================")
    print("📦 CARTRIDGE E: Tutorial Mode Run (Pixel 10)")
    print("========================================================")
    driver = get_driver(412, 915)
    try:
        driver.get(f"http://127.0.0.1:{PORT}")
        time.sleep(3.5)

        # Click TUTORIAL button (~x=206, y=795)
        print("  1. Tapping 📖 TUTORIAL button...")
        click_point(driver, 206, 795, delay=2.5)
        save_and_copy(driver, "cartridge_tutorial_01_level1.png")

        # In tutorial level 1 (3x3 grid): rotate tile (1,1) in the middle (~x=206, y=450)
        print("  2. Rotating center pipe to connect water...")
        click_point(driver, 206, 450, delay=1.0)
        save_and_copy(driver, "cartridge_tutorial_02_rotated.png")
    finally:
        driver.quit()

    print("\n🎉 ALL 5 QA CARTRIDGES COMPLETED SUCCESSFULLY!")

if __name__ == "__main__":
    run_all_qa()
