#!/usr/bin/env bash
#
# menus.sh - Sistema de Menus com Suporte a Ajuda
# Responsavel pela apresentacao e navegacao dos menus do sistema
#
# SISTEMA SAV - Script de Atualizacao Modular
# Versao: 09/01/2026-00

raiz="${raiz:-}"
sistema="${sistema:-}"
cfg_dir="${cfg_dir:-}"
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
        
        # Cabecalho
        _linha "=" "${GREEN}"
        _mensagec "${RED}" "Menu Principal"
        _linha
        _mensagec "${GREEN}" ".. Empresa: ${EMPRESA} .."
        _linha
        _mensagec "${CYAN}" "_| Sistema: ${sistema} - Versao do Iscobol: ${verclass} |_"
        _linha
        printf "\n"
        _mensagec "${PURPLE}" " Escolha a opcao:"
        _meia_linha "-" "${YELLOW}" "-" "${YELLOW}"
        printf "\n"
        # Opcoes do menu
        _mensagec "${GREEN}" "1${NORM} -|: Atualizar Programa(s) "
        printf "\n"
        _mensagec "${GREEN}" "2${NORM} -|: Atualizar Biblioteca  "
        printf "\n"
        
        if [[ "${sistema}" = "iscobol" ]]; then
            _mensagec "${GREEN}" "3${NORM} -|: Versao do Iscobol     "
        else
            _mensagec "${GREEN}" "3${NORM} -|: Funcao nao disponivel "
        fi
        printf "\n"
        _mensagec "${GREEN}" "4${NORM} -|: Versao do Linux       "
        printf "\n"
        _mensagec "${GREEN}" "5${NORM} -|: Ferramentas           "
        printf "\n"
        _meia_linha "-" "${YELLOW}" "-" "${YELLOW}"
        printf "\n"
        _mensagec "${GREEN}" "9 ${RED}-|: Sair do Sistema "
        printf "\n"
        _mensaged "${BLUE}" "${UPDATE}"
        _linha "=" "${GREEN}"
        
        # Linha de ajuda
        _linha "-" "${BLUE}"
        printf "${BLUE}Ajuda: Digite ${YELLOW}?${BLUE} (contextual) | ${YELLOW}M${BLUE} (manual) | ${YELLOW}H${BLUE} (help)${NORM}\n"
        _linha "-" "${BLUE}"

        local opcao
        read -rp "${YELLOW} Digite a opcao desejada -> ${NORM}" opcao
        
        # Verificar comandos de ajuda
        case "${opcao,,}" in
            "?")
                _exibir_ajuda_contextual "principal"
                continue
                ;;
            "m"|"manual")
                _exibir_manual_completo
                continue
                ;;
            "h"|"help"|"ajuda")
                _exibir_ajuda_contextual "principal"
                continue
                ;;
        esac

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

# Menu de atualizacao de programas
_menu_programas() {
    while true; do
        clear
        printf "\n"
        _linha "=" "${GREEN}"
        _mensagec "${RED}" "Menu de Programas"
        _linha
        printf "\n"
        _mensagec "${PURPLE}" "Escolha o tipo de Atualizacao:"
        _meia_linha "-" "${YELLOW}" 
        printf "\n"
        _mensagec "${GREEN}" "1${NORM} -|: Programa(s) ON-Line       "
        printf "\n"
        _mensagec "${GREEN}" "2${NORM} -|: Programa(s) OFF-Line      "
        printf "\n"
        _mensagec "${GREEN}" "3${NORM} -|: Programa(s) em Pacote     "
        printf "\n\n"
        _mensagec "${PURPLE}" "Escolha Desatualizar:         "
        _meia_linha "-" "${YELLOW}"
        printf "\n"
        _mensagec "${GREEN}" "4${NORM} -|: Voltar programa Atualizado"
        printf "\n"
        _meia_linha "-" "${YELLOW}"
        printf "\n" 
        _mensagec "${GREEN}" "9 ${RED}-|: Menu Anterior "
        printf "\n"
        
        if [[ -n "${verclass}" ]]; then
            printf "\n"
            _mensaged "${BLUE}" "Versao do Iscobol - ${verclass}"
        fi
        _linha "=" "${GREEN}"
        
        # Linha de ajuda
        _linha "-" "${BLUE}"
        printf "${BLUE}Ajuda: Digite ${YELLOW}?${BLUE} (contextual) | ${YELLOW}M${BLUE} (manual) | ${YELLOW}H${BLUE} (help)${NORM}\n"
        _linha "-" "${BLUE}"

        local opcao
        read -rp "${YELLOW} Digite a opcao desejada -> ${NORM}" opcao
        
        # Verificar comandos de ajuda
        case "${opcao,,}" in
            "?")
                _exibir_ajuda_contextual "programas"
                continue
                ;;
            "m"|"manual")
                _exibir_manual_completo
                continue
                ;;
            "h"|"help"|"ajuda")
                _exibir_ajuda_contextual "programas"
                continue
                ;;
        esac

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

