#!/usr/bin/env bash
#
# arquivos.sh - Modulo de Gestao de Arquivos
# Responsavel por limpeza, recuperacao, transferência e expurgo de arquivos
# SISTEMA SAV - Script de Atualizacao Modular
# Versao: 15/01/2026-00
#
# Variaveis globais esperadas
sistema="${sistema:-}"   # Tipo de sistema (ex: iscobol, outros).
base="${base:-}"           # Caminho do diretorio da segunda base de dados.
base2="${base2:-}"           # Caminho do diretorio da segunda base de dados.
base3="${base3:-}"           # Caminho do diretorio da terceira base de dados.
BASE_TRABALHO="${BASE_TRABALHO:-}" # Base de trabalho selecionada.
cmd_zip="${cmd_zip:-}"  # Comando para compactacao (ex: zip).
jut="${jut:-}"              # Caminho para o utilitario jutil.
raiz="${raiz:-}"
cfg_dir="${cfg_dir:-}"
lib_dir="${lib_dir:-}"

#---------- FUNcoES DE LIMPEZA ----------#

# Executa limpeza de arquivos temporarios
_executar_limpeza_temporarios() {
    cd "${cfg_dir}" || {
        _mensagec "${RED}" "Erro: Diretorio ${cfg_dir} nao encontrado"
        return 1
    }

    # Verificar arquivo de lista de temporarios
    local arquivo_lista="${cfg_dir}/atualizat"
    if [[ ! -f "${arquivo_lista}" ]]; then
        _mensagec "${RED}" "ERRO: Arquivo ${arquivo_lista} nao existe no diretorio"
        return 1
    elif [[ ! -r "${arquivo_lista}" ]]; then
        _mensagec "${RED}" "ERRO: Arquivo ${arquivo_lista} sem permissao de leitura"
        return 1
    fi

    # Limpar temporarios antigos do backup
    find "${BACKUP}" -type f -name "Temps*" -mtime +10 -delete 2>/dev/null || true

    # Processar cada base de dados configurada
    for base_dir in "$base" "$base2" "$base3"; do
        if [[ -n "$base_dir" ]]; then
            local caminho_base="${raiz}${base_dir}"
            if [[ -d "$caminho_base" ]]; then
                _limpar_base_especifica "$caminho_base" "$arquivo_lista"
            else
                _mensagec "${YELLOW}" "Diretorio nao existe: ${caminho_base}"
            fi
        fi
    done

    _press
}

# Limpa arquivos de uma base especifica
_limpar_base_especifica() {
    local caminho_base="$1"
    local arquivo_lista="$2"
    local arquivos_temp=()
    
    # Ler lista de arquivos temporarios
    mapfile -t arquivos_temp < "$arquivo_lista"
    
    _mensagec "${YELLOW}" "Limpando arquivos temporarios do diretorio: ${caminho_base}"
    _read_sleep 1
    _linha
    
    for padrao_arquivo in "${arquivos_temp[@]}"; do
        if [[ -n "$padrao_arquivo" ]]; then
            _mensagec "${GREEN}" "Processando padrao: ${YELLOW}${padrao_arquivo}${NORM}"
            
            # Compactar e mover arquivos temporarios
            local zip_temporarios="Temps-${UMADATA}.zip"
            if find "$caminho_base" -type f -iname "$padrao_arquivo" -exec "$cmd_zip" -m "${BACKUP}/${zip_temporarios}" {} + >>"${LOG_LIMPA}" 2>&1; then
                _log "Arquivos temporarios processados: $padrao_arquivo"
            fi
        fi
    done
        
    _linha
}

# Adiciona arquivo à lista de limpeza
_adicionar_arquivo_lixo() {
    cd "${cfg_dir}" || {
        _mensagec "${RED}" "Erro: Diretorio ${cfg_dir} nao encontrado"
        return 1
    }
    
    clear
    _meiodatela
    _mensagec "${CYAN}" "Informe o nome do arquivo a ser adicionado ao atualizat"
    _linha
    
    local novo_arquivo
    read -rp "${YELLOW}Qual o arquivo -> ${NORM}" novo_arquivo
    _linha

    if [[ -z "$novo_arquivo" ]]; then
        _mensagec "${RED}" "Nome de arquivo nao informado"
        _press
        return 1
    fi

    # Adicionar arquivo à lista
    echo "$novo_arquivo" >> atualizat
    _mensagec "${CYAN}" "Arquivo '${novo_arquivo}' adicionado com sucesso ao 'atualizat'"
    _linha
    
    _press
}

