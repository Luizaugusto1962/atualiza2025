#!/usr/bin/env bash
# Programa para gerar os arquivos .atualizac .atualizap 
#
clear
complemento="${complento:-}"
mcomplemento="${mcomplemento:-}"
#
cd ../cfg || exit 0

tracejada="#-------------------------------------------------------------------#"
traco="#####################################################################"
###
echo ${traco}
echo ${traco} >.atualizac
echo "###      ( Parametros para serem usados no atualiza.sh )          ###" >>.atualizac
echo "###      ( Parametros para serem usados no atualiza.sh )          ###"
echo ${traco} >>.atualizac
echo ${traco} >.atualizap
echo "###      ( Parametros para serem usados no atualiza.sh )          ###" >>.atualizap
echo ${traco} >>.atualizap
_ISCOBOL() {
    sistema="iscobol"
    echo ${traco}
    echo "###           (CONFIGURACAO PARA O SISTEMA EM ISCOBOL)           ###"
    echo ${traco}
    echo "sistema=iscobol"
    echo "sistema=iscobol" >>.atualizac
    echo ${tracejada}
    echo "Escolha a versao do Iscobol"
    echo
    echo "1- Versao 2018"
    echo
    echo "2- Versao 2020"
    echo
    echo "3- Versao 2023"
    echo
    echo "4- Versao 2024"
    echo
    read -rp "Escolha a versao -> " -n1 VERSAO
    echo
    case ${VERSAO} in
    1) _2018 ;;
    2) _2020 ;;
    3) _2023 ;;
    4) _2024 ;;
    *)
        echo
        echo Alternativas incorretas, saindo!
        sleep 1
        exit
        ;;
    esac
    {
        echo "exec=sav/classes"
        echo "telas=sav/tel_isc"
        echo "xml=sav/xml"
        classA="IS${VERCLASS}""_*_" # Usanda esta variavel para baixar todos os zips da atualizacao.
        classB="IS${VERCLASS}""_classA_"
        classC="IS${VERCLASS}""_classB_"
        classD="IS${VERCLASS}""_tel_isc_"
        classE="IS${VERCLASS}""_xml_"
        echo "SAVATU=tempSAV_""${classA}"
        echo "SAVATU1=tempSAV_""${classB}"
        echo "SAVATU2=tempSAV_""${classC}"
        echo "SAVATU3=tempSAV_""${classD}"
        echo "SAVATU4=tempSAV_""${classE}"
    } >>.atualizap
}

# _2018
#
# Define as variaveis para o Iscobol da versao 2018.
#
# As variaveis class e mclass recebem seus valores para a versao 2018.
#
# A variavel VERCLASS recebe o valor 2018.
#
# As variaveis sao escritas no arquivo .atualizac.
_2018() {
    {
        complemento="-class"
        mcomplemento="-mclass"
        VERCLASS="2018"
        echo "verclass=${VERCLASS}"
        echo "class=-class"
        echo "mclass=-mclass"
    } >>.atualizac
}

# _2020
#
# Define as variaveis para o Iscobol da versao 2020.
#
# As variaveis class e mclass recebem seus valores para a versao 2020.
#
# A variavel VERCLASS recebe o valor 2020.
#
# As variaveis sao escritas no arquivo .atualizac.
_2020() {
    {
        complemento="-class20"
        mcomplemento="-mclass20"
        VERCLASS="2020"
        echo "verclass=${VERCLASS}"
        echo "class=-class20"
        echo "mclass=-mclass20"
    } >>.atualizac
}

# _2023
#
# Define as variaveis para o Iscobol da versao 2023.
#
# As variaveis class e mclass recebem seus valores para a versao 2023.
#
# A variavel VERCLASS recebe o valor 2023.
#
# As variaveis sao escritas no arquivo .atualizac.
_2023() {
    {
        complemento="-class23"
        mcomplemento="-mclass23"
        VERCLASS="2023"
        echo "verclass=${VERCLASS}"
        echo "class=-class23"
        echo "mclass=-mclass23"
    } >>.atualizac
}

