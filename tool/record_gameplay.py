#!/usr/bin/env python3
"""
Automated Gameplay Video Recorder for Tubature 🎬🎮📹

Records a complete game session from Home Screen → Difficulty Select → Gameplay → Victory,
producing a smooth MP4 video. Uses a real DFS solver that reads the game state via a
JavaScript bridge (window._tubatureGrid) to compute optimal rotations.

Usage:
    python3 tool/record_gameplay.py [--difficulty easy|medium|hard] [--device mobile|desktop]
    python3 tool/record_gameplay.py --all  # Record all difficulties × all devices
"""

import argparse
import base64
import json
import os
import random
import subprocess
import sys
import tempfile
import time
from datetime import datetime
from pathlib import Path

try:
    from selenium import webdriver
    from selenium.webdriver.chrome.options import Options
except ImportError:
    print("❌ selenium not found. Install: pip install selenium")
    sys.exit(1)


# ─── Device Profiles ─────────────────────────────────────────────────────────
DEVICE_PROFILES = {
    "mobile": {"width": 412, "height": 915},
    "desktop": {"width": 1280, "height": 720},
}

GRID_SIZES = {"easy": 6, "medium": 7, "hard": 9}


# ═══════════════════════════════════════════════════════════════════════════════
# Direction & Tile Solver (pure Python port of Dart game logic)
# ═══════════════════════════════════════════════════════════════════════════════

