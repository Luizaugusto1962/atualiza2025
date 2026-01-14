#!/usr/bin/env bash
#
# SISTEMA SAV - Script de Atualizacao Modular
# lembrete.sh - Modulo de Lembretes e Notas
# Versao: 14/01/2026-00
# Autor: Luiz Augusto
# utils.sh - Modulo de Utilitarios e Funcoes Auxiliares  
# Funcoes basicas para formatacao, mensagens, validacao e controle de fluxo

#---------- FUNcoES DE LEMBRETES ----------#

cfg_dir="${cfg_dir:-}" # Caminho do diretorio de configuracao do programa.

# Mostra menu de lembretes
# Escreve nova nota
_escrever_nova_nota() {
    clear
    _linha
    _mensagec "${YELLOW}" "Digite sua nota (pressione Ctrl+D para finalizar):"
    _linha

    local arquivo_notas="${cfg_dir}/atualizal"
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
    local nota_file="${cfg_dir}/atualizal"
    
    if [[ -f "$nota_file" && -s "$nota_file" ]]; then
        _visualizar_notas_arquivo "$nota_file"
    fi
}

# Visualiza arquivo de notas formatado
# Parametros: $1=arquivo_de_notas
_visualizar_notas_arquivo() {
    local arquivo="$1"
    local largura_max=0
    local largura_total
    local llinha
    
    if [[ ! -f "$arquivo" || ! -r "$arquivo" ]]; then
        _mensagec "${RED}" "Arquivo de notas nao encontrado ou ilegivel: $arquivo"
        _press
        return 1
    fi
    # Mostrar cabecalho de notas.
    clear
    _linha "=" "${CYAN}"
    _mensagec "${YELLOW}" "LEMBRETES E NOTAS"
    _linha "=" "${CYAN}"
    printf "\n"

    # Calcular largura maxima
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
    local arquivo_notas="${cfg_dir}/atualizal"
    
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
    local arquivo_notas="${cfg_dir}/atualizal"
    
    if [[ ! -f "$arquivo_notas" ]]; then
        _mensagec "${YELLOW}" "Nenhuma nota encontrada para excluir!"
        sleep 2
        return
    fi

    if _confirmar "Tem certeza que deseja apagar todas as notas?" "N"; then
        if rm -f "$arquivo_notas"; then
            _mensagec "${RED}" "Notas excluidas com sucesso!"
        else
            _mensagec "${RED}" "Erro ao excluir notas"
        fi
        sleep 2
    fi
}