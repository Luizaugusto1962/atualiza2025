#!/usr/bin/env bash
#
# menus.sh - Sistema de Menus
# Responsável pela apresentação e navegação dos menus do sistema
#
# SISTEMA SAV - Script de Atualizaçao Modular
# Versao: 25/11/2025-00

sistema="${sistema:-}"       # Tipo de sistema que esta sendo usado (iscobol ou isam).
base="${base:-}"
base2="${base2:-}"
base3="${base3:-}"
pasta="${pasta:-}"
#---------- MENU PRINCIPAL ----------#
# Menu principal do sistema
_principal() {
    while true; do
        tput clear
        printf "\n"
        
        # Cabeçalho
        _linha "=" "${GREEN}"
        _mensagec "${RED}" "Menu Principal"
        _linha
        _mensagec "${GREEN}" ".. Empresa: ${EMPRESA} .."
        _linha
        _mensagec "${CYAN}" "_| Sistema: ${sistema} - Versao do Iscobol: ${verclass} |_"
        _linha
        _mensagec "${PURPLE}" " Escolha a opção:"
        printf "\n"
        
        # Opções do menu
        _mensagec "${GREEN}" "1${NORM} - | Atualizar Programa(s) |"
        printf "\n"
        _mensagec "${GREEN}" "2${NORM} - | Atualizar Biblioteca  |"
        printf "\n"
        
        if [[ "${sistema}" = "iscobol" ]]; then
            _mensagec "${GREEN}" "3${NORM} - | Versao do Iscobol     |"
        else
            _mensagec "${GREEN}" "3${NORM} - | Funcao nao disponivel |"
        fi
        printf "\n"
        _mensagec "${GREEN}" "4${NORM} - | Versao do Linux       |"
        printf "\n"
        _mensagec "${GREEN}" "5${NORM} - | Ferramentas           |"
        printf "\n\n"
        _mensagec "${GREEN}" "9 ${RED}- | Sair             |"
        printf "\n"
        
        _mensaged "${BLUE}" "${UPDATE}"
        _linha "=" "${GREEN}"

        local opcao
        read -rp "${YELLOW} Digite a opção desejada -> ${NORM}" opcao

        case "${opcao}" in
            1) _menu_programas ;;
            2) _menu_biblioteca ;;
            3) _mostrar_versao_iscobol ;;
            4) _mostrar_versao_linux ;;
            5) _menu_ferramentas ;;
            9) 
                clear
                _resetando
                ;;
            *)
                _opinvalida
                _read_sleep 1
                ;;
        esac
    done
}

#---------- MENU DE PROGRAMAS ----------#

# Menu de atualização de programas
_menu_programas() {
    while true; do
        clear
        printf "\n"
        _linha "=" "${GREEN}"
        _mensagec "${RED}" "Menu de Programas"
        _linha
        printf "\n"
        _mensagec "${PURPLE}" "Escolha o tipo de Atualização:"
        printf "\n"
        _mensagec "${GREEN}" "1${NORM} - | Programa(s) ON-Line        |"
        printf "\n"
        _mensagec "${GREEN}" "2${NORM} - | Programa(s) OFF-Line       |"
        printf "\n"
        _mensagec "${GREEN}" "3${NORM} - | Programa(s) em Pacote      |"
        printf "\n\n"
        _mensagec "${PURPLE}" "Escolha Desatualizar:              "
        printf "\n"
        _mensagec "${GREEN}" "4${NORM} - | Voltar programa Atualizado |"
        printf "\n\n"
        _mensagec "${GREEN}" "9 ${RED}- | Menu Anterior            |"
        printf "\n"
        
        if [[ -n "${verclass}" ]]; then
            printf "\n"
            _mensaged "${BLUE}" "Versão do Iscobol - ${verclass}"
        fi
        _linha "=" "${GREEN}"

        local opcao
        read -rp "${YELLOW} Digite a opção desejada -> ${NORM}" opcao

        case "${opcao}" in
            1) _atualizar_programa_online ;;
            2) _atualizar_programa_offline ;;
            3) _atualizar_programa_pacote ;;
            4) _reverter_programa ;;
            9) return ;;
            *)
                _opinvalida
                _read_sleep 1
                ;;
        esac
    done
}

