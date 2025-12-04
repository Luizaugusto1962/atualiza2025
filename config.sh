#!/usr/bin/env bash
#
# config.sh - Modulo de Configuracoes e Validacoes
# Responsavel por carregar configuracoes, validar sistema e definir variaveis globais
#
# SISTEMA SAV - Script de Atualizacao Modular
# Versao: 04/12/2025-00

#---------- VARIaVEIS GLOBAIS ----------#

# Arrays para organizacao das variaveis
declare -a cores=(RED GREEN YELLOW BLUE PURPLE CYAN NORM)
declare -a caminhos_base=(BASE1 BASE2 BASE3 TOOLS_DIR DIR raiz pasta base base2 base3 logs exec class telas xml olds)
declare -a caminhos_base2=(progs backup sistema TEMPS UMADATA DIRB ENVIABACK ENVBASE SERACESOFF E_EXEC T_TELAS X_XML)
declare -a biblioteca=(SAVATU SAVATU1 SAVATU2 SAVATU3 SAVATU4)
declare -a comandos=(cmd_unzip cmd_zip cmd_find cmd_who)
declare -a outros=(NOMEPROG PEDARQ prog PORTA USUARIO IPSERVER DESTINO2 VBACKUP ARQUIVO VERSAO ARQUIVO2 VERSAOANT INI SAVISC DEFAULT_UNZIP DEFAULT_ZIP DEFAULT_FIND DEFAULT_WHO DEFAULT_VERSAO VERSAO DEFAULT_ARQUIVO DEFAULT_PEDARQ DEFAULT_PROG DEFAULT_PORTA DEFAULT_USUARIO DEFAULT_IPSERVER DEFAULT_DESTINO2 UPDATE DEFAULT_PEDARQ jut JUTIL ISCCLIENT ISCCLIENTT SAVISCC Offline base_trabalho)

#-VARIAVEIS do sistema ----------------------------------------------------------------------------#
#-Variaveis de configuracao do sistema ---------------------------------------------------------#
# Variaveis de configuracao do sistema que podem ser definidas pelo usuario.
# As variaveis com o prefixo "destino" sao usadas para definir o caminho
# dos diretorios que serao usados pelo programa.
raiz="${raiz:-}"             # Caminho do diretorio raiz do programa.
cfg_dir="${cfg_dir:-}"       # Caminho do diretorio de configuracao do programa.
lib_dir="${lib_dir:-}"       # Caminho do diretorio de bibliotecas do programa.
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
libs="${libs:-}"             # Caminho do diretorio das bibliotecas.
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

# Configuracoes padrao
DEFAULT_UNZIP="unzip"        # Comando padrao para descompactar
DEFAULT_ZIP="zip"            # Comando padrao para compactar
DEFAULT_FIND="find"          # Comando padrao para buscar arquivos
DEFAULT_WHO="who"            # Comando padrao para verificar usuarios
DEFAULT_PORTA="41122"        # Porta padrao
DEFAULT_USUARIO="atualiza"   # Usuario padrao

# Diretorios de destino para diferentes tipos de biblioteca
export DESTINO2SERVER="/u/varejo/man/"                                   # Diretorio do servidor de atualizacao
export DESTINO2SAVATUISC="/home/savatu/biblioteca/temp/ISCobol/sav-5.0/" # Diretorio da biblioteca IsCOBOL
export DESTINO2SAVATUMF="/home/savatu/biblioteca/temp/Isam/sav-3.1"      # Diretorio da biblioteca Isam
export DESTINO2TRANSPC="/u/varejo/trans_pc/"                             # Diretorio de transporte PC
export SERACESOFF="/sav/portalsav/Atualiza"                              # Diretorio do servidor offline
#---------- FUNcoES DE CONFIGURAcaO ----------#

