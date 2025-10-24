#!/usr/bin/env bash
#
# config.sh - Módulo de Configurações e Validações
# Responsável por carregar configurações, validar sistema e definir variáveis globais
#
# SISTEMA SAV - Script de Atualizaçao Modular
# Versao: 10/10/2025-00

#---------- VARIÁVEIS GLOBAIS ----------#

# Arrays para organização das variáveis
declare -a cores=(RED GREEN YELLOW BLUE PURPLE CYAN NORM)
declare -a caminhos_base=(BASE1 BASE2 BASE3 tools DIR destino pasta base base2 base3 logs exec class telas xml olds progs backup sistema TEMPS UMADATA DIRB ENVIABACK ENVBASE SERACESOFF E_EXEC T_TELAS X_XML)
declare -a biblioteca=(SAVATU SAVATU1 SAVATU2 SAVATU3 SAVATU4)
declare -a comandos=(cmd_unzip cmd_zip cmd_find cmd_who)
declare -a outros=(NOMEPROG PEDARQ prog PORTA USUARIO IPSERVER DESTINO2 VBACKUP ARQUIVO VERSAO ARQUIVO2 VERSAOANT INI SAVISC DEFAULT_UNZIP DEFAULT_ZIP DEFAULT_FIND DEFAULT_WHO DEFAULT_VERSAO VERSAO DEFAULT_ARQUIVO DEFAULT_PEDARQ DEFAULT_PROG DEFAULT_PORTA DEFAULT_USUARIO DEFAULT_IPSERVER DEFAULT_DESTINO2 UPDATE DEFAULT_PEDARQ jut JUTIL ISCCLIENT ISCCLIENTT SAVISCC Offline base_trabalho)

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
libs="${libs:-}"               # Caminho do diretorio das bibliotecas.
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
Offline="${Offline:-}"       # Variavel que define se o sistema esta em modo offline.
down_dir="${down_dir:-}"     # Variavel que define o caminho do diretorio do servidor off.  
SERACESOFF="${SERACESOFF:-}" # Variavel que define o caminho do diretorio do servidor off.
acessossh="${acessossh:-}"   # Variavel que define o caminho do diretorio do servidor off.
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
RED="${RED:-}"               # Cor vermelha
GREEN="${GREEN:-}"           # Cor verde
YELLOW="${YELLOW:-}"         # Cor amarela
BLUE="${BLUE:-}"             # Cor azul
PURPLE="${PURPLE:-}"         # Cor roxa
CYAN="${CYAN:-}"             # Cor ciano
NORM="${NORM:-}"             # Cor normal
COLUMNS="${COLUMNS:-}"       # Numero de colunas do terminal
LOG="${LOG:-}"               # Variavel que define o caminho do arquivo de log.
LOG_ATU="${LOG_ATU:-}"       # Variavel que define o caminho do arquivo de log de atualizacao.
LOG_LIMPA="${LOG_LIMPA:-}"   # Variavel que define o caminho do arquivo de log de limpeza.
LOG_TMP="${LOG_TMP:-}"       # Variavel que define o caminho do arquivo de log temporario.
UMADATA="${UMADATA:-}"       # Variavel que define o caminho do arquivo de dados da UMA.
ISCCLIENT="${ISCCLIENT:-}"   # Variavel que define o caminho do cliente ISC.
base_trabalho="${base_trabalho:-}" # Variavel que define o caminho do diretorio de trabalho.

# Configurações padrão
DEFAULT_UNZIP="unzip"        # Comando padrão para descompactar
DEFAULT_ZIP="zip"            # Comando padrão para compactar
DEFAULT_FIND="find"          # Comando padrão para buscar arquivos
DEFAULT_WHO="who"            # Comando padrão para verificar usuários
DEFAULT_PORTA="41122"        # Porta padrão
DEFAULT_USUARIO="atualiza"   # Usuário padrão

# Diretórios de destino para diferentes tipos de biblioteca
export DESTINO2SERVER="/u/varejo/man/"                                   # Diretório do servidor de atualização
export DESTINO2SAVATUISC="/home/savatu/biblioteca/temp/ISCobol/sav-5.0/" # Diretório da biblioteca IsCOBOL
export DESTINO2SAVATUMF="/home/savatu/biblioteca/temp/Isam/sav-3.1"      # Diretório da biblioteca Isam
export DESTINO2TRANSPC="/u/varejo/trans_pc/"                             # Diretório de transporte PC
export SERACESOFF="/sav/portalsav/Atualiza"                              # Diretório do servidor offline
#---------- FUNÇÕES DE CONFIGURAÇÃO ----------#

