$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "🌌 JZ-RM Bootstrap: Git-Less Installer" -ForegroundColor Cyan
Write-Host "─────────────────────────────────────" -ForegroundColor Gray

# 1. Config
$RepoUrl = "https://github.com/Academico-JZ/ag-jz-rm/archive/refs/heads/main.zip"
$InstallDir = Join-Path $env:USERPROFILE ".gemini\antigravity\bootstrap_temp"
$ZipPath = Join-Path $env:USERPROFILE "ag-jz-rm-bootstrap.zip"

# 2. Cleanup Old
if (Test-Path $InstallDir) { Remove-Item $InstallDir -Recurse -Force | Out-Null }
if (Test-Path $ZipPath) { Remove-Item $ZipPath -Force | Out-Null }

# 3. Download
Write-Host " [>] Downloading JZ-RM Distribution (No Git req.)..." -ForegroundColor Gray
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri $RepoUrl -OutFile $ZipPath

# 4. Extract
Write-Host " [>] Extracting Core Files..." -ForegroundColor Gray
Expand-Archive -Path $ZipPath -DestinationPath $InstallDir -Force
$ExtractedDir = (Get-ChildItem $InstallDir | Select-Object -First 1).FullName

# 5. Install & Link
Write-Host " [>] Linking binary to global..." -ForegroundColor Gray
Push-Location $ExtractedDir

# Attempt npm install locally first to get dependencies
try {
    Write-Host " [>] Installing dependencies..." -ForegroundColor Gray
    npm install --omit=dev | Out-Null
    npm link --force | Out-Null
} catch {
    Write-Host " [!] NPM Link warning (ignoring)..." -ForegroundColor Yellow
}

# 6. Execute Init
Write-Host " [✨] Launching JZ-RM Init..." -ForegroundColor Green
node bin/cli.js init

# 7. Cleanup
Pop-Location
Remove-Item $ZipPath -Force
# We keep the bootstrap folder as the "source" for the link if npm link worked? 
# Actually, npm link symlinks the current folder. So we MUST NOT delete $InstallDir if we want the command to persist.
# However, this is a bootstrap. 
# Better strategy: Move to a permanent location before linking.

$PermPath = Join-Path $env:USERPROFILE ".gemini\antigravity\ag-jz-rm-core"
if (Test-Path $PermPath) { Remove-Item $PermPath -Recurse -Force | Out-Null }
Move-Item -Path $ExtractedDir -Destination $PermPath

Write-Host " [>] Core moved to: $PermPath" -ForegroundColor Gray
Push-Location $PermPath
npm install --omit=dev | Out-Null
npm link --force | Out-Null
Pop-Location

Write-Host ""
Write-Host "✅ Installation Complete!" -ForegroundColor Green
Write-Host "👉 You can now use 'ag-jz-rm init' anywhere." -ForegroundColor Cyan