#---------- MENU DE BIBLIOTECA ----------#

# Menu de atualização de biblioteca
_menu_biblioteca() {
    while true; do
        clear
        printf "\n"
        _linha "=" "${GREEN}"
        _mensagec "${RED}" "Menu da Biblioteca"
        _linha "="
        printf "\n"
        _mensagec "${PURPLE}" "Escolha o local da Biblioteca:      "
        printf "\n"
        _mensagec "${GREEN}" "1${NORM} - | Atualização do Transpc          |"
        printf "\n" 
        _mensagec "${GREEN}" "2${NORM} - | Atualização do Savatu           |"
        printf "\n"
        _mensagec "${GREEN}" "3${NORM} - | Atualização OFF-Line            |"
        printf "\n\n"
        _mensagec "${PURPLE}" "Escolha Desatualizar:               "
        printf "\n"
        _mensagec "${GREEN}" "4${NORM} - | Voltar Programa(s) da Biblioteca |"
        printf "\n\n"
        _mensagec "${GREEN}" "9${RED} - | Menu Anterior                 |"
        printf "\n"
        
        if [[ -n "${VERSAOANT}" ]]; then
            printf "\n"
            _mensaged "${BLUE}" "Versão Anterior - ${VERSAOANT}"
        fi
        _linha "=" "${GREEN}"

        local opcao
        read -rp "${YELLOW} Digite a opção desejada -> ${NORM}" opcao

        case "${opcao}" in
            1) _atualizar_transpc ;;
            2) _atualizar_savatu ;;
            3) _atualizar_biblioteca_offline ;;
            4) _reverter_biblioteca ;;
            9) return ;;
            *)
                _opinvalida
                _read_sleep 1
                ;;
        esac
    done
}

#---------- MENU DE FERRAMENTAS ----------#

# Menu de ferramentas do sistema
_menu_ferramentas() {
    while true; do
        tput clear
        printf "\n"
        
        _linha "=" "${GREEN}"
        _mensagec "${RED}" "Menu das Ferramentas"
        _linha
        printf "\n"
        _mensagec "${PURPLE}" " Escolha a opção:"
        printf "\n"
        
        # Verificar se sistema tem banco de dados
        if [[ "${BANCO}" = "s" ]]; then
            _mensagec "${GREEN}" "1${NORM} - | Temporarios               |"
            printf "\n"
            _mensagec "${GREEN}" "4${NORM} - | Enviar e Receber Arquivos |"
            printf "\n"
            _mensagec "${GREEN}" "5${NORM} - | Expurgador de Arquivos    |"
            printf "\n"
            _mensagec "${GREEN}" "6${NORM} - | Parametros                |"
            printf "\n"
            _mensagec "${GREEN}" "7${NORM} - | Update                    |"
            printf "\n" 
            _mensagec "${GREEN}" "8${NORM} - | Lembretes                 |"
            printf "\n\n"
        else
            _mensagec "${GREEN}" "1${NORM} - | Temporarios               |"
            printf "\n"
            _mensagec "${GREEN}" "2${NORM} - | Recuperar Arquivos        |"
            printf "\n" 
            _mensagec "${GREEN}" "3${NORM} - | Rotinas de Backup         |"
            printf "\n"
            _mensagec "${GREEN}" "4${NORM} - | Enviar e Receber Arquivos |"
            printf "\n"
            _mensagec "${GREEN}" "5${NORM} - | Expurgador de Arquivos    |"
            printf "\n"
            _mensagec "${GREEN}" "6${NORM} - | Parametros                |"
            printf "\n"
            _mensagec "${GREEN}" "7${NORM} - | Update                    |"
            printf "\n"
            _mensagec "${GREEN}" "8${NORM} - | Lembretes                 |"
            printf "\n\n"
        fi
        
        _mensagec "${GREEN}" "9${RED} - | Menu Anterior          |"
        printf "\n"
        _linha "=" "${GREEN}"

        local opcao
        read -rp "${YELLOW} Digite a opção desejada -> ${NORM}" opcao

        case "${opcao}" in
            1) _menu_temporarios ;;
            2) 
                if [[ "${BANCO}" != "s" ]]; then
                    _menu_recuperar_arquivos
                else
                    _opinvalida
                    _read_sleep 1
                fi
                ;;
            3) 
                if [[ "${BANCO}" != "s" ]]; then
                    _menu_backup
                else
                    _opinvalida
                    _read_sleep 1
                fi
                ;;
            4) _menu_transferencia_arquivos ;;
            5) _executar_expurgador "ferramentas" ;;
            6) _menu_setups ;;
            7) _executar_update ;;
            8) _menu_lembretes ;;
            9) return ;;
            *)
                _opinvalida
                _read_sleep 1
                ;;
        esac
    done
}

