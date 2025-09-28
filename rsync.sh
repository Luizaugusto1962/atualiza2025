#!/usr/bin/env bash
#
# rsync.sh - Módulo de Operações de Sincronização
# Responsável por operações de download/upload via rsync, sftp e ssh
#
destino="${destino:-}"
sistema="${sistema:-}"
acessossh="${acessossh:-}"
cmd_zip="${cmd_zip:-}"
cmd_unzip="${cmd_unzip:-}"
cmd_find="${cmd_find:-}"
#---------- CONFIGURAÇÕES DE CONEXÃO ----------#

# Configura parâmetros de conexão
_configurar_conexao() {
    # Validar parâmetros essenciais
    local parametros_obrigatorios=(
        "PORTA" 
        "USUARIO" 
        "IPSERVER"
    )
    
    for param in "${parametros_obrigatorios[@]}"; do
        if [[ -z "${!param}" ]]; then
            _mensagec "${RED}" "Erro: Parâmetro ${param} não configurado"
            return 1
        fi
    done
    
    # Configurar destinos se não definidos
    if [[ -z "${DESTINO2}" ]]; then
        case "${sistema}" in
            "iscobol") DESTINO2="${DESTINO2SAVATUISC}" ;;
            *) DESTINO2="${DESTINO2SAVATUMF}" ;;
        esac
    fi
    
    return 0
}

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

#---------- FUNÇÕES DE DOWNLOAD ----------#

# Download via SFTP
_download_sftp() {
    local arquivo_remoto="$1"
    local destino_local="${2:-.}"
    local servidor="${3:-$IPSERVER}"
    local porta="${4:-$PORTA}"
    local usuario="${5:-$USUARIO}"
    
    if [[ -z "$arquivo_remoto" ]]; then
        _mensagec "${RED}" "Erro: Arquivo remoto não especificado"
        return 1
    fi
    
    _log "Iniciando download SFTP: ${arquivo_remoto}"
    
    # Verificar conectividade
    if ! _testar_conexao "$servidor" "$porta"; then
        _mensagec "${RED}" "Erro: Não foi possível conectar ao servidor ${servidor}:${porta}"
        return 1
    fi
    
    # Executar SFTP
    if sftp -P "$porta" "${usuario}@${servidor}:${arquivo_remoto}" "$destino_local"; then
        _log_sucesso "Download SFTP concluído: ${arquivo_remoto}"
        return 0
    else
        _log_erro "Falha no download SFTP: ${arquivo_remoto}"
        return 1
    fi
}

# Download via SFTP com chave SSH configurada
_download_sftp_ssh() {
    local arquivo_remoto="$1"
    local destino_local="${2:-.}"
    
    _log "Iniciando download SFTP com chave SSH: ${arquivo_remoto}"
    
    sftp sav_servidor <<EOF
get "${arquivo_remoto}" "${destino_local}"
quit
EOF
    
    local status=$?
    if (( status == 0 )); then
        _log_sucesso "Download SFTP SSH concluído: ${arquivo_remoto}"
    else
        _log_erro "Falha no download SFTP SSH: ${arquivo_remoto}"
    fi
    
    return $status
}

# Download via RSYNC
_download_rsync() {
    local origem_remota="$1"
    local destino_local="${2:-.}"
    local servidor="${3:-$IPSERVER}"
    local porta="${4:-$PORTA}"
    local usuario="${5:-$USUARIO}"
    
    if [[ -z "$origem_remota" ]]; then
        _mensagec "${RED}" "Erro: Origem remota não especificada"
        return 1
    fi
    
    _log "Iniciando download RSYNC: ${origem_remota}"
    
    local origem_completa="${usuario}@${servidor}:${origem_remota}"
    
    if rsync -avzP -e "ssh -p ${porta}" "$origem_completa" "$destino_local"; then
        _log_sucesso "Download RSYNC concluído: ${origem_remota}"
        return 0
    else
        _log_erro "Falha no download RSYNC: ${origem_remota}"
        return 1
    fi
}

#---------- FUNÇÕES DE UPLOAD ----------#

# Upload via SFTP
_upload_sftp() {
    local arquivo_local="$1"
    local destino_remoto="$2"
    local servidor="${3:-$IPSERVER}"
    local porta="${4:-$PORTA}"
    local usuario="${5:-$USUARIO}"
    
    if [[ ! -f "$arquivo_local" ]]; then
        _mensagec "${RED}" "Erro: Arquivo local não encontrado: ${arquivo_local}"
        return 1
    fi
    
    if [[ -z "$destino_remoto" ]]; then
        _mensagec "${RED}" "Erro: Destino remoto não especificado"
        return 1
    fi
    
    _log "Iniciando upload SFTP: ${arquivo_local} -> ${destino_remoto}"
    
    # Verificar conectividade
    if ! _testar_conexao "$servidor" "$porta"; then
        _mensagec "${RED}" "Erro: Não foi possível conectar ao servidor"
        return 1
    fi
    
    if sftp -P "$porta" "${usuario}@${servidor}" <<EOF
put "${arquivo_local}" "${destino_remoto}"
quit
EOF
    then
        _log_sucesso "Upload SFTP concluído: ${arquivo_local}"
        return 0
    else
        _log_erro "Falha no upload SFTP: ${arquivo_local}"
        return 1
    fi
}

