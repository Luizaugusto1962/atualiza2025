#!/usr/bin/env bash
#
# arquivos.sh - Módulo de Gestão de Arquivos
# Responsável por limpeza, recuperação, transferência e expurgo de arquivos
# SISTEMA SAV - Script de Atualizaçao Modular
# Versao: 01/11/2025-00
#
# Variaveis globais esperadas
destino="${destino:-}" # Caminho do diretório de destino principal.
sistema="${sistema:-}"   # Tipo de sistema (ex: iscobol, outros).
base="${base:-}"           # Caminho do diretorio da segunda base de dados.
base2="${base2:-}"           # Caminho do diretorio da segunda base de dados.
base3="${base3:-}"           # Caminho do diretorio da terceira base de dados.
BASE_TRABALHO="${BASE_TRABALHO:-}" # Base de trabalho selecionada.
cmd_zip="${cmd_zip:-}"  # Comando para compactação (ex: zip).
jut="${jut:-}"              # Caminho para o utilitário jutil.
BACKUP="${BACKUP:-}" 

#---------- FUNÇÕES DE LIMPEZA ----------#

# Executa limpeza de arquivos temporários
_executar_limpeza_temporarios() {
    cd "${LIB_CFG}" || {
        _mensagec "${RED}" "Erro: Diretório ${LIB_CFG} não encontrado"
        return 1
    }

    # Verificar arquivo de lista de temporários
    local arquivo_lista="${LIB_CFG}/atualizat"
    if [[ ! -f "${arquivo_lista}" ]]; then
        _mensagec "${RED}" "ERRO: Arquivo ${arquivo_lista} não existe no diretório"
        return 1
    elif [[ ! -r "${arquivo_lista}" ]]; then
        _mensagec "${RED}" "ERRO: Arquivo ${arquivo_lista} sem permissão de leitura"
        return 1
    fi

    # Limpar temporários antigos do backup
    find "${BACKUP}" -type f -name "Temps*" -mtime +10 -delete 2>/dev/null || true

    # Processar cada base de dados configurada
    for base_dir in "$base" "$base2" "$base3"; do
        if [[ -n "$base_dir" ]]; then
            local caminho_base="${destino}${base_dir}"
            if [[ -d "$caminho_base" ]]; then
                _limpar_base_especifica "$caminho_base" "$arquivo_lista"
            else
                _mensagec "${YELLOW}" "Diretório não existe: ${caminho_base}"
            fi
        fi
    done

    _press
}

