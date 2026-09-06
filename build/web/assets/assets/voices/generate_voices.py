#!/usr/bin/env python3
"""
Regenerates all audio assets in assets/voices/ using edge-tts and ffmpeg.
Optimized for:
- Crystal-clear Italian/dialect pronunciation and intelligibility
- Loud, normalized arcade volume (volume boost + dynamic presence)
- Clean vocal formants without murky pitch degradation
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
    folder = item.get("folder", "")
    voice = item["voice"]
    prompt = item["tts_prompt"]
    rate = item.get("tts_rate", "+0%")
    
    tmp_raw = VOICES_DIR / f"_tmp_{voice_id}.mp3"
    
    # Destination in folder (e.g. assets/voices/good/a-scor-cle-un-piaser.mp3)
    folder_dir = VOICES_DIR / folder if folder else VOICES_DIR
    folder_dir.mkdir(parents=True, exist_ok=True)
    
    dst_mp3_sub = folder_dir / f"{voice_id}.mp3"
    dst_ogg_sub = folder_dir / f"{voice_id}.ogg"
    
    # Also keep top-level copy for backward compatibility
    dst_mp3_top = VOICES_DIR / f"{voice_id}.mp3"
    dst_ogg_top = VOICES_DIR / f"{voice_id}.ogg"
    
    print(f"🎙️ Generating '{voice_id}' ({folder}) using {voice} (rate={rate})...")
    subprocess.run(
        ["edge-tts", "--voice", voice, f"--rate={rate}", "--text", prompt, "--write-media", str(tmp_raw)],
        check=True
    )
    
    # Crisp arcade audio mastering filter:
    # 1. highpass=f=80: cuts sub-bass rumble
    # 2. volume=2.2: loud and clear in-game audio level
    # 3. treble=g=4: enhances consonant clarity & speech intelligibility
    # 4. loudnorm: standard broadcast loudness normalization (EBU R128)
    ffmpeg_filter = "highpass=f=80,volume=2.2,treble=g=4,loudnorm=I=-14:TP=-1.0:LRA=7"
    
    # Encode MP3
    subprocess.run(["ffmpeg", "-y", "-i", str(tmp_raw), "-af", ffmpeg_filter, str(dst_mp3_sub)], check=True)
    subprocess.run(["cp", str(dst_mp3_sub), str(dst_mp3_top)], check=True)
    
    # Encode OGG Opus
    subprocess.run(["ffmpeg", "-y", "-i", str(tmp_raw), "-af", ffmpeg_filter, "-c:a", "libopus", str(dst_ogg_sub)], check=True)
    subprocess.run(["cp", str(dst_ogg_sub), str(dst_ogg_top)], check=True)
    
    if tmp_raw.exists():
        tmp_raw.unlink()

print("✅ All voices regenerated with crystal-clear pronunciation and loud volume!")
