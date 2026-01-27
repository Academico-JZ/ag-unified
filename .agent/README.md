# 🌌 Antigravity Kit (JZ e RM Edition)

> **A fusão definitiva entre o `Awesome Skills` e o `Antigravity Kit`. 255+ Skills, 20 Agentes e 11+ Workflows em um único ambiente de alta performance.**

---

## 🐣 O que é este Kit?

Este repositório é uma versão consolidada e otimizada do ecossistema Antigravity. Ele combina a vasta biblioteca de habilidades (skills) da comunidade com a orquestração multi-agente para transformar seu assistente de IA em uma agência digital completa.

**Diferenciais desta versão:**
- ✅ **Portabilidade Total:** Scripts refatorados para funcionar em qualquer máquina sem caminhos fixos.
- ✅ **Sem Dependência de Git:** Sincronização automática via download de ZIP para ambientes restritos.
- ✅ **Híbrido (PowerShell + Node):** Comandos nativos para Windows ou via NPM para devs web.

---

## 🚀 Instalação Rápida (Escolha a sua)

### Opção A: PowerShell One-Liner (Recomendado para Windows)
Não requer Git nem Node.js instalado.
```powershell
powershell -c "irm https://raw.githubusercontent.com/Academico-JZ/antigravity-jz-rm/main/install.ps1 | iex"
```

### Opção B: Via NPM (Para Web Devs)
Se você já tem o Node.js instalado:
```bash
npx github:Academico-JZ/antigravity-jz-rm init
```
*(Nota: Este comando instala e configura o Kit Global em seu diretório de usuário)*

---

## 🏗️ Como vincular a um novo projeto

1. Vá para a pasta do seu projeto.
2. Execute o script de linkagem:
   ```powershell
   powershell -ExecutionPolicy Bypass -File "$env:USERPROFILE\.gemini\antigravity\kit\scripts\setup_workspace.ps1"
   ```
3. No seu chat com a IA (Gemini/Claude Code/Cursor), peça:
   > "Leia o arquivo `.agent/GEMINI.md` para ativar suas novas capacidades."

---

## 🛠️ Comandos Slash (Workflows)

| Comando | Descrição |
| :--- | :--- |
| `/plan` | Cria um plano técnico detalhado sem escrever código. |
| `/brainstorm` | Processo de discovery socrático para validar ideias. |
| `/create` | Orquestra a criação de uma nova aplicação do zero. |
| `/debug` | Modo de depuração sistemática com análise de causa raiz. |
| `/ui-ux-pro-max` | Foco em estética premium e animações. |

---

## 🔄 Sincronização

Mantenha suas skills sempre atualizadas baixando as novidades dos repositórios originais:
```bash
python .agent/scripts/sync_kits.py
```

### 🛡️ Identity Guard (Proteção de Identidade)
O sincronizador usa **Merge Seletivo**: adiciona skills novas sem deletar ou sobrescrever suas customizações. Arquivos core como `GEMINI.md` são **protegidos automaticamente**.

---

## 🔧 Recursos de Resiliência

| Feature | Descrição |
| :--- | :--- |
| **Socket Inactivity Timeout** | Só falha se não houver tráfego por 20s (conexões lentas funcionam). |
| **Retry Automático** | 3 tentativas de download antes de desistir. |
| **Feedback de Velocidade** | Exibe KB/s em tempo real durante o download. |

---

## 🤝 Créditos
Inspirado pelos trabalhos de **[sickn33](https://github.com/sickn33)** e **[vudovn](https://github.com/vudovn)**.
Refatorado e modularizado por **[Academico-JZ](https://github.com/Academico-JZ)** e **[RMMeurer](https://github.com/rmmeurer)**.

> Este projeto opera sob a licença MIT, respeitando as liberdades dos códigos originais.
