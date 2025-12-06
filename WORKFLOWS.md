# FEDDAKALKUN ComfyUI Workflows

This suite focuses on a flagship Image-to-Video workflow using Wan 2.2.

## 📂 I2V-wan22 (Flagship)
**Purpose:** High-end Image-to-Video generation using Wan 2.2 (14B) with advanced features like VRAM purging, frame interpolation, and auto-downloading.
*   **Model:** Wan 2.2 14B (High/Low split or single file depending on config).
*   **Features:**
    *   **Auto-Downloader:** Fetches all required models (Wan, VAE, T5, LoRAs, RIFE) on first run.
    *   **Frame Interpolation:** Uses RIFE to smooth out the video.
    *   **VRAM Management:** Includes `PurgeVRAM` to prevent OOM errors.
*   **Usage:**
    1.  Load `assets/workflows/I2V-wan22.json`.
    2.  Upload your image in the `Load Image` node.
    3.  Click "Queue Prompt".

---
**Tools:**
*   `scrape_reddit.bat`: Download training images from any subreddit.
*   `update_suite.bat`: Update ComfyUI and this suite to the latest version.
*   `import_models.bat`: Link models from your local library.
