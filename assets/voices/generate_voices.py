#!/usr/bin/env python3
"""
Regenerates all audio assets in assets/voices/ from voices.json using edge-tts and ffmpeg.
"""
import json
import os
import subprocess
from pathlib import Path

VOICES_DIR = Path(__file__).parent
JSON_PATH = VOICES_DIR / "voices.json"

with open(JSON_PATH, "r", encoding="utf-8") as f:
    data = json.load(f)

for item in data["voices"]:
    voice_id = item["id"]
    voice = item["voice"]
    prompt = item["tts_prompt"]
    rate = item.get("tts_rate", "+0%")
    pp = item.get("post_processing", {})
    
    tmp_raw = VOICES_DIR / f"_tmp_{voice_id}.mp3"
    dst_ogg = VOICES_DIR / f"{voice_id}.ogg"
    dst_mp3 = VOICES_DIR / f"{voice_id}.mp3"
    
    print(f"🎙️ Generating '{voice_id}' using {voice} (rate={rate})...")
    subprocess.run(["edge-tts", "--voice", voice, f"--rate={rate}", "--text", prompt, "--write-media", str(tmp_raw)], check=True)
    
    ffmpeg_filter = pp.get("ffmpeg_filter")
    if ffmpeg_filter:
        subprocess.run(["ffmpeg", "-y", "-i", str(tmp_raw), "-af", ffmpeg_filter, "-c:a", "libopus", str(dst_ogg)], check=True)
        subprocess.run(["ffmpeg", "-y", "-i", str(tmp_raw), "-af", ffmpeg_filter, str(dst_mp3)], check=True)
    else:
        subprocess.run(["ffmpeg", "-y", "-i", str(tmp_raw), "-c:a", "libopus", str(dst_ogg)], check=True)
        subprocess.run(["ffmpeg", "-y", "-i", str(tmp_raw), str(dst_mp3)], check=True)
        
    if tmp_raw.exists():
        tmp_raw.unlink()

print("✅ All voices regenerated successfully!")
