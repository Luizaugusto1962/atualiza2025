#!/usr/bin/env bash
#
# SISTEMA SAV - Script de Atualizaçao Modular
# Versao: 10/10/2025-00
# Autor: Luiz Augusto
# Email: luizaugusto@sav.com.br
#
UPDATE="${UPDATE:-}"

# Versão do sistema
UPDATE="03/10/2024-00"
readonly UPDATE
cd ..
# Diretório do script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR

LIB_DIR="${SCRIPT_DIR}/libs"
readonly LIB_DIR

LIB_CFG="${SCRIPT_DIR}/cfg"
readonly LIB_CFG

# Verificar se o diretório lib existe
if [[ ! -d "${LIB_DIR}" ]]; then
    echo "ERRO: Diretório ${LIB_DIR} nao encontrado."
    echo "Certifique-se de que todos os módulos estao instalados corretamente."
    exit 1
fi
# Verificar se o diretório cfg existe
if [[ ! -d "${LIB_CFG}" ]]; then
    echo "ERRO: Diretório ${LIB_CFG} nao encontrado."
    echo "Certifique-se de que todos os arquivos de configuracao estao instalados corretamente."
    exit 1
fi

# Funçao para carregar módulos com verificaçao
_carregar_modulo() {
    local modulo="$1"
    local caminho="${LIB_DIR}/${modulo}"
    if [[ ! -f "${caminho}" ]]; then
        echo "ERRO: Modulo ${modulo} nao encontrado em ${caminho}"
        exit 1
    fi
    
    if [[ ! -r "${caminho}" ]]; then
        echo "ERRO: Modulo ${modulo} nao pode ser lido"
        exit 1
    fi
    
    # shellcheck source=/dev/null
    "." "${caminho}"
}

# Carregamento sequencial dos módulos (ordem importante)
_carregar_modulo "utils.sh"      # Utilitários básicos primeiro
_carregar_modulo "config.sh"     # Configurações
_carregar_modulo "lembrete.sh"   # Sistema de lembretes
_carregar_modulo "rsync.sh"      # Operações de rede
_carregar_modulo "sistema.sh"    # Informações do sistema
_carregar_modulo "arquivos.sh"   # Gestao de arquivos
_carregar_modulo "backup.sh"     # Sistema de backup
_carregar_modulo "programas.sh"  # Gestao de programas
_carregar_modulo "biblioteca.sh" # Gestao de biblioteca
_carregar_modulo "menus.sh"      # Sistema de menus por último

# Funçao principal de inicializaçao
_inicializar_sistema() {
    # Log de início da inicialização
    _log "=== INICIANDO SISTEMA SAV ==="

    # Carregar e validar configurações
    _log "Carregando configurações..."
    _carregar_configuracoes

    # Verificar dependências críticas
    _log "Verificando dependências do sistema..."
    _check_instalado

    # Validar diretórios essenciais
    _log "Validando diretórios do sistema..."
    _validar_diretorios

    # Configurar ambiente
    _log "Configurando ambiente..."
    _configurar_ambiente

    # Executar limpeza automática diária
    _log "Executando limpeza automática diária..."
    _executar_expurgador_diario

    _log "Inicialização concluída com sucesso"
}

# Funçao principal do programa
main() {
    # Tratamento de sinais para limpeza
    trap '_resetando' EXIT INT TERM
    
    # Inicializar sistema
    _inicializar_sistema
    
    # Mostrar notas se existirem
    _mostrar_notas_iniciais
    
    # Executar menu principal
    _principal
}

# Verificar se está sendo executado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi