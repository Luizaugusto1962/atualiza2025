#!/usr/bin/env bash
#
# cadastro.sh - Programa de Cadastro de Usuario
# Permite cadastrar usuarios e senhas para o sistema SAV
#
# SISTEMA SAV - Script de Atualizacao Modular
# Versao: 06/03/2026-01
# Autor: Luiz Augusto
#
#
# Variaveis globais esperadas
cfg_dir="${cfg_dir:-}"                 # Diretorio de configuracao
lib_dir="${lib_dir:-}"                 # Diretorio de modulos de biblioteca

# Diretorio do script principal
TOOLS_DIR="${TOOLS_DIR:-$(dirname "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)")}"

# Diretorios dos modulos e configuracoes
lib_dir="${lib_dir:-${TOOLS_DIR}/libs}"       # Diretorio dos modulos de biblioteca
cfg_dir="${cfg_dir:-${TOOLS_DIR}/cfg}"  

# Carregar modulos necessarios
"." "${lib_dir}/utils.sh" 2>/dev/null || { echo "Erro: utils.sh nao encontrado."; exit 1; }
"." "${lib_dir}/auth.sh" 2>/dev/null || { echo "Erro: auth.sh nao encontrado."; exit 1; }

# Funcao principal
main() {
    tput clear
    printf "\n"
    _linha "=" "${GREEN}"
    _mensagec "${RED}" "Cadastro de Usuario - Sistema SAV"
    _linha "=" "${GREEN}"
    printf "\n"

    _cadastrar_usuario
}

# Executar
main "$@"