#!/usr/bin/env bash
#
# auth.sh - Modulo de Autenticacao
# Responsavel pela autenticacao de usuarios
#
# SISTEMA SAV - Script de Atualizacao Modular
# Versao: 09/03/2026-01
# Autor: Luiz Augusto
#
#
# Variaveis globais esperadas
cfg_dir="${cfg_dir:-}"                 # Diretorio de configuracao

# Arquivo de senhas oculto
SENHA_FILE="${cfg_dir}/.senhas"

# Variavel global para armazenar o nome do usuario autenticado
declare -u usuario           # Variavel global para armazenar o nome do usuario autenticado

# Funcao para hash da senha
_hash_senha() {
    local senha="$1"
    echo -n "$senha" | sha256sum | cut -d' ' -f1
}

# Funcao para cadastrar usuario
_cadastrar_usuario() {
    local usuario senha senha_confirm hash_senha

    printf "Cadastro de Usuario\n"
    printf "===================\n\n"

    read -rp "Digite o nome do usuario: " usuario
    usuario=$(echo "$usuario" | tr '[:lower:]' '[:upper:]')
    if [[ -z "$usuario" ]]; then
        printf "Usuario nao pode ser vazio.\n"
        return 1
    fi

    # Verificar se usuario ja existe
    if grep -q "^${usuario}:" "$SENHA_FILE" 2>/dev/null; then
        printf "Usuario ja existe.\n"
        return 1
    fi

    read -rsp "Digite a senha: " senha
    printf "\n"
    read -rsp "Confirme a senha: " senha_confirm
    printf "\n"

    if [[ "$senha" != "$senha_confirm" ]]; then
        printf "Senhas nao coincidem.\n"
        return 1
    fi

    if [[ -z "$senha" ]]; then
        printf "Senha nao pode ser vazia.\n"
        return 1
    fi

    hash_senha=$(_hash_senha "$senha")
    echo "${usuario}:${hash_senha}" >> "$SENHA_FILE"
    printf "Usuario cadastrado com sucesso.\n"
}

# Funcao para login
_login() {
    local senha hash_senha stored_hash
    # usuario is made global to be used in logging

    printf "Login no Sistema\n"
    printf "================\n\n"

    read -rp "Usuario: " usuario
    usuario=$(echo "$usuario" | tr '[:lower:]' '[:upper:]')
    read -rsp "Senha: " senha
    printf "\n"

    if [[ ! -f "$SENHA_FILE" ]]; then
        printf "Nenhum usuario cadastrado. Execute o programa de cadastro primeiro.\n"
        return 1
    fi

    # Verificar se o arquivo de senhas esta vazio
    if [[ ! -s "$SENHA_FILE" ]]; then
        printf "ALERTA: Arquivo de senhas esta vazio. Nenhum usuario cadastrado no sistema.\n"
        printf "Execute o programa de cadastro primeiro.\n"
        return 1
    fi

    stored_hash=$(grep "^${usuario}:" "$SENHA_FILE" | cut -d':' -f2)
    if [[ -z "$stored_hash" ]]; then
        printf "Usuario nao encontrado.\n"
        return 1
    fi

    hash_senha=$(_hash_senha "$senha")
    if [[ "$hash_senha" == "$stored_hash" ]]; then
        printf "Login bem-sucedido.\n"
        export usuario
        return 0
    else
        printf "Senha incorreta.\n"
        # Clear usuario on failure
        unset usuario
        return 1
    fi
}    

# Funcao para alterar senha
_alterar_senha() {
    local senha_atual nova_senha confirm_senha hash_atual hash_nova stored_hash
    read -rp "Usuario: " usuario
    usuario=$(echo "$usuario" | tr '[:lower:]' '[:upper:]')
    if [[ -z "$usuario" ]]; then
        printf "Voce precisa estar logado para alterar a senha.\n"
        return 1
    fi

    printf "Alteracao de Senha\n"
    printf "==================\n\n"

    read -rsp "Digite a senha atual: " senha_atual
    printf "\n"

    # Verificar senha atual
    stored_hash=$(grep "^${usuario}:" "$SENHA_FILE" | cut -d':' -f2)
    if [[ -z "$stored_hash" ]]; then
        printf "Usuario nao encontrado.\n"
        return 1
    fi

    hash_atual=$(_hash_senha "$senha_atual")
    if [[ "$hash_atual" != "$stored_hash" ]]; then
        printf "Senha atual incorreta.\n"
        return 1
    fi

    read -rsp "Digite a nova senha: " nova_senha
    printf "\n"
    read -rsp "Confirme a nova senha: " confirm_senha
    printf "\n"

    if [[ "$nova_senha" != "$confirm_senha" ]]; then
        printf "Novas senhas nao coincidem.\n"
        return 1
    fi

    if [[ -z "$nova_senha" ]]; then
        printf "Nova senha nao pode ser vazia.\n"
        return 1
    fi

    hash_nova=$(_hash_senha "$nova_senha")
    # Atualizar a linha no arquivo
    sed -i "s/^${usuario}:.*/${usuario}:${hash_nova}/" "$SENHA_FILE"
    printf "Senha alterada com sucesso.\n"
}