# Funcao para definir cores do terminal
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
        tput clear    # Limpa a tela
        tput bold     # Ativa o negrito
        tput setaf 7  # Define a cor branca para o texto
    else
        # Terminal sem suporte a cores
        RED=""        # Limpar variavel Vermelho
        GREEN=""      # Limpar variavel Verde
        YELLOW=""     # Limpar variavel Amarelo
        BLUE=""       # Limpar variavel Azul
        PURPLE=""     # Limpar variavel Roxo
        CYAN=""       # Limpar variavel Ciano
        NORM=""       # Limpar variavel Normal
        COLUMNS=80    # Definir colunas padrao
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
    
    # Comando para verificar usuarios
    if [[ -z "${cmd_who}" ]]; then
        cmd_who="${DEFAULT_WHO}"
    fi
    
    # Validar se os comandos existem
    for cmd in "$cmd_unzip" "$cmd_zip" "$cmd_find" "$cmd_who"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            printf "Erro: Comando %s nao encontrado.\n" "$cmd"
            exit 1
        fi
    done
}
# Configurar diretorios de trabalho e variaveis globais.
_configurar_diretorios() {
    
    # Verificar diretorio principal
    if [[ -n "${TOOLS_DIR}" ]] && [[ -d "${TOOLS_DIR}" ]]; then
        _mensagec "${CYAN}" "Diretorio encontrado: ${TOOLS_DIR}"
    else
        _mensagec "${RED}" "ERRO: Diretorio %s nao encontrado.\n" "${TOOLS_DIR}"
        return 1
    fi

    # Definir diretorio de configuracao
    raiz="${TOOLS_DIR%/*}"

    # Criar diretorio de configuracao se nao existir
    if [[ ! -d "${cfg_dir}" ]]; then
        mkdir -p "${cfg_dir}" || {
            printf "Erro ao criar diretorio de configuracao %s\n" "${cfg_dir}"
            return 1
        }
    fi
        
    # Definir diretorios de trabalho
    OLDS="${TOOLS_DIR}/olds"        # Diretorio de arquivos antigos
    PROGS="${TOOLS_DIR}/progs"      # Diretorio de programas
    LOGS="${TOOLS_DIR}/logs"        # Diretorio de logs
    ENVIA="${TOOLS_DIR}/envia"      # Diretorio de envio
    RECEBE="${TOOLS_DIR}/recebe"    # Diretorio de recebimento
    LIBS="${TOOLS_DIR}/libs"        # Diretorio de bibliotecas
    BACKUP="${TOOLS_DIR}/backup"    # Diretorio de backup

    # Criar diretorios se nao existirem
    local dirs=("${OLDS}" "${PROGS}" "${LOGS}" "${ENVIA}" "${RECEBE}" "${LIBS}" "${BACKUP}")
    for dir in "${dirs[@]}"; do
        if [[ ! -d "${dir}" ]]; then
            mkdir -p "${dir}" || {
                printf "Erro ao criar diretorio %s\n" "${dir}"
                return 1
            }
        fi
    done
    
    # Exportar variaveis de diretorio
    export OLDS PROGS LOGS ENVIA RECEBE LIBS BACKUP raiz
}

# Configurar variaveis do sistema
_configurar_variaveis_sistema() {
    # Caminhos dos executaveis e dados
    export E_EXEC="${raiz}${exec}"
    export T_TELAS="${raiz}${telas}"
    export X_XML="${raiz}${xml}"
    export BASE1="${raiz}${base}"
    export BASE2="${raiz}${base2}"
    export BASE3="${raiz}${base3}"
    
    # Configuracao do SAVISC
    readonly SAVISCC="${raiz}/savisc/iscobol/bin/"
    if [[ -n "${SAVISCC}" ]]; then
        SAVISC="${SAVISCC}"
    fi
    
    # Utilitarios
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
    
    # Arquivo de backup padrao
    INI="backup-${VERSAO}.zip"
}