# _2024
#
# Define as variaveis para o Iscobol da versao 2024.
#
# As variaveis class e mclass recebem seus valores para a versao 2024.
#
# A variavel VERCLASS recebe o valor 2024.
#
# As variaveis sao escritas no arquivo .atualizac.
_2024() {
    {
        complemento="-class24"
        mcomplemento="-mclass24"
        VERCLASS="2024"
        echo "verclass=${VERCLASS}"
        echo "class=-class24"
        echo "mclass=-mclass24"
    } >>.atualizac
}

# _COBOL
#
# Define as variaveis para o Micro Focus da versao COBOL.
#
# As variaveis class e mclass recebem seus valores para a versao COBOL.
#
# A variavel sistema recebe o valor COBOL.
#
# As variaveis sao escritas no arquivo .atualizac.
_COBOL() {
    sistema="cobol"
    {
        complemento="-6"
        mcomplemento="-m6"
        echo "sistema=cobol"
        echo "class=-6"
        echo "mclass=-m6"
    } >>.atualizac
    {
        echo "exec=sav/int"
        echo "telas=sav/tel"
        echo "SAVATU1=tempSAVintA_"
        echo "SAVATU2=tempSAVintB_"
        echo "SAVATU3=tempSAVtel_"
        echo "${tracejada}"
    } >>.atualizap
}

echo "  Em qual sistema que o SAV esta rodando "
echo "1) Iscobol"
echo
echo "2) Microfocus"
echo
read -n1 -rp "Escolha o sistema " escolha
case ${escolha} in
1)
    echo ") Iscobol"
    _ISCOBOL
    ;;
2)
    echo ") Microfocus"
    _COBOL
    ;;
*)
    echo
    echo Alternativas incorretas, saindo!
    sleep 1
    exit
    ;;
esac
clear
echo ${traco}
echo "###           ( Banco de Dados )                               ###"
read -rp " ( Sistema em banco de dados [S/N]  ->" -n1 BANCO
echo
echo ${tracejada}
if [[ "${BANCO}" =~ ^[Nn]$ ]] || [[ "${BANCO}" == "" ]]; then
    echo "BANCO=n" >>.atualizac
else
    [[ "${BANCO}" =~ ^[Ss]$ ]]
    echo "BANCO=s" >>.atualizac
fi
echo "###              ( PASTA DO SISTEMA )         ###"
read -rp " Informe o diretorio raiz sem o /->" -n1 destino
echo
echo destino="${destino}" >>.atualizac
echo ${tracejada}
echo "###           ( FACILITADOR DE ACESSO REMOTO )         ###"
read -rp " Informe se ativa o acesso facil ->" -n1 acessossh
echo
echo ${tracejada}
if [[ "${acessossh}" =~ ^[Nn]$ ]] || [[ "${acessossh}" == "" ]]; then
    echo "acessossh=n" >>.atualizac
else
    [[ "${acessossh}" =~ ^[Ss]$ ]]
    echo "acessossh=s" >>.atualizac
fi
echo

echo "###           ( IP do servidor da SAV )         ###"
read -rp " Informe o ip do servidor->" IPSERVER
echo
if [[ "${IPSERVER}" == "" ]]; then
    echo "Necessario informar O IP"
    exit
else
    echo "IPSERVER=${IPSERVER}" >>.atualizac
    echo "IP do servidor:${IPSERVER}"
    echo ${tracejada}
fi
echo

echo "###          Tipo de acesso                  ###"
read -rp "Servidor OFF [S ou N] ->" -n1 SERACESOFF
echo
if [[ "${SERACESOFF}" =~ ^[Nn]$ ]] || [[ "${SERACESOFF}" == "" ]]; then
    echo "SERACESOFF=n" >>.atualizac
elif [[ "${SERACESOFF}" =~ ^[Ss]$ ]]; then
    echo "SERACESOFF=/sav/portalsav/Atualiza" >>.atualizac