# Menu de atualizacao de biblioteca
_menu_biblioteca() {
    while true; do
        clear
        printf "\n"
        _linha "=" "${GREEN}"
        _mensagec "${RED}" "Menu da Biblioteca"
        _linha "="
        printf "\n"
        _mensagec "${PURPLE}" "Escolha o local da Biblioteca:      "
        _meia_linha "-" "${YELLOW}"
        printf "\n" 
        _mensagec "${GREEN}" "1${NORM} -|: Atualizacao do Transpc      "
        printf "\n" 
        _mensagec "${GREEN}" "2${NORM} -|: Atualizacao do Savatu       "
        printf "\n"
        _mensagec "${GREEN}" "3${NORM} -|: Atualizacao OFF-Line        "
        printf "\n\n"
        _mensagec "${PURPLE}" "Escolha Desatualizar:               "
        _meia_linha "-" "${YELLOW}"
        printf "\n"
        _mensagec "${GREEN}" "4${NORM} -|: Voltar Programa(s) da Biblioteca"
        printf "\n"
        _meia_linha "-" "${YELLOW}"
        printf "\n"
        _mensagec "${GREEN}" "9${RED} -|: Menu Anterior "
        printf "\n"
        
        if [[ -n "${VERSAOANT}" ]]; then
            printf "\n"
            _mensaged "${BLUE}" "Versao Anterior - ${VERSAOANT}"
        fi
        _linha "=" "${GREEN}"
        
        # Linha de ajuda
        _linha "-" "${BLUE}"
        printf "${BLUE}Ajuda: Digite ${YELLOW}?${BLUE} (contextual) | ${YELLOW}M${BLUE} (manual) | ${YELLOW}H${BLUE} (help)${NORM}\n"
        _linha "-" "${BLUE}"

        local opcao
        read -rp "${YELLOW} Digite a opcao desejada -> ${NORM}" opcao
        
        # Verificar comandos de ajuda
        case "${opcao,,}" in
            "?")
                _exibir_ajuda_contextual "biblioteca"
                continue
                ;;
            "m"|"manual")
                _exibir_manual_completo
                continue
                ;;
            "h"|"help"|"ajuda")
                _exibir_ajuda_contextual "biblioteca"
                continue
                ;;
        esac

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
        _mensagec "${PURPLE}" " Escolha a opcao:"
        _meia_linha "-" "${YELLOW}"
        printf "\n"
        
        # Verificar se sistema tem banco de dados
        if [[ "${BANCO}" = "s" ]]; then
            _mensagec "${GREEN}" "1${NORM} -|: Temporarios               "
            printf "\n"
            _mensagec "${GREEN}" "4${NORM} -|: Enviar e Receber Arquivos "
            printf "\n"
            _mensagec "${GREEN}" "5${NORM} -|: Expurgador de Arquivos    "
            printf "\n"
            _mensagec "${GREEN}" "6${NORM} -|: Parametros                "
            printf "\n"
            _mensagec "${GREEN}" "7${NORM} -|: Update                    "
            printf "\n" 
            _mensagec "${GREEN}" "8${NORM} -|: Lembretes                 "
            printf "\n"
        else
            _mensagec "${GREEN}" "1${NORM} -|: Temporarios               "
            printf "\n"
            _mensagec "${GREEN}" "2${NORM} -|: Recuperar Arquivos        "
            printf "\n" 
            _mensagec "${GREEN}" "3${NORM} -|: Rotinas de Backup         "
            printf "\n"
            _mensagec "${GREEN}" "4${NORM} -|: Enviar e Receber Arquivos "
            printf "\n"
            _mensagec "${GREEN}" "5${NORM} -|: Expurgador de Arquivos    "
            printf "\n"
            _mensagec "${GREEN}" "6${NORM} -|: Parametros                "
            printf "\n"
            _mensagec "${GREEN}" "7${NORM} -|: Update                    "
            printf "\n"
            _mensagec "${GREEN}" "8${NORM} -|: Lembretes                 "
            printf "\n"
        fi
        _mensagec "${GREEN}" "0${NORM} -|: Sistema de Ajuda          "
        printf "\n"
        _meia_linha "-" "${YELLOW}"
        printf "\n"
        _mensagec "${GREEN}" "9${RED} -|: Menu Anterior "
        printf "\n"
        _linha "=" "${GREEN}"
        
        # Linha de ajuda
        _linha "-" "${BLUE}"
        printf "${BLUE}Ajuda: Digite ${YELLOW}?${BLUE} (contextual) | ${YELLOW}M${BLUE} (manual) | ${YELLOW}H${BLUE} (help)${NORM}\n"
        _linha "-" "${BLUE}"

        local opcao
        read -rp "${YELLOW} Digite a opcao desejada -> ${NORM}" opcao
        
        # Verificar comandos de ajuda
        case "${opcao,,}" in
            "?")
                _exibir_ajuda_contextual "ferramentas"
                continue
                ;;
            "m"|"manual")
                _exibir_manual_completo
                continue
                ;;
            "h"|"help"|"ajuda")
                _exibir_ajuda_contextual "ferramentas"
                continue
                ;;
        esac

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
            0) _menu_ajuda_principal ;;
            9) return ;;
            *)
                _opinvalida
                _read_sleep 1
                ;;
        esac
    done
}

