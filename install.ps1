Param([switch]$Local)

# Antigravity JZ Edition - Instalador Modular
# Este script automatiza o download e configuração do Kit

if ($Local) {
    $BaseAgent = Join-Path (Get-Location) ".agent"
    $KitDir = $BaseAgent # Kit is the .agent folder itself in local mode
    $ZipFile = Join-Path $BaseAgent "kit.zip"
    $TempExt = Join-Path $BaseAgent "temp_ext"
    Write-Host "[!] Instalação LOCAL detectada (Workspace-only)" -ForegroundColor Yellow
}
else {
    $InstallDir = Join-Path $env:USERPROFILE ".gemini\antigravity"
    $KitDir = Join-Path $InstallDir "kit"
    $ZipFile = Join-Path $InstallDir "kit.zip"
    $TempExt = Join-Path $InstallDir "temp_ext"
}

Write-Host ""
Write-Host "🌌 Antigravity Kit (JZ e RM Edition) - Instalador" -ForegroundColor Cyan
Write-Host "--------------------------------------------------" -ForegroundColor DarkCyan

# 1. Preparar pastas
if ($Local) {
    if (-not (Test-Path $BaseAgent)) { New-Item -ItemType Directory -Path $BaseAgent -Force | Out-Null }
}
else {
    if (-not (Test-Path $InstallDir)) { New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null }
}

# 2. Cleanup se já existir (Apenas se for global ou kit_source antigo)
if (-not $Local -and (Test-Path $KitDir)) {
    Write-Host "[!] Instalação anterior detectada. Atualizando..." -ForegroundColor Yellow
    Remove-Item $KitDir -Recurse -Force
}

# 3. Download
Write-Host "[>] Baixando última versão do repositório Academico-JZ..." -ForegroundColor Gray
try {
    Invoke-WebRequest -Uri "https://github.com/Academico-JZ/antigravity-jz-rm/archive/refs/heads/main.zip" -OutFile $ZipFile -ErrorAction Stop
}
catch {
    Write-Error "Erro ao baixar o kit: $_"
    exit 1
}

# 4. Extração
Write-Host "[>] Extraindo arquivos..." -ForegroundColor Gray
if (Test-Path $TempExt) { Remove-Item $TempExt -Recurse -Force }
Expand-Archive -Path $ZipFile -DestinationPath $TempExt

# Localizar a pasta extraída (o GitHub coloca o branch no nome)
$ExtractedFolder = Get-ChildItem -Path $TempExt | Where-Object { $_.PSIsContainer } | Select-Object -First 1

if ($Local) {
    Write-Host "[>] Populando estrutura local..." -ForegroundColor Gray
    # Move todos os subdiretórios de .agent para a .agent root
    $SourceAgent = Join-Path $ExtractedFolder.FullName ".agent"
    Get-ChildItem -Path $SourceAgent | ForEach-Object {
        $dest = Join-Path $BaseAgent $_.Name
        if (Test-Path $dest) { Remove-Item $dest -Recurse -Force }
        Move-Item $_.FullName $dest
    }
    # Move scripts da raiz para .agent/scripts
    $SourceScripts = Join-Path $ExtractedFolder.FullName "scripts"
    $DestScripts = Join-Path $BaseAgent "scripts"
    if (Test-Path $SourceScripts) {
        if (Test-Path $DestScripts) { Remove-Item $DestScripts -Recurse -Force }
        Move-Item $SourceScripts $DestScripts
    }
}
else {
    Move-Item -Path $ExtractedFolder.FullName -Destination $KitDir
}

# 5. Cleanup Final
Remove-Item $ZipFile -Force
Remove-Item $TempExt -Recurse -Force

# 6. Auto-Hydration (Sync Skills)
Write-Host ""
Write-Host "🔄 Unifying Skills & Agents..." -ForegroundColor Cyan
try {
    $SyncScript = if ($Local) { Join-Path $BaseAgent "scripts\sync_kits.py" } else { Join-Path $KitDir ".agent\scripts\sync_kits.py" }
    
    & python "$SyncScript" *>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[✨] 255+ Skills & 21 Agents merged successfully." -ForegroundColor Green
    }
    else {
        Write-Host "[!] Auto-hydration incomplete. Run manually later." -ForegroundColor Yellow
    }
}
catch {
    Write-Host "[!] Sync issue." -ForegroundColor Yellow
}

# 7. Linking (Auto-Init)
if (-not $Local -and (Test-Path "$KitDir\scripts\setup_workspace.ps1")) {
    Write-Host ""
    Write-Host "🔗 Linking current workspace..." -ForegroundColor Cyan
    & powershell -ExecutionPolicy Bypass -File "$KitDir\scripts\setup_workspace.ps1" | Out-Null
    Write-Host "[✨] Workspace linked to Global Kit." -ForegroundColor Green
}

Write-Host ""
Write-Host "✅ $(if($Local){'Local'}else{'Global'}) Setup Complete!" -ForegroundColor Green
Write-Host "🚀 Antigravity JZ-RM is now ONLINE." -ForegroundColor Cyan
Write-Host "Rules active in .agent/rules/GEMINI.md" -ForegroundColor Gray
Write-Host ""
