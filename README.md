# ✨ FEDDAKALKUN AI Suite - Ultimate Portable Edition

A fully portable, self-contained AI Suite containing ComfyUI, a digital asset shop, and an AI assistant app. **Runs from a USB stick!**

## 🚀 Features

- **100% Portable**: No installation required on the host machine. Python, Node.js, and Git are all embedded.
- **USB Ready**: Copy this folder to a USB drive and run it on any Windows PC.
- **Unified Launcher**: Access ComfyUI, the Shop, and the App from a single menu.
- **Auto-Updates**: Includes portable Git to keep your nodes and ComfyUI up to date.
- **Weak Security Mode**: Automatically configures ComfyUI-Manager to allow all custom nodes.

## 🛠️ Project Structure

```
FEDDAKALKUN_ComfyUI_Installer/
├── start_suite.bat        # 🌟 MAIN LAUNCHER
├── install.bat            # 🌟 PORTABLE BUILDER (Run once to setup)
├── download_models.bat    # 🌟 MODEL DOWNLOADER (Optional)
├── install.ps1            # Core setup logic
├── python_embeded/        # Portable Python (Created by install.bat)
├── node_embeded/          # Portable Node.js (Created by install.bat)
├── git_embeded/           # Portable Git (Created by install.bat)
├── config/
│   ├── nodes.json         # Custom node configuration
│   └── models.json        # Model download configuration
├── assets/
│   └── workflows/         # Drop custom workflows here
├── GGAFD-com/             # AI Art Gallery & Shop
├── ggafd-phone/           # AI Assistant App
└── ComfyUI/               # ComfyUI Core
```

## 🚀 Quick Start

### 1. Build the Portable Environment (Run Once)
Double-click **`install.bat`**.
- This will download and configure Portable Python, Node.js, and Git.
- It installs ComfyUI and all dependencies into the portable environment.
- It sets `security_level = weak` for ComfyUI-Manager (Developer Mode).
- **Note:** This step requires an internet connection.

### 2. Download Models (Optional)
Double-click **`download_models.bat`**.
- Downloads essential models (SDXL, etc.) defined in `config/models.json`.

### 3. Launch the Suite
Double-click **`start_suite.bat`**.
- **[1] ComfyUI**: Launches the portable ComfyUI instance.
- **[2] GGAFD Shop**: Launches the local web store (using portable Node.js).
- **[3] AI Assistant**: Launches the mobile app (using portable Node.js).

### 4. Move to USB
Once step 1 is complete, you can copy the entire `FEDDAKALKUN_ComfyUI_Installer` folder to a USB stick. It will work on any Windows machine without installing anything!

## 🎯 Flagship Custom Nodes Included
- **📹 ComfyUI-VideoHelperSuite**
- **⚡ ComfyUI Essentials**
- **🛠️ ComfyUI Fill-Nodes**
- **📊 ComfyUI-Crystools**
- **🧠 ComfyUI-IPAdapter-Plus**
- **🎨 ComfyUI-Inspire-Pack**
- **🚀 ComfyUI-UltimateSDUpscale**
- **🔧 rgthree-comfy**

## 📋 Requirements
- **Host OS**: Windows 10/11 (x64)
- **Drivers**: NVIDIA Drivers (for GPU acceleration) are recommended on the host machine.

---

**Created by FEDDAKALKUN** - Professional AI Tools, Anywhere! ✨
