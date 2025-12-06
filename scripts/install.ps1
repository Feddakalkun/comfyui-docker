# ============================================================================ 
# FEDDAKALKUN ComfyUI - Ultimate Portable Installer
# ============================================================================ 

$ErrorActionPreference = "Stop"
$ScriptPath = $PSScriptRoot
$RootPath = Split-Path -Parent $ScriptPath
$RootPath = (Resolve-Path $RootPath).Path  # Ensure absolute path
Set-Location $RootPath

Write-Host "Installation root: $RootPath"

# Ensure logs directory exists
if (-not (Test-Path "logs")) { New-Item -ItemType Directory -Path "logs" | Out-Null }
$LogFile = Join-Path "logs" "install_log.txt"

function Write-Log {
    param([string]$Message)
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "[$Timestamp] $Message"
    Write-Host $Message
    Add-Content -Path $LogFile -Value $LogEntry
}

function Download-File {
    param([string]$Url, [string]$Dest)
    if (-not (Test-Path $Dest)) {
        Write-Log "Downloading $(Split-Path $Dest -Leaf)..."
        try {
            Invoke-WebRequest -Uri $Url -OutFile $Dest -UseBasicParsing
        } catch {
            Write-Log "ERROR: Failed to download $Url"
            throw $_ 
        }
    }
}

function Extract-Zip {
    param([string]$ZipFile, [string]$DestDir)
    Write-Log "Extracting $(Split-Path $ZipFile -Leaf)..."
    Expand-Archive -Path $ZipFile -DestinationPath $DestDir -Force
}

Write-Log "========================================="
Write-Log "Portable Installation Started"
Write-Log "========================================="

# ============================================================================ 
# 1. BOOTSTRAP PORTABLE TOOLS
# ============================================================================ 

# --- 1.1 Portable Python ---
$PyDir = Join-Path $RootPath "python_embeded"
$PyExe = Join-Path $PyDir "python.exe"

if (-not (Test-Path $PyExe)) {
    Write-Log "[1/9] Setting up Portable Python..."
    $PyZip = Join-Path $RootPath "python_embed.zip"
    Download-File "https://www.python.org/ftp/python/3.11.9/python-3.11.9-embed-amd64.zip" $PyZip
    
    New-Item -ItemType Directory -Path $PyDir -Force | Out-Null
    Extract-Zip $PyZip $PyDir
    Remove-Item $PyZip -Force

    # --- CRITICAL FIX: Configure python311._pth ---
    # 1. Enable site-packages (import site)
    # 2. Add ../ComfyUI to path so 'import comfy' works
    $PthFile = Join-Path $PyDir "python311._pth"
    $Content = Get-Content $PthFile
    $Content = $Content -replace "#import site", "import site"
    
    if ($Content -notcontains "../ComfyUI") {
        $Content += "../ComfyUI"
    }
    
    Set-Content -Path $PthFile -Value $Content
    Write-Log "Portable Python configured (Path fixed)."

    # Install Pip
    Write-Log "Installing Pip..."
    $GetPip = Join-Path $RootPath "get-pip.py"
    Download-File "https://bootstrap.pypa.io/get-pip.py" $GetPip
    Start-Process -FilePath $PyExe -ArgumentList "$GetPip" -NoNewWindow -Wait
    Remove-Item $GetPip -Force
} else {
    Write-Log "[1/9] Portable Python found."
}

# --- 1.2 Portable Git (MinGit) ---
$GitDir = Join-Path $RootPath "git_embeded"
$GitExe = Join-Path $GitDir "cmd\git.exe"

if (-not (Test-Path $GitExe)) {
    Write-Log "[2/9] Setting up Portable Git..."
    $GitZip = Join-Path $RootPath "mingit.zip"
    Download-File "https://github.com/git-for-windows/git/releases/download/v2.43.0.windows.1/MinGit-2.43.0-64-bit.zip" $GitZip
    
    New-Item -ItemType Directory -Path $GitDir -Force | Out-Null
    Extract-Zip $GitZip $GitDir
    Remove-Item $GitZip -Force
    Write-Log "Portable Git configured."
} else {
    Write-Log "[2/9] Portable Git found."
}

# --- 1.3 Portable Node.js ---
$NodeDir = Join-Path $RootPath "node_embeded"
$NodeExe = Join-Path $NodeDir "node.exe"