# Funcao para carregar configuracoes com verificacao
_carregar_parametros() {
 #   local modulo="$1"
    local caminho_cfg="${cfg_dir}/"
    if [[ ! -d "${caminho_cfg}" ]]; then
        printf "ERRO: Nao foi possivel criar o diretorio %s\n" "${caminho_cfg}"
        exit 1
    fi
}

# Carregar arquivo de configuracao da empresa
_carregar_config_empresa() {
    local config_file="${cfg_dir}/.atualizac"

    # Verificar existência e permissoes
    if [[ ! -e "${config_file}" ]]; then
        printf "ERRO: Arquivo nao existe no diretorio.\n" 
        printf "ATENCAO: Use o programa .setup.sh que esta na pasta /libs para criar as configuracoes.\n" 
        exit 1
    fi
    
    if [[ ! -r "${config_file}" ]]; then
        printf "ERRO: Arquivo %s sem permissao de leitura.\n" "${config_file}"
        exit 1
    fi
    
    # Carregar configuracoes
    # shellcheck source=/dev/null
    "." "${config_file}"
}

# Configurar acesso offline se necessario
_configurar_acessos() {
    if [[ "${Offline}" == "s" ]]; then
            down_dir="${raiz}${SERACESOFF}"    #"SERACESOFF=/sav/portalsav/Atualiza"
        if [[ ! -d "${down_dir}" ]]; then
            mkdir -p "${down_dir}" || {
                printf "Erro ao criar diretorio offline %s\n" "${down_dir}"
                exit 1
            }
        fi
    else
        down_dir="${TOOLS_DIR}"       
    fi
}

# Funcao principal de carregamento de configuracoes
_carregar_configuracoes() {
    # Mudar para diretorio do script
    cd "$(dirname "$0")" || exit 1
    
    # Definir cores
    _definir_cores
    
    # Carregar arquivos de configuracao
    _carregar_config_empresa

    # Configurar comandos
    _configurar_comandos

    # Configurar diretorios
    _configurar_diretorios
    
    # Configurar variaveis do sistema
    _configurar_variaveis_sistema
    
    # Configurar acesso offline
    _configurar_acessos
}

# Funcao para validar diretorios essenciais
_validar_diretorios() {
    # Funcao auxiliar para verificar diretorio
    _verifica_diretorio() {
        local caminho="$1"
        local mensagem_erro="$2"
        
        if [[ -n "${caminho}" ]] && [[ -d "${caminho}" ]]; then
            _mensagec "${CYAN}" "Diretorio validado: ${caminho}"
        else
            _linha "*"
            _mensagec "${RED}" "${mensagem_erro}: ${caminho}"
            _linha "*"
            _read_sleep 2
            exit 1
        fi
    }
    
    # Verificar diretorios essenciais
    _verifica_diretorio "${E_EXEC}" "Diretorio de executaveis nao encontrado"
    _verifica_diretorio "${T_TELAS}" "Diretorio de telas nao encontrado"
    _verifica_diretorio "${BASE1}" "Base principal nao encontrada"
    
    # Verificar XML apenas se for IsCOBOL
    if [[ "${sistema}" == "iscobol" ]]; then
        _verifica_diretorio "${X_XML}" "Diretorio XML nao encontrado"
    fi
    
    # Verificar bases adicionais se configuradas
    if [[ -n "${BASE2}" ]]; then
        _verifica_diretorio "${BASE2}" "Segunda base nao encontrada"
    fi
    
    if [[ -n "${BASE3}" ]]; then
        _verifica_diretorio "${BASE3}" "Terceira base nao encontrada"
    fi
}

# Configurar ambiente final
_configurar_ambiente() {
    # Verificar se o jutil existe para sistemas IsCOBOL
    if [[ "${sistema}" == "iscobol" ]] && [[ ! -x "${jut}" ]]; then
        _mensagec "${YELLOW}" "Aviso: jutil nao encontrado em ${jut}"
    fi 
}

