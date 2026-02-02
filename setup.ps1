# Setup Antigravity JZ (Robust Fix)
$ErrorActionPreference = "Stop"
$ScriptPath = $PSScriptRoot
$InstallPath = $ScriptPath

Write-Host "🚀 Iniciando Setup Modular Academico-JZ..." -ForegroundColor Cyan

# 1. Instalar AG-KIT (Base)
if (-not (Test-Path "$InstallPath\.agent\agents")) {
    Write-Host "📦 Instalando Base (ag-kit)..." -ForegroundColor Yellow
    npm install -g @vudovn/ag-kit
    ag-kit init
}
else {
    Write-Host "✅ Base já instalada." -ForegroundColor Green
}

# 2. Instalar Skills (Método Robusto Zip+Tar)
Write-Host "⚡ Baixando Skills (600+)..." -ForegroundColor Yellow
$SkillsZip = "$InstallPath\skills.zip"
$SkillsUrl = "https://github.com/sickn33/antigravity-awesome-skills/archive/refs/tags/v4.6.0.zip"
$SkillsDest = "$InstallPath\.agent\skills"

Invoke-WebRequest -Uri $SkillsUrl -OutFile $SkillsZip
Write-Host "📂 Extraindo..." -ForegroundColor Yellow
# Usar tar para melhor compatibilidade com nomes longos/symlinks (ignora erros de symlink)
tar -xf $SkillsZip 

# Merge seguro
Write-Host "🔄 Instalando..." -ForegroundColor Yellow
if (-not (Test-Path $SkillsDest)) { New-Item -ItemType Directory -Path $SkillsDest -Force | Out-Null }
$SourcePath = "$InstallPath\antigravity-awesome-skills-4.6.0\skills"
Get-ChildItem $SourcePath | ForEach-Object {
    $Target = Join-Path $SkillsDest $_.Name
    if (Test-Path $Target) { Remove-Item $Target -Recurse -Force -ErrorAction SilentlyContinue }
    Move-Item $_.FullName $SkillsDest -Force
}

# Cleanup
Remove-Item $SkillsZip, "$InstallPath\antigravity-awesome-skills-4.6.0" -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "✅ Skills instaladas: $((Get-ChildItem $SkillsDest).Count)" -ForegroundColor Green

# 3. Aplicar Customização
Write-Host "🛠️ Aplicando GEMINI.md..." -ForegroundColor Yellow
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Academico-JZ/ag-jz/main/custom/GEMINI.md" -OutFile "$InstallPath\.agent\GEMINI.md"
Write-Host "✅ Customização concluída." -ForegroundColor Green

Write-Host "✨ Setup Finalizado com Sucesso!" -ForegroundColor Cyan
