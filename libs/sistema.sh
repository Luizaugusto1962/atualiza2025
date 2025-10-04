#!/usr/bin/env bash
#
# sistema.sh - Módulo de Informações do Sistema
# Responsável por informações do IsCOBOL, Linux, parâmetros e atualizações
#

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
cfg="${cfg:-}"
verclass="${verclass:-}"
backup="${backup:-}"
class="${class:-}"
mclass="${mclass:-}"
exec="${exec:-}"
xml="${xml:-}"
olds="${olds:-}"

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
    if [[ "${SERACESOFF}" == "s" ]]; then
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
    printf "${GREEN}Servidor OFF: ${NORM}${SERACESOFF}""%*s\n"
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
    if [[ "${SERACESOFF}" == "n" ]]; then
        _atualizar_online
        export tipo_online 
    else
        _atualizar_offline
        export tipo_offline
    fi
    _press
}

# Atualização online via GitHub
_atualizar_online() {
#        cd "${LIB_DIR}" || exit 1
#    local link="https://codeload.github.com/Luizaugusto1962/atualiza2025/zip/refs/tags/Atualiza"
    local link="https://github.com/Luizaugusto1962/Atualiza2025/archive/master/atualiza.zip"
    local zipfile="atualiza.zip"
    local temp_dir="${ENVIA}"
       # Criar e acessar diretório temporário
    mkdir -p "$temp_dir" || {
        _mensagec "${RED}" "Erro: Nao foi possivel criar o diretorio temporario $temp_dir."
        return 1
    }
    _atualizando
}
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
#    cd "$temp_dir" || {
#        _mensagec "${RED}" "Erro: Nao foi possivel acessar o diretorio temporario $temp_dir."
#        return 1
#    }
    # Processar todos os arquivos .sh encontrados
    for arquivo in *.sh; do
        # Verificar se o arquivo existe
        if [[ ! -f "$arquivo" ]]; then
            _mensagec "${YELLOW}" "Aviso: Nenhum arquivo .sh encontrado para processar"
            break
        else
            chmod +x "$arquivo"    
        fi
        
        # Mover o arquivo para o diretório de destino
        if [ "$arquivo" = "atualiza.sh" ]; then
            if mv -f "$arquivo" "${TOOLS}"; then
                _mensagec "${GREEN}" "Arquivo $arquivo instalado com sucesso"
                ((arquivos_instalados++))
            else
            _mensagec "${RED}" "Erro ao instalar $arquivo"
            ((arquivos_erro++))
            fi
        fi        # Mover o arquivo para o diretório de destino

        if mv -f "$arquivo" "${LIB_DIR}"; then
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

# Atualização offline via arquivo local
_atualizar_offline() {
    local temp_dir="${ENVIA}/temp_update/"
    local dir_offline="$destino$SERACESOFF"
    local zipfile="atualiza.zip"

    # Criar e acessar diretório temporário
    mkdir -p "$temp_dir" || {
        _mensagec "${RED}" "Erro: Nao foi possivel criar o diretorio temporario $temp_dir."
        return 1
    }

    # Acessar diretório offline
    cd "$dir_offline" || {
        _mensagec "${RED}" "Erro: Diretório offline $dir_offline não acessível"
        return 1
    }

    # Verificar se o arquivo zip existe
    if [[ ! -f "$zipfile" ]]; then
        _mensagec "${RED}" "Erro: $zipfile não encontrado em $dir_offline"
        return 1
    fi
    mv $zipfile "$temp_dir"
    _atualizando
}


# Constantes
readonly tracejada="#-------------------------------------------------------------------#"

