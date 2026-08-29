import argparse
import os
import sys
import time
from google import genai
from google.genai import types

def generate_video(
    image_path: str,
    output_path: str,
    prompt: str,
    aspect_ratio: str = "16:9",
    model: str = "models/veo-3.1-generate-preview",
):
    print(f"🎬 Loading input image: {image_path}", flush=True)
    if not os.path.exists(image_path):
        raise FileNotFoundError(f"Image not found: {image_path}")

    with open(image_path, "rb") as f:
        image_bytes = f.read()

    client = genai.Client()
    
    image = types.Image(
        image_bytes=image_bytes,
        mime_type="image/jpeg" if image_path.endswith((".jpg", ".jpeg")) else "image/png"
    )

    config = types.GenerateVideosConfig(
        aspect_ratio=aspect_ratio,
        number_of_videos=1,
    )

    print(f"🚀 Submitting generation request to Veo ({model}) with aspect_ratio={aspect_ratio}...", flush=True)
    print(f"📝 Prompt: {prompt}", flush=True)

    operation = client.models.generate_videos(
        model=model,
        prompt=prompt,
        image=image,
        config=config,
    )

    op_name = getattr(operation, 'name', operation)
    print(f"⏳ Video generation operation started: {op_name}", flush=True)
    start_time = time.time()
    
    while True:
        op_status = client.operations.get(operation)
        elapsed = int(time.time() - start_time)
        print(f"⏱️ [{elapsed}s] Operation status: done={op_status.done}", flush=True)
        if op_status.done:
            break
        time.sleep(10)

    if op_status.error:
        print(f"❌ Error from Veo: {op_status.error}", flush=True)
        raise RuntimeError(f"Veo error: {op_status.error}")

    if op_status.response and op_status.response.generated_videos:
        video_part = op_status.response.generated_videos[0].video
    elif op_status.result and op_status.result.generated_videos:
        video_part = op_status.result.generated_videos[0].video
    else:
        print("Op status dump:", op_status, flush=True)
        raise RuntimeError("No generated videos in response")

    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    if hasattr(video_part, 'video_bytes') and video_part.video_bytes:
        with open(output_path, "wb") as f:
            f.write(video_part.video_bytes)
        print(f"✅ Success! Saved generated video to {output_path} ({len(video_part.video_bytes)} bytes)", flush=True)
    elif hasattr(video_part, 'uri') and video_part.uri:
        print(f"📥 Downloading video from URI: {video_part.uri}", flush=True)
        video_bytes = client.files.download(file=video_part.uri)
        with open(output_path, "wb") as f:
            f.write(video_bytes)
        print(f"✅ Downloaded {len(video_bytes)} bytes to {output_path}", flush=True)
    else:
        print("Video part:", video_part, flush=True)
        raise RuntimeError("Unable to extract video bytes or URI")

def main():
    parser = argparse.ArgumentParser(description="Generate animated splash screen v2 video using Veo.")
    parser.add_argument("--mode", choices=["landscape", "portrait", "both"], default="both", help="Which orientation video to generate")
    args = parser.parse_args()

    landscape_prompt = (
        "Cinematic fantasy animation starting from this exact image. "
        "The three human characters remain strictly unique and never duplicate: the dad Papino in yellow 'R' cap, older boy Alessandro in green 'A' cap, and younger boy Sebastiano in orange 'S' cap smile proudly and point at the pipes. "
        "Around them and from behind stone arches, a cheerful swarm of ten tiny magical creature helpers—cute mini baby dragons, friendly little dungeon gnomes, and furry critter apprentices—scamper out cheerfully holding miniature wrenches, screwdrivers, and hex keys to playfully work on the glowing pipes. "
        "Joyful, lively, Pixar-style fantasy cartoon animation at 24fps with vibrant glowing crystal lighting and solid dungeon architecture."
    )

    portrait_prompt = (
        "Cinematic fantasy 3D cartoon animation starting from this vertical portrait image. "
        "The three human characters remain strictly unique: the dad Papino in yellow 'R' cap, older boy Alessandro in green 'A' cap, and younger boy Sebastiano in orange 'S' cap. "
        "Alessandro and Sebastiano excitedly point at the glowing pipes and speak in enthusiastic Italian: 'Guarda Papino! C'è una perdita nelle tubature magiche! Prendi la chiave inglese!'. "
        "Papino raises his golden wrench, winks, and replies in Italian: 'Niente paura ragazzi, con la chiave d'oro le ripariamo tutte! Allineate i tubi!'. "
        "Around them, cute baby dragons and little dungeon gnomes cheerfully pop out holding miniature tools to help fix the pipes. "
        "Vibrant Pixar-quality animation with clear Italian spoken voices, cheerful fantasy sound effects, and joyful background music."
    )

    if args.mode in ["landscape", "both"]:
        print("\n=== Generating Landscape Video V2 (16:9) ===", flush=True)
        generate_video(
            image_path="assets/images/home_background_wide.jpg",
            output_path="assets/videos/home_background_wide_v2.mp4",
            prompt=landscape_prompt,
            aspect_ratio="16:9",
        )

    if args.mode in ["portrait", "both"]:
        print("\n=== Generating Portrait Video V2 (9:16) ===", flush=True)
        generate_video(
            image_path="assets/images/home_background.jpg",
            output_path="assets/videos/home_background_portrait_v2.mp4",
            prompt=portrait_prompt,
            aspect_ratio="9:16",
        )

if __name__ == "__main__":
    main()
