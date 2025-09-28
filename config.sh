#!/usr/bin/env bash
#
# config.sh - Módulo de Configurações e Validações
# Responsável por carregar configurações, validar sistema e definir variáveis globais
#

# Versão do sistema
UPDATE="18/09/2025-00"

#---------- VARIÁVEIS GLOBAIS ----------#

# Arrays para organização das variáveis
declare -a cores=(RED GREEN YELLOW BLUE PURPLE CYAN NORM)
declare -a caminhos_base=(BASE1 BASE2 BASE3 tools DIR destino pasta base base2 base3 logs exec class telas xml olds progs backup sistema TEMPS UMADATA DIRB ENVIABACK ENVBASE SERACESOFF E_EXEC T_TELAS X_XML)
declare -a biblioteca=(SAVATU SAVATU1 SAVATU2 SAVATU3 SAVATU4)
declare -a comandos=(cmd_unzip cmd_zip cmd_find cmd_who)
declare -a outros=(NOMEPROG PEDARQ prog PORTA USUARIO IPSERVER DESTINO2 VBACKUP ARQUIVO VERSAO ARQUIVO2 VERSAOANT INI SAVISC DEFAULT_UNZIP DEFAULT_ZIP DEFAULT_FIND DEFAULT_WHO DEFAULT_VERSAO VERSAO DEFAULT_ARQUIVO DEFAULT_PEDARQ DEFAULT_PROG DEFAULT_PORTA DEFAULT_USUARIO DEFAULT_IPSERVER DEFAULT_DESTINO2 UPDATE DEFAULT_PEDARQ jut JUTIL ISCCLIENT ISCCLIENTT SAVISCC)

#-VARIAVEIS do sistema ----------------------------------------------------------------------------#
#-Variaveis de configuracao do sistema ---------------------------------------------------------#
# Variaveis de configuracao do sistema que podem ser definidas pelo usuario.
# As variaveis com o prefixo "destino" sao usadas para definir o caminho
# dos diretorios que serao usados pelo programa.
destino="${destino:-}"       # Caminho do diretorio raiz do programa.
pasta="${pasta:-}"           # Caminho do diretorio onde estao os executaveis.
base="${base:-}"             # Caminho do diretorio da base de dados.
base2="${base2:-}"           # Caminho do diretorio da segunda base de dados.
base3="${base3:-}"           # Caminho do diretorio da terceira base de dados.
logs="${logs:-}"             # Caminho do diretorio dos arquivos de log.
exec="${exec:-}"             # Caminho do diretorio dos executaveis.
class="${class:-}"           # Extensao do programa compilando.
mclass="${mclass:-}"         # Extensao do programa compilando em modo debug.
telas="${telas:-}"           # Caminho do diretorio das telas.
xml="${xml:-}"               # Caminho do diretorio dos arquivos xml.
olds="${olds:-}"             # Caminho do diretorio dos arquivos de backup.
cfg="${cfg:-}"               # Caminho do diretorio dos arquivos de configuracao.
lib="${lib:-}"               # Caminho do diretorio das bibliotecas.
progs="${progs:-}"           # Caminho do diretorio dos programas.
backup="${backup:-}"         # Caminho do diretorio de backup.
sistema="${sistema:-}"       # Tipo de sistema que esta sendo usado (iscobol ou isam).
SAVATU="${SAVATU:-}"         # Caminho do diretorio da biblioteca do servidor da SAV.
SAVATU1="${SAVATU1:-}"       # Caminho do diretorio da biblioteca do servidor da SAV.
SAVATU2="${SAVATU2:-}"       # Caminho do diretorio da biblioteca do servidor da SAV.
SAVATU3="${SAVATU3:-}"       # Caminho do diretorio da biblioteca do servidor da SAV.
SAVATU4="${SAVATU4:-}"       # Caminho do diretorio da biblioteca do servidor da SAV.
verclass="${verclass:-}"     # Ano da versao
ENVIABACK="${ENVIABACK:-}"   # Variavel que define o caminho para onde sera enviado o backup.
VERSAO="${VERSAO:-}"         # Variavel que define a versao do programa.
INI="${INI:-}"               # Variavel que define o caminho do arquivo de configuracao do sistema.
SERACESOFF="${SERACESOFF:-}" # Variavel que define o caminho do diretorio do servidor off.
acessossh="${acessossh:-}" # Variavel que define o caminho do diretorio do servidor off.
VERSAOANT="${VERSAOANT:-}"   # Variavel que define a versao do programa anterior.
cmd_unzip="${cmd_unzip:-}"   # Comando para descompactar arquivos.
cmd_zip="${cmd_zip:-}"       # Comando para compactar arquivos.
cmd_find="${cmd_find:-}"     # Comando para buscar arquivos.
cmd_who="${cmd_who:-}"       # Comando para saber quem esta logado no sistema.
VBACKUP="${VBACKUP:-}"       # Variavel que define se sera realizado backup.
ARQUIVO="${ARQUIVO:-}"       # Variavel que define o nome do arquivo a ser baixado.
PEDARQ="${PEDARQ:-}"         # Variavel que define se sera realizado o pedido de arquivos.
prog="${prog:-}"             # Variavel que define o nome do programa a ser baixado.
PORTA="${PORTA:-}"           # Variavel que define a porta a ser usada para.
USUARIO="${USUARIO:-}"       # Variavel que define o usuario a ser usado.
IPSERVER="${IPSERVER:-}"     # Variavel que define o ip do servidor da SAV.
DESTINO2="${DESTINO2:-}"     # Variavel que define o caminho do diretorio da biblioteca do servidor da SAV.

