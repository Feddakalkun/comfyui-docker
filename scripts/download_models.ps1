# ============================================================================
# FEDDAKALKUN ComfyUI - Model Downloader
# ============================================================================

$ErrorActionPreference = "Stop"
$ScriptPath = $PSScriptRoot
Set-Location $ScriptPath

# Ensure logs directory exists
if (-not (Test-Path "logs")) { New-Item -ItemType Directory -Path "logs" | Out-Null }
$LogFile = Join-Path "logs" "model_download_log.txt"

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
            # Use BitsTransfer for large files (better progress/resume)
            Start-BitsTransfer -Source $Url -Destination $Dest
            Write-Log "Download complete."
        } catch {
            Write-Log "ERROR: Failed to download $Url"
            Write-Log $_
        }
    } else {
        Write-Log "File already exists: $(Split-Path $Dest -Leaf)"
    }
}

Write-Log "========================================="
Write-Log "Model Download Started"
Write-Log "========================================="

$ModelsConfig = Get-Content (Join-Path $ScriptPath "..\config\models.json") | ConvertFrom-Json
$ComfyDir = Join-Path $ScriptPath "..\ComfyUI"

if (-not (Test-Path $ComfyDir)) {
    Write-Log "ERROR: ComfyUI directory not found. Please run install.bat first."
    exit 1
}

foreach ($Model in $ModelsConfig) {
    $TargetDir = Join-Path $ComfyDir $Model.path
    if (-not (Test-Path $TargetDir)) {
        New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
    }
    
    $TargetFile = Join-Path $TargetDir $Model.filename
    Write-Log "Processing $($Model.name)..."
    Download-File $Model.url $TargetFile
}

Write-Log "========================================="
Write-Log "Model Download Complete!"
Write-Log "========================================="