fi
echo ${tracejada}
echo "###          ( Nome de pasta no servidor da SAV )                ###"
echo "Nome de pasta no servidor da SAV, informar somento e pasta do cliente"
read -rp "/cliente/" ENVIABACK
echo
if [[ "${ENVIABACK}" == "" ]]; then
    if [[ "${SERACESOFF}" =~ ^[Nn]$ ]] || [[ "${SERACESOFF}" == "" ]]; then
        echo "ENVIABACK="""
        echo "ENVIABACK=""" >>.atualizac
    else
        echo "ENVIABACK=/sav/portalsav/Atualiza"
        echo "ENVIABACK=/sav/portalsav/Atualiza" >>.atualizac
    fi
else
    echo "ENVIABACK=cliente/""${ENVIABACK}"
    echo "ENVIABACK=cliente/""${ENVIABACK}" >>.atualizac
fi
echo ${tracejada}
echo "###           ( NOME DA EMPRESA )            ###"
echo "###   Nao pode ter espacos entre os nomes    ###"
echo ${tracejada}
read -rp "Nome da Empresa-> " EMPRESA
echo
echo EMPRESA="${EMPRESA}"
echo EMPRESA="${EMPRESA}" >>.atualizac
echo ${tracejada}
echo "###    ( DIRETORIO DA BASE DE DADOS )        ###"
echo ${tracejada}
read -rp "Nome de pasta da base, Ex: sav/dados_? -:> " base
if [[ "${base}" == "" ]]; then
    echo "Necessario pasta informar a base de dados"
    exit
else
    echo "base=/""${base}" >>.atualizac
    echo "base=/""${base}"
fi

echo ${tracejada}
read -rp "Nome de pasta da base2, Ex: sav/dados_? -:> " base2
if [[ "${base2}" == "" ]]; then
    echo "#base2=" >>.atualizac
    echo "#base2="
else
    echo "base2=/""${base2}" >>.atualizac
    echo "base2=/""${base2}"
fi
echo ${tracejada}

read -rp "Nome de pasta da base3, Ex: sav/dados_? -:> " base3
if [[ "${base3}" == "" ]]; then
    echo "#base3=" >>.atualizac
    echo "#base3="
else
    echo "base3=/""${base3}" >>.atualizac
    echo "base3=/""${base3}"
fi
echo ${tracejada}
echo ${tracejada} >>.atualizac
clear

{
    echo "pasta=/sav/tools"
    echo "progs=/progs"
    echo "olds=/olds"
    echo "logs=/logs"
    echo "cfg=/cfg"
    echo "backup=/backup"
    echo ${tracejada}
} >>.atualizap

if [[ "${SERACESOFF}" =~ ^[Ss]$ ]]; then
    if [[ "${sistema}" = "cobol" ]]; then
        {
            echo "@echo off"
            echo "cls"
            echo "setlocal EnableDelayedExpansion"
            echo
            echo ":: Configuracoes"
            echo "set class=""${complemento}"
            echo "set mclass=""${mcomplemento}"
            echo "set SAVATU1=tempSAVintA_"
            echo "set SAVATU2=tempSAVintB_"
            echo "set SAVATU3=tempSAVtel_"
        } >atualiza.bat
    else
        {
            echo "@echo off"
            echo "cls"
            echo "setlocal EnableDelayedExpansion"
            echo
            echo ":: Configuracoes"
            echo "set class=""${complemento}"
            echo "set mclass=""${mcomplemento}"
            echo "set SAVATU1=tempSAV_${classB}"
            echo "set SAVATU2=tempSAV_${classC}"
            echo "set SAVATU3=tempSAV_${classD}"
            echo "set SAVATU4=tempSAV_${classE}"
        } >atualiza.bat
    fi
    # Check if the batch file was created successfully
    if [[ -f "atualiza.bat" ]]; then
        _ATUALIZA_BAT
    else
        echo "Falhou ao criar o arquivo atualiza.bat." >&2
        exit 1
    fi
fi

## Criando atualiza em /usr/local/bin
echo "cd ${destino}${pasta:-/sav/tools}" >/usr/local/bin/atualiza
echo ./atualiza.sh >/usr/local/bin/atualiza
chmod +x /usr/local/bin/atualiza
echo "Pronto !!!"