_lista_arquivos_lixo() {
    cd "${cfg_dir}" || {
        _mensagec "${RED}" "Erro: Diretorio ${cfg_dir} nao encontrado"
        return 1
    }
    
    clear
    _meiodatela
    _mensagec "${CYAN}" "Lista de arquivos no atualizat:"
    _linha

    if [[ -f "atualizat" && -s "atualizat" ]]; then
        nl -w3 -s'. ' atualizat
    else
        _mensagec "${YELLOW}" "Nenhum arquivo listado no 'atualizat'"
    fi

    _linha
    _press
}

#---------- FUNcoES DE RECUPERAcaO ----------#

# Recupera arquivo especifico ou todos
_recuperar_arquivo_especifico() {
    local base_trabalho
    
    # Escolher base se necessario
    if [[ -n "${base2}" ]]; then
        _menu_escolha_base || return 1
        BASE_TRABALHO="${base_trabalho}"
    else
        base_trabalho="${raiz}${base}"
    fi

    clear
    if [[ "${sistema}" != "iscobol" ]]; then
        _mensagec "${RED}" "Recuperacao em desenvolvimento para este sistema"
        _press
        return 1
    fi

    _meiodatela
    _mensagec "${CYAN}" "Informe o nome do arquivo a ser recuperado ou ENTER para todos:"
    _linha
    
    local nome_arquivo
    read -rp "${YELLOW}Nome do arquivo: ${NORM}" nome_arquivo
    nome_arquivo=$(echo "$nome_arquivo" | xargs) # Remove espacos extras
    _linha "-" "${BLUE}"
    
    if [[ -z "$nome_arquivo" ]]; then
        _recuperar_todos_arquivos "$base_trabalho"
    else
        _recuperar_arquivo_individual "$nome_arquivo" "$base_trabalho"
    fi

    _linha "-" "${YELLOW}"
    _mensagec "${YELLOW}" "Arquivo(s) recuperado(s)..."
    _linha
    _ir_para_tools
    _press
}

# Recupera todos os arquivos principais
_recuperar_todos_arquivos() {
    local base_trabalho="$1"
    local -a extensoes=('*.ARQ.dat' '*.DAT.dat' '*.LOG.dat' '*.PAN.dat')
    _mensagec "${RED}" "Recuperando todos os arquivos principais..."
    _linha "-" "${YELLOW}"
    
    if [[ -d "$base_trabalho" ]]; then
        for extensao in "${extensoes[@]}"; do
            for arquivo in ${base_trabalho}/${extensao}; do
                if [[ -f "$arquivo" && -s "$arquivo" ]]; then
                    _executar_jutil "$arquivo"
                else
                    _mensagec "${YELLOW}" "Arquivo nao encontrado ou vazio: ${arquivo##*/}"
                fi
            done
        done
    else
        _mensagec "${RED}" "Erro: Diretorio ${base_trabalho} nao existe"
    fi
}

# Recupera arquivo individual
_recuperar_arquivo_individual() {
    local nome_arquivo="$1"
    local base_trabalho="$2"
    
    # Validar nome do arquivo
    if [[ ! "$nome_arquivo" =~ ^[A-Z0-9]+$ ]]; then
        _mensagec "${RED}" "Nome de arquivo invalido. Use apenas letras maiúsculas e números."
        return 1
    fi
    
    local padrao_arquivo="${nome_arquivo}.*.dat"
    local arquivos_encontrados=0
    
    for arquivo in ${base_trabalho}/${padrao_arquivo}; do
        if [[ -f "$arquivo" ]]; then
            _executar_jutil "$arquivo"
            ((arquivos_encontrados++))
        fi
    done
    
    if (( arquivos_encontrados == 0 )); then
        _mensagec "${YELLOW}" "Nenhum arquivo encontrado para: ${nome_arquivo}"
        _linha "-" "${GREEN}"
    fi
}