#---------- MENU DE TEMPORaRIOS ----------#

# Menu de limpeza de arquivos temporarios
_menu_temporarios() {
    while true; do
        clear
        printf "\n"
        _linha "=" "${GREEN}"
        _mensagec "${RED}" "Menu de Limpeza"
        _linha
        printf "\n"
        _mensagec "${PURPLE}" " Escolha a opcao:"
        _meia_linha "-" "${YELLOW}"
        printf "\n"
        _mensagec "${GREEN}" "1${NORM} -|: Limpeza dos Arquivos Temporarios "
        printf "\n"
        _mensagec "${GREEN}" "2${NORM} -|: Adicionar Arquivos no ATUALIZAT  "
        printf "\n"
        _mensagec "${GREEN}" "3${NORM} -|: Listar Arquivos do ATUALIZAT     "
        printf "\n"
        _meia_linha "-" "${YELLOW}"
        printf "\n"
        _mensagec "${GREEN}" "9${RED} -|: Menu Anterior "
        printf "\n"
        _linha "=" "${GREEN}"
        
        # Linha de ajuda
        _linha "-" "${BLUE}"
        printf "${BLUE}Ajuda: Digite ${YELLOW}?${BLUE} (contextual) | ${YELLOW}M${BLUE} (manual) | ${YELLOW}H${BLUE} (help)${NORM}\n"
        _linha "-" "${BLUE}"

        local opcao
        read -rp "${YELLOW} Digite a opcao desejada -> ${NORM}" opcao
        
        # Verificar comandos de ajuda
        case "${opcao,,}" in
            "?")
                _exibir_ajuda_contextual "temporarios"
                continue
                ;;
            "m"|"manual")
                _exibir_manual_completo
                continue
                ;;
            "h"|"help"|"ajuda")
                _exibir_ajuda_contextual "temporarios"
                continue
                ;;
        esac

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

#---------- MENU DE RECUPERACAO ----------#