if (-not (Test-Path $NodeExe)) {
    Write-Log "[3/9] Setting up Portable Node.js..."
    $NodeZip = Join-Path $RootPath "node.zip"
    Download-File "https://nodejs.org/dist/v20.11.0/node-v20.11.0-win-x64.zip" $NodeZip
    
    Extract-Zip $NodeZip $RootPath
    $ExtractedNode = Get-ChildItem -Path $RootPath -Directory -Filter "node-v*-win-x64" | Select-Object -First 1
    if ($ExtractedNode) {
        Rename-Item -Path $ExtractedNode.FullName -NewName "node_embeded"
    }
    Remove-Item $NodeZip -Force
    Write-Log "Portable Node.js configured."
} else {
    Write-Log "[3/9] Portable Node.js found."
}

# Helper to run commands with portable environment
$env:PATH = "$GitDir\cmd;$NodeDir;$PyDir;$PyDir\Scripts;$env:PATH"

function Run-Pip {
    param([string]$Arguments)
    $Process = Start-Process -FilePath $PyExe -ArgumentList "-m pip $Arguments" -NoNewWindow -Wait -PassThru
    if ($Process.ExitCode -ne 0) {
        Write-Log "WARNING: Pip command failed: $Arguments"
    }
}

function Run-Git {
    param([string]$Arguments)
    $Process = Start-Process -FilePath $GitExe -ArgumentList "$Arguments" -NoNewWindow -Wait -PassThru
    return $Process.ExitCode
}

# ============================================================================ 
# 2. INSTALLATION LOGIC
# ============================================================================ 

