# Creates junction in target workspace pointing to central .agent
# Usage: .\init-workspace.ps1 "C:\path\to\workspace"

param(
    [Parameter(Mandatory=$false)]
    [string]$WorkspacePath = (Get-Location).Path
)

$AgentSource = "$env:USERPROFILE\.gemini\antigravity\.agent"
$AgentTarget = Join-Path $WorkspacePath ".agent"

Write-Host "`n╔══════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     ANTIGRAVITY WORKSPACE INIT       ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════╝`n" -ForegroundColor Cyan

# Verify source exists
if (-not (Test-Path $AgentSource)) {
    Write-Host "❌ Central .agent not found at: $AgentSource" -ForegroundColor Red
    Write-Host "   Run setup.ps1 first!" -ForegroundColor Yellow
    exit 1
}

# Check if target already exists
if (Test-Path $AgentTarget) {
    $item = Get-Item $AgentTarget -Force
    if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
        Write-Host "✅ Junction already exists at: $AgentTarget" -ForegroundColor Yellow
        exit 0
    } else {
        Write-Host "⚠️  Removing existing .agent folder..." -ForegroundColor Yellow
        Remove-Item $AgentTarget -Recurse -Force
    }
}

# Create junction
try {
    cmd /c mklink /J "$AgentTarget" "$AgentSource" | Out-Null
    Write-Host "✅ Junction created successfully!" -ForegroundColor Green
    Write-Host "   Source: $AgentSource" -ForegroundColor Gray
    Write-Host "   Target: $AgentTarget" -ForegroundColor Gray
} catch {
    Write-Host "❌ Failed to create junction. Try running as Administrator." -ForegroundColor Red
    exit 1
}

Write-Host "`n🚀 Workspace is now connected to central .agent!`n" -ForegroundColor Green
