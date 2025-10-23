#!/usr/bin/env bash
#
# sistema.sh - Módulo de Informações do Sistema
# Responsável por informações do IsCOBOL, Linux, parâmetros e atualizações
#
# SISTEMA SAV - Script de Atualizaçao Modular
# Versao: 10/10/2025-00

destino="${destino:-}"
sistema="${sistema:-}"
acessossh="${acessossh:-}"
cmd_zip="${cmd_zip:-}"
cmd_unzip="${cmd_unzip:-}"
cmd_find="${cmd_find:-}"
pasta="${pasta:-}"
base="${base:-}"
base2="${base2:-}"
base3="${base3:-}"
telas="${telas:-}"
logs="${logs:-}"
progs="${progs:-}"
verclass="${verclass:-}"
backup="${backup:-}"
class="${class:-}"
mclass="${mclass:-}"
exec="${exec:-}"
xml="${xml:-}"
olds="${olds:-}"
Offline="${Offline:-}"

#---------- FUNÇÕES DE VERSÃO ----------#

# Mostra versão do IsCOBOL
_mostrar_versao_iscobol() {
    if [[ "${sistema}" == "iscobol" ]]; then
        if [[ -x "${SAVISC}${ISCCLIENT}" ]]; then
            clear
            _linha "=" "${GREEN}"
            _mensagec "${GREEN}" "Versão do IsCobol"
            _linha "=" "${GREEN}"
            "${SAVISC}${ISCCLIENT}" -v
            _linha "=" "${GREEN}"
            printf "\n\n"
        else
            _linha
            _mensagec "${RED}" "Erro: ${SAVISC}${ISCCLIENT} não encontrado ou não executável"
            _linha
        fi
    elif [[ -z "${sistema}" ]]; then
        _linha
        _mensagec "${RED}" "Erro: Variável de sistema não configurada"
        _linha
    else
        _linha
        _mensagec "${YELLOW}" "Sistema não é IsCOBOL"
        _linha
    fi
    _press
}

# Mostra informações do Linux
_mostrar_versao_linux() {
    clear
    printf "\n\n"
    _mensagec "${GREEN}" "Vamos descobrir qual S.O. / Distro voce esta executando"
    _linha
    printf "\n\n"
    _mensagec "${YELLOW}" "A partir de algumas informacoes basicas o seu sistema, parece estar executando:"
    _linha

    # Checando se conecta com a internet ou nao
    if ping -c 1 google.com &>/dev/null; then
        printf "${GREEN}"" Internet:""${NORM}""Conectada""%*s\n"
    else
        printf "${GREEN}"" Internet:""${NORM}""Desconectada""%*s\n"
    fi

    # Checando tipo de OS
    os=$(uname -o)
    printf "${GREEN}""Sistema Operacional :""${NORM}""${os}""%*s\n"

    # Checando OS Versao e nome
    if [[ -f /etc/os-release ]]; then
        grep 'NAME\|VERSION' /etc/os-release | grep -v 'VERSION_ID\|PRETTY_NAME' >"${LOG_TMP}osrelease"
        printf "${GREEN}""OS Nome :""${NORM}""%*s\n"
        grep -v "VERSION" "${LOG_TMP}osrelease" | cut -f2 -d\"
        printf "${GREEN}""OS Versao :""${NORM}""%*s\n"
        grep -v "NAME" "${LOG_TMP}osrelease" | cut -f2 -d\"
    else
        printf "${RED}""Arquivo /etc/os-release nao encontrado.""%*s\n"
    fi
    printf "\n"

    # Checando hostname
    nameservers=$(hostname)
    printf "${GREEN}""Nome do Servidor :""${NORM}""${nameservers}""%*s\n"
    printf "\n"

    # Checando Interno IP
    internalip=$(ip route get 1 | awk '{print $7;exit}')
    printf "${GREEN}""IP Interno :""${NORM}""${internalip}""%*s\n"
    printf "\n"

    # Checando Externo IP
    if [[ "${Offline}" == "n" ]]; then
        externalip=$(curl -s ipecho.net/plain || printf "Nao disponivel")
        printf "${GREEN}""IP Externo :""${NORM}""${externalip}""%*s\n"
    fi

    _linha
    _press
    clear
    _linha

    # Checando os usuarios logados
    _run_who() {
        who >"${LOG_TMP}who"
    }
    _run_who
    printf "${GREEN}""Usuario Logado :""${NORM}""%*s\n"
    cat "${LOG_TMP}who"
    printf "\n"

    # Checando uso de memoria RAM e SWAP
    free | grep -v + >"${LOG_TMP}ramcache"
    printf "${GREEN}""Uso de Memoria Ram :""${NORM}""%*s\n"
    grep -v "Swap" "${LOG_TMP}ramcache"
    printf "${GREEN}""Uso de Swap :""${NORM}""%*s\n"
    grep -v "Mem" "${LOG_TMP}ramcache"
    printf "\n"

    # Checando uso de disco
    df -h | grep 'Filesystem\|/dev/sda*' >"${LOG_TMP}diskusage"
    printf "${GREEN}""Espaco em Disco :""${NORM}""%*s\n"
    cat "${LOG_TMP}diskusage"
    printf "\n"

    # Checando o Sistema Uptime
    tecuptime=$(uptime -p | cut -d " " -f2-)
    printf "${GREEN}""Sistema em uso Dias/(HH:MM) : ""${NORM}""${tecuptime}""%*s\n"

    # Unset Variables
    unset os internalip externalip nameservers tecuptime

    # Removendo temporarios arquivos
    rm -f "${LOG_TMP}osrelease" "${LOG_TMP}who" "${LOG_TMP}ramcache" "${LOG_TMP}diskusage"
    _linha
    _press
    _principal
}

