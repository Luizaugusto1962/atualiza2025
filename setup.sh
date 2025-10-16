#!/usr/bin/env bash
#
# setup.sh - Gerencia a configuração do sistema
#
# Este script gerencia a criação e a edição dos arquivos de configuração
# .atualizac e .atualizac, que são essenciais para o funcionamento do sistema.
#
# Modos de Operação:
#   - ./setup.sh: Modo de configuração inicial interativo.
#   - ./setup.sh --edit: Modo de edição para modificar configurações existentes.
#
# SISTEMA SAV - Script de Atualizaçao Modular
# Versao: 10/10/2025-00

#---------- FUNÇÕES DE LÓGICA DE NEGÓCIO ----------#

# Configuração inicial do sistema
_initial_setup() {
    clear

    # Constantes
    local tracejada="#-------------------------------------------------------------------#"
    local traco="#####################################################################"

    # Header inicial
    echo "$traco"
    echo ${traco} >.atualizac
    echo "###      ( Parâmetros para serem usados no atualiza.sh )          ###"
    echo "$traco"
    echo ${traco} >.atualizac
    # Criar arquivos de configuração
    echo "$traco" > .atualizac
    echo "###      ( Parâmetros para serem usados no atualiza.sh )          ###" >> .atualizac
    echo "$traco" >> .atualizac

    # Selecionar sistema (IsCobol ou Microfocus)
    echo "Em qual sistema o SAV está rodando?"
    echo "1) Iscobol"
    echo "2) Microfocus"
    read -n1 -rp "Escolha o sistema: " escolha
    echo

    case "$escolha" in
        1) _setup_iscobol ;;
        2) _setup_cobol ;;
        *)
            echo "Alternativa incorreta, saindo!"
            sleep 1
            exit 1
            ;;
    esac

    # Configurações adicionais
    _setup_banco_de_dados
    _setup_diretorios
    _setup_acesso_remoto
    _setup_backup
    _setup_empresa

    # Finalizar .atualizac
    {
        echo "pasta=/sav/tools"
        echo "progs=/progs"
        echo "olds=/olds"
        echo "logs=/logs"
        echo "cfg=/cfg"
        echo "backup=/backup"
        echo "$tracejada"
    } >> .atualizac

    # Criar atalho global
    echo "cd ${destino}${pasta:-/sav/tools}" > /usr/local/bin/atualiza
    echo "./atualiza.sh" >> /usr/local/bin/atualiza
    chmod +x /usr/local/bin/atualiza

    echo "Pronto!"
}

# Edição de configurações existentes
_edit_setup() {
    local tracejada="#-------------------------------------------------------------------#"

    # Mover para o diretório de configuração
    cd cfg || {
        echo "Erro: Diretório 'cfg' não encontrado."
        exit 1
    }

    # Verificar se os arquivos de configuração existem
    if [[ -f "${LIB_CFG}/.atualizac" ]]; then
        echo "Arquivos de configuração não encontrados. Execute o setup inicial primeiro."
        exit 1
    fi

    echo "=================================================="
    echo "Carregando parâmetros para edição..."
    echo "=================================================="

    # Carregar configurações existentes
    "." ./.atualizac

    # Fazer backup
    cp .atualizac .atualizac.bak

    clear

    # Edição interativa das variáveis
    _editar_variavel sistema
    _editar_variavel verclass

    if [[ -n "$verclass" ]]; then
        local verclass_sufixo="${verclass: -2}"
        class="-class${verclass_sufixo}"
        mclass="-mclass${verclass_sufixo}"
        echo "class e mclass foram atualizados automaticamente:"
        echo "class=${class}"
        echo "mclass=${mclass}"
        _atualizar_savatu_variaveis
    else
        _editar_variavel class
        _editar_variavel mclass
    fi

    _editar_variavel BANCO
    _editar_variavel destino
    _editar_variavel acessossh
    _editar_variavel IPSERVER
    _editar_variavel SERACESOFF
    _editar_variavel ENVIABACK
    _editar_variavel EMPRESA
    _editar_variavel base
    _editar_variavel base2
    _editar_variavel base3

    # Recriar arquivos de configuração
    _recreate_config_files

    echo "Arquivos .atualizac e .atualizac atualizados com sucesso!"

    # Configurar SSH se habilitado
    if [[ "${acessossh}" == "s" ]]; then
        _configure_ssh_access
    fi

    echo "$tracejada"
    read -rp "Pressione Enter para sair..."
    exit 0
}

#---------- FUNÇÕES DE SETUP INICIAL ----------#

