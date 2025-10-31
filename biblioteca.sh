#!/usr/bin/env bash
#
# biblioteca.sh - Módulo de Gestão de Biblioteca
# Responsável pela atualização das bibliotecas do sistema (Transpc, Savatu)
#
# SISTEMA SAV - Script de Atualizaçao Modular
# Versao: 10/10/2025-00

destino="${destino:-}"
sistema="${sistema:-}"
cmd_zip="${cmd_zip:-}"
cmd_unzip="${cmd_unzip:-}"
cmd_find="${cmd_find:-}"
acessossh="${acessossh:-}"
Offline="${Offline:-}"
down_dir="${down_dir:-}"

declare -g pids=()  # Array global para rastrear PIDs de background

# Função de cleanup em caso de interrupção
_limpar_interrupcao() {
    local sinal="$1"
    _log "Interrupção detectada (sinal: $sinal). Limpando processos..."
    
    # Matar todos os PIDs pendentes
    for pid in "${pids[@]}"; do
        if kill -0 "$pid" 2>/dev/null; then
            kill "$pid" 2>/dev/null || true
            _log "Processo PID $pid interrompido"
        fi
    done
    pids=()  # Limpar array
    
    # Limpeza de temporários (ex: zips parciais ou descompactados incompletos)
    cd "${TOOLS}" 2>/dev/null || true

    for temp_file in *"${VERSAO}".zip *"${VERSAO}".bkp; do
        if [[ -f "$temp_file" ]]; then
            rm -f "$temp_file" 
            _log "Arquivo temporário removido: $temp_file"
        fi
    done
    
    # Verificar se backup parcial existe e sugerir rollback
    local ultimo_backup="${OLDS}/backup-*.zip"
    if [[ -n "$(ls -A "$ultimo_backup" 2>/dev/null)" ]]; then
        _mensagec "${YELLOW}" "Backup parcial encontrado. Considere reverter manualmente com '_reverter_biblioteca'"
    fi
    
    _log "Cleanup concluído. Saída forçada."
    _press  # Pausa para o usuário ver a mensagem
    return 1
}

# Configurar traps (SIGINT=2 para Ctrl+C, SIGTERM=15 para kill)
trap '_limpar_interrupcao INT' INT
trap '_limpar_interrupcao TERM' TERM

#---------- FUNÇÕES PRINCIPAIS DE ATUALIZAÇÃO ----------#

# Atualização do Transpc
_atualizar_transpc() {
    clear
    _solicitar_versao_biblioteca
    
    if [[ -z "${VERSAO}" ]]; then
        return 1
    fi

    if [[ "${Offline}" == "s" ]]; then
        _linha
        _mensagec "${YELLOW}" "Parâmetro de biblioteca do servidor OFF ativo"
        _linha
        _press
        return 1
    fi
    _linha
    _mensagec "${YELLOW}" "Informe a senha para o usuário remoto:"
    _linha

    DESTINO2="${DESTINO2TRANSPC}"
    _configurar_acessos
    _baixar_biblioteca_rsync
}

# Atualização do Savatu
_atualizar_savatu() {
    clear
    _solicitar_versao_biblioteca
    
    if [[ -z "${VERSAO}" ]]; then
        return 1
    fi

    if [[ "${Offline}" == "s" ]]; then
        _linha
        _mensagec "${YELLOW}" "Parâmetro de biblioteca do servidor OFF ativo"
        _linha
        _press
        return 1
    fi

    _linha
    _mensagec "${YELLOW}" "Informe a senha para o usuário remoto:"
    _linha

    # Selecionar destino baseado no sistema
    if [[ "${sistema}" = "iscobol" ]]; then
        DESTINO2="${DESTINO2SAVATUISC}"
    else
        DESTINO2="${DESTINO2SAVATUMF}"
    fi
    _configurar_acessos
    _baixar_biblioteca_rsync
}

