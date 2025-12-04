#!/usr/bin/env bash
#
# Atualiza.sh - Script de Atualizacao Modular do SISTEMA SAV
# SISTEMA SAV - Script de Atualizacao Modular
# Versao: 04/12/2025-00
# Autor: Luiz Augusto

set -euo pipefail
export LC_ALL=C

# Verificacoes basicas
if [[ ! -t 0 && ! -p /dev/stdin ]]; then
    echo "Este script deve ser executado interativamente" >&2
    exit 1
fi
TOOLS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Diretorio do script TOOLS_DIR
PLIBS_DIR="${TOOLS_DIR}/libs"
readonly PLIBS_DIR TOOLS_DIR 

# Verifica se o diretorio libs existe
if [[ ! -d "${PLIBS_DIR}" ]]; then
    echo "ERRO: Diretorio ${PLIBS_DIR} nao encontrado."
    exit 1
fi

# Verifica se o arquivo principal.sh existe
if [[ -f "${PLIBS_DIR}/principal.sh" ]]; then
    echo "Carregando utilitario..."
    # Carrega o script principal
    cd "${PLIBS_DIR}" || exit 1
    "./principal.sh"
else
    echo "ERRO: Arquivo ${PLIBS_DIR}/principal.sh nao encontrado."
fi