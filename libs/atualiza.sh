#!/usr/bin/env bash
#
# SISTEMA SAV - Script de Atualizaçao Modular
# Versao: 18/09/2025-00
# Autor: Luiz Augusto
# Email: luizaugusto@sav.com.br
#

#set -euo pipefail
export LC_ALL=C

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR

# Diretório do script tools
TOOLS_DIR="${SCRIPT_DIR}/libs"
readonly TOOLS_DIR

# Verifica se o diretório tools existe
if [[ ! -d "${TOOLS_DIR}" ]]; then
    echo "ERRO: Diretório ${TOOLS_DIR} nao encontrado."
    exit 1
fi

# Verifica se o arquivo tools.sh existe
if [[ ! -f "${TOOLS_DIR}/principal.sh" ]]; then
    echo "ERRO: Arquivo ${TOOLS_DIR}/tools.sh nao encontrado."
    exit 1
fi

# Carrega a rotina _atualiza do tools.sh
cd "${TOOLS_DIR}" || exit 1
./principal.sh