#---------- MENU DE TEMPORÁRIOS ----------#

# Menu de limpeza de arquivos temporários
_menu_temporarios() {
    while true; do
        clear
        printf "\n"
        _linha "=" "${GREEN}"
        _mensagec "${RED}" "Menu de Limpeza"
        _linha
        printf "\n"
        _mensagec "${PURPLE}" " Escolha a opção:"
        printf "\n"
        _mensagec "${GREEN}" "1${NORM} - | Limpeza dos Arquivos Temporarios |"
        printf "\n"
        _mensagec "${GREEN}" "2${NORM} - | Adicionar Arquivos no ATUALIZAT  |"
        printf "\n"
        _mensagec "${GREEN}" "3${NORM} - | Listar Arquivos do ATUALIZAT     |"
        printf "\n\n" 
        _mensagec "${GREEN}" "9${RED} - | Menu Anterior                  |"
        printf "\n"
        _linha "=" "${GREEN}"

        local opcao
        read -rp "${YELLOW} Digite a opção desejada -> ${NORM}" opcao

        case "${opcao}" in
            1) _executar_limpeza_temporarios ;;
            2) _adicionar_arquivo_lixo ;;
            3) _lista_arquivos_lixo ;;
            9) return ;;
            *)
                _opinvalida
                _read_sleep 1
                ;;
        esac
    done
}

#---------- MENU DE RECUPERAÇÃO ----------#

# Menu de recuperação de arquivos
_menu_recuperar_arquivos() {
    while true; do
        clear
        printf "\n"
        _linha "=" "${GREEN}"
        _mensagec "${RED}" "Menu de Recuperação de Arquivo(s)"
        _linha
        printf "\n"
        _mensagec "${PURPLE}" " Escolha a opção:"
        printf "\n"
        _mensagec "${GREEN}" "1${NORM} - | Um arquivo ou Todos   |"
        printf "\n"
        _mensagec "${GREEN}" "2${NORM} - | Arquivos Principais   |"
        printf "\n\n"
        _mensagec "${GREEN}" "9${RED} - | Menu Anterior      |"
        printf "\n"
        _linha "=" "${GREEN}"

        local opcao
        read -rp "${YELLOW} Digite a opção desejada -> ${NORM}" opcao

        case "${opcao}" in
            1) _recuperar_arquivo_especifico ;;
            2) _recuperar_arquivos_principais ;;
            9) return ;;
            *)
                _opinvalida
                _read_sleep 1
                ;;
        esac
    done
}

#---------- MENU DE backup ----------#

# Menu de backup do sistema
_menu_backup() {
    while true; do
        clear
        printf "\n"
        _linha "=" "${GREEN}"
        _mensagec "${RED}" "Menu de Backup(s)"
        _linha
        printf "\n"
        _mensagec "${PURPLE}" " Escolha a opção:"
        printf "\n"
        _mensagec "${GREEN}" "1${NORM} - | Backup da base de dados           |"
        printf "\n"
        _mensagec "${GREEN}" "2${NORM} - | Restaurar Backup da base de dados |"
        printf "\n"
        _mensagec "${GREEN}" "3${NORM} - | Enviar Backup                     |"
        printf "\n\n"
        _mensagec "${GREEN}" "9${RED} - | Menu Anterior                  |"
        printf "\n"
        _linha "=" "${GREEN}"

        local opcao
        read -rp "${YELLOW} Digite a opção desejada -> ${NORM}" opcao

        case "${opcao}" in
            1) _executar_backup ;;
            2) _restaurar_backup ;;
            3) _enviar_backup_avulso ;;
            9) return ;;
            *)
                _opinvalida
                _read_sleep 1
                ;;
        esac
    done
}


