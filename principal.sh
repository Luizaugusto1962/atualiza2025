#!/usr/bin/env bash
#
# SISTEMA SAV - Script de Atualizacao Modular
# Versao: 04/12/2025-00
# Autor: Luiz Augusto
# Email: luizaugusto@sav.com.br
#
# Versao do sistema
readonly UPDATE="24/11/2025-00"
export UPDATE

# Diretorio do script principal
TOOLS_DIR="$(dirname "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)")"

# Diretorios dos modulos e configuracoes
lib_dir="${TOOLS_DIR}/libs"
cfg_dir="${TOOLS_DIR}/cfg"
export TOOLS_DIR lib_dir cfg_dir

# Verificar se o diretorio lib existe
if [[ ! -d "${lib_dir}" ]]; then
    echo "ERRO: Diretorio ${lib_dir} nao encontrado."
    echo "Certifique-se de que todos os modulos estao instalados corretamente."
    exit 1
fi
# Verificar se o diretorio cfg existe
if [[ ! -d "${cfg_dir}" ]]; then
    echo "ERRO: Diretorio ${cfg_dir} nao encontrado."
    echo "Certifique-se de que todos os arquivos de configuracao estao instalados corretamente."
    exit 1
fi

# Funcao para carregar modulos com verificacao
_carregar_modulo() {
    local modulo="$1"
    local caminho="${lib_dir}/${modulo}"
    if [[ ! -f "${caminho}" ]]; then
        echo "ERRO: Modulo ${modulo} nao encontrado em ${caminho}"
        exit 1
    fi
    
    if [[ ! -r "${caminho}" ]]; then
        echo "ERRO: Modulo ${modulo} nao pode ser lido"
        exit 1
    fi
    
    # shellcheck source=/dev/null
    if ! source "${caminho}"; then
        echo "ERRO: Falha ao carregar modulo ${modulo}"
        exit 1
    fi
}

# Carregamento sequencial dos modulos (ordem importante)
_carregar_modulo "utils.sh"      # Utilitarios basicos primeiro
_carregar_modulo "config.sh"     # Configuracoes
_carregar_modulo "lembrete.sh"   # Sistema de lembretes
_carregar_modulo "rsync.sh"      # Operacoes de rede
_carregar_modulo "sistema.sh"    # Informacoes do sistema
_carregar_modulo "arquivos.sh"   # Gestao de arquivos
_carregar_modulo "backup.sh"     # Sistema de backup
_carregar_modulo "programas.sh"  # Gestao de programas
_carregar_modulo "biblioteca.sh" # Gestao de biblioteca
_carregar_modulo "menus.sh"      # Sistema de menus por último

# Funcao principal de inicializacao
_inicializar_sistema() {
    # Carregar e validar configuracoes
    _carregar_configuracoes
    
    # Verificar dependências
    _check_instalado

    # Validar diretorios
    _validar_diretorios
    
    # Configurar ambiente
    _configurar_ambiente
    
    # Executar limpeza automatica diaria
    _executar_expurgador_diario
}

# Funcao principal do programa
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

# Verificar se esta sendo executado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi