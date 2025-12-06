# ============================================================================
# FEDDAKALKUN ComfyUI - Local Model Importer
# ============================================================================

$ErrorActionPreference = "Stop"
$ScriptPath = $PSScriptRoot
$RootPath = Split-Path -Parent $ScriptPath
Set-Location $RootPath

$SourceDir = Join-Path $RootPath "0-ALL-MODELS-SCRIPTS"
$ComfyModelsDir = Join-Path $RootPath "ComfyUI\models"

function Write-Log {
    param([string]$Message)
    Write-Host $Message -ForegroundColor Cyan
}

function Link-Or-Copy {
    param([string]$Source, [string]$Dest)
    
    if (-not (Test-Path $Source)) { return }
    if (-not (Test-Path $Dest)) { New-Item -ItemType Directory -Path $Dest -Force | Out-Null }

    $Files = Get-ChildItem -Path $Source -File -Recurse
    foreach ($File in $Files) {
        $DestFile = Join-Path $Dest $File.Name
        if (-not (Test-Path $DestFile)) {
            Write-Log "Linking: $($File.Name)"
            try {
                # Try Symbolic Link first (requires Admin)
                New-Item -ItemType SymbolicLink -Path $DestFile -Target $File.FullName | Out-Null
            } catch {
                # Fallback to Copy
                Write-Log "  Symlink failed, copying instead..."
                Copy-Item -Path $File.FullName -Destination $DestFile
            }
        } else {
            Write-Log "Skipping: $($File.Name) (Already exists)"
        }
    }
}

if (-not (Test-Path $SourceDir)) {
    Write-Log "Source directory '0-ALL-MODELS-SCRIPTS' not found."
    exit
}

Write-Log "========================================="
Write-Log "Importing Local Models..."
Write-Log "========================================="

# --- Mappings ---

# 1. Wan Models -> diffusion_models
Link-Or-Copy (Join-Path $SourceDir "wan") (Join-Path $ComfyModelsDir "diffusion_models")

# 2. SDXL -> checkpoints
Link-Or-Copy (Join-Path $SourceDir "sdxl") (Join-Path $ComfyModelsDir "checkpoints")

# 3. LoRAs -> loras
Link-Or-Copy (Join-Path $SourceDir "loras") (Join-Path $ComfyModelsDir "loras")

# 4. VAE -> vae
Link-Or-Copy (Join-Path $SourceDir "vae") (Join-Path $ComfyModelsDir "vae")

# 5. CLIP -> text_encoders (Standard for ComfyUI new structure)
Link-Or-Copy (Join-Path $SourceDir "clip") (Join-Path $ComfyModelsDir "text_encoders")
# Also link to 'clip' just in case
Link-Or-Copy (Join-Path $SourceDir "clip") (Join-Path $ComfyModelsDir "clip")

# 6. ControlNet -> controlnet
Link-Or-Copy (Join-Path $SourceDir "controlnet") (Join-Path $ComfyModelsDir "controlnet")

# 7. IPAdapter -> ipadapter (Custom location)
Link-Or-Copy (Join-Path $SourceDir "ipadapter") (Join-Path $ComfyModelsDir "ipadapter")

# 8. Flux -> unet (Flux usually goes here)
Link-Or-Copy (Join-Path $SourceDir "flux") (Join-Path $ComfyModelsDir "unet")

Write-Log "========================================="
Write-Log "Import Complete!"
Write-Log "========================================="
Start-Sleep -Seconds 3