#---------- FUNÇÕES DE PARÂMETROS ----------#

# Mostra parâmetros do sistema
_mostrar_parametros() {
    clear
    _linha "=" "${GREEN}"
    printf "${GREEN}Sistema e banco de dados: ${NORM}${BANCO}""%*s\n"
    printf "${GREEN}Diretório raiz: ${NORM}${destino}""%*s\n"
    printf "${GREEN}Diretório do atualiza.sh: ${NORM}${destino}${pasta}""%*s\n"
    printf "${GREEN}Diretório da base principal: ${NORM}${destino}${base}""%*s\n"
    printf "${GREEN}Diretório da segunda base: ${NORM}${destino}${base2}""%*s\n"
    printf "${GREEN}Diretório da terceira base: ${NORM}${destino}${base3}""%*s\n"
    printf "${GREEN}Diretório dos executáveis: ${NORM}${destino}/${exec}""%*s\n"
    printf "${GREEN}Diretório das telas: ${NORM}${destino}/${telas}""%*s\n"
    printf "${GREEN}Diretório dos xmls: ${NORM}${destino}/${xml}""%*s\n"
    printf "${GREEN}Diretório dos logs: ${NORM}${destino}${pasta}${logs}""%*s\n"
    printf "${GREEN}Diretório dos olds: ${NORM}${destino}${pasta}${olds}""%*s\n"
    printf "${GREEN}Diretório dos progs: ${NORM}${destino}${pasta}${progs}""%*s\n"
    printf "${GREEN}Diretório do backup: ${NORM}${destino}${pasta}${backup}""%*s\n"
    printf "${GREEN}Diretório de configuracoes: ${NORM}${destino}${pasta}${LIB_CFG}""%*s\n"
    printf "${GREEN}Sistema em uso: ${NORM}${sistema}""%*s\n"
    printf "${GREEN}Versão em uso: ${NORM}${verclass}""%*s\n"
    printf "${GREEN}Biblioteca 1: ${NORM}${SAVATU1}""%*s\n"
    printf "${GREEN}Biblioteca 2: ${NORM}${SAVATU2}""%*s\n"
    printf "${GREEN}Biblioteca 3: ${NORM}${SAVATU3}""%*s\n"
    printf "${GREEN}Biblioteca 4: ${NORM}${SAVATU4}""%*s\n"
    _linha "=" "${GREEN}"
    _press
    clear
    _linha "=" "${GREEN}"
    printf "${GREEN}Diretório para envio de backup: ${NORM}${ENVIABACK}""%*s\n"
    printf "${GREEN}Servidor OFF: ${NORM}${Offline}""%*s\n"
    printf "${GREEN}Versão anterior da biblioteca: ${NORM}${VERSAOANT}""%*s\n"
    printf "${GREEN}Variável da classe: ${NORM}${class}""%*s\n"
    printf "${GREEN}Variável da mclass: ${NORM}${mclass}""%*s\n"
    printf "${GREEN}Porta de conexão: ${NORM}${PORTA}""%*s\n"
    printf "${GREEN}Usuário de conexão: ${NORM}${USUARIO}""%*s\n"
    printf "${GREEN}Servidor IP: ${NORM}${IPSERVER}""%*s\n"
    _linha "=" "${GREEN}"
    _press
}

