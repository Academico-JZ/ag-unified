# AG-JZ - Antigravity Kit Modular

> Arquitetura agêntica modular que combina [antigravity-kit](https://github.com/vudovn/antigravity-kit) + [antigravity-awesome-skills](https://github.com/sickn33/antigravity-awesome-skills) com customizações próprias.

## 🚀 Quick Start (Recomendado)

### Windows (PowerShell)
Basta rodar este bloco. Ele instala tudo (Agents + 600 Skills + Config):
```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Academico-JZ/ag-jz/main/setup.ps1" -OutFile "setup.ps1"; .\setup.ps1
```

---

## 📁 Estrutura

```
ag-jz/
├── setup.ps1              # Script principal (Self-healing)
├── custom/
│   ├── GEMINI.md          # Regras customizadas do AI
│   └── overrides/         # Sobrescritas de skills/agents
└── scripts/
    ├── init-workspace.ps1 # Cria junction em workspace
    └── update.ps1         # Atualiza dos repos upstream
```

---

## 📊 Assets

| Source | Type | Count |
|--------|------|-------|
| antigravity-kit | Agents | 20 |
| antigravity-awesome-skills | Skills | 600+ |
| ag-jz | Custom Rules | 1 |

---

## 🔧 Scripts

| Script | Função |
|--------|--------|
| `setup.ps1` | Instalação completa (Kit + Skills + Custom) |
| `scripts/init-workspace.ps1` | Cria junction em workspace |
| `scripts/update.ps1` | Atualiza dos repos upstream |

---

## 📝 Customizações

O arquivo `custom/GEMINI.md` contém:
- Sequential Thinking Protocol
- User Profile (SysAdmin/DevOps)
- Socratic Gate rules
- Agent routing preferences
