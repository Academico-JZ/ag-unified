# Setup Antigravity JZ (Robust Fix)
# Usage: .\setup.ps1 [-Force]
param([switch]$Force)

$ErrorActionPreference = "Stop"
$ScriptPath = $PSScriptRoot
$InstallPath = $ScriptPath
$RepoOwner = "Academico-JZ"
$RepoName = "ag-unified"
$Branch = "main"

Write-Host "🚀 Iniciando Setup Modular Academico-JZ ($RepoName)..." -ForegroundColor Cyan

# 0. Verificar se já é um Workspace Linkado (Junction)
$AgentPath = "$InstallPath\.agent"
if (Test-Path $AgentPath) {
    if ((Get-Item $AgentPath).Attributes -band [IO.FileAttributes]::ReparsePoint) {
        Write-Host "✅ Este diretório já possui um link para o Brain (.agent atalho)." -ForegroundColor Green
        Write-Host "   Nenhuma instalação necessária aqui." -ForegroundColor Gray
        exit 0
    }
}

# 1. Instalar AG-KIT (Base)
if (-not (Test-Path "$AgentPath\agents") -or $Force) {
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
} else { Write-Host "✅ Base já instalada." -ForegroundColor Green }

# 2. Instalar Skills (Método Robusto Zip+Tar)
$SkillsDest = "$AgentPath\skills"
$SkillsCount = 0; if (Test-Path $SkillsDest) { $SkillsCount = (Get-ChildItem $SkillsDest).Count }

if ($SkillsCount -lt 50 -or $Force) {
    Write-Host "⚡ Baixando Skills (600+)..." -ForegroundColor Yellow
    $SkillsZip = "$InstallPath\skills.zip"
    $SkillsUrl = "https://github.com/sickn33/antigravity-awesome-skills/archive/refs/tags/v4.6.0.zip"
    Invoke-WebRequest -Uri $SkillsUrl -OutFile $SkillsZip
    Write-Host "📂 Extraindo..." -ForegroundColor Yellow
    try { tar -xf $SkillsZip 2>$null } catch { Expand-Archive $SkillsZip -DestinationPath "." -Force }
    
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
    Remove-Item $SkillsZip, "$InstallPath\antigravity-awesome-skills-4.6.0" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "✅ Skills instaladas." -ForegroundColor Green
} else { Write-Host "✅ Skills já instaladas." -ForegroundColor Green }

# 3. Aplicar Customização
Write-Host "🛠️ Verificando atualizações do GEMINI.md..." -ForegroundColor Yellow
$CustomGeminiUrl = "https://raw.githubusercontent.com/$RepoOwner/$RepoName/$Branch/custom/GEMINI.md"

try {
    Invoke-WebRequest -Uri $CustomGeminiUrl -OutFile "$InstallPath\.agent\GEMINI.md"
    Write-Host "✅ Custom baixado de $RepoName." -ForegroundColor Green
} catch {
    Write-Host "⚠️  Falha ao baixar GEMINI.md de $RepoName. Verifique conexão." -ForegroundColor Red
}

$GlobalGemini = "$env:USERPROFILE\.gemini\GEMINI.md"
if (-not (Test-Path $GlobalGemini) -or $Force) {
    Write-Host "   Sobreescrevendo GEMINI.md GLOBAL" -ForegroundColor Yellow
    Copy-Item "$InstallPath\.agent\GEMINI.md" $GlobalGemini -Force
}

# 4. Gerar Script de Inicialização (Self-contained)
$InitScriptPath = "$InstallPath\.agent\scripts\init-workspace.ps1"
if (-not (Test-Path $InitScriptPath) -or $Force) {
    Write-Host "🔌 Gerando script de workspace..." -ForegroundColor Yellow
    if (-not (Test-Path (Split-Path $InitScriptPath))) { New-Item -ItemType Directory -Path (Split-Path $InitScriptPath) -Force | Out-Null }
    
    $InitContent = @'
param([string]$WorkspacePath)
$ErrorActionPreference = "Stop"
$RepoRoot = Resolve-Path "$PSScriptRoot\..\.." | Select-Object -ExpandProperty Path
$AgentSource = Join-Path $RepoRoot ".agent"
$AgentTarget = Join-Path $WorkspacePath ".agent"

Write-Host "`n🔗 LINKING WORKSPACE: $WorkspacePath" -ForegroundColor Cyan
if (Test-Path $AgentTarget) {
    try {
        if ((Get-Item $AgentTarget).Attributes -band [IO.FileAttributes]::ReparsePoint) { Write-Host "✅ Junction exists."; exit 0 }
        Remove-Item $AgentTarget -Recurse -Force
    } catch { Write-Host "❌ Error accessing target."; exit 1 }
}
try { cmd /c mklink /J "$AgentTarget" "$AgentSource" | Out-Null; Write-Host "✅ Success!" -ForegroundColor Green }
catch { Write-Host "❌ Failed. Run as Admin?" -ForegroundColor Red }
'@
    $InitContent | Out-File -FilePath $InitScriptPath -Encoding utf8
}

Write-Host "✨ Setup Finalizado!" -ForegroundColor Cyan
