# FEDDAKALKUN ComfyUI Workflows

This suite includes a set of "Master Workflows" designed for high-performance generation.

## 📂 01_Generation_Test (SD1.5)
**Purpose:** "Hello World" test to verify GPU acceleration and basic generation.
*   **Model:** DreamShaper 8 (SD1.5)
*   **Usage:** Load and run. It will auto-download the model on first run.

## 📂 02_Wan2.1_Video (Text-to-Video)
**Purpose:** Generate high-quality videos from text prompts.
*   **Model:** Wan2.1 1.3B (BF16)
*   **Usage:**
    1.  Load workflow.
    2.  Enter your prompt in the `WanVideoTextEncode` node.
    3.  Run. (First run downloads ~7GB of models).

## 📂 03_Wan2.1_I2V (Image-to-Video)
**Purpose:** Animate static images into video.
*   **Model:** Wan2.1 14B (FP8 Quantized) - *Requires 16GB+ VRAM recommended.*
*   **Usage:**
    1.  Load workflow.
    2.  Upload an image to the `LoadImage` node.
    3.  Run. (First run downloads ~14GB model).

## 📂 04_Ultimate_Upscale
**Purpose:** Upscale images to 4K resolution with added detail.
*   **Model:** 4x-UltraSharp + DreamShaper 8 (for hallucinating details).
*   **Usage:**
    1.  Load workflow.
    2.  Upload your low-res image.
    3.  Run.

## 📂 05_Wan2.2_Dual (Dual-Stream Video)
**Purpose:** Advanced video generation using split High/Low frequency models.
*   **Model:** Wan2.1 14B (Split High/Low).
*   **Usage:**
    1.  **Manual Setup Required:** You must obtain the `High` and `Low` safetensors files and place them in `ComfyUI/models/diffusion_models/`.
    2.  Select the files in the loader nodes.
    3.  Run.

---
**Tools:**
*   `scrape_reddit.bat`: Downloads training images from any subreddit.
*   `update_suite.bat`: Updates ComfyUI, custom nodes, and this suite.
