# AG-JZ - Antigravity Kit Modular

> Arquitetura agêntica modular que combina [antigravity-kit](https://github.com/vudovn/antigravity-kit) + [antigravity-awesome-skills](https://github.com/sickn33/antigravity-awesome-skills) com customizações próprias.

## 🚀 Quick Start

### Windows (PowerShell)
```powershell
# Download e executa setup
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Academico-JZ/ag-jz/main/setup.ps1" -OutFile "setup.ps1"
.\setup.ps1
```

### Manual
```powershell
# 1. Instala ag-kit base
npm install -g @vudovn/ag-kit
ag-kit init

# 2. Aplica customizações
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Academico-JZ/ag-jz/main/custom/GEMINI.md" -OutFile ".agent\GEMINI.md"
```

---

## 📁 Estrutura

```
ag-jz/
├── setup.ps1              # Script de instalação modular
├── custom/
│   ├── GEMINI.md          # Regras customizadas do AI
│   └── overrides/         # Sobrescritas de skills/agents
└── scripts/
    ├── init-workspace.ps1 # Cria junction em workspace
    └── update.ps1         # Atualiza dos repos upstream
```

---

## 🔄 Arquitetura Modular

```
┌─────────────────────────────────────────────────────────┐
│                    ag-jz (seu repo)                     │
│  • GEMINI.md customizado                                │
│  • Scripts de setup                                     │
│  • Overrides específicos                                │
└────────────────────────┬────────────────────────────────┘
                         │ merge
┌────────────────────────┴────────────────────────────────┐
│              antigravity-kit (upstream)                 │
│  • 20 Agents                                            │
│  • Workflows                                            │
│  • Scripts base                                         │
└────────────────────────┬────────────────────────────────┘
                         │ merge
┌────────────────────────┴────────────────────────────────┐
│          antigravity-awesome-skills (upstream)          │
│  • 36 Skills                                            │
└─────────────────────────────────────────────────────────┘
```

---

## 📊 Assets

| Source | Type | Count |
|--------|------|-------|
| antigravity-kit | Agents | 20 |
| antigravity-kit | Workflows | 11 |
| antigravity-awesome-skills | Skills | 36 |
| ag-jz | Custom Rules | 1 |

---

## 🔧 Scripts

| Script | Função |
|--------|--------|
| `setup.ps1` | Instalação completa em nova máquina |
| `scripts/init-workspace.ps1` | Cria junction em workspace |
| `scripts/update.ps1` | Atualiza dos repos upstream |

---

## 📝 Customizações

O arquivo `custom/GEMINI.md` contém:
- Sequential Thinking Protocol
- User Profile (SysAdmin/DevOps)
- Socratic Gate rules
- Agent routing preferences