# Recupera arquivos principais baseado na lista
_recuperar_arquivos_principais() {
    cd "${cfg_dir}" || return 1
    
    # Escolher base se necessario
    if [[ -n "${base2}" ]]; then
        _menu_escolha_base || return 1
        BASE_TRABALHO="${base_trabalho}"
    else
        base_trabalho="${raiz}${base}"
    fi
    
    if [[ "${sistema}" = "iscobol" ]]; then
        local base_trabalho="${BASE_TRABALHO:-${raiz}${base}}"
        cd "$base_trabalho" || {
            _mensagec "${RED}" "Erro: Diretorio ${base_trabalho} nao encontrado"
            return 1
        }
        
        # Gerar lista de arquivos atuais
        local var_ano var_ano4
        var_ano=$(date +%y)
        var_ano4=$(date +%Y)
        
        # Criar lista temporaria
        {
            ls ATE"${var_ano}"*.dat 2>/dev/null || true
            ls NFE?"${var_ano4}".*.dat 2>/dev/null || true
        } > "${cfg_dir}/atualizaj2"
        
        cd "${cfg_dir}" || return 1
        _read_sleep 1
        
        # Verificar arquivos de lista
        for lista in "atualizaj2" "atualizaj"; do
            if [[ -f "$lista" && -r "$lista" ]]; then
                _processar_lista_arquivos "$lista" "$base_trabalho"
            fi
        done
        
        # Limpar arquivo temporario
        [[ -f "atualizaj2" ]] && rm -f "atualizaj2"
        
        _mensagec "${YELLOW}" "Arquivos principais recuperados"
    else
        _mensagec "${RED}" "Recuperacao nao disponivel para este sistema"
    fi
    
    _press
}

# Processa lista de arquivos para recuperacao
_processar_lista_arquivos() {
    local arquivo_lista="$1"
    local base_trabalho="$2"
    
    while IFS= read -r listando || [[ -n "$listando" ]]; do
        [[ -z "$listando" ]] && continue
        
        local caminho_arquivo="${base_trabalho}/${listando}"
        if [[ -e "$caminho_arquivo" ]]; then
            _executar_jutil "$caminho_arquivo"
        else
            _mensagec "${RED}" "Arquivo nao encontrado: ${listando}"
        fi
    done < "$arquivo_lista"
}

# Executa jutil no arquivo especificado
_executar_jutil() {
    local arquivo="$1"
    
    if [[ -n "$arquivo" && -e "$arquivo" && -s "$arquivo" ]]; then
        if [[ -x "${jut}" ]]; then
            if "${jut}" -rebuild "$arquivo" -a -f; then
                _log_sucesso "Rebuild executado: $(basename "$arquivo")"
            else
                _mensagec "${RED}" "Erro no rebuild: $(basename "$arquivo")"
                _linha "-" "${RED}"
                return 1
            fi
            _linha "-" "${GREEN}"
        else
            _mensagec "${RED}" "Erro: jutil nao encontrado em ${jut}"
            return 1
        fi
    else
        _mensagec "${YELLOW}" "Arquivo nao encontrado ou vazio: $(basename "$arquivo" 2>/dev/null || echo "$arquivo")"
        return 1
    fi
}

#---------- FUNcoES DE TRANSFERÊNCIA ----------#