# Configuração para IsCobol
_setup_iscobol() {
    sistema="iscobol"
    echo "sistema=iscobol" >> .atualizac
    echo "$tracejada"
    echo "Escolha a versão do Iscobol:"
    echo "1) Versao 2018"
    echo "2) Versao 2020"
    echo "3) Versao 2023"
    echo "4) Versao 2024"
    read -rp "Escolha a versao -> " -n1 VERSAO
    echo

    case "$VERSAO" in
        1) _2018 ;;
        2) _2020 ;;
        3) _2023 ;;
        4) _2024 ;;
        *)
            echo "Alternativa incorreta, saindo!"
            sleep 1
            exit 1
            ;;
    esac

    {
        echo "exec=sav/classes"
        echo "telas=sav/tel_isc"
        echo "xml=sav/xml"
        local classA="IS${VERCLASS}_*_"
        local classB="IS${VERCLASS}_classA_"
        local classC="IS${VERCLASS}_classB_"
        local classD="IS${VERCLASS}_tel_isc_"
        local classE="IS${VERCLASS}_xml_"
        echo "SAVATU=tempSAV_${classA}"
        echo "SAVATU1=tempSAV_${classB}"
        echo "SAVATU2=tempSAV_${classC}"
        echo "SAVATU3=tempSAV_${classD}"
        echo "SAVATU4=tempSAV_${classE}"
    } >> .atualizac
}

# Configuração para Micro Focus Cobol
_setup_cobol() {
    sistema="cobol"
    {
        echo "sistema=cobol"
        echo "class=-6"
        echo "mclass=-m6"
    } >> .atualizac
    {
        echo "exec=sav/int"
        echo "telas=sav/tel"
        echo "SAVATU1=tempSAVintA_"
        echo "SAVATU2=tempSAVintB_"
        echo "SAVATU3=tempSAVtel_"
    } >> .atualizac
}

# Funções de versão do IsCobol
_2018() {
    {
        echo "verclass=2018"
        echo "class=-class"
        echo "mclass=-mclass"
    } >> .atualizac
    VERCLASS="2018"
}
_2020() {
    {
        echo "verclass=2020"
        echo "class=-class20"
        echo "mclass=-mclass20"
    } >> .atualizac
    VERCLASS="2020"
}
_2023() {
    {
        echo "verclass=2023"
        echo "class=-class23"
        echo "mclass=-mclass23"
    } >> .atualizac
    VERCLASS="2023"
}
_2024() {
    {
        echo "verclass=2024"
        echo "class=-class24"
        echo "mclass=-mclass24"
    } >> .atualizac
    VERCLASS="2024"
}

# Configurações adicionais
_setup_banco_de_dados() {
    echo "$tracejada"
    read -rp "Sistema em banco de dados [S/N]: " -n1 BANCO
    echo
    if [[ "${BANCO}" =~ ^[Ss]$ ]]; then
        echo "BANCO=s" >> .atualizac
    else
        echo "BANCO=n" >> .atualizac
    fi
}
_setup_diretorios() {
    echo "$tracejada"
    echo "###     ( Informe a letra da pasta do sistema )    ###"
    read -rp "Informe o diretorio raiz sem o /->: " -n1  destino
    echo "destino=${destino}" >> .atualizac
    echo
    echo ${tracejada}
    echo "###     ( Nome de pasta no servidor )              ###"
    read -rp "Nome da pasta da base de dados (Ex: sav/dados): " base
    echo "base=/${base}" >> .atualizac
    echo ${tracejada}
    read -rp "Nome da pasta da base 2 (Opcional): " base2
    [[ -n "$base2" ]] && echo "base2=/${base2}" >> .atualizac || echo "#base2=" >> .atualizac
    echo ${tracejada}
    read -rp "Nome da pasta da base 3 (Opcional): " base3
    [[ -n "$base3" ]] && echo "base3=/${base3}" >> .atualizac || echo "#base3=" >> .atualizac
    echo ${tracejada}
}
_setup_acesso_remoto() {
    echo "###      ( FACILITADOR DE ACESSO REMOTO )         ###"
    read -rp "Ativar acesso facil (SSH) [S/N]: " -n1 acessossh
    echo
    if [[ "${acessossh}" =~ ^[Ss]$ ]]; then
        echo "acessossh=s" >> .atualizac
    else
        echo "acessossh=n" >> .atualizac
    fi
    echo ${tracejada}
    echo "###      ( IP do servidor da SAV )         ###"
    read -rp "Informe o IP do servidor: " IPSERVER
    echo "IPSERVER=${IPSERVER}" >> .atualizac
    echo "IP do servidor:${IPSERVER}"
    echo ${tracejada}

    echo "###      ( Tipo de acesso        )         ###"
    read -rp "Servidor OFF [S/N]: " -n1 SERACESOFF
    echo
    if [[ "${SERACESOFF}" =~ ^[Ss]$ ]]; then
        echo "SERACESOFF=/sav/portalsav/Atualiza" >> .atualizac
    else
        echo "SERACESOFF=n" >> .atualizac
    fi
}