# Upload via RSYNC
_upload_rsync() {
    local arquivo_local="$1"
    local destino_remoto="$2"
    local servidor="${3:-$IPSERVER}"
    local porta="${4:-$PORTA}"
    local usuario="${5:-$USUARIO}"
    
    if [[ ! -f "$arquivo_local" ]]; then
        _mensagec "${RED}" "Erro: Arquivo local não encontrado: ${arquivo_local}"
        return 1
    fi
    
    _log "Iniciando upload RSYNC: ${arquivo_local}"
    
    local destino_completo="${usuario}@${servidor}:${destino_remoto}"
    
    if rsync -avzP -e "ssh -p ${porta}" "$arquivo_local" "$destino_completo"; then
        _log_sucesso "Upload RSYNC concluído: ${arquivo_local}"
        return 0
    else
        _log_erro "Falha no upload RSYNC: ${arquivo_local}"
        return 1
    fi
}

#---------- FUNÇÕES DE SINCRONIZAÇÃO DE BIBLIOTECA ----------#

# Sincroniza biblioteca completa
_sincronizar_biblioteca() {
    local versao="$1"
    local tipo_sistema="${2:-$sistema}"
    
    if [[ -z "$versao" ]]; then
        _mensagec "${RED}" "Erro: Versão não especificada"
        return 1
    fi
    
    _configurar_conexao || return 1
    
    _definir_variaveis_biblioteca_rsync "$versao"
    
    local arquivos_sync
    if [[ "$tipo_sistema" == "iscobol" ]]; then
        arquivos_sync=("${SYNC_ATUALIZA1}" "${SYNC_ATUALIZA2}" "${SYNC_ATUALIZA3}" "${SYNC_ATUALIZA4}")
    else
        arquivos_sync=("${SYNC_ATUALIZA1}" "${SYNC_ATUALIZA2}" "${SYNC_ATUALIZA3}")
    fi
    
    _mensagec "${YELLOW}" "Sincronizando biblioteca versão ${versao}..."
    _linha
    
    local falhas=0
    for arquivo in "${arquivos_sync[@]}"; do
        _mensagec "${GREEN}" "Sincronizando: $(basename "$arquivo")"
        
        if [[ "${acessossh}" == "n" ]]; then
            if ! _download_sftp "$arquivo"; then
                ((falhas++))
                continue
            fi
        else
            if ! _download_sftp_ssh "$arquivo"; then
                ((falhas++))
                continue
            fi
        fi
        
        _mensagec "${GREEN}" "Concluído: $(basename "$arquivo")"
        _linha
    done
    
    if (( falhas > 0 )); then
        _mensagec "${YELLOW}" "Sincronização concluída com ${falhas} falha(s)"
        return 1
    else
        _mensagec "${GREEN}" "Sincronização concluída com sucesso!"
        return 0
    fi
}

# Define variáveis de arquivos para sincronização
_definir_variaveis_biblioteca_rsync() {
    local versao="$1"
    
    case "${DESTINO2}" in
        *"trans_pc"*)
            SYNC_ATUALIZA1="${DESTINO2TRANSPC}${SAVATU1}${versao}.zip"
            SYNC_ATUALIZA2="${DESTINO2TRANSPC}${SAVATU2}${versao}.zip"
            SYNC_ATUALIZA3="${DESTINO2TRANSPC}${SAVATU3}${versao}.zip"
            SYNC_ATUALIZA4="${DESTINO2TRANSPC}${SAVATU4}${versao}.zip"
            ;;
        *"ISCobol"*)
            SYNC_ATUALIZA1="${DESTINO2SAVATUISC}${SAVATU1}${versao}.zip"
            SYNC_ATUALIZA2="${DESTINO2SAVATUISC}${SAVATU2}${versao}.zip"
            SYNC_ATUALIZA3="${DESTINO2SAVATUISC}${SAVATU3}${versao}.zip"
            SYNC_ATUALIZA4="${DESTINO2SAVATUISC}${SAVATU4}${versao}.zip"
            ;;
        *)
            SYNC_ATUALIZA1="${DESTINO2SAVATUMF}${SAVATU1}${versao}.zip"
            SYNC_ATUALIZA2="${DESTINO2SAVATUMF}${SAVATU2}${versao}.zip"
            SYNC_ATUALIZA3="${DESTINO2SAVATUMF}${SAVATU3}${versao}.zip"
            SYNC_ATUALIZA4="${DESTINO2SAVATUMF}${SAVATU4}${versao}.zip"
            ;;
    esac
}

