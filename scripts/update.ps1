# ============================================================================ 
# FEDDAKALKUN ComfyUI - Update Script 
# ============================================================================ 

$ErrorActionPreference = "Stop"
$ScriptPath = $PSScriptRoot
$RootPath = Split-Path -Parent $ScriptPath
Set-Location $RootPath

# Ensure logs directory exists
if (-not (Test-Path "logs")) { New-Item -ItemType Directory -Path "logs" | Out-Null }
$LogFile = Join-Path "logs" "update_log.txt"

function Write-Log {
    param([string]$Message)
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "[$Timestamp] $Message"
    Write-Host $Message
    Add-Content -Path $LogFile -Value $LogEntry
}

function Run-Git {
    param([string]$Arguments, [string]$Dir)
    $GitExe = Join-Path $RootPath "git_embeded\cmd\git.exe"
    if (-not (Test-Path $GitExe)) {
        Write-Log "ERROR: Portable Git not found."
        return
    }
    
    Push-Location $Dir
    try {
        $Process = Start-Process -FilePath $GitExe -ArgumentList "$Arguments" -NoNewWindow -Wait -PassThru
        if ($Process.ExitCode -ne 0) {
            Write-Log "WARNING: Git command failed in $Dir"
        }
    } finally {
        Pop-Location
    }
}

Write-Log "========================================="
Write-Log "Update Started"
Write-Log "========================================="

# 1. Update Installer Repository
Write-Log "Updating Installer Suite..."
Run-Git "pull" $RootPath

# 2. Update ComfyUI Core
$ComfyDir = Join-Path $RootPath "ComfyUI"
if (Test-Path $ComfyDir) {
    Write-Log "Updating ComfyUI Core..."
    Run-Git "pull" $ComfyDir
}

# 3. Update Custom Nodes
$CustomNodesDir = Join-Path $ComfyDir "custom_nodes"
if (Test-Path $CustomNodesDir) {
    Write-Log "Updating Custom Nodes..."
    $Nodes = Get-ChildItem -Path $CustomNodesDir -Directory
    foreach ($Node in $Nodes) {
        Write-Log "Updating $($Node.Name)..."
        Run-Git "pull" $Node.FullName
    }
}

# 4. Update Python Dependencies (Optional but recommended)
Write-Log "Checking for dependency updates..."
$PyExe = Join-Path $RootPath "python_embeded\python.exe"
if (Test-Path $PyExe) {
    # Update pip first
    Start-Process -FilePath $PyExe -ArgumentList "-m pip install --upgrade pip" -NoNewWindow -Wait
    # Re-run requirements to catch new deps
    Start-Process -FilePath $PyExe -ArgumentList "-m pip install -r $ComfyDir\requirements.txt" -NoNewWindow -Wait
}

Write-Log "========================================="
Write-Log "Update Complete!"
Write-Log "========================================="
Start-Sleep -Seconds 3