#---------- FUNÇÕES DE ATUALIZAÇÃO ----------#

# Executa atualização do script
_executar_update() {
    if [[ "${Offline}" == "n" ]]; then
        _atualizar_online
        export tipo_online 
    else
        _atualizar_offline
        export tipo_offline
    fi
    _press
}

# Atualização online via GitHub
_atualizando() {

    _mensagec "${GREEN}" "Atualizando script via GitHub..."

    # Criar backup do arquivo atual
    if [[ ! -d "$backup" ]]; then
        mkdir -p "$backup" || {
            _mensagec "${RED}" "Erro: Não foi possível criar diretório de backup"
            return 1
        }
    fi

    # Fazer backup dos arquivos atuais
    local backup_sucesso=0
    local backup_erro=0
    cd "${LIB_DIR}" || {
        _mensagec "${RED}" "Erro: Diretório de atualização não encontrado"
        return 1
    }
    # Processar todos os arquivos .sh para backup
    for arquivo in *.sh; do
        # Verificar se o arquivo existe
        if [[ ! -f "$arquivo" ]]; then
            _mensagec "${YELLOW}" "Aviso: Nenhum arquivo .sh encontrado para backup"
            break
        fi

        # Copiar o arquivo para o diretório de backup
        if cp -f "$arquivo" "${backup}/.$arquivo.bak"; then
            _mensagec "${GREEN}" "Backup do arquivo $arquivo feito com sucesso"
            ((backup_sucesso++))
        else
            _mensagec "${RED}" "Erro ao fazer backup de $arquivo"
            ((backup_erro++))
        fi
    done

    # Verificar se houve erros no backup
    if [[ $backup_erro -gt 0 ]]; then
        _mensagec "${RED}" "Falha no backup de $backup_erro arquivo(s)"
        return 1
    elif [[ $backup_sucesso -eq 0 ]]; then
        _mensagec "${YELLOW}" "Nenhum arquivo foi copiado para backup"
        return 1
    else
        _mensagec "${GREEN}" "Backup de $backup_sucesso arquivo(s) realizado com sucesso"
    fi

    # Acessar diretório de trabalho
    cd "$ENVIA" || {
        _mensagec "${RED}" "Erro: Diretório $ENVIA não acessível"
        return 1
    }

    # Baixar arquivo
        if ! wget -q -c "$link"; then
            _mensagec "${RED}" "Erro ao baixar arquivo de atualização"
        return 1
        fi
    #fi
    # Descompactar
    if ! "${cmd_unzip}" -o -j "$zipfile" >>"$LOG_ATU" 2>&1; then
        _mensagec "${RED}" "Erro ao descompactar atualização"
        return 1
    fi

    # Verificar e instalar arquivos
    local arquivos_instalados=0
    local arquivos_erro=0

    # Processar todos os arquivos .sh encontrados
    for arquivo in *.sh; do
        # Verificar se o arquivo existe
        if [[ ! -f "$arquivo" ]]; then
            _mensagec "${YELLOW}" "Aviso: Nenhum arquivo .sh encontrado para processar"
            break
        else
            chmod +x "$arquivo"
        fi

        # Determinar destino
        if [ "$arquivo" = "atualiza.sh" ]; then
            target="${TOOLS}"
        else
            target="${LIB_DIR}"
        fi
        # Mover o arquivo para o diretório de destino
        if mv -f "$arquivo" "$target"; then
            _mensagec "${GREEN}" "Arquivo $arquivo instalado com sucesso"
            ((arquivos_instalados++))
        else
            _mensagec "${RED}" "Erro ao instalar $arquivo"
            ((arquivos_erro++))
        fi
    done

    # Verificar se houve erros na instalação
    if [[ $arquivos_erro -gt 0 ]]; then
        _mensagec "${RED}" "Falha na instalação de $arquivos_erro arquivo(s)"
        return 1
    elif [[ $arquivos_instalados -eq 0 ]]; then
        _mensagec "${YELLOW}" "Nenhum arquivo foi instalado"
        return 1
    else
        _mensagec "${GREEN}" "Instalados $arquivos_instalados arquivo(s) com sucesso"
    fi

    # Limpeza
    cd "$ENVIA" && rm -rf "$temp_dir"

    _linha
    _mensagec "${GREEN}" "Atualização concluída com sucesso!"
    _mensagec "${GREEN}" "Ao terminar, entre novamente no sistema"
    _linha

    exit 0
}
_atualizar_online() {
    local link="https://github.com/Luizaugusto1962/Atualiza2025/archive/master/atualiza.zip"
    local zipfile="atualiza.zip"
    local temp_dir="${ENVIA}/temp_update"
       # Criar e acessar diretório temporário
    mkdir -p "$temp_dir" || {
        _mensagec "${RED}" "Erro: Nao foi possivel criar o diretorio temporario $temp_dir."
        return 1
    }
    _atualizando
}

