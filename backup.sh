#!/usr/bin/env bash
#
# backup.sh - Modulo do Sistema de Backup
# Responsavel por backup completo, incremental e restauracao
#
# SISTEMA SAV - Script de Atualizacao Modular
# Versao: 29/12/2025-00
# Autor: Luiz Augusto

sistema="${sistema:-}"
base="${base:-}"           # Caminho do diretorio da segunda base de dados.
base2="${base2:-}"           # Caminho do diretorio da segunda base de dados.
base3="${base3:-}"           # Caminho do diretorio da terceira base de dados.
cmd_zip="${cmd_zip:-}"
Offline="${Offline:-}"
BACKUP="${BACKUP:-}"
backup="${backup:-}"
raiz="${raiz:-}"

#---------- FUNcoES PRINCIPAIS DE backup ----------#

# Executa backup do sistema
_executar_backup() {
    local base_trabalho

    # Escolher base se necessario
    if [[ -n "${base2}" ]]; then
        _menu_escolha_base || return 1
        if [[ -z "${base_trabalho}" ]]; then
           _mensagec "${RED}" "Erro: Base de trabalho nao foi selecionada"
        return 1
       fi
    else
        base_trabalho="${raiz}${base}"
    fi
 

    # Criar diretorio de backup se nao existir
    if [[ ! -d "$backup" ]]; then
        _mensagec "$YELLOW" "Criando diretorio de backups em $backup..."
        mkdir -p "$backup" || {
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
    nome_backup="${EMPRESA}_${tipo_backup}_$(date +%Y%m%d%H%M).zip"
    local caminho_backup="${BACKUP}/$nome_backup"

    # Verificar backups recentes
    if _verificar_backups_recentes; then
        if ! _confirmar "Ja existe backup recente. Deseja continuar?" "N"; then
            _mensagec "$RED" "Operacao cancelada"
            _read_sleep 3
            return 1
        fi
        _mensagec "$YELLOW" "Sera criado backup adicional"
    fi

    # Mudar para diretorio base
    _diretorio_trabalho
    _linha
    _mensagec "$YELLOW" "Criando Backup da pasta: ${base_trabalho}..."
    _linha

    # Variavel para armazenar PID do processo em background
    local backup_pid

    # === LoGICA ESPECIAL PARA backup INCREMENTAL: PEDIR ENTRADA ANTES DO & ===
    if [[ "$tipo_backup" == "incremental" ]]; then
        local mes ano data_referencia

        _linha
        _mensagec "$YELLOW" "Digite o mes (01-12) e ano (ex: 2025) para o backup incremental:"
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

    if (( ${#arquivos_backup[@]} == 0 )); then
        _mensagec "${RED}" "Nenhum arquivo .zip encontrado em ${BACKUP}"
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

    # Escolher tipo de restauracao
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

    # Listar backups disponiveis
    local backups=()
    backups=( "${BACKUP}/${EMPRESA}"_*.zip )

    # Verificar se ha backups disponiveis
    if [[ ! -e "${backups[0]}" ]]; then
        _mensagec "${RED}" "Nenhum backup encontrado"
        _press
        return 1
    fi
    # Mostrar lista
    _linha
    ls -lh "${BACKUP}/${EMPRESA}"_*.zip
    _linha

    # Solicitar selecao
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
    if [[ "${Offline}" == "s" ]]; then
        _mover_backup_offline "$backup_selecionado"
        return
    fi

    # Envio via rede
    if _confirmar "Enviar backup via rede?" "S"; then
        _enviar_backup_rede "$backup_selecionado"
    fi
}

#---------- FUNcoES DE EXECUcaO DE backup ----------#

# Executa backup completo
_executar_backup_completo() {
    local arquivo_destino="$1"
    _diretorio_trabalho
    "$cmd_zip" "$arquivo_destino" ./*.* -x ./*.zip ./*.tar ./*.tar.gz >/dev/null 2>&1
}

# Executa backup incremental (recebe data como parametro)
_executar_backup_incremental() {
    local arquivo_destino="$1"
    local data_referencia="$2"

    # Validar data antes de usar
    if ! date -d "$data_referencia" >/dev/null 2>&1; then
        _mensagec "${RED}" "Data invalida: $data_referencia"
        return 1
    fi

    _diretorio_trabalho

    find . -type f -newermt "$data_referencia" \
           ! -name "*.zip" ! -name "*.tar" ! -name "*.tar.gz" -print0 | \
        xargs -0 "$cmd_zip" "$arquivo_destino" >/dev/null 2>&1

        # Verificar se o backup foi criado
    if [[ ! -f "$arquivo_destino" ]]; then
        _mensagec "${RED}" "Erro: Backup nao foi criado"
        return 1
    fi    
}

# Diretorio de trabalho
_diretorio_trabalho() {
    local base_trabalho="${BASE_TRABALHO:-${raiz}${base}}"
    cd "$base_trabalho" || {
        _mensagec "${RED}" "Erro: Diretorio ${base_trabalho} nao encontrado"
        return 1 
    } 
}

#---------- FUNcoES DE RESTAURAcaO ----------#

# Restaura backup completo
_restaurar_backup_completo() {
    local arquivo_backup="$1"
    base_trabalho="${raiz}${base}"
    _linha
    _mensagec "${YELLOW}" "Restaurando todos os arquivos..."
    _linha
    if ! "${cmd_unzip:-unzip}" -o "$arquivo_backup" -d "${base_trabalho}" >>"${LOG_ATU}" 2>&1; then
        _mensagec "${RED}" "Erro na restauracao completa"
        _press
        return 1
    fi
    _mensagec "${GREEN}" "Restauracao completa concluida"
    _press
}

# Restaura arquivo especifico
_restaurar_arquivo_especifico() {
    local arquivo_backup="$1"
    local nome_arquivo
    base_trabalho="${raiz}${base}"
#    _diretorio_trabalho
    read -rp "${YELLOW}Nome do arquivo (maiúsculo, sem extensao): ${NORM}" nome_arquivo
    if [[ ! "$nome_arquivo" =~ ^[A-Z0-9]+$ ]]; then
        _mensagec "${RED}" "Nome de arquivo invalido"
        _press
        return 1
    fi
    _linha
    _mensagec "${YELLOW}" "Restaurando ${nome_arquivo}..."
    _linha
    if ! "${cmd_unzip}" -o "$arquivo_backup" "${nome_arquivo}*.*" -d "${base_trabalho}" >>"${LOG_ATU}" 2>&1; then
        _mensagec "${RED}" "Erro ao extrair ${nome_arquivo}"
        _press
        return 1
    fi
    if ls "${base_trabalho}/${nome_arquivo}"*.* >/dev/null 2>&1; then
        _mensagec "${GREEN}" "Arquivo ${nome_arquivo} restaurado com sucesso"
    else
        _mensagec "${YELLOW}" "Arquivo ${nome_arquivo} nao encontrado apos restauracao"
    fi
    _press
}

#---------- FUNcoES DE ENVIO ----------#

# Envia backup para servidor
_enviar_backup_servidor() {
    local nome_backup="$1"
    local destino_remoto

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
    _linha
    _mensagec "${YELLOW}" "Movendo backup para diretorio offline..."
    _linha
    if [[ -z "${down_dir}" ]]; then
        _mensagec "${RED}" "Diretorio offline nao configurado"
        return 1
    fi
# Criando diretorio diretorio offline
    if [[ ! -d "${down_dir}" ]]; then
        mkdir -p "${down_dir}" || {
        _mensagec "${RED}" "Erro ao criar diretorio offline"
        return 1
        }
    fi
    
    if mv -f "${BACKUP}/${nome_backup}" "$down_dir"; then
        _mensagec "${YELLOW}" "Backup movido para: ${down_dir}"
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

#---------- FUNcoES AUXILIARES ----------#

# Verifica backups recentes (últimos 2 dias)
_verificar_backups_recentes() {
    if find "${BACKUP}" -maxdepth 1 -ctime -2 -name "${EMPRESA}*zip" -print -quit | grep -q .; then
        _linha
        _mensagec "$CYAN" "Ja existe backup recente em $backup:"
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
    _mensagec "$YELLOW" "O backup $nome_backup foi criado em $backup"
    _linha
    _mensagec "$YELLOW" "Backup Concluido!"
    _linha
}

# Menu de selecao de backup
_selecionar_backup_menu() {
    local backups=("$@")
    local escolha

    _linha
    _mensagec "${RED}" "Varios backups encontrados. Escolha um:"
    _linha
    select escolha in "${backups[@]}" "Cancelar"; do
        case $REPLY in
            ''|*[!0-9]*)
                printf "Digite o número da opcao.\n"
                continue
                ;;
        esac
        if (( REPLY >= 1 && REPLY <= ${#backups[@]} )); then
            printf "%s\n" "$escolha"
            return 0
        else
           printf "\n"
            return 1
        fi
    done
}