# Função para definir cores do terminal
_definir_cores() {
    # Verificar se o terminal suporta cores
    if [[ -t 1 ]] && command -v tput >/dev/null 2>&1; then
        RED=$(tput bold)$(tput setaf 1)    # Vermelho
        GREEN=$(tput bold)$(tput setaf 2)  # Verde
        YELLOW=$(tput bold)$(tput setaf 3) # Amarelo
        BLUE=$(tput bold)$(tput setaf 4)   # Azul
        PURPLE=$(tput bold)$(tput setaf 5) # Roxo
        CYAN=$(tput bold)$(tput setaf 6)   # Ciano
        NORM=$(tput sgr0)                  # Normal
        COLUMNS=$(tput cols)               # Numero de colunas do terminal

        # Limpar tela inicial
        tput clear     # Limpa a tela
        tput bold      # Ativa o negrito
        tput setaf 7   # Define a cor branca para o texto
    else
        # Terminal sem suporte a cores
        RED=""     # Limpar variavel Vermelho
        GREEN=""   # Limpar variavel Verde
        YELLOW=""  # Limpar variavel Amarelo
        BLUE=""    # Limpar variavel Azul
        PURPLE=""  # Limpar variavel Roxo
        CYAN=""    # Limpar variavel Ciano
        NORM=""    # Limpar variavel Normal
        COLUMNS=80 # Definir colunas padrão
    fi
readonly RED GREEN YELLOW BLUE PURPLE CYAN NORM 
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
    # Salvar diretório atual
    local dir_atual
    dir_atual="$(pwd)"
    cd .. || exit 1
    # Definir diretório raiz
    local raiz="/"
    
    # Definir diretório de destino
    destino="${raiz}${destino}"
    TOOLS="$(dirname "${SCRIPT_DIR}")"
   
    # Verificar diretório principal
    if [[ -n "${TOOLS}" ]] && [[ -d "${TOOLS}" ]]; then
        _mensagec "${CYAN}" "Diretório encontrado: ${TOOLS}"
        cd "${TOOLS}" || {
            _mensagec "${RED}" "Erro: Não foi possível acessar %s\n" "${TOOLS}"
            exit 1
        }
    else
        _mensagec "${RED}" "ERRO: Diretório %s não encontrado.\n" "${TOOLS}"
        exit 1
    fi

    # Criar diretório de configuração se não existir
    if [[ ! -d "${LIB_CFG}" ]]; then
        mkdir -p "${LIB_CFG}" || {
            printf "Erro ao criar diretório de configuração %s\n" "${LIB_CFG}"
            exit 1
        }
    fi
        
    # Definir diretórios de trabalho
    OLDS="${TOOLS}/olds"        # Diretório de arquivos antigos
    PROGS="${TOOLS}/progs"     # Diretório de programas
    LOGS="${TOOLS}/logs"        # Diretório de logs
    ENVIA="${TOOLS}/envia"     # Diretório de envio
    RECEBE="${TOOLS}/recebe"  # Diretório de recebimento
    LIBS="${TOOLS}/libs"        # Diretório de bibliotecas
    backup="${TOOLS}/backup"  # Diretório de backup

    down_dir="${destino}${pasta}"      # Diretório do servidor off-line

    # Criar diretórios se não existirem
    local dirs=("${OLDS}" "${PROGS}" "${LOGS}" "${ENVIA}" "${RECEBE}" "${LIBS}" "${down_dir}" "${backup}")
    for dir in "${dirs[@]}"; do
        if [[ ! -d "${dir}" ]]; then
            mkdir -p "${dir}" || {
                printf "Erro ao criar diretório %s\n" "${dir}"
                exit 1
            }
        fi
    done

    # Restaurar diretório original
    cd "$dir_atual" || exit 1

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
    LOG_ATU="${LOGS}/atualiza.$(date +"%Y-%m-%d").log"
    LOG_LIMPA="${LOGS}/limpando.$(date +"%Y-%m-%d").log"
    LOG_TMP="${LOGS}/"
    
    # Data atual formatada
    UMADATA=$(date +"%d-%m-%Y_%H%M%S")
    
    # Arquivo de backup padrão
    INI="backup-${VERSAO}.zip"
}

# Funçao para carregar configuraçoes com verificaçao
_carregar_parametros() {
 #   local modulo="$1"
    local caminho_cfg="${LIB_CFG}/"
    if [[ ! -d "${caminho_cfg}" ]]; then
        printf "ERRO: Não foi possível criar o diretório %s\n" "${caminho_cfg}"
        exit 1
    fi
}

