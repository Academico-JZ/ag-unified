# Creates junction in target workspace pointing to local .agent
# Usage: .\init-workspace.ps1 "C:\path\to\workspace"

param(
    [Parameter(Mandatory=$false)]
    [string]$WorkspacePath = (Get-Location).Path
)

# Portable logic: Finds .agent relative to this script's location (ag-jz/scripts/.. -> ag-jz/.agent)
$RepoRoot = Resolve-Path "$PSScriptRoot\.." | Select-Object -ExpandProperty Path
$AgentSource = Join-Path $RepoRoot ".agent"
$AgentTarget = Join-Path $WorkspacePath ".agent"

Write-Host "`n╔══════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     ANTIGRAVITY WORKSPACE INIT       ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════╝`n" -ForegroundColor Cyan

# Verify source exists
if (-not (Test-Path $AgentSource)) {
    Write-Host "❌ .agent folder not found at: $AgentSource" -ForegroundColor Red
    Write-Host "   Run setup.ps1 first to install dependencies!" -ForegroundColor Yellow
    exit 1
}

# Check if target already exists
if (Test-Path $AgentTarget) {
    try {
        $item = Get-Item $AgentTarget -Force -ErrorAction Stop
        if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
            Write-Host "✅ Junction already exists at: $AgentTarget" -ForegroundColor Yellow
            exit 0
        } else {
            Write-Host "⚠️  Removing existing .agent folder..." -ForegroundColor Yellow
            Remove-Item $AgentTarget -Recurse -Force
        }
    } catch {
        Write-Host "❌ Error verifying target. Check permissions." -ForegroundColor Red
        exit 1
    }
}

# Create junction
try {
    # Check write permission roughly (try creating a temp file)
    $TestFile = Join-Path $WorkspacePath ".permtest"
    New-Item $TestFile -ItemType File -Force -ErrorAction Stop | Out-Null
    Remove-Item $TestFile -Force
    
    cmd /c mklink /J "$AgentTarget" "$AgentSource" | Out-Null
    
    if (Test-Path $AgentTarget) {
        Write-Host "✅ Junction created successfully!" -ForegroundColor Green
        Write-Host "   Source: $AgentSource" -ForegroundColor Gray
        Write-Host "   Target: $AgentTarget" -ForegroundColor Gray
    } else {
        throw "Junction creation failed silently."
    }
} catch {
    Write-Host "❌ Failed to create junction." -ForegroundColor Red
    Write-Host "   Error: $_" -ForegroundColor Gray
    Write-Host "   Try running PowerShell as Administrator." -ForegroundColor Yellow
    exit 1
}

Write-Host "`n🚀 Workspace is now connected to central .agent!`n" -ForegroundColor Green