#---------- FUNÇÕES DE VERIFICAÇÃO ----------#

# Verifica integridade do arquivo baixado
_verificar_integridade() {
    local arquivo="$1"
    local tamanho_minimo="${2:-1024}" # 1KB por padrão
    
    if [[ ! -f "$arquivo" ]]; then
        _log_erro "Arquivo não existe: $arquivo"
        return 1
    fi
    
    if [[ ! -s "$arquivo" ]]; then
        _log_erro "Arquivo vazio: $arquivo"
        return 1
    fi
    
    local tamanho_arquivo
    tamanho_arquivo=$(stat -c%s "$arquivo" 2>/dev/null || echo "0")
    
    if (( tamanho_arquivo < tamanho_minimo )); then
        _log_erro "Arquivo muito pequeno (${tamanho_arquivo} bytes): $arquivo"
        return 1
    fi
    
    # Verificar se é arquivo ZIP válido
    if [[ "$arquivo" == *.zip ]]; then
        if ! "${cmd_unzip}" -t "$arquivo" >/dev/null 2>&1; then
            _log_erro "Arquivo ZIP corrompido: $arquivo"
            return 1
        fi
    fi
    
    _log_sucesso "Integridade verificada: $arquivo (${tamanho_arquivo} bytes)"
    return 0
}

# Lista arquivos no servidor remoto
_listar_arquivos_remotos() {
    local diretorio_remoto="$1"
    local servidor="${2:-$IPSERVER}"
    local porta="${3:-$PORTA}"
    local usuario="${4:-$USUARIO}"
    
    if [[ -z "$diretorio_remoto" ]]; then
        _mensagec "${RED}" "Erro: Diretório remoto não especificado"
        return 1
    fi
    
    _log "Listando arquivos em: ${servidor}:${diretorio_remoto}"
    
    sftp -P "$porta" "${usuario}@${servidor}" <<EOF
cd "${diretorio_remoto}"
ls -la
quit
EOF
}

#---------- FUNÇÕES DE LIMPEZA ----------#

# Remove arquivos temporários de sincronização
_limpar_temporarios_sync() {
    local diretorios_temp=(
        "${TOOLS}/temp_sync"
        "${ENVIA}/temp_update"
        "${RECEBE}/temp_download"
    )
    
    for dir in "${diretorios_temp[@]}"; do
        if [[ -d "$dir" ]]; then
            _log "Removendo diretório temporário: $dir"
            rm -rf "$dir"
        fi
    done
    
    # Remover arquivos .part (downloads incompletos)
    find "${TOOLS}" "${ENVIA}" "${RECEBE}" -name "*.part" -type f -delete 2>/dev/null || true
    
    _log "Limpeza de temporários de sincronização concluída"
}

#---------- FUNÇÕES DE CONFIGURAÇÃO SSH ----------#

# Configura chaves SSH se necessário
_configurar_ssh() {
    local ssh_dir="$HOME/.ssh"
    local config_ssh="$ssh_dir/config"
    
    # Criar diretório .ssh se não existir
    if [[ ! -d "$ssh_dir" ]]; then
        mkdir -p "$ssh_dir"
        chmod 700 "$ssh_dir"
    fi
    
    # Verificar se existe configuração para sav_servidor
    if [[ -f "$config_ssh" ]] && grep -q "Host sav_servidor" "$config_ssh"; then
        _log "Configuração SSH já existe para sav_servidor"
        return 0
    fi
    
    _log "Configuração SSH não encontrada - usando método padrão"
    return 1
}

#---------- FUNÇÕES DE RETRY ----------#

# Executa comando com retry automático
_executar_com_retry() {
    local comando="$1"
    local max_tentativas="${2:-3}"
    local intervalo="${3:-5}"
    local tentativa=1
    
    while (( tentativa <= max_tentativas )); do
        _log "Tentativa ${tentativa}/${max_tentativas}: ${comando}"
        
        if eval "$comando"; then
            _log_sucesso "Comando executado com sucesso na tentativa ${tentativa}"
            return 0
        else
            _log_erro "Falha na tentativa ${tentativa}"
            if (( tentativa < max_tentativas )); then
                _log "Aguardando ${intervalo}s antes da próxima tentativa..."
                sleep "$intervalo"
            fi
            ((tentativa++))
        fi
    done
    
    _log_erro "Comando falhou após ${max_tentativas} tentativas: ${comando}"
    return 1
}