# Atualização offline da biblioteca
_atualizar_biblioteca_offline() {
    clear
    _solicitar_versao_biblioteca
    
    if [[ -z "${VERSAO}" ]]; then
        return 1
    fi

    if [[ "${Offline}" == "s" ]]; then
        _processar_biblioteca_offline
    else
        _salvar_atualizacao_biblioteca
    fi
}

# Reverter biblioteca para versão anterior
_reverter_biblioteca() {
    _meiodatela
    _mensagec "${RED}" "Informe a versão da biblioteca para reverter:"
    _linha
    
    local versao_reverter
    read -rp "${YELLOW}Versão a reverter: ${NORM}" versao_reverter
    _linha

    if [[ -z "${versao_reverter}" ]]; then
        _mensagec "${RED}" "Versão não informada"
        _linha
        _press
        return 1
    fi

    local arquivo_backup="${OLDS}/backup-${versao_reverter}.zip"

    if [[ ! -r "${arquivo_backup}" ]]; then
        _mensagec "${RED}" "Backup da biblioteca não encontrado: ${arquivo_backup}"
        _linha
        _press
        return 1
    fi

    # Perguntar se é reversão completa ou específica
    if _confirmar "Reverter todos os programas da biblioteca?" "N"; then
       _linha 
        _reverter_biblioteca_completa "${arquivo_backup}"
    else
        _linha
        _reverter_programa_especifico_biblioteca "${arquivo_backup}"
    fi
#    _linha 
}

#---------- FUNÇÕES DE PROCESSAMENTO ----------#

# Processa biblioteca offline
_processar_biblioteca_offline() {
    _configurar_acessos
    cd "$down_dir" || return 1

    _definir_variaveis_biblioteca
  
    local -a arquivos_update
    read -ra arquivos_update <<< "$(_obter_arquivos_atualizacao)"

    for arquivo in "${arquivos_update[@]}"; do
        if [[ -f "${down_dir}/${arquivo}" ]]; then
            if mv -f "${down_dir}/${arquivo}" "${TOOLS}"; then
                _mensagec "${GREEN}" "Movendo biblioteca: ${arquivo}"
                _linha
            else
                _mensagec "${RED}" "Erro ao mover arquivo: ${arquivo}"
                return 1
            fi
        else
            _mensagec "${YELLOW}" "Arquivo não encontrado: ${arquivo}"
        fi
    done
    _salvar_atualizacao_biblioteca
    _read_sleep 2
}

# Salva atualização da biblioteca
_salvar_atualizacao_biblioteca() {
    cd "${TOOLS}" || return 1
    clear
    _definir_variaveis_biblioteca

    _linha
    _mensagec "${YELLOW}" "A atualização deve estar no diretório ${TOOLS}"
    _linha

    # Verificar arquivos de atualização
    local -a arquivos_verificar
    read -ra arquivos_verificar <<< "$(_obter_arquivos_atualizacao)"

    for arquivo in "${arquivos_verificar[@]}"; do
        if [[ ! -r "${arquivo}" ]]; then
            _mensagec "${RED}" "Atualização não encontrada ou incompleta: ${arquivo}"
            _linha
            _press
            return 1
        fi
    done

    _processar_atualizacao_biblioteca
}