# Configurações padrão
DEFAULT_UNZIP="unzip"
DEFAULT_ZIP="zip"
DEFAULT_FIND="find"
DEFAULT_WHO="who"
DEFAULT_PORTA="41122"
DEFAULT_USUARIO="atualiza"

# Diretórios de destino para diferentes tipos de biblioteca
export DESTINO2SERVER="/u/varejo/man/"
export DESTINO2SAVATUISC="/home/savatu/biblioteca/temp/ISCobol/sav-5.0/"
export DESTINO2SAVATUMF="/home/savatu/biblioteca/temp/Isam/sav-3.1"
export DESTINO2TRANSPC="/u/varejo/trans_pc/"

#---------- FUNÇÕES DE CONFIGURAÇÃO ----------#

# Função para definir cores do terminal
_definir_cores() {
    # Verificar se o terminal suporta cores
    if [[ -t 1 ]] && command -v tput >/dev/null 2>&1; then
        RED=$(tput bold)$(tput setaf 1)
        GREEN=$(tput bold)$(tput setaf 2)
        YELLOW=$(tput bold)$(tput setaf 3)
        BLUE=$(tput bold)$(tput setaf 4)
        PURPLE=$(tput bold)$(tput setaf 5)
        CYAN=$(tput bold)$(tput setaf 6)
        NORM=$(tput sgr0)
        COLUMNS=$(tput cols)
        
        # Limpar tela inicial
        tput clear
        tput bold
        tput setaf 7
    else
        # Terminal sem suporte a cores
        RED=""
        GREEN=""
        YELLOW=""
        BLUE=""
        PURPLE=""
        CYAN=""
        NORM=""
        readonly COLUMNS=80
    fi
    
    # Tornar as variáveis de cores somente leitura
    readonly RED GREEN YELLOW BLUE PURPLE CYAN NORM
}