# Limpa arquivos de uma base específica
_limpar_base_especifica() {
    local caminho_base="$1"
    local arquivo_lista="$2"
    local arquivos_temp=()
    
    # Ler lista de arquivos temporários
    mapfile -t arquivos_temp < "$arquivo_lista"
    
    _mensagec "${YELLOW}" "Limpando arquivos temporários do diretório: ${caminho_base}"
    _linha

    for padrao_arquivo in "${arquivos_temp[@]}"; do
        if [[ -n "$padrao_arquivo" ]]; then
            _mensagec "${GREEN}" "Processando padrão: ${YELLOW}${padrao_arquivo}${NORM}"
            
            # Compactar e mover arquivos temporários
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
    cd "${LIB_CFG}" || {
        _mensagec "${RED}" "Erro: Diretório ${LIB_CFG} não encontrado"
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
        _mensagec "${RED}" "Nome de arquivo não informado"
        _press
        return 1
    fi

    # Adicionar arquivo à lista
    echo "$novo_arquivo" >> atualizat
    _mensagec "${CYAN}" "Arquivo '${novo_arquivo}' adicionado com sucesso ao 'atualizat'"
    _linha
    
    _press
}

#---------- FUNÇÕES DE RECUPERAÇÃO ----------#

# Recupera arquivo específico ou todos
_recuperar_arquivo_especifico() {
    local base_trabalho
    
    # Escolher base se necessário
    if [[ -n "${base2}" ]]; then
        _menu_escolha_base || return 1
        BASE_TRABALHO="${base_trabalho}"
    else
        base_trabalho="${destino}${base}"
    fi

    clear
    if [[ "${sistema}" != "iscobol" ]]; then
        _mensagec "${RED}" "Recuperação em desenvolvimento para este sistema"
        _press
        return 1
    fi

    _meiodatela
    _mensagec "${CYAN}" "Informe o nome do arquivo a ser recuperado ou ENTER para todos:"
    _linha
    
    local nome_arquivo
    read -rp "${YELLOW}Nome do arquivo: ${NORM}" nome_arquivo
    nome_arquivo=$(echo "$nome_arquivo" | xargs) # Remove espaços extras
    _linha "-" "${BLUE}"
    
    if [[ -z "$nome_arquivo" ]]; then
        _recuperar_todos_arquivos "$base_trabalho"
    else
        _recuperar_arquivo_individual "$nome_arquivo" "$base_trabalho"
    fi

    _linha "-" "${YELLOW}"
    _mensagec "${YELLOW}" "Arquivo(s) recuperado(s)..."
    _linha

    cd "${TOOLS}" || return 1
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
        _mensagec "${RED}" "Erro: Diretorio ${base_trabalho} não existe"
    fi
}

# Recupera arquivo individual
_recuperar_arquivo_individual() {
    local nome_arquivo="$1"
    local base_trabalho="$2"
    
    # Validar nome do arquivo
    if [[ ! "$nome_arquivo" =~ ^[A-Z0-9]+$ ]]; then
        _mensagec "${RED}" "Nome de arquivo inválido. Use apenas letras maiúsculas e números."
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
    cd "${LIB_CFG}" || return 1
    
    # Escolher base se necessário
    if [[ -n "${base2}" ]]; then
        _menu_escolha_base || return 1
        BASE_TRABALHO="${base_trabalho}"
    else
        base_trabalho="${destino}${base}"
    fi
    
    if [[ "${sistema}" = "iscobol" ]]; then
        local base_trabalho="${BASE_TRABALHO:-${destino}${base}}"
        cd "$base_trabalho" || {
            _mensagec "${RED}" "Erro: Diretório ${base_trabalho} não encontrado"
            return 1
        }
        
        # Gerar lista de arquivos atuais
        local var_ano var_ano4
        var_ano=$(date +%y)
        var_ano4=$(date +%Y)
        
        # Criar lista temporária
        {
            ls ATE"${var_ano}"*.dat 2>/dev/null || true
            ls NFE?"${var_ano4}".*.dat 2>/dev/null || true
        } > "${LIB_CFG}/atualizaj2"
        
        cd "${LIB_CFG}" || return 1
        _read_sleep 1
        
        # Verificar arquivos de lista
        for lista in "atualizaj2" "atualizaj"; do
            if [[ -f "$lista" && -r "$lista" ]]; then
                _processar_lista_arquivos "$lista" "$base_trabalho"
            fi
        done
        
        # Limpar arquivo temporário
        [[ -f "atualizaj2" ]] && rm -f "atualizaj2"
        
        _mensagec "${YELLOW}" "Arquivos principais recuperados"
    else
        _mensagec "${RED}" "Recuperação não disponível para este sistema"
    fi
    
    _press
}

# Processa lista de arquivos para recuperação
_processar_lista_arquivos() {
    local arquivo_lista="$1"
    local base_trabalho="$2"
    
    while IFS= read -r listando || [[ -n "$listando" ]]; do
        [[ -z "$listando" ]] && continue
        
        local caminho_arquivo="${base_trabalho}/${listando}"
        if [[ -e "$caminho_arquivo" ]]; then
            _executar_jutil "$caminho_arquivo"
        else
            _mensagec "${RED}" "Arquivo não encontrado: ${listando}"
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
            _mensagec "${RED}" "Erro: jutil não encontrado em ${jut}"
            return 1
        fi
    else
        _mensagec "${YELLOW}" "Arquivo não encontrado ou vazio: $(basename "$arquivo" 2>/dev/null || echo "$arquivo")"
        return 1
    fi
}

#---------- FUNÇÕES DE TRANSFERÊNCIA ----------#

# Envia arquivo avulso
_enviar_arquivo_avulso() {
    clear
    local dir_origem arquivo_enviar destino_remoto
    
    # Solicitar diretório de origem
    _linha
    _mensagec "${YELLOW}" "1- Origem: Informe o diretório onde está o arquivo:"
    read -rp "${YELLOW} -> ${NORM}" dir_origem
    _linha
    
    if [[ ! -d "$dir_origem" ]]; then
        if [[ -z "$dir_origem" ]]; then
            dir_origem="${ENVIA}"
            if [[ -d "$dir_origem" ]]; then
                _linha
                _mensagec "${YELLOW}" "Usando diretório padrão: ${dir_origem}"
                if ls -s "${dir_origem}"/*.* &>/dev/null; then
                    _linha
                    _mensagec "${YELLOW}" "Arquivos encontrados no diretório"
                    _linha
                else
                    _mensagec "${YELLOW}" "Nenhum arquivo encontrado no diretório"
                    _press
                    return 1
                fi
            fi
        else
            _mensagec "${RED}" "Diretório não encontrado: ${dir_origem}"
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
        _mensagec "${RED}" "Nome do arquivo não informado"
        _press
        return 1
    fi
    
    if [[ ! -e "${dir_origem}/${arquivo_enviar}" ]]; then
        _mensagec "${YELLOW}" "${arquivo_enviar} não encontrado em ${dir_origem}"
        _press
        return 1
    fi
    
    # Solicitar destino remoto
    printf "\n"
    _linha
    _mensagec "${YELLOW}" "3- Destino: Informe o diretório no servidor:"
    read -rp "${YELLOW} -> ${NORM}" destino_remoto
    _linha
    
    if [[ -z "$destino_remoto" ]]; then
        _mensagec "${RED}" "Destino não informado"
        _press
        return 1
    fi
    
    # Enviar arquivo
    _linha
    _mensagec "${YELLOW}" "Informe a senha para o usuário remoto:"
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
    _mensagec "${YELLOW}" "1- Origem: Diretório remoto do arquivo:"
    read -rp "${YELLOW} -> ${NORM}" origem_remota
    _linha
    
    # Solicitar nome do arquivo
    _mensagec "${RED}" "Informe o arquivo que deseja RECEBER"
    _linha
    read -rp "${YELLOW}2- Nome do ARQUIVO: ${NORM}" arquivo_receber
    
    if [[ -z "$arquivo_receber" ]]; then
        _mensagec "${RED}" "Nome do arquivo não informado"
        _press
        return 1
    fi
    
    # Solicitar destino local
    _linha
    _mensagec "${YELLOW}" "3- Destino: Diretório local para receber:"
    read -rp "${YELLOW} -> ${NORM}" destino_local
    
    if [[ -z "$destino_local" ]]; then
        destino_local="${RECEBE}"
    fi
    
    if [[ ! -d "$destino_local" ]]; then
        _mensagec "${RED}" "Diretório de destino não encontrado: ${destino_local}"
        _press
        return 1
    fi
    
    # Receber arquivo
    _linha
    _mensagec "${YELLOW}" "Informe a senha para o usuário remoto:"
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

#---------- FUNÇÕES DE EXPURGO ----------#

# Executa expurgador de arquivos antigos
_executar_expurgador() {
    local origem="${1:-principal}"
    clear
    
    _linha
    _mensagec "${RED}" "Verificando e excluindo arquivos com mais de 30 dias"
    _linha
    printf "\n\n"
    
    # Definir diretórios para limpeza
    local diretorios_limpeza=(
        "${BACKUP}/"
        "${OLDS}/"
        "${PROGS}/"
        "${LOGS}/"
        "${destino}/sav/portalsav/log/"
        "${destino}/sav/err_isc/"
        "${destino}/sav/savisc/viewvix/tmp/"
    )
    
    local diretorios_zip=(
        "${E_EXEC}/"
        "${T_TELAS}/"
    )
    
    # Limpar arquivos antigos nos diretórios padrão
    for diretorio in "${diretorios_limpeza[@]}"; do
        if [[ -d "$diretorio" ]]; then
            local arquivos_removidos
            arquivos_removidos=$(find "$diretorio" -mtime +30 -type f -delete -print 2>/dev/null | wc -l)
            _mensagec "${GREEN}" "Limpando arquivos do diretório: ${diretorio} (${arquivos_removidos} arquivos)"
        else
            _mensagec "${YELLOW}" "Diretório não encontrado: ${diretorio}"
        fi
    done
    
    # Limpar arquivos ZIP antigos específicos
    for diretorio in "${diretorios_zip[@]}"; do
        if [[ -d "$diretorio" ]]; then
            local zips_removidos
            zips_removidos=$(find "$diretorio" -name "*.zip" -type f -mtime +15 -delete -print 2>/dev/null | wc -l)
            _mensagec "${GREEN}" "Limpando arquivos .zip antigos: ${diretorio} (${zips_removidos} arquivos)"
        else
            _mensagec "${YELLOW}" "Diretório não encontrado: ${diretorio}"
        fi
    done
    
    printf "\n\n"
    _linha
    _press
    
    cd "${TOOLS}" || return 1
    
    # Retornar ao menu baseado na origem
    if [[ "$origem" == "ferramentas" ]]; then
        return 0
    else
        _principal
    fi
}