# Funcao para validar a configuracao atual do sistema
_validar_configuracao() {
    clear
    _linha "=" "${GREEN}"
    _mensagec "${RED}" "Validacao de Configuracao"
    _linha
    
    local erros=0
    local warnings=0
    
    # Verificar arquivos de configuracao
    if [[ ! -f "${cfg_dir}/.atualizac" ]]; then
        _mensagec "${RED}" "ERRO: Arquivo .atualizac nao encontrado!"
        ((erros++))
    else
        _mensagec "${GREEN}" "OK: Arquivo .atualizac encontrado"
    fi

    # Verificar variaveis essenciais
    if [[ -z "${sistema}" ]]; then
        _mensagec "${RED}" "ERRO: Variavel 'sistema' nao definida!"
        ((erros++))
    elif [[ "${sistema}" != "iscobol" && "${sistema}" != "cobol" ]]; then
        _mensagec "${YELLOW}" "WARNING: Valor desconhecido para 'sistema': ${sistema}"
        ((warnings++))
    else
        _mensagec "${GREEN}" "OK: Sistema definido como ${sistema}"
    fi
    
    if [[ -z "${raiz}" ]]; then
        _mensagec "${RED}" "ERRO: Variavel 'raiz' nao definida!"
        ((erros++))
    else
        _mensagec "${GREEN}" "OK: Diretorio raiz definido"
    fi
    
    if [[ -z "${BANCO}" ]]; then
        _mensagec "${YELLOW}" "WARNING: Variavel 'BANCO' nao definida"
        ((warnings++))
    else
        _mensagec "${GREEN}" "OK: Configuracao de banco de dados definida"
    fi
    
    # Verificar diretorios essenciais
    local dirs=("exec" "telas" "olds" "progs" "logs" "cfg" "libs" "backup")
    for dir in "${dirs[@]}"; do
        local dir_path=""
        # Tratamento especial para exec e telas que ficam em ${raiz}
        if [[ "$dir" == "exec" ]] || [[ "$dir" == "telas" ]]; then
            dir_path="${raiz}/${!dir}"
        else
            # Para outros diretorios, usar o caminho padrao
            dir_path="${TOOLS_DIR}${!dir}"
        fi
        
        if [[ ! -d "${dir_path}" ]]; then
            _mensagec "${YELLOW}" "WARNING: Diretorio ${dir} nao encontrado: ${dir_path}"
            ((warnings++))
        else
            _mensagec "${GREEN}" "OK: Diretorio ${dir} encontrado"
        fi
    done
    
    # Verificar conectividade se for modo online
    if [[ "${Offline}" == "n" ]]; then
        _mensagec "${YELLOW}" "INFO: Servidor em modo On ..."
    else 
        _mensagec "${GREEN}" "INFO: Servidor em modo Off ..."
    fi
    
    _linha
    printf "\n"
    _mensagec "${CYAN}" "Resumo:"
    _mensagec "${RED}" "Erros: ${erros}"
    _mensagec "${YELLOW}" "Avisos: ${warnings}"
    
    if (( erros == 0 )); then
        _mensagec "${GREEN}" "Configuracao valida!"
    else
        _mensagec "${RED}" "Configuracao com erros!"
    fi
    
    _linha
}

_ir_para_tools() {
    cd "${TOOLS_DIR}" || {
        printf "Erro ao acessar o diretorio %s\n" "${TOOLS_DIR}"
        exit 1
    }
}

# Funcao para resetar variaveis (cleanup)
_resetando() {
    unset -v "${cores[@]}" 2>/dev/null || true
    unset -v "${caminhos_base[@]}" 2>/dev/null || true
    unset -v "${caminhos_base2[@]}" 2>/dev/null || true
    unset -v "${biblioteca[@]}" 2>/dev/null || true
    unset -v "${comandos[@]}" 2>/dev/null || true
    unset -v "${outros[@]}" 2>/dev/null || true
    
    tput sgr0 2>/dev/null || true
    exit 1
}