# Menu de recuperacao de arquivos
_menu_recuperar_arquivos() {
    while true; do
        clear
        printf "\n"
        _linha "=" "${GREEN}"
        _mensagec "${RED}" "Menu de Recuperacao de Arquivo(s)"
        _linha
        printf "\n"
        _mensagec "${PURPLE}" " Escolha a opcao:"
        _meia_linha "-" "${YELLOW}"
        printf "\n"
        _mensagec "${GREEN}" "1${NORM} -|: Um arquivo ou Todos   "
        printf "\n"
        _mensagec "${GREEN}" "2${NORM} -|: Arquivos Principais   "
        printf "\n"
        _meia_linha "-" "${YELLOW}"
        printf "\n"
        _mensagec "${GREEN}" "9${RED} -|: Menu Anterior "
        printf "\n"
        _linha "=" "${GREEN}"
        
        # Linha de ajuda
        _linha "-" "${BLUE}"
        printf "${BLUE}Ajuda: Digite ${YELLOW}?${BLUE} (contextual) | ${YELLOW}M${BLUE} (manual) | ${YELLOW}H${BLUE} (help)${NORM}\n"
        _linha "-" "${BLUE}"

        local opcao
        read -rp "${YELLOW} Digite a opcao desejada -> ${NORM}" opcao
        
        # Verificar comandos de ajuda
        case "${opcao,,}" in
            "?")
                _exibir_ajuda_contextual "recuperacao"
                continue
                ;;
            "m"|"manual")
                _exibir_manual_completo
                continue
                ;;
            "h"|"help"|"ajuda")
                _exibir_ajuda_contextual "recuperacao"
                continue
                ;;
        esac

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
        _mensagec "${PURPLE}" " Escolha a opcao:"
        _meia_linha "-" "${YELLOW}"
        printf "\n"
        _mensagec "${GREEN}" "1${NORM} -|: Backup da base de dados  "
        printf "\n"
        _mensagec "${GREEN}" "2${NORM} -|: Restaurar base de dados  "
        printf "\n"
        _mensagec "${GREEN}" "3${NORM} -|: Enviar Backup            "
        printf "\n"
        _meia_linha "-" "${YELLOW}"
        printf "\n"
        _mensagec "${GREEN}" "9${RED} -|: Menu Anterior "
        printf "\n"
        _linha "=" "${GREEN}"
        
        # Linha de ajuda
        _linha "-" "${BLUE}"
        printf "${BLUE}Ajuda: Digite ${YELLOW}?${BLUE} (contextual) | ${YELLOW}M${BLUE} (manual) | ${YELLOW}H${BLUE} (help)${NORM}\n"
        _linha "-" "${BLUE}"

        local opcao
        read -rp "${YELLOW} Digite a opcao desejada -> ${NORM}" opcao
        
        # Verificar comandos de ajuda
        case "${opcao,,}" in
            "?")
                _exibir_ajuda_contextual "backup"
                continue
                ;;
            "m"|"manual")
                _exibir_manual_completo
                continue
                ;;
            "h"|"help"|"ajuda")
                _exibir_ajuda_contextual "backup"
                continue
                ;;
        esac

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


#---------- MENU DE TRANSFERÃŠNCIA ----------#