# Envia arquivo avulso
_enviar_arquivo_avulso() {
    clear
    local dir_origem arquivo_enviar destino_remoto
    
    # Solicitar diretorio de origem
    _linha
    _mensagec "${YELLOW}" "1- Origem: Informe o diretorio onde esta o arquivo:"
    read -rp "${YELLOW} -> ${NORM}" dir_origem
    _linha
    
    if [[ ! -d "$dir_origem" ]]; then
        if [[ -z "$dir_origem" ]]; then
            dir_origem="${ENVIA}"
            if [[ -d "$dir_origem" ]]; then
                _linha
                _mensagec "${YELLOW}" "Usando diretorio padrao: ${dir_origem}"
                if ls -s "${dir_origem}"/*.* &>/dev/null; then
                    _linha
                    _mensagec "${YELLOW}" "Arquivos encontrados no diretorio"
                    _linha
                else
                    _mensagec "${YELLOW}" "Nenhum arquivo encontrado no diretorio"
                    _press
                    return 1
                fi
            fi
        else
            _mensagec "${RED}" "Diretorio nao encontrado: ${dir_origem}"
            _press
            return 1
        fi
    fi
    
    # Solicitar nome do arquivo
    _linha
    _mensagec "${CYAN}" "Informe o arquivo que deseja enviar"
    _linha
    read -rp "${YELLOW}2- Nome do ARQUIVO: ${NORM}" arquivo_enviar
    
    if [[ -z "$arquivo_enviar" ]]; then
        _mensagec "${RED}" "Nome do arquivo nao informado"
        _press
        return 1
    fi
    
    if [[ ! -e "${dir_origem}/${arquivo_enviar}" ]]; then
        _mensagec "${YELLOW}" "${arquivo_enviar} nao encontrado em ${dir_origem}"
        _press
        return 1
    fi
    
    # Solicitar destino remoto
    printf "\n"
    _linha
    _mensagec "${YELLOW}" "3- Destino: Informe o diretorio no servidor:"
    read -rp "${YELLOW} -> ${NORM}" destino_remoto
    _linha
    
    if [[ -z "$destino_remoto" ]]; then
        _mensagec "${RED}" "Destino nao informado"
        _press
        return 1
    fi
    
    # Enviar arquivo
    _linha
    _mensagec "${YELLOW}" "Informe a senha para o usuario remoto:"
    _linha
    
    if rsync -avzP -e "ssh -p ${PORTA}" "${dir_origem}/${arquivo_enviar}" "${USUARIO}@${IPSERVER}:${destino_remoto}"; then
        _mensagec "${YELLOW}" "Arquivo enviado para \"${destino_remoto}\""
        _linha
        _read_sleep 3
    else
        _mensagec "${RED}" "Erro no envio do arquivo"
        _press
    fi
}

# Recebe arquivo avulso
_receber_arquivo_avulso() {
    clear
    local origem_remota arquivo_receber destino_local
    
    # Solicitar origem remota
    _linha
    _mensagec "${YELLOW}" "1- Origem: Diretorio remoto do arquivo:"
    read -rp "${YELLOW} -> ${NORM}" origem_remota
    _linha
    
    # Solicitar nome do arquivo
    _mensagec "${RED}" "Informe o arquivo que deseja RECEBER"
    _linha
    read -rp "${YELLOW}2- Nome do ARQUIVO: ${NORM}" arquivo_receber
    
    if [[ -z "$arquivo_receber" ]]; then
        _mensagec "${RED}" "Nome do arquivo nao informado"
        _press
        return 1
    fi
    
    # Solicitar destino local
    _linha
    _mensagec "${YELLOW}" "3- Destino: Diretorio local para receber:"
    read -rp "${YELLOW} -> ${NORM}" destino_local
    
    if [[ -z "$destino_local" ]]; then
        destino_local="${RECEBE}"
    fi
    
    if [[ ! -d "$destino_local" ]]; then
        _mensagec "${RED}" "Diretorio de destino nao encontrado: ${destino_local}"
        _press
        return 1
    fi
    
    # Receber arquivo
    _linha
    _mensagec "${YELLOW}" "Informe a senha para o usuario remoto:"
    _linha
    
    if sftp -P "${PORTA}" "${USUARIO}@${IPSERVER}:${origem_remota}/${arquivo_receber}" "${destino_local}/."; then
        _mensagec "${YELLOW}" "Arquivo recebido em \"${destino_local}\""
        _linha
        _read_sleep 3
    else
        _mensagec "${RED}" "Erro no recebimento do arquivo"
        _press
    fi
}

#---------- FUNCOES DE EXPURGO ----------#

# Executa expurgador de arquivos antigos
_executar_expurgador() {
    local origem="${1:-principal}"
    clear
    
    _linha
    _mensagec "${RED}" "Verificando e excluindo arquivos com mais de 30 dias"
    _linha
    printf "\n\n"
    
    # Definir diretorios para limpeza
    local diretorios_limpeza=(
        "${BACKUP}/"
        "${OLDS}/"
        "${PROGS}/"
        "${LOGS}/"
        "${raiz}/portalsav/log/"
        "${raiz}/err_isc/"
        "${raiz}/savisc/viewvix/tmp/"
    )
    
    local diretorios_zip=(
        "${E_EXEC}/"
        "${T_TELAS}/"
    )
    
    # Limpar arquivos antigos nos diretorios padrao
    for diretorio in "${diretorios_limpeza[@]}"; do
        if [[ -d "$diretorio" ]]; then
            local arquivos_removidos
            arquivos_removidos=$(find "$diretorio" -mtime +30 -type f -delete -print 2>/dev/null | wc -l)
            _mensagec "${GREEN}" "Limpando arquivos do diretorio: ${diretorio} (${arquivos_removidos} arquivos)"
        else
            _mensagec "${YELLOW}" "Diretorio nao encontrado: ${diretorio}"
        fi
    done
    
    # Limpar arquivos ZIP antigos especificos
    for diretorio in "${diretorios_zip[@]}"; do
        if [[ -d "$diretorio" ]]; then
            local zips_removidos
            zips_removidos=$(find "$diretorio" -name "*.zip" -type f -mtime +15 -delete -print 2>/dev/null | wc -l)
            _mensagec "${GREEN}" "Limpando arquivos .zip antigos: ${diretorio} (${zips_removidos} arquivos)"
        else
            _mensagec "${YELLOW}" "Diretorio nao encontrado: ${diretorio}"
        fi
    done
    
    printf "\n\n"
    _linha
    _press
    _ir_para_tools
    
    # Retornar ao menu baseado na origem
    if [[ "$origem" == "arquivos" ]]; then
        return 0
    else
        _menu_arquivos
    fi
}