#---------- MENU DE TRANSFERÊNCIA ----------#

# Menu de envio e recebimento de arquivos
_menu_transferencia_arquivos() {
    while true; do
        clear
        printf "\n"
        _linha "=" "${GREEN}"
        _mensagec "${RED}" "Menu de Enviar e Receber Arquivo(s)"
        _linha
        printf "\n"
        _mensagec "${PURPLE}" " Escolha a opção:"
        printf "\n"
        _mensagec "${GREEN}" "1${NORM} - | Enviar arquivo(s)     |"
        printf "\n"
        _mensagec "${GREEN}" "2${NORM} - | Receber arquivo(s)    |"
        printf "\n\n"
        _mensagec "${GREEN}" "9${RED} - | Menu Anterior      |"
        printf "\n"
        _linha "=" "${GREEN}"

        local opcao
        read -rp "${YELLOW} Digite a opção desejada -> ${NORM}" opcao

        case "${opcao}" in
            1) _enviar_arquivo_avulso ;;
            2) _receber_arquivo_avulso ;;
            9) return ;;
            *)
                _opinvalida
                _read_sleep 1
                ;;
        esac
    done
}

# Menu de setups do sistema
_menu_setups() {
    while true; do
        clear
        printf "\n"
        _linha "=" "${GREEN}"
        _mensagec "${RED}" "Menu de Setup do Sistema"
        _linha
        printf "\n"
        _mensagec "${PURPLE}" " Escolha a opção:"
        printf "\n"
        _mensagec "${GREEN}" "1${NORM} - | Consulta de setup    |"
        printf "\n"
        _mensagec "${GREEN}" "2${NORM} - | Manutencao de setup  |"
        printf "\n"
        _mensagec "${GREEN}" "3${NORM} - | Validar configuracao |"
        printf "\n\n"
        _mensagec "${GREEN}" "9${RED} - | Menu Anterior     |"
        
        printf "\n"
        _linha "=" "${GREEN}"

        local opcao
        read -rp "${YELLOW} Digite a opção desejada -> ${NORM}" opcao

        case "${opcao}" in
            1) 
                _mostrar_parametros
#                _press
                ;;
            2) 
               _manutencao_setup
                # Após a manutenção, recarregar as configurações
                if [[ -f "${LIB_CFG}/.atualizac" ]]; then
                    # shellcheck source=/dev/null
                    "." "${LIB_CFG}/.atualizac"
                    _mensagec "${GREEN}" "Configurações recarregadas com sucesso!"
                    _read_sleep 2
                fi
                ;;
            3)
                _validar_configuracao
                _press
                ;;
            9) return ;;
            *)
                _opinvalida
                _read_sleep 1
                ;;
        esac
    done
}


#---------- MENU DE LEMBRETES ----------#

# Menu de bloco de notas/lembretes
_menu_lembretes() {
    while true; do
        clear
        printf "\n"
        _linha "=" "${GREEN}"
        _mensagec "${RED}" " Bloco de Notas "
        _linha
        printf "\n"
        _mensagec "${PURPLE}" " Escolha a opção:"
        printf "\n"
        _mensagec "${GREEN}" "1${NORM} - | Escrever nova nota    |"
        printf "\n"
        _mensagec "${GREEN}" "2${NORM} - | Visualizar nota       |"
        printf "\n"
        _mensagec "${GREEN}" "3${NORM} - | Editar nota           |"
        printf "\n"
        _mensagec "${GREEN}" "4${NORM} - | Apagar nota           |"
        printf "\n\n"
        _mensagec "${GREEN}" "9${RED} - | Menu Anterior      |"
        printf "\n"
        _linha "=" "${GREEN}"

        local opcao
        read -rp "${YELLOW} Digite a opção desejada -> ${NORM}" opcao

        case "${opcao}" in
            1) _escrever_nova_nota ;;
            2) _visualizar_notas_arquivo "${LIB_CFG}/atualizal" ;;
            3) _editar_nota_existente ;;
            4) _apagar_nota_existente ;;
            9) return ;;
            *)
                _opinvalida
                _read_sleep 1
                ;;
        esac
    done
}

