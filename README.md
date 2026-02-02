# AG-UNIFIED - Antigravity Kit Modular

> Arquitetura agêntica modular que combina [antigravity-kit](https://github.com/vudovn/antigravity-kit) + [antigravity-awesome-skills](https://github.com/sickn33/antigravity-awesome-skills) com customizações próprias.

## 🚀 Quick Start (Recomendado)

### Opção 1: Via PowerShell (One-line)
Basta rodar este bloco. Ele instala tudo (Agents + 600 Skills + Config):
```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Academico-JZ/ag-unified/main/setup.ps1" -OutFile "setup.ps1"; .\setup.ps1
```

### Opção 2: Via Git Clone
Se você prefere clonar o repositório para ter controle de versão:
```bash
git clone https://github.com/Academico-JZ/ag-unified.git
cd ag-unified
.\setup.ps1
```
*O script detecta automaticamente que está rodando dentro do repo e configura os links.*

---\

## 📁 Estrutura

```
ag-unified/
├── setup.ps1              # Script principal (Self-healing & Idempotente)
├── custom/
│   ├── GEMINI.md          # Regras customizadas do AI
│   └── overrides/         # Sobrescritas de skills/agents
└── scripts/
    ├── init-workspace.ps1 # Cria junction em workspace (Portátil)
    └── update.ps1         # Atualiza dos repos upstream
```

---

## 📊 Assets

| Source | Type | Count |
|--------|------|-------|
| antigravity-kit | Agents | 20 |
| antigravity-awesome-skills | Skills | 600+ |
| ag-unified | Custom Rules | 1 |

---

## 🔧 Scripts

| Script | Função |
|--------|--------|
| `setup.ps1` | Instalação completa, robusta e idempotente (Kit + Skills + Custom) |
| `scripts/init-workspace.ps1` | Cria junction local (funciona em qualquer pasta) |
| `scripts/update.ps1` | Atualiza todo o ambiente (puxa setup.ps1 e roda) |

---

## 📝 Customizações

O arquivo `custom/GEMINI.md` contém:
- Sequential Thinking Protocol
- User Profile (SysAdmin/DevOps)
- Socratic Gate rules
- Agent routing preferences
