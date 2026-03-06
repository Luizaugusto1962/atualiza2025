#!/usr/bin/env bash
#
# auth.sh - Modulo de Autenticacao
# Responsavel pela autenticacao de usuarios
#
# SISTEMA SAV - Script de Atualizacao Modular
# Versao: 06/03/2026-01
# Autor: Luiz Augusto
#
#
# Variaveis globais esperadas
cfg_dir="${cfg_dir:-}"                 # Diretorio de configuracao

# Arquivo de senhas oculto
SENHA_FILE="${cfg_dir}/.senhas"

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
    local usuario senha hash_senha stored_hash

    printf "Login no Sistema\n"
    printf "================\n\n"

    read -rp "Usuario: " usuario
    read -rsp "Senha: " senha
    printf "\n"

    if [[ ! -f "$SENHA_FILE" ]]; then
        printf "Nenhum usuario cadastrado. Execute o programa de cadastro primeiro.\n"
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
        return 0
    else
        printf "Senha incorreta.\n"
        return 1
    fi
}