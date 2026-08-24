#!/usr/bin/env python3
"""
Captures screenshots of Tubature v2.4.0 demonstrating the Torrential River Flood engine.
"""

import time
from selenium import webdriver
from selenium.webdriver.chrome.options import Options

OUTPUT_PNG = "/Users/ricc/.gemini/antigravity/brain/b072ac92-5a93-4d40-8255-dd341aac46a7/qa/torrential_river_flood_v2_4_0.png"

def click_cdp(driver, x, y, delay=0.3):
    driver.execute_cdp_cmd("Input.dispatchMouseEvent", {
        "type": "mousePressed",
        "x": int(x),
        "y": int(y),
        "button": "left",
        "clickCount": 1
    })
    time.sleep(0.04)
    driver.execute_cdp_cmd("Input.dispatchMouseEvent", {
        "type": "mouseReleased",
        "x": int(x),
        "y": int(y),
        "button": "left",
        "clickCount": 1
    })
    time.sleep(delay)

def capture():
    opts = Options()
    opts.add_argument("--headless=new")
    opts.add_argument("--window-size=412,915")
    opts.add_argument("--no-sandbox")
    opts.add_argument("--disable-dev-shm-usage")

    driver = webdriver.Chrome(options=opts)
    try:
        driver.get("http://localhost:8765")
        time.sleep(3.5)

        # Tap PLAY EASY
        click_cdp(driver, 100, 560, delay=0.5)
        # Tap PLAY
        click_cdp(driver, 206, 640, delay=2.5)

        # Tap a couple of tiles to trigger rotation & flood
        click_cdp(driver, 200, 350, delay=0.6)
        click_cdp(driver, 250, 420, delay=0.6)

        driver.save_screenshot(OUTPUT_PNG)
        print(f"✅ Saved screenshot to {OUTPUT_PNG}")
    finally:
        driver.quit()

if __name__ == "__main__":
    capture()
