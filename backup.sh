#!/usr/bin/env bash
#
# backup.sh - Modulo do Sistema de Backup
# Responsavel por backup completo, incremental e restauraçao
#
# SISTEMA SAV - Script de Atualizaçao Modular
# Versao: 10/10/2025-00

destino="${destino:-}"
sistema="${sistema:-}"
base="${base:-}"           # Caminho do diretorio da segunda base de dados.
base2="${base2:-}"           # Caminho do diretorio da segunda base de dados.
base3="${base3:-}"           # Caminho do diretorio da terceira base de dados.
BASE_TRABALHO="${BASE_TRABALHO:-}"
cmd_zip="${cmd_zip:-}"

# Carregar configurações e variaveis globais
_carregar_modulo "config.sh"

# Verificar variáveis essenciais
if [[ -z "$destino" ]]; then
    _mensagec "${RED}" "Erro: Variável 'destino' não definida"
    return 1
fi

if [[ -z "$sistema" ]]; then
    _mensagec "${RED}" "Erro: Variável 'sistema' não definida"
    return 1
fi

if [[ -z "$BACKUP" ]]; then
    _mensagec "${RED}" "Erro: Variável 'BACKUP' não definida"
    return 1
fi

# Verificar comandos externos necessários
for cmd in zip unzip; do
    if ! command -v "${cmd}" &>/dev/null; then
        _mensagec "${RED}" "Erro: Comando ${cmd} não encontrado"
        return 1
    fi
done

#---------- FUNÇÕES PRINCIPAIS DE BACKUP ----------#

# Executa backup do sistema
_executar_backup() {
    local base_trabalho

    # Escolher base se necessario
    if [[ -n "${base2}" ]]; then
        _menu_escolha_base || return 1
        base_trabalho="${BASE_TRABALHO}"
    else
        base_trabalho="${destino}${base}"
    fi
 

    # Criar diretorio de backup se nao existir
    if [[ ! -d "$BACKUP" ]]; then
        _mensagec "$YELLOW" "Criando diretorio de backups em $BACKUP..."
        mkdir -p "$BACKUP" || {
            _mensagec "$RED" "Erro ao criar diretorio de backup"
            return 1
        }
    fi

    # Escolher tipo de backup
    _menu_tipo_backup
    if [[ -z "$tipo_backup" ]]; then
        return 1
    fi

    # Gerar nome do arquivo
    local nome_backup
    nome_backup="${EMPRESA}_${base_trabalho}_${tipo_backup}_$(date +%Y%m%d%H%M).zip"
    local caminho_backup="$BACKUP/$nome_backup"

    # Verificar backups recentes
    if _verificar_backups_recentes; then
        if ! _confirmar "Ja existe backup recente. Deseja continuar?" "N"; then
            _mensagec "$RED" "Operaçao cancelada"
            _read_sleep 3
            return 1
        fi
        _mensagec "$YELLOW" "Sera criado backup adicional"
    fi

    # Mudar para diretorio base
    _diretorio_trabalho

    _linha
    _mensagec "$YELLOW" "Criando Backup..."
    _linha

    # Variavel para armazenar PID do processo em background
    local backup_pid

    # === LoGICA ESPECIAL PARA BACKUP INCREMENTAL: PEDIR ENTRADA ANTES DO & ===
    if [[ "$tipo_backup" == "incremental" ]]; then
        local mes ano data_referencia

        _linha
        _mensagec "$YELLOW" "Digite o mês (01-12) e ano (ex: 202?) para o backup incremental:"
        _linha

        read -rp "${YELLOW}Mes (MM): ${NORM}" mes
        _linha
        read -rp "${YELLOW}Ano (AAAA): ${NORM}" ano
        _linha

        # Validar entrada
        if ! [[ "$mes" =~ ^(0[1-9]|1[0-2])$ ]] || ! [[ "$ano" =~ ^[0-9]{4}$ ]]; then
            _mensagec "$RED" "Mes ou ano invalido. Use formato MM (01-12) e YYYY."
            _read_sleep 2
            return 1
        fi

        data_referencia="${ano}-${mes}-01"
        local data_atual
        data_atual=$(date +%Y%m%d)
        local data_input
        data_input=$(date -d "$data_referencia" +%Y%m%d 2>/dev/null) || {
            _mensagec "$RED" "Data invalida."
            return 1
        }

        if [[ "$data_input" -gt "$data_atual" ]]; then
            _mensagec "$RED" "A data nao pode ser futura."
            _read_sleep 2
            return 1
        fi

        # Agora sim, executar o backup incremental em background
        _executar_backup_incremental "$caminho_backup" "$data_referencia" &
        backup_pid=$!

    else
        # Backup completo: executa diretamente em background
        _executar_backup_completo "$caminho_backup" &
        backup_pid=$!
    fi

    # Mostrar barra de progresso
    _mostrar_progresso_backup "$backup_pid"

    # Verificar resultado
    if wait "$backup_pid" 2>/dev/null; then
        _finalizar_backup_sucesso "$nome_backup"
    else
        _mensagec "$RED" "Erro ao criar backup"
        return 1
    fi

    # Perguntar sobre envio
    if _confirmar "Deseja enviar backup para servidor?" "N"; then
        _enviar_backup_servidor "$nome_backup"
    fi
}