# Menu de envio e recebimento de arquivos
_menu_transferencia_arquivos() {
    while true; do
        clear
        printf "\n"
        _linha "=" "${GREEN}"
        _mensagec "${RED}" "Menu de Enviar e Receber Arquivo(s)"
        _linha
        printf "\n"
        _mensagec "${PURPLE}" " Escolha a opcao:"
        _meia_linha "-" "${YELLOW}"
        printf "\n"
        _mensagec "${GREEN}" "1${NORM} -|: Enviar arquivo(s)     "
        printf "\n"
        _mensagec "${GREEN}" "2${NORM} -|: Receber arquivo(s)    "
        printf "\n"
        _meia_linha "-" "${YELLOW}"
        printf "\n"
        _mensagec "${GREEN}" "9${RED} -|: Menu Anterior "
        printf "\n"
        _linha "=" "${GREEN}"
        
        # Linha de ajuda
        _linha "-" "${BLUE}"
        printf "${BLUE}Ajuda: Digite ${YELLOW}?${BLUE} (contextual) | ${YELLOW}M${BLUE} (manual) | ${YELLOW}H${BLUE} (help)${NORM}\n"
        _linha "-" "${BLUE}"

        local opcao
        read -rp "${YELLOW} Digite a opcao desejada -> ${NORM}" opcao
        
        # Verificar comandos de ajuda
        case "${opcao,,}" in
            "?")
                _exibir_ajuda_contextual "transferencia"
                continue
                ;;
            "m"|"manual")
                _exibir_manual_completo
                continue
                ;;
            "h"|"help"|"ajuda")
                _exibir_ajuda_contextual "transferencia"
                continue
                ;;
        esac

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
        _mensagec "${PURPLE}" " Escolha a opcao:"
        _meia_linha "-" "${YELLOW}"
        printf "\n"
        _mensagec "${GREEN}" "1${NORM} -|: Consulta de setup    "
        printf "\n"
        _mensagec "${GREEN}" "2${NORM} -|: Manutencao de setup  "
        printf "\n"
        _mensagec "${GREEN}" "3${NORM} -|: Validar configuracao "
        printf "\n"
        _meia_linha "-" "${YELLOW}"
        printf "\n"
        _mensagec "${GREEN}" "9${RED} -|: Menu Anterior "
        printf "\n"
        _linha "=" "${GREEN}"
        
        # Linha de ajuda
        _linha "-" "${BLUE}"
        printf "${BLUE}Ajuda: Digite ${YELLOW}?${BLUE} (contextual) | ${YELLOW}M${BLUE} (manual) | ${YELLOW}H${BLUE} (help)${NORM}\n"
        _linha "-" "${BLUE}"

        local opcao
        read -rp "${YELLOW} Digite a opcao desejada -> ${NORM}" opcao
        
        # Verificar comandos de ajuda
        case "${opcao,,}" in
            "?")
                _exibir_ajuda_contextual "setups"
                continue
                ;;
            "m"|"manual")
                _exibir_manual_completo
                continue
                ;;
            "h"|"help"|"ajuda")
                _exibir_ajuda_contextual "setups"
                continue
                ;;
        esac

        case "${opcao}" in
            1) 
                _mostrar_parametros
                ;;
            2) 
               _manutencao_setup
                # Apos a manutencao, recarregar as configuracoes
                if [[ -f "${cfg_dir}/.atualizac" ]]; then
                    # shellcheck source=/dev/null
                    "." "${cfg_dir}/.atualizac"
                    _mensagec "${GREEN}" "Configuracoes recarregadas com sucesso!"
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
        _mensagec "${PURPLE}" " Escolha a opcao:"
        _meia_linha "-" "${YELLOW}"
        printf "\n"
        _mensagec "${GREEN}" "1${NORM} -|: Escrever nova nota    "
        printf "\n"
        _mensagec "${GREEN}" "2${NORM} -|: Visualizar nota       "
        printf "\n"
        _mensagec "${GREEN}" "3${NORM} -|: Editar nota           "
        printf "\n"
        _mensagec "${GREEN}" "4${NORM} -|: Apagar nota           "
        printf "\n"
        _meia_linha "-" "${YELLOW}"
        printf "\n"
        _mensagec "${GREEN}" "9${RED} -|: Menu Anterior "
        printf "\n"
        _linha "=" "${GREEN}"
        
        # Linha de ajuda
        _linha "-" "${BLUE}"
        printf "${BLUE}Ajuda: Digite ${YELLOW}?${BLUE} (contextual) | ${YELLOW}M${BLUE} (manual) | ${YELLOW}H${BLUE} (help)${NORM}\n"
        _linha "-" "${BLUE}"

        local opcao
        read -rp "${YELLOW} Digite a opcao desejada -> ${NORM}" opcao
        
        # Verificar comandos de ajuda
        case "${opcao,,}" in
            "?")
                _exibir_ajuda_contextual "lembretes"
                continue
                ;;
            "m"|"manual")
                _exibir_manual_completo
                continue
                ;;
            "h"|"help"|"ajuda")
                _exibir_ajuda_contextual "lembretes"
                continue
                ;;
        esac

        case "${opcao}" in
            1) _escrever_nova_nota ;;
            2) _visualizar_notas_arquivo "${cfg_dir}/atualizal" ;;
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
        _mensagec "${PURPLE}" " Escolha a opcao:"
        printf "\n"
        _mensagec "${GREEN}" "1${NORM} -|: Base em ${raiz}${base}"
        printf "\n"
        _mensagec "${GREEN}" "2${NORM} -|: Base em ${raiz}${base2}"
        printf "\n"
        
        if [[ -n "${base3}" ]]; then
            _mensagec "${GREEN}" "3${NORM} -|: Base em ${raiz}${base3}"
            printf "\n"
        fi
        
        printf "\n"
        _meia_linha "-" "${YELLOW}"
        printf "\n"
        _mensagec "${GREEN}" "9${RED} -|: Menu Anterior "
        printf "\n"
        _linha "=" "${GREEN}"

        local opcao
        read -rp "${YELLOW} Digite a opcao desejada -> ${NORM}" opcao

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