# 4. Setup ComfyUI Repository
Write-Log "`n[4/9] Setting up ComfyUI repository..."
$ComfyDir = Join-Path $RootPath "ComfyUI"
if (-not (Test-Path $ComfyDir)) {
    Write-Log "Cloning ComfyUI repository..."
    try {
        Run-Git "clone --depth 1 https://github.com/comfyanonymous/ComfyUI.git `"$ComfyDir`""
        Write-Log "ComfyUI cloned successfully."
    } catch {
        Write-Log "ERROR: Failed to clone ComfyUI repository."
        exit 1
    }
} else {
    Write-Log "ComfyUI directory already exists."
}

# 5. Core Dependencies
Write-Log "`n[5/9] Installing core dependencies..."
$ComfyDir = Join-Path $RootPath "ComfyUI"

Write-Log "Upgrading pip..."
Run-Pip "install --upgrade pip wheel setuptools"

Write-Log "Installing PyTorch (CUDA)..."
Run-Pip "install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118"
if ($LASTEXITCODE -ne 0) {
    Write-Log "CUDA PyTorch failed, trying CPU..."
    Run-Pip "install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu"
}

Write-Log "Installing ComfyUI requirements..."
$ReqFile = Join-Path $ComfyDir "requirements.txt"
Run-Pip "install -r $ReqFile"

Write-Log "Installing core dependencies..."
Run-Pip "install numpy scipy matplotlib pillow tqdm requests psutil"

# 6. Custom Nodes Installation
Write-Log "`n[6/9] Installing Custom Nodes..."
$NodesConfig = Get-Content (Join-Path $RootPath "config\nodes.json") | ConvertFrom-Json
$CustomNodesDir = Join-Path $ComfyDir "custom_nodes"

$InstalledCount = 0
$SkippedCount = 0
$FailedCount = 0

foreach ($Node in $NodesConfig) {
    # Skip local nodes (e.g., AutoModelFetcher)
    if ($Node.local -eq $true) {
        Write-Log "[$($Node.name)] - Local node, skipping git clone"
        continue
    }
    
    $NodeDir = Join-Path $CustomNodesDir $Node.folder
    if (-not (Test-Path $NodeDir)) {
        Write-Log "Installing $($Node.name)..."
        Run-Git "clone --depth 1 $($Node.url) `"$NodeDir`""
        if ($LASTEXITCODE -eq 0) {
            Write-Log "[$($Node.name)] - Installed successfully"
            $InstalledCount++
            
            # Create __init__.py if missing
            $InitFile = Join-Path $NodeDir "__init__.py"
            if (-not (Test-Path $InitFile)) {
                $InitContent = @"
# $($Node.folder) - Custom nodes for ComfyUI
import sys
import os
from pathlib import Path

current_dir = os.path.dirname(__file__)
if current_dir not in sys.path:
    sys.path.append(current_dir)

NODE_CLASS_MAPPINGS = {}
NODE_DISPLAY_NAME_MAPPINGS = {}
__all__ = ['NODE_CLASS_MAPPINGS', 'NODE_DISPLAY_NAME_MAPPINGS']
"@
                Set-Content -Path $InitFile -Value $InitContent
            }
        } else {
            Write-Log "[$($Node.name)] - Failed to install"
            $FailedCount++
        }
    } else {
        Write-Log "[$($Node.name)] - Already present"
        $SkippedCount++
    }
}

# --- CRITICAL FIX: Patch Efficiency Nodes ---
$EffNodeFile = Join-Path $CustomNodesDir "Efficiency-Nodes\py\smZ_cfg_denoiser.py"
if (Test-Path $EffNodeFile) {
    Write-Log "Patching Efficiency Nodes..."
    $EffContent = Get-Content $EffNodeFile -Raw
    if ($EffContent -match "CompVisVDenoiser") {
        $EffContent = $EffContent.Replace(
            "from comfy.samplers import KSampler, CompVisVDenoiser, KSamplerX0Inpaint",
            "from comfy.samplers import KSampler, KSamplerX0Inpaint"
        )
        $EffContent = $EffContent.Replace(
            "from comfy.k_diffusion.external import CompVisDenoiser",
            "from comfy.k_diffusion.external import CompVisDenoiser, CompVisVDenoiser"
        )
        Set-Content -Path $EffNodeFile -Value $EffContent
        Write-Log "Efficiency Nodes patched successfully."
    }
}

# 7. Comprehensive Dependencies (Updated with fixes)
Write-Log "`n[7/9] Installing comprehensive dependencies..."

# 7.1 Install Build Tools first (Fix for llama-cpp-python)
Write-Log "Installing build dependencies..."
Run-Pip "install scikit-build-core cmake ninja"

# 7.2 Main Dependencies
$Deps = @(
    "accelerate", "transformers", "diffusers", "safetensors",
    "huggingface-hub", "onnxruntime-gpu", "onnxruntime", "omegaconf",
    "aiohttp", "aiohttp-sse",
    "pytube", "yt-dlp", "moviepy", "youtube-transcript-api",
    "numba",
    "opencv-python", "opencv-python-headless", "imageio", "imageio-ffmpeg", "av",
    "gdown", "pandas", "reportlab", "google-auth", "google-auth-oauthlib", "google-auth-httplib2",
    "GPUtil", "wandb",
    "piexif", "rembg",
    "pillow-heif",
    "librosa", "soundfile",
    "webdriver-manager", "beautifulsoup4", "lxml", "shapely",
    "deepdiff", "fal_client"
)
Run-Pip "install $($Deps -join ' ')"

# 7.3 Install llama-cpp-python separately (with pre-built wheel preference)
Write-Log "Installing llama-cpp-python..."
# Try installing with --prefer-binary to avoid building from source if possible
Run-Pip "install llama-cpp-python --prefer-binary --extra-index-url https://abetlen.github.io/llama-cpp-python/whl/cu118"


# 8. Install Custom Workflows
Write-Log "`n[8/9] Installing Custom Workflows..."
$WorkflowsSrc = Join-Path $RootPath "assets\workflows"
$WorkflowsDest = Join-Path $ComfyDir "user\default\workflows"

if (Test-Path $WorkflowsSrc) {
    if (-not (Test-Path $WorkflowsDest)) { New-Item -ItemType Directory -Path $WorkflowsDest -Force | Out-Null }
    $WorkflowFiles = Get-ChildItem -Path $WorkflowsSrc -Filter "*.json"
    foreach ($File in $WorkflowFiles) {
        Copy-Item -Path $File.FullName -Destination $WorkflowsDest -Force
        Write-Log "Installed workflow: $($File.Name)"
    }
}

# 9. Configure ComfyUI-Manager Security (Weak Mode)
Write-Log "`n[9/9] Configuring ComfyUI-Manager Security..."
$ManagerConfigDir = Join-Path $ComfyDir "user\default\ComfyUI-Manager"
$ManagerConfigFile = Join-Path $ManagerConfigDir "config.ini"

if (-not (Test-Path $ManagerConfigDir)) {
    New-Item -ItemType Directory -Path $ManagerConfigDir -Force | Out-Null
}

if (-not (Test-Path $ManagerConfigFile)) {
    $ConfigContent = @"
[default]
security_level = weak
"@
    Set-Content -Path $ManagerConfigFile -Value $ConfigContent
    Write-Log "Security level set to 'weak' (Developer Mode)."
} else {
    Write-Log "ComfyUI-Manager config already exists. Skipping."
}

# 10. Shortcut
Write-Log "Creating desktop shortcut..."
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\ComfyUI - FEDDAKALKUN.lnk")
$Shortcut.TargetPath = "$RootPath\start_suite.bat"
$Shortcut.IconLocation = "$RootPath\ComfyUI\comfyui.ico"
$Shortcut.Save()

Write-Log "`n================================================"
Write-Log " Portable Installation Complete!"
Write-Log "================================================"