class Dir:
    """Direction enum: NORTH=0, EAST=1, SOUTH=2, WEST=3."""
    N, E, S, W = 0, 1, 2, 3
    DELTAS = {0: (-1, 0), 1: (0, 1), 2: (1, 0), 3: (0, -1)}
    OPP = {0: 2, 1: 3, 2: 0, 3: 1}
    NAMES = {"north": 0, "east": 1, "south": 2, "west": 3}

    @staticmethod
    def rotate_cw(d, deg):
        return (d + (deg // 90)) % 4


# Base openings at rotation=0 (matching Dart tile model exactly)
BASE_OPENINGS = {
    "line":    {Dir.N, Dir.S},
    "corner":  {Dir.S, Dir.E},
    "tee":     {Dir.N, Dir.E, Dir.S},  # missing W
    "cross":   {Dir.N, Dir.E, Dir.S, Dir.W},
    "deadEnd": {Dir.S},
    "source":  set(),
    "empty":   set(),
}


def get_openings(tile):
    """Compute effective openings for a tile dict at its current rotation."""
    t = tile["type"]
    rot = tile.get("rotation", 0)
    if t == "source":
        bd_name = tile.get("baseDirection")
        if bd_name and bd_name in Dir.NAMES:
            return {Dir.NAMES[bd_name]}
        return set()
    base = BASE_OPENINGS.get(t, set())
    return {Dir.rotate_cw(d, rot) for d in base}


def bfs_connected(grid, rows, cols):
    """BFS from source, return set of connected positions."""
    source = None
    for r in range(rows):
        for c in range(cols):
            if grid[r][c]["type"] == "source":
                source = (r, c)
                break
    if not source:
        return set()

    visited = {source}
    queue = [source]
    while queue:
        cr, cc = queue.pop(0)
        for d in get_openings(grid[cr][cc]):
            dr, dc = Dir.DELTAS[d]
            nr, nc = cr + dr, cc + dc
            if 0 <= nr < rows and 0 <= nc < cols and (nr, nc) not in visited:
                if Dir.OPP[d] in get_openings(grid[nr][nc]):
                    visited.add((nr, nc))
                    queue.append((nr, nc))
    return visited


def check_win(grid, rows, cols):
    """Check if ALL non-empty tiles are connected to source."""
    total = sum(1 for r in range(rows) for c in range(cols) if grid[r][c]["type"] != "empty")
    return len(bfs_connected(grid, rows, cols)) == total


def solve_with_oracle(driver, centers, rows, cols, frame_dir, fn):
    """
    Deterministic solver using solvedRotation from the JS bridge cheat code.
    Reads the correct rotation for each tile and clicks the exact number
    of times to reach it. O(n) guaranteed, zero heuristics.
    Returns (fn, total_clicks, solved).
    """
    total_clicks = 0

    grid_state = read_grid_state(driver)
    if not grid_state:
        return fn, 0, False

    tiles = grid_state["tiles"]
    has_solution = grid_state.get("hasSolution", False)

    if not has_solution:
        print("  ⚠️  No solvedRotation data — game doesn't expose cheat code")
        return fn, 0, False

    # Build click plan: for each tile, compute clicks needed
    click_plan = []
    for r in range(rows):
        for c in range(cols):
            tile = tiles[r][c]
            if tile.get("isFixed", False) or tile["type"] in ("source", "empty"):
                continue
            current = tile["rotation"]
            target = tile.get("solvedRotation", current)
            n_clicks = ((target - current) % 360) // 90
            if n_clicks > 0:
                click_plan.append((r, c, n_clicks))

    total_clicks_needed = sum(n for _, _, n in click_plan)
    print(f"  ✅ Solution: {total_clicks_needed} clicks across {len(click_plan)} tiles")

    # Execute in serpentine order for natural feel
    click_plan.sort(key=lambda x: (x[0], x[1] if x[0] % 2 == 0 else -x[1]))

    for idx, (r, c, n_clicks) in enumerate(click_plan):
        cx, cy = centers[(r, c)]

        for click_i in range(n_clicks):
            # Human-like pause
            if click_i == 0:
                pause = random.uniform(0.30, 0.55)
            else:
                pause = random.uniform(0.12, 0.25)

            fn = capture_duration(driver, frame_dir, fn, pause)
            click_at(driver, cx, cy, delay=0.08)
            fn = save_frame(capture_frame(driver), frame_dir, fn)
            total_clicks += 1

        # Progress logging
        if (idx + 1) % max(1, len(click_plan) // 5) == 0 or idx == len(click_plan) - 1:
            gs = read_grid_state(driver)
            if gs:
                conn = gs["connectedCount"]
                tot = gs["totalTiles"]
                pct = conn * 100 // tot
                bar = "█" * (pct // 5) + "░" * (20 - pct // 5)
                print(f"  ⏳ [{bar}] {conn}/{tot} ({pct}%) — {total_clicks}/{total_clicks_needed} clicks")

                if gs.get("isComplete"):
                    print(f"  🏆 SOLVED!")
                    return fn, total_clicks, True

    final = read_grid_state(driver)
    solved = final.get("isComplete", False) if final else False
    return fn, total_clicks, solved


# ═══════════════════════════════════════════════════════════════════════════════
# Coordinate Math (matching Flutter GridWidget layout)
# ═══════════════════════════════════════════════════════════════════════════════

def compute_tile_centers(profile, rows, cols):
    """Compute pixel center (x, y) for each tile, matching Flutter layout."""
    W, H = profile["width"], profile["height"]
    top_bar = 80
    bottom_bar = 90
    pad = 16

    avail_w = W - pad * 2
    avail_h = H - top_bar - bottom_bar - pad * 2

    tile_size = min(avail_w / cols, avail_h / rows)
    tile_size = max(tile_size, 48.0)

    grid_w = tile_size * cols
    grid_h = tile_size * rows

    grid_left = (W - grid_w) / 2
    grid_top = top_bar + pad + (avail_h - grid_h) / 2

    centers = {}
    for r in range(rows):
        for c in range(cols):
            centers[(r, c)] = (
                grid_left + (c + 0.5) * tile_size,
                grid_top + (r + 0.5) * tile_size,
            )
    return centers, tile_size


def home_screen_coords(profile, difficulty):
    """Return (chip_xy, play_xy) for home screen navigation.
    Coordinates measured from CDP-overridden 412×915 viewport screenshot.
    """
    W, H = profile["width"], profile["height"]

    # Measured from actual 412×915 screenshot with CDP viewport override:
    # [Auto ⚡]  [Easy 🟢]    row1: y ≈ H*0.672
    # [Med  🟡]  [Hard 🔴]    row2: y ≈ H*0.748
    # [    PLAY!    ]          play: y ≈ H*0.820
    # [   TUTORIAL  ]          tut:  y ≈ H*0.891

    left_x = W * 0.27   # ~111px
    right_x = W * 0.73  # ~301px

    row1_y = H * 0.672  # ~615px  (Auto / Easy row)
    row2_y = H * 0.748  # ~685px  (Med / Hard row)
    play_y = H * 0.820  # ~750px  (PLAY! button center)
    tut_y = H * 0.891   # ~815px  (TUTORIAL button center)

    chips = {
        "auto":     (left_x,  row1_y),
        "easy":     (right_x, row1_y),
        "medium":   (left_x,  row2_y),
        "hard":     (right_x, row2_y),
        "tutorial": (W * 0.5, tut_y),
    }
    return chips.get(difficulty, chips["medium"]), (W * 0.5, play_y)


# ═══════════════════════════════════════════════════════════════════════════════
# Browser Helpers
# ═══════════════════════════════════════════════════════════════════════════════

def get_version():
    vf = Path(__file__).parent.parent / "VERSION"
    return vf.read_text().strip() if vf.exists() else "unknown"


def output_filename(difficulty, device):
    return f"out/{datetime.now():%Y%m%d}-game-v{get_version()}-{difficulty}-{device}.mp4"


def click_at(driver, x, y, delay=0.3):
    driver.execute_cdp_cmd("Input.dispatchMouseEvent", {
        "type": "mousePressed", "x": int(x), "y": int(y),
        "button": "left", "clickCount": 1,
    })
    time.sleep(0.04)
    driver.execute_cdp_cmd("Input.dispatchMouseEvent", {
        "type": "mouseReleased", "x": int(x), "y": int(y),
        "button": "left", "clickCount": 1,
    })
    time.sleep(delay)


def capture_frame(driver):
    r = driver.execute_cdp_cmd("Page.captureScreenshot", {"format": "png"})
    return base64.b64decode(r["data"])


def save_frame(data, frame_dir, frame_num):
    path = os.path.join(frame_dir, f"frame_{frame_num:05d}.png")
    with open(path, "wb") as f:
        f.write(data)
    return frame_num + 1


def capture_duration(driver, frame_dir, frame_num, seconds, fps=10):
    interval = 1.0 / fps
    end = time.time() + seconds
    while time.time() < end:
        frame_num = save_frame(capture_frame(driver), frame_dir, frame_num)
        time.sleep(interval)
    return frame_num


def read_grid_state(driver, retries=20, interval=0.5):
    """Read game state from window._tubatureGrid with retry logic."""
    # First check if the bridge is even available
    ready = driver.execute_script("return window._tubatureReady;")
    if not ready:
        print("  ⚠️  window._tubatureReady not set — Flutter JS bridge may not be compiled in")

    for attempt in range(retries):
        result = driver.execute_script("return window._tubatureGrid;")
        if result is not None:
            data = json.loads(result) if isinstance(result, str) else result
            if data and data.get("tiles"):
                return data
        if attempt < retries - 1:
            time.sleep(interval)
            if attempt % 4 == 3:
                print(f"  ⏳ Waiting for grid state... (attempt {attempt + 1}/{retries})")
    return None


# ═══════════════════════════════════════════════════════════════════════════════
# Main Recording Pipeline
# ═══════════════════════════════════════════════════════════════════════════════

def record_game(difficulty="medium", device="mobile", url="http://localhost:8765", speed=2):
    """Complete recording pipeline: launch → navigate → solve → encode."""
    profile = DEVICE_PROFILES[device]
    out_file = output_filename(difficulty, device)
    W, H = profile["width"], profile["height"]

    print(f"🎬 Recording Tubature v{get_version()}")
    print(f"   Difficulty: {difficulty}")
    print(f"   Device: {device} ({W}×{H})")
    print(f"   Speed: {speed}x")
    print(f"   Output: {out_file}\n")

    opts = Options()
    opts.add_argument("--headless=new")
    opts.add_argument(f"--window-size={W},{H}")
    opts.add_argument("--no-sandbox")
    opts.add_argument("--disable-dev-shm-usage")
    opts.add_argument("--force-device-scale-factor=1")
    opts.add_argument("--disable-background-timer-throttling")
    opts.add_argument("--disable-backgrounding-occluded-windows")
    opts.add_argument("--disable-renderer-backgrounding")
    opts.add_argument("--incognito")
    opts.add_argument("--disable-application-cache")

    driver = webdriver.Chrome(options=opts)

    # Force exact viewport — Chrome headless may use a different native size
    driver.execute_cdp_cmd("Emulation.setDeviceMetricsOverride", {
        "width": W, "height": H,
        "deviceScaleFactor": 1, "mobile": device == "mobile",
    })

    # Bypass service worker cache to always load fresh build
    driver.execute_cdp_cmd("Network.enable", {})
    driver.execute_cdp_cmd("Network.setBypassServiceWorker", {"bypass": True})

    try:
        with tempfile.TemporaryDirectory(prefix="tubature_rec_") as frame_dir:
            fn = 0  # frame number

            # ─── 1. Load Home Screen ─────────────────────────────
            print("🌐 Loading game...")
            driver.get(url)
            time.sleep(4.0)

            print("🏠 Capturing home screen (2s)...")
            fn = capture_duration(driver, frame_dir, fn, 2.0)

            # ─── 2. Select Difficulty & Start Game ───────────────
            print(f"🎯 Selecting {difficulty}...")
            chip_xy, play_xy = home_screen_coords(profile, difficulty)
            click_at(driver, *chip_xy, delay=0.8)
            fn = capture_duration(driver, frame_dir, fn, 0.5)

            print("▶️  Clicking PLAY...")
            click_at(driver, *play_xy, delay=3.0)
            fn = capture_duration(driver, frame_dir, fn, 1.5)

            # ─── 3. Read Grid State via JS Bridge ────────────────
            print("🧠 Reading grid state from Flutter JS bridge...")
            grid_state = read_grid_state(driver)

            if grid_state is None:
                print("⚠️  JS bridge not available, falling back to blind solver")
                rows = cols = GRID_SIZES.get(difficulty, 7)
                centers, tile_size = compute_tile_centers(profile, rows, cols)
                fn = _play_blind(driver, frame_dir, fn, centers, rows, cols)
            else:
                rows = grid_state["rows"]
                cols = grid_state["cols"]
                total = grid_state["totalTiles"]
                connected = grid_state["connectedCount"]
                print(f"📐 Grid: {rows}×{cols}")
                print(f"📊 Initial state: {connected}/{total} connected ({connected*100//total}%)")

                centers, tile_size = compute_tile_centers(profile, rows, cols)

                # ─── 4. Solve with Oracle ─────────────────────
                # Click each tile, read connectedCount, keep best rotation
                print("🧮 Oracle solver: click → read connectedCount → keep best\n")
                fn, total_clicks, solved = solve_with_oracle(
                    driver, centers, rows, cols, frame_dir, fn)

                final = read_grid_state(driver)
                if final:
                    conn = final["connectedCount"]
                    tot = final["totalTiles"]
                    complete = final.get("isComplete", False)
                    print(f"\n  🏆 Final: {conn}/{tot} connected — {'✅ SOLVED!' if complete else '❌ Not solved'}")
                    print(f"  📊 Total clicks: {total_clicks}")

            # ─── 7. Capture Victory / Final State (5s) ───────────
            print(f"🎉 Capturing victory celebration (5s)...")
            fn = capture_duration(driver, frame_dir, fn, 5.0)

            print(f"📸 Total: {fn} frames\n")

            # ─── 8. Encode to MP4 ────────────────────────────────
            os.makedirs("out", exist_ok=True)
            success = encode_video(frame_dir, out_file, input_fps=10, output_fps=30, speed=speed)

            if success:
                print(f"\n🎉 Recording complete: {out_file}")
            else:
                print(f"\n❌ Encoding failed")
                return False
    finally:
        driver.quit()

    return True


def _play_blind(driver, frame_dir, fn, centers, rows, cols):
    """Fallback: blind clicking (no JS bridge available)."""
    print("🎮 Playing blind (no state access)...\n")
    scan_order = []
    for r in range(rows):
        col_range = range(cols) if r % 2 == 0 else range(cols - 1, -1, -1)
        for c in col_range:
            scan_order.append((r, c))

    for pass_num in range(3):
        if pass_num > 0:
            random.shuffle(scan_order)
        for r, c in scan_order:
            cx, cy = centers[(r, c)]
            pause = random.uniform(0.30, 0.60)
            fn = capture_duration(driver, frame_dir, fn, pause)
            click_at(driver, cx, cy, delay=0.08)
            fn = save_frame(capture_frame(driver), frame_dir, fn)
        fn = capture_duration(driver, frame_dir, fn, 1.0)
    return fn


def encode_video(frame_dir, output_path, input_fps=10, output_fps=30, speed=1):
    """Encode PNG frames to H.264 MP4 via ffmpeg, with optional speed multiplier."""
    print(f"📹 Encoding video ({input_fps} → {output_fps} FPS, {speed}x speed)...")

    vf_parts = []
    if speed > 1:
        vf_parts.append(f"setpts={1.0/speed}*PTS")
    # x264 requires even dimensions; 915px height is odd
    vf_parts.append("scale=trunc(iw/2)*2:trunc(ih/2)*2")
    vf_parts.append(f"fps={output_fps}")
    vf_parts.append("format=yuv420p")

    cmd = [
        "ffmpeg", "-y",
        "-framerate", str(input_fps),
        "-i", os.path.join(frame_dir, "frame_%05d.png"),
        "-vf", ",".join(vf_parts),
        "-c:v", "libx264",
        "-preset", "medium",
        "-crf", "22",
        "-movflags", "+faststart",
        output_path,
    ]

    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"❌ ffmpeg error:\n{result.stderr[-500:]}")
        return False

    size_mb = os.path.getsize(output_path) / (1024 * 1024)
    duration_s = "?"
    try:
        probe = subprocess.run(
            ["ffprobe", "-v", "quiet", "-show_entries", "format=duration",
             "-of", "csv=p=0", output_path],
            capture_output=True, text=True)
        duration_s = f"{float(probe.stdout.strip()):.0f}s"
    except Exception:
        pass
    print(f"✅ Video: {output_path} ({size_mb:.1f} MB, {duration_s}, {speed}x)")
    return True


def main():
    parser = argparse.ArgumentParser(description="Record Tubature gameplay video 🎬")
    parser.add_argument("-d", "--difficulty", default="medium",
                        choices=["easy", "medium", "hard"])
    parser.add_argument("--device", default="mobile",
                        choices=["mobile", "desktop"])
    parser.add_argument("--url", default="http://localhost:8765")
    parser.add_argument("--speed", type=int, default=2,
                        help="Playback speed multiplier (default: 2)")
    parser.add_argument("--all", action="store_true",
                        help="Record all difficulties × all devices")
    args = parser.parse_args()

    if args.all:
        for diff in ["easy", "medium", "hard"]:
            for dev in ["mobile", "desktop"]:
                print(f"\n{'='*60}")
                record_game(diff, dev, args.url, speed=args.speed)
    else:
        record_game(args.difficulty, args.device, args.url, speed=args.speed)


if __name__ == "__main__":
    main()
