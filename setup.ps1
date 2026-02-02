# Setup Antigravity Unified (Universal & Automatic)
# Usage: .\setup.ps1 [-Force]
param([switch]$Force)

$ErrorActionPreference = "Stop"
$CurrentPath = $PSScriptRoot
$RepoOwner = "Academico-JZ"
$RepoName = "ag-unified"
$Branch = "main"

# LOCALIZAÇÃO CENTRAL DEFINIDA
$CentralPath = "$env:USERPROFILE\.gemini\antigravity"
$CentralAgent = "$CentralPath\.agent"

Write-Host "`n🚀 AG-UNIFIED: AUTOMATIC SETUP" -ForegroundColor Cyan

# --- LÓGICA DE ROTEAMENTO AUTOMÁTICO ---

# 1. Verificar se estamos rodando fora da central (MODO WORKSPACE)
if ($CurrentPath -ne $CentralPath) {
    Write-Host "📂 Modo Workspace Detectado (Linking)..." -ForegroundColor Yellow
    
    # Verificar se a central existe
    if (-not (Test-Path $CentralAgent)) {
        Write-Host "❌ Erro: Central não encontrada em $CentralPath" -ForegroundColor Red
        Write-Host "   Por favor, instale primeiro na central usando o comando Quick Start do README." -ForegroundColor Gray
        exit 1
    }

    $TargetAgent = Join-Path $CurrentPath ".agent"
    
    # Tratar link existente
    if (Test-Path $TargetAgent) {
        if ((Get-Item $TargetAgent).Attributes -band [IO.FileAttributes]::ReparsePoint) {
            Write-Host "✅ Link (Junction) já existe neste workspace." -ForegroundColor Green
            exit 0
        }
        Write-Host "⚠️  Havia uma pasta .agent real. Removendo para criar o link..." -ForegroundColor Gray
        Remove-Item $TargetAgent -Recurse -Force
    }

    # Criar Junction AUTOMÁTICO
    Write-Host "🔗 Criando link automático para a central..." -ForegroundColor Cyan
    cmd /c mklink /J "$TargetAgent" "$CentralAgent" | Out-Null
    
    if (Test-Path $TargetAgent) {
        Write-Host "✅ Workspace vinculado com sucesso! O AI agora tem acesso a 600+ skills." -ForegroundColor Green
    } else {
        Write-Host "❌ Falha ao criar link. Tente rodar como Administrador." -ForegroundColor Red
    }
    exit 0
}

# --- MODO INSTALAÇÃO CENTRAL (Apenas se estiver em $CentralPath) ---

Write-Host "🧠 Modo Central (Brain Center) Detectado..." -ForegroundColor Yellow

# 1. Instalar ag-kit
if (-not (Test-Path "$CentralAgent\agents") -or $Force) {
    Write-Host "📦 Instalando Base..." -ForegroundColor Yellow
    try {
        npm install -g @vudovn/ag-kit 2>$null
        ag-kit init
    } catch {
        Invoke-WebRequest "https://github.com/vudovn/antigravity-kit/archive/refs/heads/main.zip" -OutFile "kit.zip"
        Expand-Archive "kit.zip" -DestinationPath "." -Force
        if (-not (Test-Path ".agent")) { New-Item -ItemType Directory -Path ".agent" | Out-Null }
        Copy-Item "antigravity-kit-main\.agent\*" ".agent" -Recurse -Force
        Remove-Item "kit.zip", "antigravity-kit-main" -Recurse -Force
    }
}

# 2. Instalar Skills
$SkillsDest = "$CentralAgent\skills"
if (-not (Test-Path $SkillsDest) -or (Get-ChildItem $SkillsDest).Count -lt 50 -or $Force) {
    Write-Host "⚡ Baixando 600+ Skills..." -ForegroundColor Yellow
    $SkillsZip = "$CurrentPath\skills.zip"
    $SkillsUrl = "https://github.com/sickn33/antigravity-awesome-skills/archive/refs/tags/v4.6.0.zip"
    Invoke-WebRequest -Uri $SkillsUrl -OutFile $SkillsZip
    try { tar -xf $SkillsZip 2>$null } catch { Expand-Archive $SkillsZip -DestinationPath "." -Force }
    
    if (-not (Test-Path $SkillsDest)) { New-Item -ItemType Directory -Path $SkillsDest -Force | Out-Null }
    Get-ChildItem "$CurrentPath\antigravity-awesome-skills-4.6.0\skills" | Move-Item -Destination $SkillsDest -Force
    Remove-Item $SkillsZip, "$CurrentPath\antigravity-awesome-skills-4.6.0" -Recurse -Force -ErrorAction SilentlyContinue
}

# 3. GEMINI.md Sync
Write-Host "🛠️ Sincronizando GEMINI.md..." -ForegroundColor Yellow
$CustomUrl = "https://raw.githubusercontent.com/$RepoOwner/$RepoName/$Branch/custom/GEMINI.md"
try {
    Invoke-WebRequest -Uri $CustomUrl -OutFile "$CentralAgent\GEMINI.md"
    Copy-Item "$CentralAgent\GEMINI.md" "$env:USERPROFILE\.gemini\GEMINI.md" -Force
    Write-Host "✅ Configurações aplicadas globalmente." -ForegroundColor Green
} catch {
    Write-Host "⚠️  Falha ao baixar GEMINI.md remoto. Usando local." -ForegroundColor Gray
}

Write-Host "`n✨ CENTRAL BRAIN PRONTA! 🎉" -ForegroundColor Green
Write-Host "Agora rode este script dentro de qualquer projeto para vinculá-lo dinamicamente." -ForegroundColor Gray
