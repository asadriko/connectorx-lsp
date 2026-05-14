#!/usr/bin/env bash
# Publica connectorx-lsp nos 2 marketplaces (Visual Studio Marketplace + Open VSX).
#
# Uso:
#   export VSCE_PAT=<token-azure-devops>
#   export OVSX_PAT=<token-openvsx>
#   ./publish.sh                 # empacota + publica nos dois
#   ./publish.sh --dry-run       # só empacota e valida (não publica)
#   ./publish.sh --marketplace   # só Visual Studio Marketplace
#   ./publish.sh --openvsx       # só Open VSX
#   ./publish.sh --package-only  # só gera o .vsix
#
# Documentação: ~/.claude/skills/senior-lsp/extension-publish.md
set -euo pipefail

# ============================================================================
# Helpers
# ============================================================================
RED='\033[0;31m'; GRN='\033[0;32m'; YLW='\033[0;33m'; BLU='\033[0;34m'; NC='\033[0m'
say()  { echo -e "${BLU}▶${NC} $*"; }
ok()   { echo -e "${GRN}✓${NC} $*"; }
warn() { echo -e "${YLW}⚠${NC} $*"; }
die()  { echo -e "${RED}✗${NC} $*" >&2; exit 1; }

# ============================================================================
# Flags
# ============================================================================
MODE="all"
for arg in "$@"; do
  case "$arg" in
    --dry-run)      MODE="dry-run" ;;
    --marketplace)  MODE="marketplace" ;;
    --openvsx)      MODE="openvsx" ;;
    --package-only) MODE="package-only" ;;
    -h|--help)
      grep '^#' "$0" | sed 's/^# \?//; 1d'; exit 0 ;;
    *) die "flag desconhecida: $arg (use --help)" ;;
  esac
done

# ============================================================================
# 1. Ambiente: ir para a pasta da extensão, checar ferramentas
# ============================================================================
cd "$(dirname "$(readlink -f "$0")")"
say "Pasta de trabalho: $(pwd)"

command -v vsce >/dev/null || die "vsce não está instalado. Rode: npm install -g @vscode/vsce"
command -v ovsx >/dev/null || die "ovsx não está instalado. Rode: npm install -g ovsx"
command -v python3 >/dev/null || die "python3 não disponível"
command -v jq >/dev/null 2>&1 || warn "jq ausente — alguns checks usam python3 como fallback"

# ============================================================================
# 2. Validação dos JSONs (rápida — vsce também valida, mas dá erro melhor aqui)
# ============================================================================
say "Validando JSONs…"
python3 -c "import json; json.load(open('package.json'))" || die "package.json inválido"
python3 -c "import json; json.load(open('snippets/lsp.json'))" || die "snippets/lsp.json inválido"
python3 -c "import json; json.load(open('syntaxes/lsp.tmLanguage.json'))" || die "syntaxes/lsp.tmLanguage.json inválido"
ok "Todos os JSONs validam"

# ============================================================================
# 3. Lê versão declarada
# ============================================================================
VER=$(python3 -c "import json; print(json.load(open('package.json'))['version'])")
NAME=$(python3 -c "import json; print(json.load(open('package.json'))['name'])")
PUB=$(python3 -c "import json; print(json.load(open('package.json'))['publisher'])")
say "Pacote: ${PUB}.${NAME}@${VER}"

# ============================================================================
# 4. CHANGELOG tem entrada para essa versão?
# ============================================================================
if ! grep -qE "^##.*\b${VER}\b" CHANGELOG.md; then
  warn "CHANGELOG.md não tem entrada para versão ${VER}. Continuar mesmo assim? [y/N]"
  if [[ "$MODE" != "dry-run" && "$MODE" != "package-only" ]]; then
    read -r ans
    [[ "$ans" == "y" || "$ans" == "Y" ]] || die "Abortado pelo usuário"
  fi
fi

# ============================================================================
# 5. Limpa .vsix antigos
# ============================================================================
rm -f ./*.vsix

# ============================================================================
# 6. Empacota
# ============================================================================
say "Empacotando…"
vsce package --no-yarn
VSIX=$(ls ./*.vsix | tail -1)
[ -f "$VSIX" ] || die "vsce não gerou .vsix"
SIZE=$(du -h "$VSIX" | cut -f1)
ok "Pacote gerado: $VSIX ($SIZE)"

# Sanity check do tamanho — se passou de 1MB, provavelmente tem lixo no pacote
SIZE_BYTES=$(stat -c%s "$VSIX")
if (( SIZE_BYTES > 1048576 )); then
  warn "Pacote >1MB. Revise .vscodeignore — pode estar incluindo coisa que não devia."
fi

if [[ "$MODE" == "dry-run" || "$MODE" == "package-only" ]]; then
  ok "Dry-run completo. Pacote em $VSIX (não publicado)."
  echo
  echo "Para testar local: copie o .vsix e use 'Extensions: Install from VSIX' no Antigravity/VSCode."
  exit 0
fi

# ============================================================================
# 7. Publicação Marketplace (Microsoft)
# ============================================================================
if [[ "$MODE" == "all" || "$MODE" == "marketplace" ]]; then
  [ -n "${VSCE_PAT:-}" ] || die "VSCE_PAT não definido. Veja extension-publish.md seção Tokens."
  say "Publicando no Visual Studio Marketplace…"
  vsce publish -p "$VSCE_PAT" --packagePath "$VSIX"
  ok "Publicado: https://marketplace.visualstudio.com/items?itemName=${PUB}.${NAME}"
fi

# ============================================================================
# 8. Publicação Open VSX (Eclipse Foundation)
# ============================================================================
if [[ "$MODE" == "all" || "$MODE" == "openvsx" ]]; then
  [ -n "${OVSX_PAT:-}" ] || die "OVSX_PAT não definido. Veja extension-publish.md seção Tokens."
  say "Publicando no Open VSX…"
  ovsx publish "$VSIX" -p "$OVSX_PAT"
  ok "Publicado: https://open-vsx.org/extension/${PUB,,}/${NAME}"
fi

# ============================================================================
# 9. Sumário
# ============================================================================
echo
echo "============================================================"
echo "  ${GRN}✓${NC} ${PUB}.${NAME}@${VER} publicado"
echo "============================================================"
echo "  Marketplace:  https://marketplace.visualstudio.com/items?itemName=${PUB}.${NAME}"
echo "  Open VSX:     https://open-vsx.org/extension/${PUB,,}/${NAME}"
echo "============================================================"
echo
echo "Próximo passo: aguarde 2-5min para os marketplaces indexarem,"
echo "depois rode 'Extensions: Update' no Antigravity/VSCode."
