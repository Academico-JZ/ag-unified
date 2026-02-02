# Setup Antigravity JZ (Robust Fix)
$ErrorActionPreference = "Stop"
$ScriptPath = $PSScriptRoot
$InstallPath = $ScriptPath

Write-Host "🚀 Iniciando Setup Modular Academico-JZ..." -ForegroundColor Cyan

# 1. Instalar AG-KIT (Base)
if (-not (Test-Path "$InstallPath\.agent\agents")) {
    Write-Host "📦 Instalando Base (ag-kit)..." -ForegroundColor Yellow
    try {
        npm install -g @vudovn/ag-kit 2>$null
        ag-kit init
    }
    catch {
        Write-Host "   ⚠️ npm falhou/indisponível. Baixando ag-kit manualmente..." -ForegroundColor Gray
        Invoke-WebRequest "https://github.com/vudovn/antigravity-kit/archive/refs/heads/main.zip" -OutFile "kit.zip"
        Expand-Archive "kit.zip" -DestinationPath "." -Force
        if (-not (Test-Path ".agent")) { New-Item -ItemType Directory -Path ".agent" | Out-Null }
        Copy-Item "antigravity-kit-main\.agent\*" ".agent" -Recurse -Force
        Remove-Item "kit.zip", "antigravity-kit-main" -Recurse -Force
    }
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
# Usar tar se disponível (mais rápido/robusto)
try {
    tar -xf $SkillsZip 2>$null
}
catch {
    Expand-Archive $SkillsZip -DestinationPath "." -Force
}

# Merge seguro
Write-Host "🔄 Instalando..." -ForegroundColor Yellow
if (-not (Test-Path $SkillsDest)) { New-Item -ItemType Directory -Path $SkillsDest -Force | Out-Null }
$SourcePath = "$InstallPath\antigravity-awesome-skills-4.6.0\skills"
if (Test-Path $SourcePath) {
    Get-ChildItem $SourcePath | ForEach-Object {
        $Target = Join-Path $SkillsDest $_.Name
        if (Test-Path $Target) { Remove-Item $Target -Recurse -Force -ErrorAction SilentlyContinue }
        Move-Item $_.FullName $SkillsDest -Force
    }
}

# Cleanup
Remove-Item $SkillsZip, "$InstallPath\antigravity-awesome-skills-4.6.0" -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "✅ Skills instaladas: $((Get-ChildItem $SkillsDest).Count)" -ForegroundColor Green

# 3. Aplicar Customização
Write-Host "🛠️ Aplicando GEMINI.md customizado..." -ForegroundColor Yellow
$CustomGeminiUrl = "https://raw.githubusercontent.com/Academico-JZ/ag-jz/main/custom/GEMINI.md"
# Local .agent
Invoke-WebRequest -Uri $CustomGeminiUrl -OutFile "$InstallPath\.agent\GEMINI.md"
# Global User Profile (Essencial para substituir o padrão)
$GlobalGemini = "$env:USERPROFILE\.gemini\GEMINI.md"
Write-Host "   Sobreescrevendo GEMINI.md GLOBAL: $GlobalGemini" -ForegroundColor Yellow
Invoke-WebRequest -Uri $CustomGeminiUrl -OutFile $GlobalGemini
Write-Host "✅ Customização concluída (Local + Global)." -ForegroundColor Green

# 4. Gerar Script de Inicialização (Self-contained)
Write-Host "🔌 Gerando script de workspace..." -ForegroundColor Yellow
$InitScriptPath = "$InstallPath\.agent\scripts\init-workspace.ps1"
if (-not (Test-Path (Split-Path $InitScriptPath))) { New-Item -ItemType Directory -Path (Split-Path $InitScriptPath) -Force | Out-Null }

$InitContent = @'
param([string]$WorkspacePath)
$ErrorActionPreference = "Stop"
$AgentSource = Resolve-Path "$PSScriptRoot\..\.." | Select-Object -ExpandProperty Path
$AgentTarget = Join-Path $WorkspacePath ".agent"

Write-Host "🔗 Linking Workspace..." -ForegroundColor Cyan
if (Test-Path $AgentTarget) {
    $item = Get-Item $AgentTarget
    if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) { Write-Host "✅ Junction exists."; exit 0 }
    Remove-Item $AgentTarget -Recurse -Force
}
cmd /c mklink /J "$AgentTarget" "$AgentSource\.agent"
if (Test-Path $AgentTarget) { Write-Host "✅ Success!" -ForegroundColor Green }
'@
$InitContent | Out-File -FilePath $InitScriptPath -Encoding utf8
Write-Host "✅ Script gerado: init-workspace.ps1" -ForegroundColor Green

Write-Host "✨ Setup Finalizado com Sucesso!" -ForegroundColor Cyan