# Atualização offline via arquivo local
_atualizar_offline() {
    local temp_dir="${ENVIA}/temp_update/"
#    local dir_offline="$down_dir"
    local zipfile="atualiza.zip"

    # Criar e acessar diretório temporário
    mkdir -p "$temp_dir" || {
        _mensagec "${RED}" "Erro: Nao foi possivel criar o diretorio temporario $temp_dir."
        return 1
    }

    # Acessar diretório offline
    cd "$down_dir" || {
        _mensagec "${RED}" "Erro: Diretório offline $down_dir não acessível"
        return 1
    }

    # Verificar se o arquivo zip existe
    if [[ ! -f "$zipfile" ]]; then
        _mensagec "${RED}" "Erro: $zipfile não encontrado em $down_dir"
        return 1
    fi
    mv "${zipfile}" "${temp_dir}"
    _atualizando
}

#---------- FUNÇÕES DE MANUTENÇÃO DO SETUP ----------#
# Constantes
readonly tracejada="#-------------------------------------------------------------------#"

# Variáveis globais
declare -l sistema base base2 base3 BANCO destino Offline ENVIABACK
declare -u EMPRESA
# Posiciona o script no diretório LIB_CFG.
cd "${LIB_CFG}" || {
    _mensagec "${RED}" "Erro: Diretório ${LIB_CFG} não encontrado"
    return 1
}