# Carregar arquivo de configuração da empresa
_carregar_config_empresa() {
    local config_file="${LIB_CFG}/.atualizac"

    # Verificar existência e permissões
    if [[ ! -e "${config_file}" ]]; then
        printf "ERRO: Arquivo não existe no diretório.\n" 
        printf "ATENCAO: Use o programa .setup.sh que esta na pasta /libs para criar as configuracoes.\n" 
        exit 1
    fi
    
    if [[ ! -r "${config_file}" ]]; then
        printf "ERRO: Arquivo %s sem permissão de leitura.\n" "${config_file}"
        exit 1
    fi
    
    # Carregar configurações
    # shellcheck source=/dev/null
    "." "${config_file}"
}

# Configurar acesso offline se necessário
_configurar_acessos() {
    if [[ "${Offline}" == "s" ]]; then
            down_dir="${destino}${SERACESOFF}"
        if [[ ! -d "${down_dir}" ]]; then
            mkdir -p "${down_dir}" || {
                printf "Erro ao criar diretório offline %s\n" "${down_dir}"
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

    # Configurar comandos
    _configurar_comandos

    # Configurar diretórios
    _configurar_diretorios
    
    # Configurar variáveis do sistema
    _configurar_variaveis_sistema
    
    # Configurar acesso offline
    _configurar_acessos
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
}

# Função para validar a configuração atual do sistema
_validar_configuracao() {
    clear
    _linha "=" "${GREEN}"
    _mensagec "${RED}" "Validação de Configuração"
    _linha
    
    local erros=0
    local warnings=0
    
    # Verificar arquivos de configuração
    if [[ ! -f "${LIB_CFG}/.atualizac" ]]; then
        _mensagec "${RED}" "ERRO: Arquivo .atualizac não encontrado!"
        ((erros++))
    else
        _mensagec "${GREEN}" "OK: Arquivo .atualizac encontrado"
    fi

    # Verificar variáveis essenciais
    if [[ -z "${sistema}" ]]; then
        _mensagec "${RED}" "ERRO: Variável 'sistema' não definida!"
        ((erros++))
    elif [[ "${sistema}" != "iscobol" && "${sistema}" != "cobol" ]]; then
        _mensagec "${YELLOW}" "WARNING: Valor desconhecido para 'sistema': ${sistema}"
        ((warnings++))
    else
        _mensagec "${GREEN}" "OK: Sistema definido como ${sistema}"
    fi
    
    if [[ -z "${destino}" ]]; then
        _mensagec "${RED}" "ERRO: Variavel 'destino' nao definida!"
        ((erros++))
    else
        _mensagec "${GREEN}" "OK: Diretório raiz definido"
    fi
    
    if [[ -z "${BANCO}" ]]; then
        _mensagec "${YELLOW}" "WARNING: Variável 'BANCO' não definida"
        ((warnings++))
    else
        _mensagec "${GREEN}" "OK: Configuração de banco de dados definida"
    fi
    
    # Verificar diretórios essenciais
    local dirs=("exec" "telas" "olds" "progs" "logs" "backup" "cfg")
    for dir in "${dirs[@]}"; do
        local dir_path=""
        # Tratamento especial para exec e telas que ficam em ${destino}/sav
        if [[ "$dir" == "exec" ]] || [[ "$dir" == "telas" ]]; then
            dir_path="${destino}/${!dir}"
        else
            # Para outros diretórios, usar o caminho padrão
            dir_path="${destino}${pasta}${!dir}"
        fi
        
        if [[ ! -d "${dir_path}" ]]; then
            _mensagec "${YELLOW}" "WARNING: Diretório ${dir} não encontrado: ${dir_path}"
            ((warnings++))
        else
            _mensagec "${GREEN}" "OK: Diretório ${dir} encontrado"
        fi
    done
    
    # Verificar conectividade se for modo online
    if [[ "${Offline}" == "n" ]]; then
        _mensagec "${YELLOW}" "INFO: Verificando conectividade com servidor..."
        if command -v ping >/dev/null 2>&1; then
            if ping -c 1 -W 5 "${IPSERVER}" >/dev/null 2>&1; then
                _mensagec "${GREEN}" "OK: Conectividade com servidor estabelecida"
            else
                _mensagec "${YELLOW}" "WARNING: Não foi possível conectar ao servidor ${IPSERVER}"
                ((warnings++))
            fi
        else
            _mensagec "${YELLOW}" "INFO: Comando ping não disponível para teste de conectividade"
        fi
    else
        _mensagec "${GREEN}" "INFO: Modo offline - conectividade não verificada"
    fi
    
    _linha
    printf "\n"
    _mensagec "${CYAN}" "Resumo:"
    _mensagec "${RED}" "Erros: ${erros}"
    _mensagec "${YELLOW}" "Avisos: ${warnings}"
    
    if (( erros == 0 )); then
        _mensagec "${GREEN}" "Configuração válida!"
    else
        _mensagec "${RED}" "Configuração com erros!"
    fi
    
    _linha
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
