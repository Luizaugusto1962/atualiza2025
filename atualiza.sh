#!/usr/bin/env bash
#
# SISTEMA SAV - Script de Atualizaçao Modular
# Versao: 10/10/2025-00
# Autor: Luiz Augusto
# Email: luizaugusto@sav.com.br
#

set -euo pipefail
export LC_ALL=C

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Diretório do script tools
LIBS_DIR="${SCRIPT_DIR}/libs"
readonly LIBS_DIR SCRIPT_DIR

# Verifica se o diretório libs existe
if [[ ! -d "${LIBS_DIR}" ]]; then
    echo "ERRO: Diretório ${LIBS_DIR} nao encontrado."
    exit 1
fi

# Verifica se o arquivo principal.sh existe
if [[ ! -f "${LIBS_DIR}/principal.sh" ]]; then
    echo "ERRO: Arquivo ${LIBS_DIR}/principal.sh nao encontrado."
    exit 1
fi

# Carrega o script principal
cd "${LIBS_DIR}" || exit 1
./principal.sh
