# 🎬 FEDDAKALKUN I2V-WAN22 Flagship Pack

**Portable, fully automated Image-to-Video workflow using WAN 2.2 with LLM-powered prompt generation.**

Runs entirely from a USB stick with zero system dependencies!

## 🚀 Features

- **100% Portable**: Python, Git, Node.js, and all dependencies embedded
- **Zero Configuration**: All models auto-download on first run (22GB)
- **I2V/T2V Generation**: WAN 2.2 14B models with dual-stage sampling
- **Frame Interpolation**: RIFE 2x multiplier for smooth video output
- **LLM Prompt Enhancement**: Florence2 captioning + Mistral 7B prompt optimization
- **Motion LoRAs**: LightX2V, FusionX, RealismBoost included
- **USB Ready**: Copy folder to any Windows machine and run

## 📋 Requirements

- **OS**: Windows 10/11 (x64)
- **GPU Memory**: 12-24 GB VRAM (NVIDIA recommended)
- **Disk Space**: 35-40 GB (25GB portable environment + 22GB models + outputs)
- **Internet**: Required for first-run model downloads (~30-60 minutes)

## 🛠️ Quick Start

### 1. Installation (First Time Only)
```bash
install.bat
```
- Downloads Portable Python 3.11, Git, Node.js
- Clones ComfyUI repository
- Installs 34 custom node packages
- Copies I2V-wan22-advanced-v2.json workflow
- *Takes 20-30 minutes with internet*

### 2. Launch ComfyUI
```bash
run.bat
```
- Starts ComfyUI at `http://localhost:8188`

### 3. Load Workflow
- Open UI → Load workflow → Select `I2V-wan22-advanced-v2.json`
- On first load, HuggingFaceDownloader auto-fetches 22GB of models
- *This takes 15-30 minutes (one-time)*

### 4. Generate Video
1. Upload image via LoadImage node
2. Enter optional motion prompt (e.g., "Make them smile and wave")
3. Click Queue
4. Output video saved to `ComfyUI/output/VIDEO/WAN22/`
- *Takes 8-15 minutes per 5-second clip on 24GB VRAM*

## 📁 Project Structure

```
ComfyGGAFD/
├── install.bat              # 🌟 Run this first (setup)
├── run.bat                  # 🌟 Launch ComfyUI
├── README.md                # This file
├── WORKFLOWS.md             # Workflow documentation
├── scripts/
│   ├── install.ps1          # Installer logic
│   ├── download_models.ps1  # Optional model downloader
│   └── update.ps1           # Update script
├── config/
│   ├── nodes.json           # 34 custom nodes configuration
│   ├── models.json          # Model sources
│   └── model_sources.txt    # Additional URLs
├── assets/
│   └── workflows/
│       └── I2V-wan22-advanced-v2.json  # Primary workflow
├── python_embeded/          # Created by install.bat
├── git_embeded/             # Created by install.bat
├── node_embeded/            # Created by install.bat
└── ComfyUI/                 # Created by install.bat
    ├── custom_nodes/        # 34 node packages
    ├── output/              # Generated videos
    └── user/default/workflows/  # Loaded workflows
```

## 🎯 Workflow Capabilities

**Input**:
- Single image (JPEG, PNG, WebP)
- Optional text prompt for motion direction

**Output**:
- MP4 video (30 FPS, H.264 codec)
- Duration: ~5-7 seconds (77 base frames → RIFE 2x → 154 frames)
- Quality: CRF 19 (good balance of quality/size)

**Models Used**:
- `wan2.2_i2v_high_noise_14B_fp8_scaled` - Motion structure
- `wan2.2_i2v_low_noise_14B_fp8_scaled` - Motion refinement
- `wan_2.1_vae.safetensors` - VAE encoder (prevents color artifacts)
- `nsfw_wan_umt5-xxl_fp8_scaled` - Text encoder
- `Mistral-7B-Instruct-v0.3.Q4_K_M.gguf` - LLM prompt generator

## 💻 Performance

| VRAM | Time/5sec Clip | Note |
|------|---|---|
| 24GB | 8-11 min | RTX 4090, RTX 5880 |
| 12GB | 15-20 min | RTX 3080, RTX 4070 Ti |
| 8GB | Not recommended | OOM risk |

## 🔧 Included Custom Nodes (34 total)

**Essential**:
- ComfyUI-Manager (node management)
- ComfyUI-WanVideoWrapper (WAN models)
- ComfyUI-VideoHelperSuite (video encoding)
- ComfyUI-Frame-Interpolation (RIFE)
- ComfyUI-Florence2 (image captioning)
- ComfyUI_Searge_LLM (LLM integration)
- ComfyUI-Studio-nodes (HuggingFaceDownloader)
- ComfyUI-Easy-Use (utilities)
- rgthree-comfy (LoRA loader)

**Supporting**: 20+ additional utility nodes

## 📝 Troubleshooting

**Models not downloading?**
- Check internet connection
- HuggingFaceDownloader shows status in node output
- Models cache in `ComfyUI/models/`

**CUDA out of memory?**
- Reduce resolution or frame count in workflow
- Use CPU mode (very slow)
- Ensure only ComfyUI is running

**Workflow won't load?**
- Check `ComfyUI/user/default/workflows/I2V-wan22-advanced-v2.json` exists
- Verify all custom nodes installed (Manager shows issues)

## 🚀 USB Deployment

After install.bat completes:
```
Copy entire folder → USB drive → Run on any Windows machine
```

No additional setup needed on target machine!

## 📖 More Information

- `WORKFLOWS.md` - Detailed workflow node documentation
- `logs/install_log.txt` - Installation log for troubleshooting

---

**Flagship Pack** - Professional I2V Generation, Anywhere! 🎬