_setup_backup() {
    echo ${tracejada}
    echo "###     ( Nome de pasta no servidor da SAV )                ###"
    echo "Nome de pasta no servidor da SAV, informar somento o nome do cliente"
    read -rp "(Ex: cliente/NOME_CLIENTE): " ENVIABACK
    if [[ -z "$ENVIABACK" && "${SERACESOFF}" =~ ^[Nn]$ ]]; then
        echo "ENVIABACK=" >> .atualizac
    elif [[ -n "$ENVIABACK" ]]; then
        echo "ENVIABACK=cliente/${ENVIABACK}" >> .atualizac
    else
        echo "ENVIABACK=/sav/portalsav/Atualiza" >> .atualizac
    fi
}
_setup_empresa() {
echo ${tracejada}
echo "###     ( NOME DA EMPRESA )                   ###"
echo "###   Nao pode conter espacos entre o nome    ###"
echo ${tracejada}
    read -rp "Nome da Empresa (sem espaços): " EMPRESA
    echo "EMPRESA=${EMPRESA}" >> .atualizac
}

#---------- FUNÇÕES DE EDIÇÃO ----------#

# Edita uma variável de forma interativa
_editar_variavel() {
    local nome="$1"
    local valor_atual="${!nome}"
    local tracejada="#-------------------------------------------------------------------#"

    read -rp "Deseja alterar ${nome} (valor atual: ${valor_atual})? [s/N] " alterar
    if [[ "${alterar,,}" =~ ^s$ ]]; then
        case "$nome" in
            "sistema")
                echo "1) IsCobol"
                echo "2) Micro Focus Cobol"
                read -rp "Opção [1-2]: " opt
                [[ "$opt" == "1" ]] && sistema="iscobol"
                [[ "$opt" == "2" ]] && sistema="cobol"
                ;;
            "BANCO"|"acessossh")
                read -rp "Novo valor (s/n): " opt
                [[ "$opt" == "s" ]] && eval "$nome=s"
                [[ "$opt" == "n" ]] && eval "$nome=n"
                ;;
            "SERACESOFF")
                read -rp "Sistema em modo Offline? (s/n): " opt
                if [[ "$opt" == "s" ]]; then
                    SERACESOFF="/sav/portalsav/Atualiza"
                else
                    SERACESOFF="n"
                fi
                ;;
            *)
                read -rp "Novo valor para ${nome}: " novo_valor
                eval "$nome=\"$novo_valor\""
                ;;
        esac
    fi
    echo "$tracejada"
}

# Atualiza as variáveis SAVATU com base na 'verclass'
_atualizar_savatu_variaveis() {
    local ano="${verclass}"
    local sufixo="IS${ano}"
    SAVATU="tempSAV_${sufixo}_*_"
    SAVATU1="tempSAV_${sufixo}_classA_"
    SAVATU2="tempSAV_${sufixo}_classB_"
    SAVATU3="tempSAV_${sufixo}_tel_isc_"
    SAVATU4="tempSAV_${sufixo}_xml_"
}

# Recria os arquivos de configuração
_recreate_config_files() {
    local tracejada="#-------------------------------------------------------------------#"
    echo "Recriando arquivos de configuração..."

    {
        echo "sistema=${sistema}"
        [[ -n "$verclass" ]] && echo "verclass=${verclass}"
        [[ -n "$class" ]] && echo "class=${class}"
        [[ -n "$mclass" ]] && echo "mclass=${mclass}"
        echo "BANCO=${BANCO}"
        echo "destino=${destino}"
        echo "acessossh=${acessossh}"
        echo "IPSERVER=${IPSERVER}"
        echo "SERACESOFF=${SERACESOFF}"
        echo "ENVIABACK=${ENVIABACK}"
        echo "EMPRESA=${EMPRESA}"
        echo "base=${base}"
        [[ -n "$base2" ]] && echo "base2=${base2}" || echo "#base2="
        [[ -n "$base3" ]] && echo "base3=${base3}" || echo "#base3="
    } > .atualizac

    {
        echo "exec=sav/classes"
        echo "telas=sav/tel_isc"
        echo "xml=sav/xml"
        echo "SAVATU=${SAVATU}"
        echo "SAVATU1=${SAVATU1}"
        echo "SAVATU2=${SAVATU2}"
        echo "SAVATU3=${SAVATU3}"
        echo "SAVATU4=${SAVATU4}"
        echo "pasta=/sav/tools"
        echo "progs=/progs"
        echo "olds=/olds"
        echo "logs=/logs"
        echo "cfg=/cfg"
        echo "backup=/backup"
    } > .atualizac

    echo "$tracejada"
}