# Verificar dependências do sistema
_check_instalado() {
    local app
    local missing=""
    
    for app in zip unzip rsync wget; do
        if ! command -v "$app" &>/dev/null; then
            missing="$missing $app"
            printf "\n%s" "${RED}"
            printf "%*s\n" $(((20 + COLUMNS) / 2)) "PROGRAMA NÃO ENCONTRADO: ${app}"
            printf "\n%s" "${NORM}"
            
            case "$app" in
                zip|unzip) echo "  Sugestão: Instale o zip e unzip." ;;
                rsync)     echo "  Sugestão: Instale o rsync." ;;
                wget)      echo "  Sugestão: Instale o wget." ;;
            esac
        fi
    done
    
    if [[ -n "$missing" ]]; then
        _mensagec "${YELLOW}" "Instale os programas ausentes ($missing) e tente novamente."
        exit 1
    fi
}

# Configurar comandos do sistema
_configurar_comandos() {
    # Comando para descompactar
    if [[ -z "${cmd_unzip}" ]]; then
        cmd_unzip="${DEFAULT_UNZIP}"
    fi
    
    # Comando para compactar
    if [[ -z "${cmd_zip}" ]]; then
        cmd_zip="${DEFAULT_ZIP}"
    fi
    
    # Comando para localizar arquivos
    if [[ -z "${cmd_find}" ]]; then
        cmd_find="${DEFAULT_FIND}"
    fi
    
    # Comando para verificar usuários
    if [[ -z "${cmd_who}" ]]; then
        cmd_who="${DEFAULT_WHO}"
    fi
    
    # Validar se os comandos existem
    for cmd in "$cmd_unzip" "$cmd_zip" "$cmd_find" "$cmd_who"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            printf "Erro: Comando %s não encontrado.\n" "$cmd"
            exit 1
        fi
    done
}

# Configurar diretórios do sistema
_configurar_diretorios() {
    cd .. || exit 1
    
    local raiz="/"
    destino="${raiz}${destino}"
    
    readonly TOOLS="${destino}${pasta}" # Diretório principal do sistema
    readonly CFG="${TOOLS}/cfg"  # Diretório de configuração centralizado 

    # Verificar diretório principal
    if [[ -n "${TOOLS}" ]] && [[ -d "${TOOLS}" ]]; then
        _mensagec "${CYAN}" "Diretório encontrado: ${TOOLS}"
        cd "${TOOLS}" || {
            printf "Erro: Não foi possível acessar %s\n" "${TOOLS}"
            exit 1
        }
    else
        printf "ERRO: Diretório %s não encontrado.\n" "${TOOLS}"
        exit 1
    fi
    
    # Criar diretório de configuração se não existir
    if [[ ! -d "${CFG}" ]]; then
        mkdir -p "${CFG}" || {
            printf "Erro ao criar diretório de configuração %s\n" "${CFG}"
            exit 1
        }
    fi
        
    # Definir diretórios de trabalho
    readonly BACKUP="${BACKUP:-${TOOLS}/backup}"
    readonly OLDS="${OLDS:-${TOOLS}/olds}"
    readonly PROGS="${PROGS:-${TOOLS}/progs}"
    readonly LOGS="${LOGS:-${TOOLS}/logs}"
    readonly ENVIA="${ENVIA:-${TOOLS}/envia}"
    readonly RECEBE="${RECEBE:-${TOOLS}/recebe}"
    readonly LIB="${LIB:-${TOOLS}/lib}"
    #export CFG="${CFG:-${TOOLS}/cfg}"

    # Criar diretórios se não existirem
    local dirs=("${OLDS}" "${PROGS}" "${LOGS}" "${BACKUP}" "${ENVIA}" "${LIB}" "${CFG}" "${RECEBE}")
    for dir in "${dirs[@]}"; do
        if [[ ! -d "${dir}" ]]; then
            mkdir -p "${dir}" || {
                printf "Erro ao criar diretório %s\n" "${dir}"
                exit 1
            }
        fi
    done
}

