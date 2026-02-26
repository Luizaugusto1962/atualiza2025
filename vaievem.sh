#!/usr/bin/env bash
#
# vaievem.sh - Modulo de Operacoes de Sincronizacao
# Responsavel por operacoes de download/upload via rsync, sftp e ssh
#
# SISTEMA SAV - Script de Atualizacao Modular
# Versao: 25/02/2026-00
#
#---------- CONFIGURACOES DE CONEXAO ----------#
#
# Variaveis globais esperadas
acessossh="${acessossh:-s}"            # Acesso via SSH (s/n)
arquivo_enviar="${arquivo_enviar:-}"   # Arquivo a ser enviado (pode conter wildcard)
dir_origem="${dir_origem:-.}"          # Diretório de origem para upload
arquivos_encontrados=()                # Array para armazenar arquivos encontrados para envio

# Testa conectividade com o servidor
_testar_conexao() {
    local servidor="$1"
    local porta="$2"
    local timeout="${3:-5}"
    
    if command -v nc >/dev/null 2>&1; then
        if nc -z -w"$timeout" "$servidor" "$porta" 2>/dev/null; then
            return 0
        fi
    elif command -v telnet >/dev/null 2>&1; then
        if timeout "$timeout" telnet "$servidor" "$porta" </dev/null >/dev/null 2>&1; then
            return 0
        fi
    fi
    
    return 1
}

#---------- FUNCOES DE DOWNLOAD ----------#
# Inativado para uso futuro.
# Download via SFTP
#_download_sftp() {
#    local arquivo_remoto="$1"
#    local destino_local="${2:-.}"
#    local servidor="${3:-$IPSERVER}"
#    local porta="${4:-$PORTA}"
#    local usuario="${5:-$USUARIO}"
#    
#    if [[ -z "$arquivo_remoto" ]]; then
#        _mensagec "${RED}" "Erro: Arquivo remoto nao especificado"
#        return 1
#    fi
#    
#    _log "Iniciando download SFTP: ${arquivo_remoto}"
#    
#    # Verificar conectividade
#    if ! _testar_conexao "$servidor" "$porta"; then
#        _mensagec "${RED}" "Erro: Nao foi possivel conectar ao servidor ${servidor}:${porta}"
#        return 1
#    fi
#    
#    # Executar SFTP
#    if sftp -P "$porta" "${usuario}@${servidor}:${arquivo_remoto}" "$destino_local"; then
#        _log_sucesso "Download SFTP concluido: ${arquivo_remoto}"
#        return 0
#    else
#        _log_erro "Falha no download SFTP: ${arquivo_remoto}"
#        return 1
#    fi
#}

# Download via SFTP com chave SSH configurada
_download_sftp_ssh() {
    local arquivo_remoto="$1"
    local destino_local="${2:-.}"
    
    _log "Iniciando download SFTP com chave SSH: ${arquivo_remoto}"
    # Executar SFTP   
    sftp sav_servidor <<EOF
get "${arquivo_remoto}" "${destino_local}"
quit
EOF
    
    local status=$?
    if (( status == 0 )); then
        _log_sucesso "Download SFTP SSH concluido: ${arquivo_remoto}"
    else
        _log_erro "Falha no download SFTP SSH: ${arquivo_remoto}"
    fi
    
    return $status
}

# Download via SCP com chave SSH configurada
_download_scp() {
    local arquivo_remoto="$1"
    local destino_local="${2:-.}"
    local servidor="${3:-$IPSERVER}"
    local porta="${4:-$PORTA}"
    local usuario="${5:-$USUARIO}"    

    _log "Iniciando download SCP: ${arquivo_remoto}"
    # Executar SCP
    if scp -P "$porta" "${usuario}@${servidor}:${arquivo_remoto}" "$destino_local"; then
        _log_sucesso "Download SCP concluido: ${arquivo_remoto}"
        return 0
    else
        _log_erro "Falha no download SCP: ${arquivo_remoto}"
        return 1
    fi
}


#---------- FUNcoES DE UPLOAD ----------#
#
# Upload via RSYNC
_upload_rsync() {
    local arquivo_local="$1"
    local destino_remoto="$2"
    local servidor="${3:-$IPSERVER}"
    local porta="${4:-$PORTA}"
    local usuario="${5:-$USUARIO}"
    
    if [[ ! -f "$arquivo_local" ]]; then
        _mensagec "${RED}" "Erro: Arquivo local nao encontrado: ${arquivo_local}"
        return 1
    fi
    
    _log "Iniciando upload RSYNC: ${arquivo_local}"
    
    local destino_completo="${usuario}@${servidor}:${destino_remoto}"
    
    if rsync -avzP -e "ssh -p ${porta}" "$arquivo_local" "$destino_completo"; then
        _log_sucesso "Upload RSYNC concluido: ${arquivo_local}"
        return 0
    else
        _log_erro "Falha no upload RSYNC: ${arquivo_local}"
        return 1
    fi
}

