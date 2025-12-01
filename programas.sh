#!/usr/bin/env bash
#
# programas.sh - Módulo de Gestão de Programas
# Responsável pela atualização, instalação e reversão de programas
#
# SISTEMA SAV - Script de Atualizaçao Modular
# Versao: 01/11/2025-00

destino="${destino:-}"
sistema="${sistema:-}"
acessossh="${acessossh:-}"
cmd_zip="${cmd_zip:-}"
cmd_unzip="${cmd_unzip:-}"
cmd_find="${cmd_find:-}"
class="${class:-}"
mclass="${mclass:-}"
Offline="${Offline:-}"
down_dir="${down_dir:-}"
#---------- VARIÁVEIS GLOBAIS DO MÓDULO ----------#

# Arrays para armazenar programas e arquivos
declare -a PROGRAMAS_SELECIONADOS=()
declare -a ARQUIVOS_PROGRAMA=()

#---------- FUNÇÕES DE ATUALIZAÇÃO ONLINE ----------#

# Atualização de programas via conexão online
_atualizar_programa_online() {
    if [[ "${Offline}" == "s" ]]; then
        _linha
        _mensagec "${YELLOW}" "Parâmetro do servidor OFF ativo"
        _linha
        _press
        return 1
    fi
    
    # Solicitar programas a serem atualizados
    _solicitar_programas_atualizacao
    
    if (( ${#ARQUIVOS_PROGRAMA[@]} == 0 )); then
        _mensagec "${YELLOW}" "Nenhum programa selecionado"
        _press
        return 1
    fi
    
    # Baixar programas via rsync
    _baixar_programas_rsync
    
    # Atualizar programas baixados
    _processar_atualizacao_programas
    
    _press
}

# Atualização de programas via arquivos offline
_atualizar_programa_offline() {
    # Solicitar programas a serem atualizados
    _solicitar_programas_atualizacao
    
    if (( ${#ARQUIVOS_PROGRAMA[@]} == 0 )); then
        _mensagec "${YELLOW}" "Nenhum programa selecionado"
        _press
        return 1
    fi
    
    _linha
    _mensagec "${YELLOW}" "Os programas devem estar no diretório ${down_dir}"
    _linha
    _read_sleep 1
    
    # Mover arquivos do servidor offline se configurado
    _mover_arquivos_offline
    
    # Atualizar programas
    _processar_atualizacao_programas
    
    _press
}

# Atualização de programas em pacotes
_atualizar_programa_pacote() {
        _solicitar_pacotes_atualizacao
    if [[ "${Offline}" == "s" ]]; then
        _linha
        _mensagec "${YELLOW}" "Parâmetro do servidor OFF ativo"
        _mover_arquivos_offline
    else 
        _baixar_pacotes_rsync
    fi
        _processar_atualizacao_pacotes
        _press
}

#---------- FUNÇÕES DE REVERSÃO ----------#

# Reverter programas para versão anterior
_reverter_programa() {
    local MAX_REPETICOES=6
    local contador=0
    local programa
    PROGRAMAS_SELECIONADOS=()
    ARQUIVOS_PROGRAMA=()

    # Solicitar programas a reverter
    for ((contador = 1; contador <= MAX_REPETICOES; contador++)); do
        _meiodatela
        _mensagec "${RED}" "Informe o nome do programa a ser revertido:"
        _linha
        
        read -rp "${YELLOW}Nome do programa (ENTER para sair): ${NORM}" programa
        _linha

        # Verificar se foi digitado ENTER
        if [[ -z "${programa}" ]]; then
            _mensagec "${RED}" "Nenhum programa informado. Saindo..."
            _linha
            break
        fi

        # Validar nome do programa
        if ! _validar_nome_programa "$programa"; then
            _mensagec "${RED}" "Erro: Nome inválido. Use apenas letras maiúsculas e números."
            continue
        fi

        # Armazenar programa
        PROGRAMAS_SELECIONADOS+=("$programa")
        local arquivo_zip="${programa}${class}.zip"
        ARQUIVOS_PROGRAMA+=("$arquivo_zip")
        
        _linha
        _mensagec "${GREEN}" "Programa adicionado: ${programa}"
        _linha
        
        # Mostrar lista atual
        _mensagec "${YELLOW}" "Programas a serem revertidos:"
        for prog in "${PROGRAMAS_SELECIONADOS[@]}"; do
            _mensagec "${GREEN}" "  - $prog"
        done
    done

    # Processar reversão
    if (( ${#PROGRAMAS_SELECIONADOS[@]} > 0 )); then
        _processar_reversao_programas
        _mensagem_conclusao_reversao
    else
        _mensagec "${RED}" "Nenhum programa foi selecionado para reversão"
        _press
    fi
}

#---------- FUNÇÕES DE SOLICITAÇÃO DE DADOS ----------#

# Solicita programas para atualização
_solicitar_programas_atualizacao() {
    local MAX_REPETICOES=6
    local contador=0
    local programa
    local tipo_compilacao
    local arquivo_compilado
    
    # Limpar arrays
    PROGRAMAS_SELECIONADOS=()
    ARQUIVOS_PROGRAMA=()

    # Loop para coletar programas
    for ((contador = 1; contador <= MAX_REPETICOES; contador++)); do
        _meiodatela
        _mensagec "${RED}" "Informe o nome do programa a ser atualizado:"
        _linha
        
        read -rp "${YELLOW}Nome do programa (ENTER para finalizar): ${NORM}" programa
        _linha

        # Verificar se foi digitado ENTER
        if [[ -z "${programa}" ]]; then
            _mensagec "${YELLOW}" "Finalizando seleção de programas..."
            _linha
            break
        fi

        # Validar nome do programa
        if ! _validar_nome_programa "$programa"; then
            _mensagec "${RED}" "Erro: Nome inválido. Use apenas letras maiúsculas e números."
            continue
        fi

        # Solicitar tipo de compilação
        _mensagec "${RED}" "Informe o tipo de compilação (1 - Normal, 2 - Depuração):"
        _linha

        read -rp "${YELLOW}Tipo de compilação: ${NORM}" -n1 tipo_compilacao
        printf "\n"

        case "$tipo_compilacao" in
            1)
                arquivo_compilado="${programa}${class}.zip"
                ;;
            2)
                arquivo_compilado="${programa}${mclass}.zip"
                ;;
            *)
                _mensagec "${RED}" "Erro: Opção inválida. Digite 1 ou 2."
                continue
                ;;
        esac

        # Armazenar resultados
        PROGRAMAS_SELECIONADOS+=("$programa")
        ARQUIVOS_PROGRAMA+=("$arquivo_compilado")
        
        _linha
        _mensagec "${GREEN}" "Programa adicionado: ${arquivo_compilado}"
        _linha
        
        # Mostrar lista atual
        _mensagec "${YELLOW}" "Programas selecionados:"
        for arquivo in "${ARQUIVOS_PROGRAMA[@]}"; do
            _mensagec "${GREEN}" "  - $arquivo"
        done
    done
}

# Solicita pacotes para atualização
_solicitar_pacotes_atualizacao() {
    local MAX_REPETICOES=6
    local contador=0
    local programa
    local tipo_compilacao
    local arquivo_compilado
    
    # Limpar arrays
    PROGRAMAS_SELECIONADOS=()
    ARQUIVOS_PROGRAMA=()

    # Loop para coletar pacotes
    for ((contador = 1; contador <= MAX_REPETICOES; contador++)); do
        _meiodatela
        _mensagec "${RED}" "Informe o nome do pacote:"
        _linha
        
        read -rp "${YELLOW}Nome do pacote (ENTER para finalizar): ${NORM}" programa
        _linha

        if [[ -z "${programa}" ]]; then
            _mensagec "${YELLOW}" "Finalizando seleção de pacotes..."
            break
        fi

        if ! _validar_nome_programa "$programa"; then
            _mensagec "${RED}" "Erro: Nome inválido. Use apenas letras maiúsculas e números."
            continue
        fi

        # Solicitar tipo de compilação
        _mensagec "${RED}" "Informe o tipo de compilação (1 - Normal, 2 - Depuração):"
        _linha

        read -rp "${YELLOW}Tipo de compilação: ${NORM}" -n1 tipo_compilacao
        printf "\n"

        case "$tipo_compilacao" in
            1) arquivo_compilado="${programa}${class}.zip" ;;
            2) arquivo_compilado="${programa}${mclass}.zip" ;;
            *)
                _mensagec "${RED}" "Erro: Opção inválida."
                continue
                ;;
        esac

        PROGRAMAS_SELECIONADOS+=("$programa")
        ARQUIVOS_PROGRAMA+=("$arquivo_compilado")
        
        _mensagec "${GREEN}" "Pacote adicionado: ${arquivo_compilado}"
        _linha
    done
}

#---------- FUNÇÕES DE DOWNLOAD ----------#

# Baixa programas via RSYNC/SFTP
_baixar_programas_rsync() {
   _ir_para_tools

    if (( ${#ARQUIVOS_PROGRAMA[@]} == 0 )); then
        return 1
    fi

    _linha
    _mensagec "${YELLOW}" "Realizando sincronização dos arquivos..."

    for arquivo in "${ARQUIVOS_PROGRAMA[@]}"; do
        _linha
        _mensagec "${GREEN}" "Transferindo: $arquivo"
        _linha

        if [[ "${acessossh}" == "n" ]]; then
            _mensagec "${YELLOW}" "Informe a senha para o usuário remoto:"
            _linha
            echo "Transferindo: $arquivo"
#            _press
            if ! sftp -P "$PORTA" "$USUARIO"@"${IPSERVER}":"${DESTINO2SERVER}${arquivo}" .; then
                _mensagec "${RED}" "Falha no download: $arquivo"
                continue
            fi
        else
            sftp sav_servidor <<EOF
get "${DESTINO2SERVER}${arquivo}"
EOF
        fi

        # Verificar se arquivo foi baixado
        if [[ ! -f "$arquivo" || ! -s "$arquivo" ]]; then
            _mensagec "${RED}" "ERRO: Falha ao baixar '$arquivo'"
            continue
        fi
        
        _mensagec "${GREEN}" "Download concluído: $arquivo"
    done
}

# Baixa pacotes para diretório específico
_baixar_pacotes_rsync() {
    _configurar_acessos

    cd "${down_dir}" || {
        _mensagec "${RED}" "Erro: Diretório $down_dir não encontrado"
        return 1
    }

    _baixar_programas_rsync
}

#---------- FUNÇÕES DE PROCESSAMENTO ----------#

# Move arquivos do servidor offline
_mover_arquivos_offline() {
    _configurar_acessos

    cd "${down_dir}" || return 1
    if [[ "${Offline}" == "s" ]]; then
        for arquivo in "${ARQUIVOS_PROGRAMA[@]}"; do
            if [[ -f "${down_dir}/${arquivo}" ]]; then
                if ! mv -f "${down_dir}/${arquivo}" "${TOOLS}"; then
                    _mensagec "${RED}" "Erro ao mover: ${arquivo}"
                    continue
                fi
                _mensagec "${GREEN}" "Arquivo movido: ${arquivo}"
            else
                _mensagec "${RED}" "Arquivo não encontrado: ${arquivo}"
            fi
        done
    fi
}

# Processa atualização dos programas
_processar_atualizacao_programas() {
    _ir_para_tools
    local arquivo         # Nome do arquivo
    local extensao        # Extensão do arquivo
    local backup_file     # Nome do arquivo de backup
    local programa_idx=0  # Índice do programa no array
#    _configurar_acessos
     
    # Verificar se arquivos existem
    for arquivo in "${ARQUIVOS_PROGRAMA[@]}"; do
        if [[ ! -f "${arquivo}" ]]; then
            _mensagec "${RED}" "Arquivo não encontrado: ${arquivo}"
            return 1
        fi
    done

    # Criar backup dos programas antigos
    for programa_idx in "${!PROGRAMAS_SELECIONADOS[@]}"; do
        local programa="${PROGRAMAS_SELECIONADOS[$programa_idx]}"
        local arquivo_backup="${OLDS}/${programa}-anterior.zip"
        
        # Verificar se já existe backup
        if [[ -f "$arquivo_backup" ]]; then
            mv -f "$arquivo_backup" "${OLDS}/${UMADATA}-${programa}-anterior.zip"
        fi
        
        _mensagec "${YELLOW}" "Salvando programa antigo: ${programa}"
        
        # Backup de arquivos .class
        if [[ -f "${E_EXEC}/${programa}.class" ]]; then
            "${cmd_zip}" -m -j "$arquivo_backup" "${E_EXEC}/${programa}"*.class
        fi
        
        # Backup de arquivos .int
        if [[ -f "${E_EXEC}/${programa}.int" ]]; then
            "${cmd_zip}" -m -j "$arquivo_backup" "${E_EXEC}/${programa}.int"
        fi
        
        # Backup de arquivos .TEL
        if [[ -f "${T_TELAS}/${programa}.TEL" ]]; then
            "${cmd_zip}" -m -j "$arquivo_backup" "${T_TELAS}/${programa}.TEL"
        fi
    done

    _linha
    _mensagec "${YELLOW}" "Backup dos programas efetuado"
    _linha
    _read_sleep 1

    # Descompactar e atualizar programas
    for arquivo in "${ARQUIVOS_PROGRAMA[@]}"; do
        if ! "${cmd_unzip}" -o "${arquivo}" >>"${LOG_ATU}"; then
            _mensagec "${RED}" "Erro ao descompactar ${arquivo}"
            continue
        fi
    done

    # Mover arquivos para diretórios corretos
    for extensao in ".class" ".int" ".TEL"; do
        if compgen -G "*${extensao}" >/dev/null; then
            for arquivo in *"${extensao}"; do
                if [[ "${extensao}" == ".TEL" ]]; then
                    mv -f "${arquivo}" "${T_TELAS}/" >>"${LOG_ATU}"
                else
                    mv -f "${arquivo}" "${E_EXEC}/" >>"${LOG_ATU}"
                    _obter_data_arquivo "${arquivo}"
                fi
            done
        fi
    done

    _mensagec "${GREEN}" "Atualizando os programas..."
    _linha

    # Mover arquivos .zip para .bkp
    for arquivo in "${ARQUIVOS_PROGRAMA[@]}"; do
        if [[ -f "${arquivo}" ]]; then
            backup_file="${arquivo%.zip}.bkp"
            mv -f "${arquivo}" "${PROGS}/${backup_file}"
        fi
    done

    _mensagec "${GREEN}" "Alterando extensão da atualização"
    _linha
    _mensagec "${YELLOW}" "Atualização concluída com sucesso!"
}

# Processa atualização de pacotes
_processar_atualizacao_pacotes() {
#    cd "${down_dir}" || return 1
    _configurar_acessos
    # Descompactar pacotes
    for arquivo in "${ARQUIVOS_PROGRAMA[@]}"; do
        if [[ ! -f "${arquivo}" ]]; then
            _mensagec "${RED}" "Arquivo não encontrado: ${arquivo}"
            continue
        fi

        if ! "${cmd_unzip}" -o "${arquivo}" >>"${LOG_ATU}"; then
            _mensagec "${RED}" "Erro ao descompactar ${arquivo}"
            continue
        fi
    done

    # Mover arquivos .zip para .bkp
    for arquivo in "${ARQUIVOS_PROGRAMA[@]}"; do
        if [[ -f "${arquivo}" ]]; then
            local backup_file="${arquivo%.zip}.bkp"
            mv -f "${arquivo}" "${PROGS}/${backup_file}"
        fi
    done

    # Processar arquivos .class encontrados
    find . -type f -name "*.class" | while read -r classfile; do
        local progname="${classfile##*/}" # Extrair nome do arquivo
        progname="${progname%%.class}"    # Remover extensão

        # Backup dos arquivos antigos
        if [[ "${sistema}" == "iscobol" ]]; then
            find "${E_EXEC}" -name "${progname}*.class" -exec "${cmd_zip}" -m -j "${OLDS}/${progname}-anterior.zip" {} + 2>/dev/null
        else
            find "${E_EXEC}" -name "${progname}*.int" -exec "${cmd_zip}" -m -j "${OLDS}/${progname}-anterior.zip" {} + 2>/dev/null
        fi

        # Backup de arquivos .TEL se existirem
        if [[ -f "${progname}.TEL" ]]; then
            find "${T_TELAS}" -name "${progname}*.TEL" -exec "${cmd_zip}" -m -j "${OLDS}/${progname}-anterior.zip" {} + 2>/dev/null
        fi

        # Mover novos arquivos
        mv ./*.class "${E_EXEC}/" >>"${LOG_ATU}" 2>&1
        if [[ -f "${progname}.TEL" ]]; then
            mv ./*.TEL "${T_TELAS}/" >>"${LOG_ATU}" 2>&1
        fi
    done
}

# Processa reversão de programas
_processar_reversao_programas() {
    for programa_idx in "${!PROGRAMAS_SELECIONADOS[@]}"; do
        local programa="${PROGRAMAS_SELECIONADOS[$programa_idx]}"
        local arquivo_anterior="${OLDS}/${programa}-anterior.zip"
        
        if [[ -f "$arquivo_anterior" ]]; then
            mv -f "$arquivo_anterior" "${TOOLS}/${programa}${class}.zip"
            _mensagec "${GREEN}" "Programa revertido: ${programa}"
        else
            _mensagec "${RED}" "Backup não encontrado para: ${programa}"
        fi
    done

    # Processar atualização com os arquivos revertidos
    _ir_para_tools
    _processar_atualizacao_programas
}

#---------- FUNÇÕES AUXILIARES ----------#

# Obtém data de modificação do arquivo
_obter_data_arquivo() {
    local arquivo="$1" # Nome do arquivo
    if [[ -f "${E_EXEC}/${arquivo}" ]]; then
        local data_modificacao
        data_modificacao=$(stat -c %y "${E_EXEC}/${arquivo}" 2>/dev/null)
        if [[ -n "$data_modificacao" ]]; then
            local data_formatada
            data_formatada=$(date -d "$data_modificacao" +"%d/%m/%Y %H:%M:%S" 2>/dev/null)
            _mensagec "${GREEN}" "Nome do programa: ${arquivo}"
            _mensagec "${YELLOW}" "Data do programa: ${data_formatada}"
        fi
    fi
}

# Mensagem de conclusão da reversão
_mensagem_conclusao_reversao() {
    _linha
    _mensagec "${YELLOW}" "Volta do(s) Programa(s) Concluída(s)"
    _linha
    _press

    # Perguntar se deseja reverter mais programas
    if _confirmar "Deseja reverter mais algum programa?" "N"; then
        _reverter_programa
    fi
}

#---------- FUNÇÕES DE INTERFACE ----------#

# Limpa arrays de programas
_limpar_selecao_programas() {
    PROGRAMAS_SELECIONADOS=()
    ARQUIVOS_PROGRAMA=()
}