#!/usr/bin/env bash
#
# utils.sh - Módulo de Utilitários e Funções Auxiliares  
# Funções básicas para formatação, mensagens, validação e controle de fluxo
#
# SISTEMA SAV - Script de Atualizaçao Modular
# Versao: 10/10/2025-00

destino="${destino:-}"       # Caminho do diretorio raiz do programa.

#---------- FUNÇÕES DE FORMATAÇÃO DE TELA ----------#

# Limpa a tela e posiciona cursor no centro
_meiodatela() {
    printf "\033c\033[10;10H\n"
}

# Exibe mensagem centralizada colorida
# Parâmetros: $1=cor $2=mensagem
_mensagec() {
    local color="${1}"
    local message="${2}"
    printf "%s%*s%s\n" "${color}" $(((${#message} + $(tput cols)) / 2)) "${message}" "${NORM}"
}

# Exibe mensagem alinhada à direita
# Parâmetros: $1=cor $2=mensagem  
_mensaged() {
    local color="${1}"
    local mensagem="${2}"
    local largura_terminal
    local largura_mensagem
    local posicao_inicio
    
    largura_terminal=$(tput cols)
    largura_mensagem=${#mensagem}
    posicao_inicio=$((largura_terminal - largura_mensagem))
    
    printf "%s%*s%s${NORM}\n" "${color}" "${posicao_inicio}" "" "$mensagem"
}

# Cria linha horizontal com caractere especificado
# Parâmetros: $1=caractere (opcional, padrão='-') $2=cor (opcional)
_linha() {
    local Traco=${1:-'-'}
    local CCC="${2:-}"
    local Espacos
    local linhas
    
    printf -v Espacos "%$(tput cols)s" ""
    linhas=${Espacos// /$Traco}
    printf "%s" "${CCC}"
    printf "%*s\n" $(((${#linhas} + COLUMNS) / 2)) "$linhas"
    printf "%s" "${NORM}"
}

#---------- FUNÇÕES DE CONTROLE DE FLUXO ----------#

# Pausa a execução por tempo especificado
# Parâmetros: $1=tempo_em_segundos
_read_sleep() {
    if [[ -z "${1}" ]]; then
        printf "Erro: Nenhum argumento passado para _read_sleep.\n"
        return 1
    fi

    if ! [[ "${1}" =~ ^[0-9.]+$ ]]; then
        printf "Erro: Argumento inválido para _read_sleep: %s\n" "${1}"
        return 1
    fi

    read -rt "${1}" <> <(:) || :
}

# Aguarda pressionar qualquer tecla com timeout
_press() {
    printf "%s" "${YELLOW}"
    printf "%*s\n" $(((36 + COLUMNS) / 2)) "<< ... Pressione qualquer tecla para continuar ... >>"
    printf "%s" "${NORM}"
    read -rt 15 || :
    tput sgr0
}

# Exibe mensagem de opção inválida
_opinvalida() {
    _linha
    _mensagec "${RED}" "Opção Inválida"
    _linha
}

#---------- FUNÇÕES DE VALIDAÇÃO ----------#

# Valida nome de programa (letras maiúsculas e números)
# Parâmetros: $1=nome_programa
# Retorna: 0=válido 1=inválido
_validar_nome_programa() {
    local programa="$1"
    [[ -n "$programa" && "$programa" =~ ^[A-Z0-9]+$ ]]
}

# Valida se diretório existe e é acessível
# Parâmetros: $1=caminho_diretorio
# Retorna: 0=válido 1=inválido
_validar_diretorio() {
    local dir="$1"
    [[ -n "$dir" && -d "$dir" && -r "$dir" ]]
}

# Valida se arquivo existe e é legível
# Parâmetros: $1=caminho_arquivo
# Retorna: 0=válido 1=inválido  
_validar_arquivo() {
    local arquivo="$1"
    [[ -n "$arquivo" && -f "$arquivo" && -r "$arquivo" ]]
}

# Valida formato de data (DD-MM-AAAA)
# Parâmetros: $1=data
# Retorna: 0=válido 1=inválido
_validar_data() {
    local data="$1"
    [[ "$data" =~ ^[0-9]{2}-[0-9]{2}-[0-9]{4}$ ]]
}

# Valida formato de versão (numérico)
# Parâmetros: $1=versao
# Retorna: 0=válido 1=inválido
_validar_versao() {
    local versao="$1"
    [[ -n "$versao" && "$versao" =~ ^[0-9]+([.-][0-9]+)*$ ]]
}

# Valida se a configuração do sistema está correta
# Retorna: 0=válido 1=inválido
_validar_configuracao_sistema() {
    local erros=0
    
    # Verificar arquivos de configuração
    if [[ ! -f "${CFG}/.atualizac" ]]; then
        _log_erro "Arquivo .atualizac não encontrado"
        ((erros++))
    fi
    
    # Verificar variáveis essenciais
    if [[ -z "${sistema}" ]]; then
        _log_erro "Variável 'sistema' não definida"
        ((erros++))
    fi
    
    if [[ -z "${destino}" ]]; then
        _log_erro "Variável 'destino' não definida"
        ((erros++))
    fi
    
    # Verificar se a variável pasta está definida
    if [[ -z "${pasta}" ]]; then
        _log_erro "Variável 'pasta' não definida"
        ((erros++))
    fi
    
    # Verificar diretórios essenciais
    local dirs=("exec" "telas" "olds" "progs" "logs" "backup" "cfg")
    for dir in "${dirs[@]}"; do
        local dir_path=""
        # Tratamento especial para exec e telas que ficam em ${destino}/sav
        if [[ "$dir" == "exec" ]] || [[ "$dir" == "telas" ]]; then
            dir_path="${destino}/sav/${!dir}"
        else
            # Para outros diretórios, usar o caminho padrão
            dir_path="${destino}${pasta}/${!dir}"
        fi
        
        if [[ ! -d "${dir_path}" ]]; then
            _log_erro "Diretório ${dir} não encontrado: ${dir_path}"
            ((erros++))
        fi
    done
    
    return $(( erros > 0 ? 1 : 0 ))
}

#---------- FUNÇÕES DE ENTRADA DE DADOS ----------#

# Solicita entrada do usuário com validação
# Parâmetros: $1=prompt $2=função_validacao $3=mensagem_erro
# Retorna: valor validado em stdout
_solicitar_entrada() {
    local prompt="$1"
    local funcao_validacao="$2" 
    local mensagem_erro="${3:-Entrada inválida}"
    local entrada
    local tentativas=0
    local max_tentativas=3
    
    while (( tentativas < max_tentativas )); do
        read -rp "${YELLOW}${prompt}: ${NORM}" entrada
        
        # Permite saída com ENTER vazio
        if [[ -z "$entrada" ]]; then
            echo ""
            return 0
        fi
        
        # Valida entrada se função fornecida
        if [[ -n "$funcao_validacao" ]]; then
            if "$funcao_validacao" "$entrada"; then
                echo "$entrada"
                return 0
            else
                _mensagec "${RED}" "$mensagem_erro"
                ((tentativas++))
            fi
        else
            echo "$entrada"
            return 0
        fi
    done
    
    _mensagec "${RED}" "Máximo de tentativas excedido"
    return 1
}

# Solicita confirmação S/N
# Parâmetros: $1=mensagem $2=padrão(S/N)
# Retorna: 0=sim 1=não
_confirmar() {
    local mensagem="$1"
    local padrao="${2:-N}"
    local opcoes
    local resposta
    
    case "$padrao" in
        [Ss]) opcoes="[S/n]" ;;
        [Nn]) opcoes="[N/s]" ;;
        *) opcoes="[S/N]" ;;
    esac
    
    read -rp "${YELLOW}${mensagem} ${opcoes}: ${NORM}" resposta
    
    # Se resposta vazia, usar padrão
    if [[ -z "$resposta" ]]; then
        resposta="$padrao"
    fi
    
    case "${resposta,,}" in
        s|sim|y|yes) return 0 ;;
        n|nao|não|no) return 1 ;;
        *) 
            _mensagec "${RED}" "Resposta inválida"
            _confirmar "$mensagem" "$padrao"
            ;;
    esac
}

#---------- FUNÇÕES DE PROGRESSO ----------#

# Exibe barra de progresso simples
# Parâmetros: $1=atual $2=total $3=largura_barra(opcional)
_barra_progresso() {
    local atual="$1"
    local total="$2"
    local largura="${3:-20}"
    local percent
    local preenchido
    local vazio
    local barra
    
    if (( total == 0 )); then
        return 1
    fi
    
    percent=$(( atual * 100 / total ))
    preenchido=$(( percent * largura / 100 ))
    vazio=$(( largura - preenchido ))
    
    # Criar barra visual
    barra=$(printf "%${preenchido}s" | tr ' ' '#')
    barra+=$(printf "%${vazio}s" | tr ' ' '-')
    
    printf "\r${YELLOW}[%s] %d%%${NORM}" "$barra" "$percent"
}

# Mostra progresso do backup com spinner animado e tempo decorrido
_mostrar_progresso_backup() {
    local pid="$1"
    local delay=0.2
    local spin=( '⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏' )
    local i=0
    local elapsed=0
    local msg="Processo em andamento"

    # Verifica se o processo ainda esta ativo
    if ! kill -0 "$pid" 2>/dev/null; then
        _mensagec "$YELLOW" "Iniciando..."
        sleep 1
        return
    fi

    # Oculta o cursor
    tput civis

    # Salva posiçao do cursor
    tput sc
    printf "${YELLOW}%s... [${NORM}" "$msg"

    # Loop de animaçao
    while kill -0 "$pid" 2>/dev/null; do
        tput rc  # Restaura posiçao
        printf "${YELLOW}%s... [%3ds] ${NORM}${GREEN}%s${NORM}" \
            "$msg" "$elapsed" "${spin[i]}"
        ((i = (i + 1) % ${#spin[@]}))
        ((elapsed += 1))
        sleep "$delay"
    done

    # Mostra o cursor novamente
    tput cnorm

    # Mensagem final
    if wait "$pid" 2>/dev/null; then
        printf "\r${YELLOW}%s... [Concluido] ✓${NORM}\n" "$msg"
    else
        printf "\r${YELLOW}%s... [Falhou] ✗${NORM}\n" "$msg"
    fi
}

#---------- FUNÇÕES DE LOG ----------#

# Registra mensagem no log com timestamp
# Parâmetros: $1=mensagem $2=arquivo_log(opcional)
_log() {
    local mensagem="$1"
    local arquivo_log="${2:-$LOG_ATU}"
    local timestamp
    
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $mensagem" >> "$arquivo_log" 2>/dev/null
}

# Registra erro no log
# Parâmetros: $1=mensagem_erro $2=arquivo_log(opcional)
_log_erro() {
    local erro="$1"
    local arquivo_log="${2:-$LOG_ATU}"
    
    _log "ERRO: $erro" "$arquivo_log"
}

# Registra sucesso no log  
# Parâmetros: $1=mensagem_sucesso $2=arquivo_log(opcional)
_log_sucesso() {
    local sucesso="$1"
    local arquivo_log="${2:-$LOG_ATU}"
    
    _log "SUCESSO: $sucesso" "$arquivo_log"
}

#---------- FUNÇÕES DE FORMATAÇÃO DE DADOS ----------#

# Formata tamanho de arquivo para leitura humana
# Parâmetros: $1=tamanho_bytes
_formatar_tamanho() {
    local tamanho="$1"
    local unidades=('B' 'KB' 'MB' 'GB' 'TB')
    local unidade=0
    
    while (( tamanho >= 1024 && unidade < ${#unidades[@]} - 1 )); do
        tamanho=$(( tamanho / 1024 ))
        ((unidade++))
    done
    
    printf "%d %s" "$tamanho" "${unidades[$unidade]}"
}

# Formata duração em segundos para formato legível
# Parâmetros: $1=segundos
_formatar_duracao() {
    local segundos="$1"
    local horas=$(( segundos / 3600 ))
    local minutos=$(( (segundos % 3600) / 60 ))
    local segs=$(( segundos % 60 ))
    
    if (( horas > 0 )); then
        printf "%02d:%02d:%02d" "$horas" "$minutos" "$segs"
    elif (( minutos > 0 )); then
        printf "%02d:%02d" "$minutos" "$segs"
    else
        printf "%ds" "$segs"
    fi
}

#---------- FUNÇÕES DE SISTEMA ----------#

# Obtém informações básicas do sistema
_info_sistema() {
    echo "OS: $(uname -s)"
    echo "Versao: $(uname -r)"
    echo "Arquitetura: $(uname -m)"
    echo "Hostname: $(hostname)"
    echo "Usuário: $(whoami)"
    echo "Diretório: $(pwd)"
}

# Verifica espaço em disco disponível
# Parâmetros: $1=caminho
# Retorna: espaço_livre_em_MB
_espaco_livre() {
    local caminho="${1:-.}"
    df -m "$caminho" | awk 'NR==2 {print $4}'
}

# Verifica se há espaço suficiente
# Parâmetros: $1=caminho $2=espaço_necessário_MB
# Retorna: 0=suficiente 1=insuficiente
_verificar_espaco() {
    local caminho="$1"
    local necessario="$2"
    local livre
    
    livre=$(_espaco_livre "$caminho")
    (( livre >= necessario ))
}

#---------- FUNÇÕES DE ARQUIVO ----------#

# Cria backup de arquivo com timestamp
# Parâmetros: $1=arquivo_original $2=diretório_backup(opcional)
_backup_arquivo() {
    local arquivo="$1"
    local dir_backup="${2:-${BACKUP:-./backup}}"
    local nome_base
    local extensao
    local timestamp
    local arquivo_backup
    
    if [[ ! -f "$arquivo" ]]; then
        _log_erro "Arquivo não encontrado para backup: $arquivo"
        return 1
    fi
	
    # Criar diretório de backup se necessário
    mkdir -p "$dir_backup"
    
    # Extrair nome e extensão
    nome_base=$(basename "$arquivo")
    if [[ "$nome_base" == *.* ]]; then
        extensao=".${nome_base##*.}"
        nome_base="${nome_base%.*}"
    else
        extensao=""
    fi
    
    timestamp=$(date +"%Y%m%d_%H%M%S")
    arquivo_backup="${dir_backup}/${nome_base}_${timestamp}${extensao}"
    
    if cp "$arquivo" "$arquivo_backup"; then
        _log_sucesso "Backup criado: $arquivo_backup"
        echo "$arquivo_backup"
        return 0
    else
        _log_erro "Falha ao criar backup: $arquivo"
        return 1
    fi
}

# Remove arquivos antigos de um diretório
# Parâmetros: $1=diretório $2=dias $3=padrão(opcional)
_limpar_arquivos_antigos() {
    local diretorio="$1"
    local dias="$2"
    local padrao="${3:-*}"
    local count
    
    if [[ ! -d "$diretorio" ]]; then
        _log_erro "Diretório não encontrado: $diretorio"
        return 1
    fi
    
    count=$(find "$diretorio" -name "$padrao" -type f -mtime +"$dias" -print | wc -l)
    
    if (( count > 0 )); then
        _log "Removendo $count arquivos antigos de $diretorio"
        find "$diretorio" -name "$padrao" -type f -mtime +"$dias" -delete
        return 0
    else
        _log "Nenhum arquivo antigo encontrado em $diretorio"
        return 0
    fi
}

#---------- FUNÇÕES DE INICIALIZAÇÃO ----------#

# Executa limpeza automática diária
_executar_expurgador_diario() {
    local flag_file
    local savlog="${destino}/sav/portalsav/log"
    local err_isc="${destino}/sav/err_isc"
    local viewvix="${destino}/sav/savisc/viewvix/tmp"

    flag_file="${LOGS}/.expurgador_$(date +%Y%m%d)"
    
    # Se já foi executado hoje, pular
    if [[ -f "$flag_file" ]]; then
        return 0
    fi
    
    # Remover flags antigas (mais de 3 dias)
    find "${LOGS}" -name ".expurgador_*" -mtime +3-delete 2>/dev/null || true
    
    # Executar limpeza básica
    _limpar_arquivos_antigos "${LOGS}" 30 "*.log"
    _limpar_arquivos_antigos "${BACKUP}" 30 "Temps*"
    _limpar_arquivos_antigos "${OLDS}" 30 "Temps*"
    _limpar_arquivos_antigos "${savlog}" 30 "Temps*"
    _limpar_arquivos_antigos "${err_isc}" 30 "Temps*"
    _limpar_arquivos_antigos "${viewvix}" 30 "Temps*"
    
    # Criar flag para hoje
    touch "$flag_file"
    
    _log "Limpeza automática diária executada"
}

# Funcao para checar se o zip esta instalado
# Checa se os programas necessarios para o atualiza.sh estao instalados no sistema.
# Se o programa nao for encontrado, exibe uma mensagem de erro e sai do programa.
_check_instalado() {
    local app
    local missing=""
    for app in zip unzip rsync wget; do
        if ! command -v "$app" &>/dev/null; then
            missing="$missing $app"
            printf "\n"
            printf "%*s""${RED}"
            printf "%*s\n" $(((${#Z1} + COLUMNS) / 2)) "${Z1}"
            printf "%*s""${NORM}"
            printf "%*s""${YELLOW}" " O programa nao foi encontrado ->> " "${NORM}" "${app}"
            printf "\n"
            case "$app" in
            zip | unzip) echo "  Sugestao: Instale o zip, unzip." ;;
            rsync) echo "  Sugestao: Instale o rsync." ;;
            wget) echo "  Sugestao: Instale o wget." ;;
            esac
        fi
    done
    if [ -n "$missing" ]; then
        _mensagec "${YELLOW}" "Instale os programas ausentes ($missing) e tente novamente."
        exit 1
    fi
}
 