# Configurar variáveis do sistema
_configurar_variaveis_sistema() {
    # Caminhos dos executáveis e dados
    export E_EXEC="${destino}/${exec}"
    export T_TELAS="${destino}/${telas}"
    export X_XML="${destino}/${xml}"
    export BASE1="${destino}${base}"
    export BASE2="${destino}${base2}"
    export BASE3="${destino}${base3}"
    
    # Configuração do SAVISC
    readonly SAVISCC="${destino}/sav/savisc/iscobol/bin/"
    if [[ -n "${SAVISCC}" ]]; then
        SAVISC="${SAVISCC}"
    fi
    
    # Utilitários
    readonly JUTILL="jutil"
    if [[ -n "${JUTILL}" ]]; then
        JUTIL="${JUTILL}"
    fi
    
    readonly ISCCLIENTT="iscclient"
    if [[ -n "${ISCCLIENTT}" ]]; then
        ISCCLIENT="${ISCCLIENTT}"
    fi
    
    # Caminho completo do jutil
    jut="${SAVISC}${JUTIL}"
    
    # Configurar porta e acesso
    if [[ -z "${PORTA}" ]]; then
        PORTA="${DEFAULT_PORTA}"
    fi
    
    if [[ -z "${USUARIO}" ]]; then
        USUARIO="${DEFAULT_USUARIO}"
    fi
    
    # Configurar logs
    readonly LOG_ATU="${LOGS}/atualiza.$(date +"%Y-%m-%d").log"
    readonly LOG_LIMPA="${LOGS}/limpando.$(date +"%Y-%m-%d").log"
    readonly LOG_TMP="${LOGS}/"
    
    # Data atual formatada
    readonly UMADATA=$(date +"%d-%m-%Y_%H%M%S")
    
    # Arquivo de backup padrão
    INI="backup-${VERSAO}.zip"
}

# Funçao para carregar configuraçoes com verificaçao
_carregar_parametros() {
 #   local modulo="$1"
    local caminho_cfg="${CFG}/"
    if [[ ! -d "${caminho_cfg}" ]]; then
        printf "ERRO: Não foi possível criar o diretório %s\n" "${caminho_cfg}"
        exit 1
    fi
}

# Carregar arquivo de configuração da empresa
_carregar_config_empresa() {
    local config_dir="${CFG}/"
    local config_file="${config_dir}.atualizac"

# Criar diretório de configuração se não existir
    if [[ ! -d "${config_dir}" ]]; then
        mkdir -p "${config_dir}" || {
            printf "ERRO: Não foi possível criar o diretório %s\n" "${config_dir}"
            exit 1
        }
    fi
  
    # Verificar existência e permissões
    if [[ ! -e "${config_file}" ]]; then
        printf "ERRO: Arquivo não existe no diretório.\n" 
        _setup_inicializacao
    fi
    
    if [[ ! -r "${config_file}" ]]; then
        printf "ERRO: Arquivo %s sem permissão de leitura.\n" "${config_file}"
        exit 1
    fi
    
    # Carregar configurações
    # shellcheck source=/dev/null
    "." "${config_file}"
}
# Carregar arquivo de parâmetros do sistema
_carregar_config_parametros() {
    local config_dir="${CFG}/"
    local param_file="${config_dir}.atualizap"
    # Criar diretório de configuração se não existir
    if [[ ! -d "${config_dir}" ]]; then
        mkdir -p "${config_dir}" || {
            printf "ERRO: Não foi possível criar o diretório %s\n" "${config_dir}"
            exit 1
        }
    fi

    # Verificar existência e permissões
    if [[ ! -e "${param_file}" ]]; then
        printf "ERRO: Arquivo %s não existe. Use ./setup.sh para configurar.\n" "${param_file}"
        printf "DICA: O arquivo deve estar em %s\n" "${config_dir}"
        exit 1
    fi
    
    if [[ ! -r "${param_file}" ]]; then
        printf "ERRO: Arquivo %s sem permissão de leitura.\n" "${param_file}"
        exit 1
    fi
    
    # Carregar parâmetros
    # shellcheck source=/dev/null
    "." "${param_file}"

}