# Processa a atualização da biblioteca
_processar_atualizacao_biblioteca() {
    local arquivo_backup="backup-${VERSAO}.zip"
    local caminho_backup="${OLDS}/${arquivo_backup}"

    # Inicializar contadores para progresso geral (opcional, para log final)
    local contador=0
    local total_etapas=2 # Para sistemas não-iscobol
    if [[ "$sistema" = "iscobol" ]]; then
        total_etapas=3 # Para iscobol inclui XML
    fi

    # Exibir mensagem inicial
    _linha
    _mensagec "${YELLOW}" "Iniciando compactação dos arquivos anteriores para backup..."
    _linha
    _read_sleep 1

    # Compactação em E_EXEC
    cd "$E_EXEC" || return 1
    {
        "$cmd_find" "$E_EXEC"/ -type f \( -iname "*.class" -o -iname "*.int" -o -iname "*.jpg" -o -iname "*.png" -o -iname "brw*.*" -o -iname "*." -o -iname "*.dll" \) -exec "$cmd_zip" -r -q "${caminho_backup}" {} + >>"${LOG_ATU}" 2>&1
    } &
    local pid_zip_exec=$!
    pids+=("$pid_zip_exec")  # Registrar PID para trap
    _mostrar_progresso_backup "$pid_zip_exec"
    if wait "$pid_zip_exec"; then
        ((contador++))
        _mensagec "${GREEN}" "Compactação de $E_EXEC concluída [Etapa ${contador}/${total_etapas}]"
        _linha
    else
        _mensagec "${RED}" "Falha na compactação de $E_EXEC"
        return 1
    fi

    # Compactação em T_TELAS
    cd "$T_TELAS" || return 1
    {
        "$cmd_find" "$T_TELAS"/ -type f \( -iname "*.TEL" \) -exec "$cmd_zip" -r -q "${caminho_backup}" {} + >>"${LOG_ATU}" 2>&1
    } &
    local pid_zip_telas=$!
    pids+=("$pid_zip_telas")  # Registrar PID
    _mostrar_progresso_backup "$pid_zip_telas"
    if wait "$pid_zip_telas"; then
        ((contador++))
        _mensagec "${GREEN}" "Compactação de $T_TELAS concluída [Etapa ${contador}/${total_etapas}]"
        _linha
    else
        _mensagec "${RED}" "Falha na compactação de $T_TELAS"
        return 1
    fi

    # Compactação em X_XML (apenas para IsCOBOL)
    if [[ "$sistema" == "iscobol" ]]; then
        cd "$X_XML" || return 1
        {
            "$cmd_find" "$X_XML"/ -type f \( -iname "*.xml" \) -exec "$cmd_zip" -r -q "${caminho_backup}" {} + >>"${LOG_ATU}" 2>&1
        } &
        local pid_zip_xml=$!
        pids+=("$pid_zip_xml")  # Registrar PID
        _mostrar_progresso_backup "$pid_zip_xml"
        if wait "$pid_zip_xml"; then
            ((contador++))
            _mensagec "${GREEN}" "Compactação de $X_XML concluída [Etapa ${contador}/${total_etapas}]"
            _linha
        else
            _mensagec "${RED}" "Falha na compactação de $X_XML"
            return 1
        fi
    fi

    cd "${TOOLS}" || return 1
    clear
    _linha
    _mensagec "${YELLOW}" "Backup Completo"
    _linha
    _read_sleep 1

    # Verificar se backup foi criado
    if [[ ! -r "${caminho_backup}" ]]; then
        _linha
        _mensagec "${RED}" "Backup não encontrado no diretório ou dados não informados"
        _linha
        _read_sleep 2
        
        if _confirmar "Deseja continuar a atualização?" "S"; then
            _mensagec "${YELLOW}" "Continuando a atualização..."
        else
            pids=()  # Limpar PIDs se saindo
            return 1
        fi
    fi

    pids=()  # Limpar PIDs após sucesso
    _executar_atualizacao_biblioteca
}

