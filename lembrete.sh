#!/usr/bin/env bash
#
# utils.sh - Módulo de Utilitários e Funções Auxiliares  
# Funções básicas para formatação, mensagens, validação e controle de fluxo
#---------- FUNÇÕES DE LEMBRETES ----------#

# Escreve nova nota
_escrever_nova_nota() {
    clear
    _linha
    _mensagec "${YELLOW}" "Digite sua nota (pressione Ctrl+D para finalizar):"
    _linha

    local arquivo_notas="${CFG}/atualizal"
    if cat >> "$arquivo_notas"; then
        _linha
        _mensagec "${YELLOW}" "Nota gravada com sucesso!"
        sleep 2
    else
        _mensagec "${RED}" "Erro ao gravar nota"
        sleep 2
    fi
}

# Mostra notas iniciais se existirem
_mostrar_notas_iniciais() {
    local nota_file="${CFG}/atualizal"
    
    if [[ -f "$nota_file" && -s "$nota_file" ]]; then
        _visualizar_notas_arquivo "$nota_file"
    fi
}

# Visualiza arquivo de notas formatado
# Parâmetros: $1=arquivo_de_notas
_visualizar_notas_arquivo() {
    local arquivo="$1"
    local largura_max=0
    local largura_total
    local llinha
    
    if [[ ! -f "$arquivo" || ! -r "$arquivo" ]]; then
        _mensagec "${RED}" "Arquivo de notas não encontrado ou ilegível: $arquivo"
        _press
        return 1
    fi
    
    clear
    
    # Calcular largura máxima
    while IFS= read -r llinha; do
        if (( ${#llinha} > largura_max )); then
            largura_max=${#llinha}
        fi
    done < "$arquivo"
    
    largura_total=$((largura_max + 4))
    
    # Criar moldura superior
    printf "+"
    printf "%*s" $((largura_total - 2)) "" | tr ' ' '='
    printf "+\n"
    
    # Mostrar conteúdo com bordas
    while IFS= read -r llinha || [[ -n "$llinha" ]]; do
        printf "| %-*s |\n" $((largura_total - 4)) "$llinha"
    done < "$arquivo"
    
    # Criar moldura inferior  
    printf "+"
    printf "%*s" $((largura_total - 2)) "" | tr ' ' '='
    printf "+\n"
    _linha
    _press 
}

# Edita nota existente
_editar_nota_existente() {
    local arquivo_notas="${CFG}/atualizal"
    
    clear
    if [[ -f "$arquivo_notas" ]]; then
        if ! ${EDITOR:-nano} "$arquivo_notas"; then
            _mensagec "${RED}" "Erro ao abrir editor!"
            sleep 2
        fi
    else
        _mensagec "${YELLOW}" "Nenhuma nota encontrada para editar!"
        sleep 2
    fi
}

# Apaga nota existente
_apagar_nota_existente() {
    local arquivo_notas="${CFG}/atualizal"
    
    if [[ ! -f "$arquivo_notas" ]]; then
        _mensagec "${YELLOW}" "Nenhuma nota encontrada para excluir!"
        sleep 2
        return
    fi

    if _confirmar "Tem certeza que deseja apagar todas as notas?" "N"; then
        if rm -f "$arquivo_notas"; then
            _mensagec "${RED}" "Notas excluídas com sucesso!"
        else
            _mensagec "${RED}" "Erro ao excluir notas"
        fi
        sleep 2
    fi
}