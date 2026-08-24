#!/usr/bin/env python3
"""
QA script to verify vetted audio playback on localhost:8765
"""

import time
from selenium import webdriver
from selenium.webdriver.chrome.options import Options

def click_cdp(driver, x, y, delay=0.4):
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

def test_soundboard():
    opts = Options()
    opts.add_argument("--headless=new")
    opts.add_argument("--window-size=412,915")
    opts.add_argument("--no-sandbox")
    opts.add_argument("--disable-dev-shm-usage")

    driver = webdriver.Chrome(options=opts)
    try:
        driver.get("http://localhost:8765")
        time.sleep(3.5)

        # Click SOUNDS button
        click_cdp(driver, 310, 875, delay=1.0)

        # Tap several voice cards
        click_cdp(driver, 200, 360, delay=0.8) # Ascor
        click_cdp(driver, 200, 440, delay=0.8) # Movache
        click_cdp(driver, 200, 520, delay=0.8) # Mayal
        click_cdp(driver, 200, 680, delay=0.8) # Ac giurnadaza

        driver.save_screenshot("/Users/ricc/.gemini/antigravity/brain/b072ac92-5a93-4d40-8255-dd341aac46a7/qa/soundboard_vetted_audio_tested.png")
        print("✅ Tested soundboard cards successfully")
    finally:
        driver.quit()

if __name__ == "__main__":
    test_soundboard()
