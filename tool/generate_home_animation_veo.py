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
    parser = argparse.ArgumentParser(description="Generate animated splash screen video using Veo.")
    parser.add_argument("--mode", choices=["landscape", "portrait", "both"], default="both", help="Which orientation video to generate")
    args = parser.parse_args()

    landscape_prompt = (
        "Animate ONLY the three human characters and the small green dragon in this exact image with subtle, charming movements. "
        "The bearded dad (Papino) in the yellow 'R' cap smiles and winks, proudly turning the golden wrench in his hand. "
        "The older boy (Alessandro) in the green 'A' cap laughs joyfully and playfully holds his wrench. "
        "The youngest boy (Sebastiano) in the orange 'S' cap smiles warmly, giggling and holding his small wrench. "
        "The cute little green dragon at their feet blinks happily and looks up at them with a cheerful expression. "
        "All dungeon masonry, stone arch runes, torches, background pipes, bridges, and waterfalls remain completely solid and stationary without warping. "
        "Smooth, natural 24fps character animation in high quality 2D/3D cartoon fantasy style."
    )

    portrait_prompt = (
        "Animate ONLY the three human characters and the magical dragon companion in this vertical image with subtle, charming movements. "
        "The bearded plumber dad (Papino) in the yellow cap smiles and adjusts his wrench tool. "
        "The older boy (Alessandro) in the green cap and the younger boy (Sebastiano) in the orange cap smile, laugh and playfully point at the plumbing pipes. "
        "The friendly dragon blinks and wiggles happily. "
        "The stone arches, glowing crystal cavern, water streams and pipes remain completely stable and solid. "
        "Smooth, natural 24fps character animation in cheerful Pixar/cartoon fantasy style."
    )

    if args.mode in ["landscape", "both"]:
        print("\n=== Generating Landscape Video (16:9) ===", flush=True)
        generate_video(
            image_path="assets/images/home_background_wide.jpg",
            output_path="assets/videos/home_background_wide.mp4",
            prompt=landscape_prompt,
            aspect_ratio="16:9",
        )

    if args.mode in ["portrait", "both"]:
        print("\n=== Generating Portrait Video (9:16) ===", flush=True)
        generate_video(
            image_path="assets/images/home_background.jpg",
            output_path="assets/videos/home_background_portrait.mp4",
            prompt=portrait_prompt,
            aspect_ratio="9:16",
        )

if __name__ == "__main__":
    main()
