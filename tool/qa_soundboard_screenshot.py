#!/usr/bin/env python3
"""
Captures a screenshot of the Audio & Voice Soundboard Debug Panel.
"""

import time
from selenium import webdriver
from selenium.webdriver.chrome.options import Options

OUTPUT_PNG = "/Users/ricc/.gemini/antigravity/brain/b072ac92-5a93-4d40-8255-dd341aac46a7/qa/soundboard_debug_panel.png"

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
    opts.add_argument("--force-device-scale-factor=1")

    driver = webdriver.Chrome(options=opts)
    try:
        driver.get("http://localhost:8765")
        time.sleep(3.5)

        # Tap SOUNDS 🧪 button at bottom of home screen (approx x=300, y=745 on 500x772)
        click_cdp(driver, 300, 745, delay=1.0)

        driver.save_screenshot(OUTPUT_PNG)
        print(f"✅ Saved screenshot to {OUTPUT_PNG}")
    finally:
        driver.quit()

if __name__ == "__main__":
    capture()