#---------- MENU DE ESCOLHA DE BASE ----------#

# Menu para escolher base de dados
_menu_escolha_base() {
    while true; do
        clear
        printf "\n"
        _linha "=" "${GREEN}"
        _mensagec "${RED}" "Escolha a Base"
        _linha
        printf "\n"
        _mensagec "${PURPLE}" " Escolha a opção:"
        printf "\n"
        _mensagec "${GREEN}" "1${NORM} - | Base em ${destino}${base}"
        printf "\n"
        _mensagec "${GREEN}" "2${NORM} - | Base em ${destino}${base2}"
        printf "\n"
        
        if [[ -n "${base3}" ]]; then
            _mensagec "${GREEN}" "3${NORM} - | Base em ${destino}${base3}"
            printf "\n"
        fi
        
        printf "\n"
        _mensagec "${GREEN}" "9${NORM} - | ${RED}Menu Anterior    |"
        printf "\n"
        _linha "=" "${GREEN}"

        local opcao
        read -rp "${YELLOW} Digite a opção desejada -> ${NORM}" opcao

        case "${opcao}" in
            1) 
                _definir_base_trabalho "base"
                return 0
                ;;
            2) 
                _definir_base_trabalho "base2"
                return 0
                ;;
            3) 
                if [[ -n "${base3}" ]]; then
                    _definir_base_trabalho "base3"
                    return 0
                else
                    _opinvalida
                    _read_sleep 1
                fi
                ;;
            9) return 1 ;;
            *)
                _opinvalida
                _read_sleep 1
                ;;
        esac
    done
}

#---------- MENU DE TIPO DE backup ----------#

# Menu para escolher tipo de backup
_menu_tipo_backup() {
#export tipo_backup
    while true; do
        clear
        printf "\n"
        _linha "=" "${GREEN}"
        _mensagec "${RED}" "Menu de Tipo de Backup(s)"
        _linha
        printf "\n"
        _mensagec "${PURPLE}" " Escolha a opção:"
        printf "\n"
        _mensagec "${GREEN}" "1${NORM} - Backup Completo      "
        printf "\n"
        _mensagec "${GREEN}" "2${NORM} - Backup Incremental   "
        printf "\n\n"
        _mensagec "${GREEN}" "9${NORM} - ${RED}Menu Anterior"
        printf "\n"
        _linha "=" "${GREEN}"

        local opcao
        read -rp "${YELLOW} Digite a opção desejada -> ${NORM}" opcao

        case "${opcao}" in
            1) 
                tipo_backup="completo"
                export tipo_backup
                return 0
                ;;
            2) 
                tipo_backup="incremental"
                export tipo_backup
                return 0
                ;;
            9) return 1 ;;
            *)
                _opinvalida
                _read_sleep 1
                ;;
        esac
    done
}

#---------- FUNÇÕES AUXILIARES DE MENU ----------#

# Define a base de trabalho atual
# Parâmetros: $1=nome_da_base (base, base2, base3)
_definir_base_trabalho() {
    local base_var="$1"
    local base_dir="${!base_var}"
    
    if [[ -z "${destino}" ]] || [[ -z "${base_dir}" ]]; then
        _mensagec "${RED}" "Erro: Variáveis de configuração não definidas"
        _linha
        _read_sleep 2
        return 1
    fi
    
    export base_trabalho="${destino}${base_dir}"
    
    if [[ ! -d "${base_trabalho}" ]]; then
        _mensagec "${RED}" "Erro: Diretório ${base_trabalho} não encontrado"
        _linha
        _read_sleep 2
        return 1
    fi
    
    _mensagec "${GREEN}" "Base de trabalho definida: ${base_trabalho}"
    return 0
}

# Limpa tela e volta ao menu especificado
# Parâmetros: $1=nome_da_funcao_menu
_voltar_menu() {
    local menu_funcao="${1:-_principal}"
    clear
    "$menu_funcao"
}