#---------- FUNÇÕES AUXILIARES ----------#

# Cria script de lote para Windows
_create_batch_script() {
    local complemento classA classB classC classD classE

    if [[ "$sistema" == "cobol" ]]; then
        complemento="-6"
        mcomplemento="-m6"
        classA="tempSAVintA_"
        classB="tempSAVintB_"
        classC="tempSAVtel_"
    else
        local verclass_sufixo="${VERCLASS: -2}"
        complemento="-class${verclass_sufixo}"
        mcomplemento="-mclass${verclass_sufixo}"
        classA="tempSAV_IS${VERCLASS}_classA_"
        classB="tempSAV_IS${VERCLASS}_classB_"
        classC="tempSAV_IS${VERCLASS}_tel_isc_"
        classD="tempSAV_IS${VERCLASS}_xml_"
    fi

    {
        echo "@echo off"
        echo "cls"
        echo "setlocal EnableDelayedExpansion"
        echo "set class=${complemento}"
        echo "set mclass=${mcomplemento}"
        echo "set SAVATU1=${classA}"
        echo "set SAVATU2=${classB}"
        echo "set SAVATU3=${classC}"
        [[ -n "$classD" ]] && echo "set SAVATU4=${classD}"
    } > atualiza.bat
}

# Configura acesso SSH facilitado
_configure_ssh_access() {
    local SERVER_IP="${IPSERVER}"
    local SERVER_PORT="${PORTA:-41122}"
    local SERVER_USER="${USUARIO:-atualiza}"
    local CONTROL_PATH_BASE="/${TOOLS}/.ssh/control"

    if [[ -z "$SERVER_IP" || -z "$SERVER_PORT" || -z "$SERVER_USER" ]]; then
        echo "Erro: Variáveis de servidor não definidas para configuração SSH."
        return 1
    fi

    local SSH_CONFIG_DIR
    SSH_CONFIG_DIR=$(dirname "$CONTROL_PATH_BASE")
    mkdir -p "$SSH_CONFIG_DIR" && chmod 700 "$SSH_CONFIG_DIR"

    local CONTROL_PATH="$CONTROL_PATH_BASE"
    mkdir -p "$CONTROL_PATH" && chmod 700 "$CONTROL_PATH"

    if [[ ! -f "/root/.ssh/config" ]]; then
        mkdir -p "/root/.ssh" && chmod 700 "/root/.ssh"
        cat << EOF > "/root/.ssh/config"
Host sav_servidor
    HostName $SERVER_IP
    Port $SERVER_PORT
    User $SERVER_USER
    ControlMaster auto
    ControlPath $CONTROL_PATH/%r@%h:%p
    ControlPersist 10m
EOF
        chmod 600 "/root/.ssh/config"
        echo "Configuração SSH criada."
    elif ! grep -q "Host sav_servidor" "/root/.ssh/config"; then
        echo "Adicionando configuração 'sav_servidor' ao seu ~/.ssh/config..."
        cat << EOF >> "/root/.ssh/config"

Host sav_servidor
    HostName $SERVER_IP
    Port $SERVER_PORT
    User $SERVER_USER
    ControlMaster auto
    ControlPath $CONTROL_PATH/%r@%h:%p
    ControlPersist 10m
EOF
    fi
}

#---------- PONTO DE ENTRADA PRINCIPAL ----------#

# Função principal que direciona para o modo correto
main() {
cd ..
# Diretório do script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR

#LIB_DIR="${SCRIPT_DIR}/libs"
#readonly LIB_DIR

LIB_CFG="${SCRIPT_DIR}/cfg"
readonly LIB_CFG

# Verifica se o diretório tools existe
if [[ ! -d "${LIB_CFG}" ]]; then
    echo "ERRO: Diretório ${LIB_CFG} nao encontrado."
    exit 1
fi

    # Verificar modo de operação
    if [[ "$1" == "--edit" ]]; then
        _edit_setup
    else
        # Verificar se os arquivos de configuração já existem
        if [[ -f "${LIB_CFG}/.atualizac" ]]; then
            clear
            echo "Arquivos de configuração já existem."
            read -rp "Deseja sobrescrevê-los com a configuração inicial? [s/N]: " choice
            if [[ "${choice,,}" == "s" ]]; then
                cd cfg || exit 1
                _initial_setup
            else
                echo "Operação cancelada. Use './setup.sh --edit' para modificar."
                exit 0
            fi
        else
            mkdir -p cfg
            cd cfg || exit 1
            _initial_setup
        fi
    fi
}

# Executar a função principal
main "$@"