# Restaura backup do sistema
_restaurar_backup() {
    local arquivos_backup
    local backup_selecionado

    # Listar backups disponiveis
    shopt -s nullglob
    mapfile -t arquivos_backup < <(printf '%s\n' "${BACKUP}"/*.zip)
    
    # Restaurar configuração original ao sair da função
    trap 'shopt -u nullglob' RETURN

    if (( ${#arquivos_backup[@]} == 0 )); then
        _mensagec "${RED}" "Nenhum arquivo de backup encontrado em ${BACKUP}"
        _press
        return 1
    fi

    # Mostrar backups disponiveis
    _linha
    ls -lh "${BACKUP}"/*.zip 2>/dev/null
    _linha
    _mensagec "${RED}" "Informe parte do nome do backup para restaurar:"
    _linha

    local nome_backup
    read -rp "${YELLOW}Nome do backup: ${NORM}" nome_backup
    if [[ -z "$nome_backup" ]]; then
        _mensagec "${RED}" "Nome nao informado"
        _press
        return 1
    fi

    # Buscar backups correspondentes
    local backups_encontrados=()
    mapfile -t backups_encontrados < <(ls -1 "${BACKUP}"/*"${nome_backup}"*.zip 2>/dev/null)
    case ${#backups_encontrados[@]} in
        0)
            _mensagec "${RED}" "Nenhum backup corresponde a \"${nome_backup}\""
            _press
            return 1
            ;;
        1)
            backup_selecionado="${backups_encontrados[0]}"
            ;;
        *)
            backup_selecionado=$(_selecionar_backup_menu "${backups_encontrados[@]}")
            if [[ -z "$backup_selecionado" ]]; then
                return 1
            fi
            ;;
    esac

    # Escolher tipo de restauraçao
    if _confirmar "Deseja restaurar TODOS os arquivos do backup?" "N"; then
        _restaurar_backup_completo "$backup_selecionado"
    else
        _restaurar_arquivo_especifico "$backup_selecionado"
    fi
}

# Envia backup avulso
_enviar_backup_avulso() {
local backup_selecionado
shopt -s nullglob

# Listar backups disponíveis
backups=( "${BACKUP}/${EMPRESA}"_*.zip )

# Restaurar configuração original ao sair da função
trap 'shopt -u nullglob' RETURN

if (( ${#backups[@]} == 0 )); then
    _mensagec "${RED}" "Nenhum backup encontrado"
    _press
    return 1
fi
    # Mostrar lista
    _linha
    ls -lh "${BACKUP}/${EMPRESA}"_*.zip
    _linha

    # Solicitar seleçao
    local nome_backup
    read -rp "${YELLOW}Informe parte do nome do backup: ${NORM}" nome_backup
    if [[ -z "$nome_backup" ]]; then
        _mensagec "${RED}" "Nome nao informado"
        _press
        return 1
    fi

    # Buscar backups
    local backups_encontrados=()
    mapfile -t backups_encontrados < <(ls -1 "${BACKUP}"/*"${nome_backup}"*.zip 2>/dev/null)
    case ${#backups_encontrados[@]} in
        0)
            _mensagec "${RED}" "Backup nao encontrado"
            _press
            return 1
            ;;
        1)
            backup_selecionado=$(basename "${backups_encontrados[0]}")
            ;;
        *)
            backup_selecionado=$(_selecionar_backup_menu "${backups_encontrados[@]}")
            if [[ -z "$backup_selecionado" ]]; then
                return 1
            fi
            backup_selecionado=$(basename "$backup_selecionado")
            ;;
    esac

    _mensagec "${YELLOW}" "Backup selecionado: ${backup_selecionado}"

    # Verificar modo offline
    if [[ "${SERACESOFF}" == "s" ]]; then
        _mover_backup_offline "$backup_selecionado"
        return
    fi

    # Envio via rede
    if _confirmar "Enviar backup via rede?" "S"; then
        _enviar_backup_rede "$backup_selecionado"
    fi
}

#---------- FUNÇÕES DE EXECUÇaO DE BACKUP ----------#

# Executa backup completo
_executar_backup_completo() {
    local arquivo_destino="$1"
    _log "Executando backup completo para: $arquivo_destino"
    _diretorio_trabalho

    local arquivos_encontrados
    arquivos_encontrados=$(find . -maxdepth 1 -type f -name "*.*" ! -name "*.zip" ! -name "*.tar" ! -name "*.tar.gz" | wc -l)
    _log "Arquivos encontrados para backup: $arquivos_encontrados"

    if ! "$cmd_zip" "$arquivo_destino" ./*.* -x ./*.zip ./*.tar ./*.tar.gz >>"${LOG_ATU}" 2>&1; then
        _mensagec "${RED}" "Erro ao criar backup completo"
        _log_erro "Falha na criação do backup completo: $arquivo_destino"
        return 1
    fi

    # Verificar se arquivo foi criado e tamanho
    if [[ -f "$arquivo_destino" && -s "$arquivo_destino" ]]; then
        local tamanho
        tamanho=$(du -h "$arquivo_destino" | cut -f1)
        _log_sucesso "Backup completo criado com sucesso: $arquivo_destino (Tamanho: $tamanho)"
    else
        _log_erro "Backup completo não foi criado ou está vazio: $arquivo_destino"
        return 1
    fi
}

# Executa backup incremental (recebe data como parâmetro)
_executar_backup_incremental() {
    local arquivo_destino="$1"
    local data_referencia="$2"
    _diretorio_trabalho

    local arquivos_encontrados
    arquivos_encontrados=$(find . -type f -newermt "$data_referencia" \
           ! -name "*.zip" ! -name "*.tar" ! -name "*.tar.gz" -print | wc -l)
           
    if [[ "$arquivos_encontrados" -eq 0 ]]; then
        _mensagec "${YELLOW}" "Nenhum arquivo encontrado para backup incremental desde $data_referencia"
        return 1
    fi

    if ! find . -type f -newermt "$data_referencia" \
           ! -name "*.zip" ! -name "*.tar" ! -name "*.tar.gz" -print0 | \
        xargs -0 "$cmd_zip" "$arquivo_destino" >/dev/null 2>&1; then
        _mensagec "${RED}" "Erro ao criar backup incremental"
        return 1
    fi
}

# Diretorio de trabalho
_diretorio_trabalho() {
    local base_trabalho="${BASE_TRABALHO:-${destino}${base}}"
    cd "$base_trabalho" || {
        _mensagec "${RED}" "Erro: Diretorio ${base_trabalho} nao encontrado"
        return 1 
    } 
}

#---------- FUNÇÕES DE RESTAURAÇaO ----------#

# Restaura backup completo
_restaurar_backup_completo() {
    local arquivo_backup="$1"
    base_trabalho="${destino}${base}"
    _linha
    _mensagec "${YELLOW}" "Restaurando todos os arquivos..."
    _linha
    if ! "${cmd_unzip:-unzip}" -o "$arquivo_backup" -d "${base_trabalho}" >>"${LOG_ATU}" 2>&1; then
        _mensagec "${RED}" "Erro na restauraçao completa"
        _press
        return 1
    fi
    _mensagec "${GREEN}" "Restauraçao completa concluida"
    _press
}

# Restaura arquivo especifico
_restaurar_arquivo_especifico() {
    local arquivo_backup="$1"
    local nome_arquivo
    base_trabalho="${destino}${base}"
    read -rp "${YELLOW}Nome do arquivo (maiúsculo, sem extensao): ${NORM}" nome_arquivo
    if [[ ! "$nome_arquivo" =~ ^[A-Z0-9]+$ ]]; then
        _mensagec "${RED}" "Nome de arquivo invalido"
        _press
        return 1
    fi
    _linha
    _mensagec "${YELLOW}" "Restaurando ${nome_arquivo}..."
    _linha
    if ! "${cmd_unzip}" -o "$arquivo_backup" "${nome_arquivo}"*.* -d "${base_trabalho}" >>"${LOG_ATU}" 2>&1; then
        _mensagec "${RED}" "Erro ao extrair ${nome_arquivo}"
        _press
        return 1
    fi
    if ls "${base_trabalho}/${nome_arquivo}"*.* >/dev/null 2>&1; then
        _mensagec "${GREEN}" "Arquivo ${nome_arquivo} restaurado com sucesso"
    else
        _mensagec "${YELLOW}" "Arquivo ${nome_arquivo} nao encontrado apos restauraçao"
    fi
    _press
}

#---------- FUNÇÕES DE ENVIO ----------#

# Envia backup para servidor
_enviar_backup_servidor() {
    local nome_backup="$1"
    local destino_remoto

    # Verificar se rsync está disponível
    if ! command -v rsync &>/dev/null; then
        _mensagec "${RED}" "Erro: Comando rsync não encontrado"
        _press
        return 1
    fi

    # Determinar destino
    if [[ -n "${ENVIABACK}" ]]; then
        destino_remoto="${ENVIABACK}"
    else
        read -rp "${YELLOW}Diretorio de destino no servidor: ${NORM}" destino_remoto
        while [[ -z "$destino_remoto" ]]; do
            _mensagec "$RED" "Diretorio nao pode estar vazio"
            read -rp "${YELLOW}Diretorio de destino: ${NORM}" destino_remoto
        done
    fi

    _linha
    _mensagec "${YELLOW}" "Enviando backup via rsync..."
    _linha
    if rsync -avzP -e "ssh -p ${PORTA}" "${BACKUP}/${nome_backup}" "${USUARIO}@${IPSERVER}:/${destino_remoto}"; then
        _mensagec "${YELLOW}" "Backup enviado para \"${destino_remoto}\""
        _read_sleep 3
        # Perguntar sobre manter backup local
        if _confirmar "Manter backup local?" "S"; then
            _mensagec "${YELLOW}" "Backup local mantido"
        else
            if rm -f "${BACKUP}/${nome_backup}"; then
                _mensagec "${YELLOW}" "Backup local excluido"
            fi
        fi
    else
        _mensagec "${RED}" "Erro ao enviar backup"
    fi
}

# Move backup para diretorio offline
_mover_backup_offline() {
    local nome_backup="$1"
    local destino_offline="${destino}${SERACESOFF}"
    mkdir -p "$destino_offline" || {
        _mensagec "${RED}" "Erro ao criar diretorio offline"
        return 1
    }
    if mv -f "${BACKUP}/${nome_backup}" "$destino_offline"; then
        _mensagec "${YELLOW}" "Backup movido para: ${destino_offline}"
        _press
    else
        _mensagec "${RED}" "Erro ao mover backup"
        _press
    fi
}

# Envia backup via rede
_enviar_backup_rede() {
    local nome_backup="$1"
    local destino_remoto
    
    # Verificar se rsync está disponível
    if ! command -v rsync &>/dev/null; then
        _mensagec "${RED}" "Erro: Comando rsync não encontrado"
        _press
        return 1
    fi
    
    if [[ -n "${ENVIABACK}" ]]; then
        destino_remoto="${ENVIABACK}"
    else
        read -rp "${YELLOW}Diretorio remoto: ${NORM}" destino_remoto
        while [[ -z "$destino_remoto" ]]; do
            _mensagec "$RED" "Diretorio nao informado"
            read -rp "${YELLOW}Diretorio remoto: ${NORM}" destino_remoto
        done
    fi

    _linha
    _mensagec "${YELLOW}" "Enviando backup..."
    _linha
    if rsync -avzP -e "ssh -p ${PORTA}" "${BACKUP}/${nome_backup}" "${USUARIO}@${IPSERVER}:/${destino_remoto}" 2>/dev/null; then
        _mensagec "${YELLOW}" "Backup enviado para \"${destino_remoto}\" no servidor ${IPSERVER}"
        _read_sleep 3
    else
        _mensagec "${RED}" "Erro ao enviar backup via rsync"
        _press
    fi
}

#---------- FUNÇÕES AUXILIARES ----------#

# Verifica backups recentes (últimos 2 dias)
_verificar_backups_recentes() {
    if find "$BACKUP" -maxdepth 1 -ctime -2 -name "${EMPRESA}*zip" -print -quit | grep -q .; then
        _linha
        _mensagec "$CYAN" "Ja existe backup recente em $BACKUP:"
        _linha
        ls -ltrh "${BACKUP}/${EMPRESA}"_*.zip
        _linha
        return 0
    fi
    return 1
}

# Finaliza backup com sucesso
_finalizar_backup_sucesso() {
    local nome_backup="$1"
    _mensagec "$YELLOW" "O backup $nome_backup foi criado em $BACKUP"
    _linha
    _mensagec "$YELLOW" "Backup Concluido!"
    _linha
}

# Menu de seleçao de backup
_selecionar_backup_menu() {
    local backups=("$@")
    local escolha
    _linha
    _mensagec "${RED}" "Varios backups encontrados. Escolha um:"
    _linha
    select escolha in "${backups[@]}" "Cancelar"; do
        case $REPLY in
            ''|*[!0-9]*)
                echo "Digite o número da opçao."
                continue
                ;;
        esac
        if (( REPLY >= 1 && REPLY <= ${#backups[@]} )); then
            echo "$escolha"
            return 0
        else
            echo ""
            return 1
        fi
    done
}