#!/usr/bin/env python3
"""
Captures Ermete Easter Egg ("Mayàl, ac du bàl!") in action on puzzle completion.
"""

import time
import os
from selenium import webdriver
from selenium.webdriver.chrome.options import Options

OUTPUT_PNG = "/Users/ricc/.gemini/antigravity/brain/b072ac92-5a93-4d40-8255-dd341aac46a7/qa/ermete_mayal_easter_egg.png"

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

        # Tap Tutorial (250, 710)
        click_cdp(driver, 250, 710, delay=2.5)

        # Tap tile at row 1, col 2 (280, 310)
        click_cdp(driver, 280, 310, delay=0.4)
        click_cdp(driver, 280, 310, delay=0.4)
        click_cdp(driver, 280, 310, delay=0.4)

        # Wait for water flow & Ermete victory dialogue
        time.sleep(0.8)
        driver.save_screenshot(OUTPUT_PNG)
        print(f"✅ Saved screenshot to {OUTPUT_PNG}")
    finally:
        driver.quit()

if __name__ == "__main__":
    capture()