# Configurar acesso offline se necessário
_configurar_acesso_offline() {
    if [[ "${SERACESOFF}" == "s" ]]; then
        local offline_dir="${destino}${SERACESOFF}"
        if [[ ! -d "${offline_dir}" ]]; then
            mkdir -p "${offline_dir}" || {
                printf "Erro ao criar diretório offline %s\n" "${offline_dir}"
                exit 1
            }
        fi
        
        # Mover arquivo batch se existir
        local bat_file="${TOOLS}/atualiza.bat"
        if [[ -f "${bat_file}" ]]; then
            chmod 777 "${bat_file}"
            mv -f "${bat_file}" "${offline_dir}" || {
                printf "Erro ao mover arquivo batch para %s\n" "${offline_dir}"
                exit 1
            }
        fi
    fi
}

# Função principal de carregamento de configurações
_carregar_configuracoes() {
    # Mudar para diretório do script
    cd "$(dirname "$0")" || exit 1
    
    # Definir cores
    _definir_cores
    
    # Carregar arquivos de configuração
    _carregar_config_empresa
    _carregar_config_parametros

    # Configurar comandos
    _configurar_comandos

    # Configurar diretórios
    _configurar_diretorios
    
    # Configurar variáveis do sistema
    _configurar_variaveis_sistema
    
    # Configurar acesso offline
    _configurar_acesso_offline
}

# Função para validar diretórios essenciais
_validar_diretorios() {
    # Função auxiliar para verificar diretório
    _verifica_diretorio() {
        local caminho="$1"
        local mensagem_erro="$2"
        
        if [[ -n "${caminho}" ]] && [[ -d "${caminho}" ]]; then
            _mensagec "${CYAN}" "Diretório validado: ${caminho}"
        else
            _linha "*"
            _mensagec "${RED}" "${mensagem_erro}: ${caminho}"
            _linha "*"
            _read_sleep 2
            exit 1
        fi
    }
    
    # Verificar diretórios essenciais
    _verifica_diretorio "${E_EXEC}" "Diretório de executáveis não encontrado"
    _verifica_diretorio "${T_TELAS}" "Diretório de telas não encontrado"
    _verifica_diretorio "${BASE1}" "Base principal não encontrada"
    
    # Verificar XML apenas se for IsCOBOL
    if [[ "${sistema}" == "iscobol" ]]; then
        _verifica_diretorio "${X_XML}" "Diretório XML não encontrado"
    fi
    
    # Verificar bases adicionais se configuradas
    if [[ -n "${BASE2}" ]]; then
        _verifica_diretorio "${BASE2}" "Segunda base não encontrada"
    fi
    
    if [[ -n "${BASE3}" ]]; then
        _verifica_diretorio "${BASE3}" "Terceira base não encontrada"
    fi
}

# Configurar ambiente final
_configurar_ambiente() {
    # Verificar se o jutil existe para sistemas IsCOBOL
    if [[ "${sistema}" == "iscobol" ]] && [[ ! -x "${jut}" ]]; then
        _mensagec "${YELLOW}" "Aviso: jutil não encontrado em ${jut}"
    fi
    
    # Tornar variáveis essenciais somente leitura
    readonly TOOLS BACKUP OLDS PROGS LOGS ENVIA RECEBE LOG LIB CFG
    readonly E_EXEC T_TELAS X_XML BASE1 BASE2 BASE3
    readonly LOG_ATU LOG_LIMPA LOG_TMP UMADATA
    readonly jut SAVISC JUTIL ISCCLIENT
}

# Função para resetar variáveis (cleanup)
_resetando() {
    unset -v "${cores[@]}" 2>/dev/null || true
    unset -v "${caminhos_base[@]}" 2>/dev/null || true  
    unset -v "${biblioteca[@]}" 2>/dev/null || true
    unset -v "${comandos[@]}" 2>/dev/null || true
    unset -v "${outros[@]}" 2>/dev/null || true
    
    tput sgr0 2>/dev/null || true
    exit 1
}
