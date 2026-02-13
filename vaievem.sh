#!/usr/bin/env bash
#
# vaievem.sh - Modulo de Operacoes de Sincronizacao
# Responsavel por operacoes de download/upload via rsync, sftp e ssh
#
# SISTEMA SAV - Script de Atualizacao Modular
# Versao: 10/02/2026-00

#---------- CONFIGURACOES DE CONEXAO ----------#

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

#---------- FUNcoES DE DOWNLOAD ----------#

# Download via SFTP
_download_sftp() {
    local arquivo_remoto="$1"
    local destino_local="${2:-.}"
    local servidor="${3:-$IPSERVER}"
    local porta="${4:-$PORTA}"
    local usuario="${5:-$USUARIO}"
    
    if [[ -z "$arquivo_remoto" ]]; then
        _mensagec "${RED}" "Erro: Arquivo remoto nao especificado"
        return 1
    fi
    
    _log "Iniciando download SFTP: ${arquivo_remoto}"
    
    # Verificar conectividade
    if ! _testar_conexao "$servidor" "$porta"; then
        _mensagec "${RED}" "Erro: Nao foi possivel conectar ao servidor ${servidor}:${porta}"
        return 1
    fi
    
    # Executar SFTP
    if sftp -P "$porta" "${usuario}@${servidor}:${arquivo_remoto}" "$destino_local"; then
        _log_sucesso "Download SFTP concluido: ${arquivo_remoto}"
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
        _log_sucesso "Download SFTP SSH concluido: ${arquivo_remoto}"
    else
        _log_erro "Falha no download SFTP SSH: ${arquivo_remoto}"
    fi
    
    return $status
}


#---------- FUNcoES DE UPLOAD ----------#

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