editar_variavel() {
    local nome="$1"
    local valor_atual="${!nome}"

    # Função para editar variável com prompt
    read -rp "Deseja alterar ${nome} (valor atual: ${valor_atual})? [s/N] " alterar
    alterar=${alterar,,}
    if [[ "$alterar" =~ ^s$ ]]; then
        if [[ "$nome" == "sistema" ]]; then
            printf "\n"
            printf "%s\n" "Escolha o sistema:"
            printf "%s\n" "1) IsCobol"
            printf "%s\n" "2) Micro Focus Cobol"
            read -rp "Opcao [1-2]: " opcao
            case "$opcao" in
            1) sistema="iscobol" ;;
            2) sistema="cobol" ;;
            *) echo "Opcao invalida. Mantendo valor anterior: $valor_atual" ;;
            esac

        elif [[ "$nome" == "BANCO" ]]; then
            printf "\n"
            printf "%s\n" "${tracejada}"
            printf "%s\n" "O sistema usa banco de dados?"
            printf "%s\n" "1) Sim"
            printf "%s\n" "2) Nao"
            read -rp "Opcao [1-2]: " opcao
            case "$opcao" in
            1) BANCO="s" ;;
            2) BANCO="n" ;;
            *) echo "Opcao invalida. Mantendo valor anterior: $valor_atual" ;;
            esac

        elif [[ "$nome" == "acessossh" ]]; then
            printf "\n"
            printf "%s\n" "${tracejada}"
            printf "%s\n" "Metodo de acesso facil?"
            printf "%s\n" "1) Sim"
            printf "%s\n" "2) Nao"
            read -rp "Opcao [1-2]: " opcao
            case "$opcao" in
            1) acessossh="s" ;;
            2) acessossh="n" ;;
            *) echo "Opcao invalida. Mantendo valor anterior: $valor_atual" ;;
            esac

        elif [[ "$nome" == "IPSERVER" ]]; then
            printf "\n"
            printf "%s\n" "${tracejada}"
            read -rp "Digite o IP do Servidor SAV (ou pressione Enter para manter $valor_atual): " novo_ip
        if [[ -n "$novo_ip" ]]; then
            IPSERVER="$novo_ip"
        else
            IPSERVER="$valor_atual"
            echo "Mantendo valor anterior: $valor_atual"
        fi    

        elif [[ "$nome" == "Offline" ]]; then
            printf "\n"
            printf "%s\n" "${tracejada}"
            printf "%s\n" "O sistema em modo Offline ?"
            printf "%s\n" "1) Sim"
            printf "%s\n" "2) Nao"
            read -rp "Opcao [1-2]: " opcao
            case "$opcao" in
            1) Offline="s" ;;
            2) Offline="n" ;;
            *) printf "%s\n" "Opcao invalida. Mantendo valor anterior: $valor_atual" ;;
            esac
        else
            read -rp "Novo valor para ${nome}: " novo_valor
            eval "$nome=\"$novo_valor\""
        fi
    fi
    printf "%s\n" "${tracejada}"
}
_manutencao_setup() {
# Atualiza as variáveis SAVATU* com base na verclass
atualizar_savatu_variaveis() {
    local ano="${verclass}"
    local sufixo="IS${ano}"

    SAVATU="tempSAV_${sufixo}_*_"
    SAVATU1="tempSAV_${sufixo}_classA_"
    SAVATU2="tempSAV_${sufixo}_classB_"
    SAVATU3="tempSAV_${sufixo}_tel_isc_"
    SAVATU4="tempSAV_${sufixo}_xml_"

    echo "Variaveis SAVATU atualizadas com base em verclass:"
    echo "SAVATU=$SAVATU"
    echo "SAVATU1=$SAVATU1"
    echo "SAVATU2=$SAVATU2"
    echo "SAVATU3=$SAVATU3"
    echo "SAVATU4=$SAVATU4"
    echo ${tracejada}
}

# Se os arquivos existem, carrega e pergunta se quer editar campo a campo
if [[ -f ".atualizac" ]]; then
    echo "=================================================="
    echo "Arquivo .atualizac ja existem."
    echo "Carregando parametros para edicao..."
    echo "=================================================="
    echo

    # Carrega os valores existentes do arquivo .atualizac
    "." ./.atualizac || {
        echo "Erro: Falha ao carregar .atualizac"
        exit 1
    }

    # Faz backup dos arquivos
    cp .atualizac .atualizac.bak || {
        echo "Erro: Falha ao criar backup de .atualizac"
        exit 1
    }
fi

clear

    # Edita as variáveis
    editar_variavel sistema
    editar_variavel verclass

    if [[ -n "$verclass" ]]; then
        verclass_sufixo="${verclass: -2}"
        class="-class${verclass_sufixo}"
        mclass="-mclass${verclass_sufixo}"
        echo "class e mclass foram atualizados automaticamente:"
        echo "class=${class}"
        echo "mclass=${mclass}"
        atualizar_savatu_variaveis
    else
        editar_variavel class
        editar_variavel mclass
    fi

    editar_variavel BANCO
    editar_variavel destino
    editar_variavel acessossh
    editar_variavel IPSERVER
    editar_variavel Offline
    editar_variavel ENVIABACK
    editar_variavel EMPRESA
    editar_variavel base
    editar_variavel base2
    editar_variavel base3

    # Recria .atualizac
    echo "Recriando .atualizac com os novos parametros..."
    echo ${tracejada}

    {
        echo "sistema=${sistema}"
        [[ -n "$verclass" ]] && echo "verclass=${verclass}"
        [[ -n "$class" ]] && echo "class=${class}"
        [[ -n "$mclass" ]] && echo "mclass=${mclass}"
        [[ -n "$BANCO" ]] && echo "BANCO=${BANCO}"
        [[ -n "$destino" ]] && echo "destino=${destino}"
        [[ -n "$acessossh" ]] && echo "acessossh=${acessossh}"
        [[ -n "$IPSERVER" ]] && echo "IPSERVER=${IPSERVER}"      
        [[ -n "$Offline" ]] && echo "Offline=${Offline}"
        [[ -n "$ENVIABACK" ]] && echo "ENVIABACK=${ENVIABACK}"
        [[ -n "$EMPRESA" ]] && echo "EMPRESA=${EMPRESA}"
        [[ -n "$base" ]] && echo "base=${base}"
        [[ -n "$base2" ]] && echo "base2=${base2}"
        [[ -n "$base3" ]] && echo "base3=${base3}"
        echo "exec=sav/classes"
        echo "telas=sav/tel_isc"
        echo "xml=sav/xml"
        echo "SAVATU=${SAVATU}"
        echo "SAVATU1=${SAVATU1}"
        echo "SAVATU2=${SAVATU2}"
        echo "SAVATU3=${SAVATU3}"
        echo "SAVATU4=${SAVATU4}"
        echo "pasta=/sav/tools"
        echo "progs=/progs"
        echo "olds=/olds"
        echo "logs=/logs"
        echo "cfg=/cfg"
        echo "backup=/backup"
    } >.atualizac

    echo
    echo "Arquivo .atualizac atualizado com sucesso!"
    echo
    echo ${tracejada}
    
if [[ "${acessossh}" = "s" ]]; then

# CONFIGURAÇÕES PERSONALIZÁVEIS (ALTERE AQUI OU VIA VARIÁVEIS DE AMBIENTE)
SERVER_IP="${IPSERVER}"        # IP do servidor (padrão: 177.45.80.10)
SERVER_PORT="${SERVER_PORT:-41122}"            # Porta SFTP (padrão: 41122)
SERVER_USER="${SERVER_USER:-atualiza}"         # Usuário SSH (padrão: atualiza)
CONTROL_PATH_BASE="${CONTROL_PATH_BASE:-${TOOLS}/.ssh/control}"
# VALIDAÇÃO DAS VARIÁVEIS OBRIGATÓRIAS
if [[ -z "$SERVER_IP" || -z "$SERVER_PORT" || -z "$SERVER_USER" ]]; then
    echo "Erro: Variaveis obrigatorias nao definidas!"
    echo "Defina via ambiente ou edite as configuracoes no inicio do script:"
    echo "  export SERVER_IP='seu.ip.aqui'"
    echo "  export SERVER_PORT='porta'"
    echo "  export SERVER_USER='usuario'"
    exit 1
fi

# PREPARAÇÃO DOS DIRETÓRIOS
SSH_CONFIG_DIR="$(dirname "$CONTROL_PATH_BASE")"
CONTROL_PATH="$CONTROL_PATH_BASE"

# Verifica/cria diretório base
if [[ ! -d "$SSH_CONFIG_DIR" ]]; then
    echo "Criando diretorio $SSH_CONFIG_DIR..."
    mkdir -p "$SSH_CONFIG_DIR" || {
        echo "Falha: Permissao negada para criar $SSH_CONFIG_DIR. Use sudo se necessario."
        exit 1
    }
    chmod 700 "$SSH_CONFIG_DIR"
fi

# Verifica/cria diretório de controle
if [[ ! -d "$CONTROL_PATH" ]]; then
    echo "Criando diretorio de controle $CONTROL_PATH..."
    mkdir -p "$CONTROL_PATH" || {
        echo "Falha: Permissao negada para criar $SSH_CONFIG_DIR."
        exit 1
    }
    chmod 700 "$CONTROL_PATH"
fi

# CONFIGURAÇÃO SSH
if [[ ! -f "/root/.ssh/config" ]]; then
    mkdir -p "/root/.ssh"
    chmod 700 "/root/.ssh"
    
    # Injeta as variáveis diretamente na configuração (sem aspas em EOF para expansão)
    cat << EOF >> "/root/.ssh/config"
Host sav_servidor
    HostName $SERVER_IP
    Port $SERVER_PORT
    User $SERVER_USER
    ControlMaster auto
    ControlPath $CONTROL_PATH/%r@%h:%p
    ControlPersist 10m
EOF
    chmod 600 "/root/.ssh/config"
    echo "Configuracao SSH criada com parametros:"
else
    echo "Arquivo de configuracao ja existe regravando: /root/.ssh/config"
    
    # Verifica se a configuração específica já está presente
        cat << EOF >> "/root/.ssh/config"
# Configuração adicionada automaticamente
Host sav_servidor
    HostName $SERVER_IP
    Port $SERVER_PORT
    User $SERVER_USER
    ControlMaster auto
    ControlPath $CONTROL_PATH/%r@%h:%p
    ControlPersist 10m
EOF
        echo "Configuracao 'sav_servidor' adicionada com parametros:"
    fi
fi
_linha
# EXIBE OS PARÂMETROS UTILIZADOS
echo -e "\n   IP do Servidor:   $SERVER_IP"
echo "   Porta:            $SERVER_PORT"
echo "   Usuário:          $SERVER_USER"
echo "   ControlPath:      $CONTROL_PATH/%r@%h:%p"
echo -e "\n Validacao concluida! Teste com:"
echo "   sftp sav_servidor"
echo
echo
_linha
_press 
exit 1

}
