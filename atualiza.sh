#!/usr/bin/env bash
#
# SISTEMA SAV - Script de Atualizaçao Modular
# Versao: 10/10/2025-00
# Autor: Luiz Augusto
# Email: luizaugusto@sav.com.br
#

set -euo pipefail
export LC_ALL=C

PSCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Diretório do script tools
PLIBS_DIR="${PSCRIPT_DIR}/libs"
readonly PLIBS_DIR PSCRIPT_DIR 

# Verifica se o diretório libs existe
if [[ ! -d "${PLIBS_DIR}" ]]; then
    echo "ERRO: Diretório ${PLIBS_DIR} nao encontrado."
    exit 1
fi

# Verifica se o arquivo principal.sh existe
if [[ -f "${PLIBS_DIR}/principal.sh" ]]; then
    echo "Carregando utilitario..."
## Carrega o script principal
    cd "${PLIBS_DIR}" || exit 1
    ./"principal.sh"
else
    echo "ERRO: Arquivo ${PLIBS_DIR}/principal.sh nao encontrado."
fi