# Executa a atualização da biblioteca
_executar_atualizacao_biblioteca() {
    cd "${TOOLS}" || return 1

    _definir_variaveis_biblioteca
    local -a arquivos_update
    read -ra arquivos_update <<< "$(_obter_arquivos_atualizacao)"
    # Contar arquivos a processar
    local total_arquivos=0
    for arquivo in "${arquivos_update[@]}"; do
        [[ -n "${arquivo}" && -r "${arquivo}" ]] && ((total_arquivos++))
    done
    local contador=0

    # Processar cada arquivo de atualização
    for arquivo in "${arquivos_update[@]}"; do
        if [[ -n "${arquivo}" && -r "${arquivo}" ]]; then
            _linha
            _mensagec "${YELLOW}" "Descompactando e atualizando: ${arquivo} [Etapa ${contador}/${total_arquivos}]"
            _linha
            _mensagec "${GREEN}" "Iniciando descompactação..."

            # Descompactar arquivo em background
            {
                "${cmd_unzip}" -o "${arquivo}" -d "/${destino}" >>"${LOG_ATU}" 2>&1
            } &
            local pid_unzip=$!
            pids+=("$pid_unzip")  # Registrar PID para trap
            _mostrar_progresso_backup "$pid_unzip"
            if wait "$pid_unzip"; then
                _mensagec "${GREEN}" "Descompactação de ${arquivo} concluída com sucesso"
                ((contador++))
            else
                _mensagec "${RED}" "Erro na descompactação de ${arquivo} - Verifique o log ${LOG_ATU}"
                return 1
            fi
            _linha
            _read_sleep 1
            clear
        fi
    done

    # Finalizar atualização
    _linha
    _mensagec "${YELLOW}" "Atualização concluída com sucesso!"
    _linha

    # Mover arquivos .zip para .bkp
    for arquivo_zip in *_"${VERSAO}".zip; do
        if [[ -f "${arquivo_zip}" ]]; then
            mv -f "${arquivo_zip}" "${arquivo_zip%.zip}.bkp"
        fi
    done
    
    # Mover backups para diretório
    local arquivos=(*_"${VERSAO}".bkp)
    if (( ${#arquivos[@]} )); then
        mv -- "${arquivos[@]}" "${OLDS}" || {
        _mensagec "${YELLOW}" "Erro ao mover arquivos de backup."
        return 1
        }
    else
        _mensagec "${YELLOW}" "Nenhum arquivo de backup para mover"
    fi

    # Atualizar mensagens finais
    _linha
    _mensagec "${YELLOW}" "Alterando a extensão da atualização"
    _mensagec "${YELLOW}" "De *.zip para *.bkp"
    _mensagec "${RED}" "Versão atualizada - ${VERSAO}"
    _linha

    # Salvar versão anterior
    if ! printf "VERSAOANT=%s\n" "${VERSAO}" >> "${LIB_CFG}/.atualizac"; then
        _mensagec "${RED}" "Erro ao gravar arquivo de versão atualizada"
        _press
        exit
    fi

    pids=()  # Limpar PIDs após sucesso
    _press
}

#---------- FUNÇÕES DE REVERSÃO ----------#

# Reverte biblioteca completa
_reverter_biblioteca_completa() {
    local arquivo_backup="$1"
    local raiz="/"
    
    if ! cd "${OLDS}"; then
        _mensagec "${RED}" "Erro: Falha ao acessar o diretório ${OLDS}"
        _press
        return 1
    fi

    if ! "${cmd_unzip}" -o "${arquivo_backup}" -d "${raiz}" >>"${LOG_ATU}"; then
        _mensagec "${RED}" "Erro ao descompactar ${arquivo_backup}"
        _press
        return 1
    fi

    cd "${TOOLS}" || return 1
    _mensagec "${YELLOW}" "Voltando backup anterior..."
    _linha
    _mensagec "${YELLOW}" "Volta dos Programas Concluída"
    _linha
    _press
}

# Reverte programa específico da biblioteca
_reverter_programa_especifico_biblioteca() {
    local arquivo_backup="$1"
    local programa_reverter

    if ! cd "${OLDS}"; then
        _mensagec "${RED}" "Erro ao acessar diretório ${OLDS}"
        return 1
    fi

    read -rp "${YELLOW}Informe o nome do programa em MAIÚSCULO: ${NORM}" programa_reverter

    if [[ -z "${programa_reverter}" || ! "${programa_reverter}" =~ ^[A-Z0-9]+$ ]]; then
        _mensagec "${RED}" "Nome do programa inválido"
        _press
        return 1
    fi

    _linha
    _mensagec "${YELLOW}" "Voltando versão anterior do programa ${programa_reverter}"
    _linha

    local padrao="*/"
    if ! "${cmd_unzip}" -o "${arquivo_backup}" "${padrao}${programa_reverter}*" -d "/" >>"${LOG_ATU}"; then
        _mensagec "${RED}" "Erro ao descompactar programa ${programa_reverter}"
        _press
        return 1
    fi
    
    _mensagec "${YELLOW}" "Volta do Programa Concluída"
    _linha
    _press
}

#---------- FUNÇÕES DE DOWNLOAD ----------#

# Baixa biblioteca via RSYNC
_baixar_biblioteca_rsync() {
    cd "${TOOLS}" || return 1

    if [[ "${acessossh}" == "n" ]]; then
        if [[ "${sistema}" == "iscobol" ]]; then
            local src="${USUARIO}@${IPSERVER}:${DESTINO2}${SAVATU}${VERSAO}.zip"
            sftp -P "$PORTA" "${src}" "."
        else
            _definir_variaveis_biblioteca
            local arquivos_update
            read -ra arquivos_update <<< "$(_obter_arquivos_atualizacao)"

            for arquivo in "${arquivos_update[@]}"; do
                local src="${USUARIO}@${IPSERVER}:${DESTINO2}${arquivo}"
                sftp -P "$PORTA" "${src}" "."
            done
        fi
    else
        _definir_variaveis_biblioteca
        local arquivos_update
        read -ra arquivos_update <<< "$(_obter_arquivos_atualizacao)"

        for arquivo in "${arquivos_update[@]}"; do
            local src="${DESTINO2}${arquivo}"
            sftp sav_servidor <<EOF
get "${src}" "."
EOF
        done
    fi

    _salvar_atualizacao_biblioteca
}

#---------- FUNÇÕES AUXILIARES ----------#

# Solicita versão da biblioteca
_solicitar_versao_biblioteca() {
    _linha
    _mensagec "${YELLOW}" "Informe versão a da Biblioteca a ser atualizada:"
    _linha
    printf "\n"
    read -rp "${GREEN}Informe somente o numeral da versão: ${NORM}" VERSAO
    
    if [[ -z "${VERSAO}" ]]; then
        printf "\n"
        _linha
        _mensagec "${RED}" "Versão a ser atualizada não foi informada"
        _linha
        _press
        return 1
    fi
    
    return 0
}

# Define variáveis da biblioteca baseado na versão
_definir_variaveis_biblioteca() {
    ATUALIZA1="${SAVATU1}${VERSAO}.zip"
    ATUALIZA2="${SAVATU2}${VERSAO}.zip"
    ATUALIZA3="${SAVATU3}${VERSAO}.zip"
    ATUALIZA4="${SAVATU4}${VERSAO}.zip"
}

_obter_arquivos_atualizacao() {
    if [[ "${sistema}" == "iscobol" ]]; then
        echo "${ATUALIZA1}" "${ATUALIZA2}" "${ATUALIZA3}" "${ATUALIZA4}"
    else
        echo "${ATUALIZA1}" "${ATUALIZA2}" "${ATUALIZA3}"
    fi
}

#---------- VALIDAÇÕES ----------#
# Valida se os diretórios de destino estão configurados
_validar_diretorios_biblioteca() {
    local diretorios_validar=(
        "DESTINO2SERVER"
        "DESTINO2SAVATUISC" 
        "DESTINO2SAVATUMF"
        "DESTINO2TRANSPC"
    )
    
    for dir_var in "${diretorios_validar[@]}"; do
        if [[ -z "${!dir_var}" ]]; then
            _mensagec "${RED}" "Erro: Variável ${dir_var} não configurada"
            return 1
        fi
    done
    
    return 0
}