#---------- FUNCOES DE DOWNLOAD ----------#
#
# Download biblioteca via SFTP (funcao principal)
_baixar_biblioteca_sincroniza() {
    _log "Iniciando download da biblioteca: ${SAVATU}${VERSAO}"

    # Criar diretório de recebimento se não existir
    [[ ! -d "${RECEBE}" ]] && mkdir -p "${RECEBE}"

    cd "${RECEBE}" || return 1

    if [[ "${acessossh}" == "s" ]]; then
        local src="${USUARIO}@${IPSERVER}:${DESTINO2}${SAVATU}${VERSAO}.zip"

        if sftp -P "$PORTA" "${src}" "."; then
            _log_sucesso "Download da biblioteca concluido: ${SAVATU}${VERSAO}.zip"
            return 0
        else
            _log_erro "Falha no download da biblioteca: ${SAVATU}${VERSAO}.zip"
            return 1
        fi
    else
        _definir_variaveis_biblioteca

        local arquivos_update
        read -ra arquivos_update <<< "$(_obter_arquivos_atualizacao)"

        if [[ ${#arquivos_update[@]} -eq 0 ]]; then
            _mensagec "${RED}" "Erro: Nenhum arquivo de atualizacao encontrado"
            return 1
        fi

        for arquivo in "${arquivos_update[@]}"; do
            local src="${USUARIO}@${IPSERVER}:${DESTINO2}${arquivo}"

            if scp -P "$PORTA" "${src}" "."; then
                _log_sucesso "Download concluido: ${arquivo}"
            else
                _log_erro "Falha no download: ${arquivo}"
                return 1
            fi
        done

        return 0
    fi
}

# Enviar arquivo(s) via RSYNC. Pode lidar com arquivos únicos ou múltiplos usando wildcard.
_enviar_arquivo_multi() {
   # Verificar se está enviando múltiplos arquivos ou apenas um
    if [[ "$arquivo_enviar" == *"*"* ]]; then
        # Enviar múltiplos arquivos usando _upload_rsync do vaievem.sh
        local falhas_envio=0
        for arquivo_item in "${arquivos_encontrados[@]}"; do
            if ! _upload_rsync "$arquivo_item" "${destino_remoto}/"; then
                ((falhas_envio++))
            fi
        done
        if (( falhas_envio == 0 )); then
            _mensagec "${YELLOW}" "Arquivo(s) enviado(s) para \"${destino_remoto}\""
            _linha
            _read_sleep 3
        else
            _mensagec "${RED}" "Erro no envio de ${falhas_envio} arquivo(s)"
            _press
        fi
    else
        # Enviar arquivo único usando _upload_rsync do vaievem.sh
        if _upload_rsync "${dir_origem}/${arquivo_enviar}" "${destino_remoto}"; then
            _mensagec "${YELLOW}" "Arquivo enviado para \"${destino_remoto}\""
            _linha
            _read_sleep 3
        else
            _mensagec "${RED}" "Erro no envio do arquivo"
            _press
        fi
    fi
}

# Baixa programas via vaievem (SFTP)
_baixar_programas_vaievem() {
    # Criar diretório RECEBE se não existir
    [[ ! -d "${RECEBE}" ]] && mkdir -p "${RECEBE}"
    
    # Ir para o diretório RECEBE
    cd "${RECEBE}" || return 1

    if (( ${#ARQUIVOS_PROGRAMA[@]} == 0 )); then
        return 1
    fi

    _linha
    _mensagec "${YELLOW}" "Realizando sincronizacao dos arquivos..."

    for arquivo in "${ARQUIVOS_PROGRAMA[@]}"; do
        _linha
        _mensagec "${GREEN}" "Transferindo: $arquivo"
        _linha

        if [[ "${acessossh}" == "s" ]]; then
            _mensagec "${YELLOW}" "Informe a senha para o usuario remoto:"
            _linha
            _mensagec "${GREEN}" "Transferindo: $arquivo"

            if ! _download_sftp_ssh "${DESTINO2SERVER}${arquivo}" "."; then
                _mensagec "${RED}" "Falha no download: $arquivo"
                continue
            fi
        else
            if ! _download_scp "${DESTINO2SERVER}${arquivo}" "."; then
                _mensagec "${RED}" "Falha no download: $arquivo"
                continue
            fi
        fi
        _linha
        # Verificar se arquivo foi baixado
        if [[ ! -f "$arquivo" || ! -s "$arquivo" ]]; then
            _mensagec "${RED}" "ERRO: Falha ao baixar '$arquivo'"
            continue
        fi

        if ! unzip -t "$arquivo" >/dev/null 2>&1; then
           _mensagec "${RED}" "ERRO: Arquivo corrompido: $arquivo"
           rm -f "$arquivo"
           continue
        fi
        _mensagec "${GREEN}" "Download concluido: $arquivo"
    done
}
