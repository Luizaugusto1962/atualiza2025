#!/usr/bin/env bash
#
# help.sh - Sistema de Ajuda e Manual do Usuario
# Fornece documentacao completa e help contextual para o sistema
#
# SISTEMA SAV - Script de Atualizacao Modular
# Versao: 08/01/2026-00

cfg_dir="${cfg_dir:-}"
TOOLS_DIR="${TOOLS_DIR:-}"

#---------- CONFIGURACOES DO SISTEMA DE AJUDA ----------#

# Arquivo de manual principal
MANUAL_FILE="${cfg_dir}/manual.txt"

# Cores para o sistema de ajuda
#readonly CYAN="${CYAN}"      # Títulos principais
#readonly GREEN="${GREEN}"   # Seções e subtítulos
#readonly NORM="${NORM}"       # Texto normal do corpo
#readonly YELLOW="${YELLOW}"  # Comandos e exemplos
#readonly RED="${RED}"     # Avisos e alertas importantes

#---------- FUNCOES DE NAVEGACAO DO MANUAL ----------#

# Exibe o manual completo
_exibir_manual_completo() {
    if [[ ! -f "$MANUAL_FILE" ]]; then
        _criar_manual_padrao
    fi
    
    clear
    
    local linhas_por_pagina=25
    local total_linhas
    total_linhas=$(wc -l < "$MANUAL_FILE")
    local linha_atual=1
    
    while [[ $linha_atual -le $total_linhas ]]; do
        clear
        sed -n "${linha_atual},$((linha_atual + linhas_por_pagina - 1))p" "$MANUAL_FILE"
        
        linha_atual=$((linha_atual + linhas_por_pagina))
        
        if [[ $linha_atual -le $total_linhas ]]; then
            echo ""
            echo "--- Pressione ENTER para continuar ou 'q' para sair ---"
            read -r resposta
            [[ "$resposta" == "q" ]] && break
        fi
    done
    
    _press
}

# Exibe ajuda contextual baseada no menu atual
# Parametros: $1=contexto (principal, programas, biblioteca, etc)
_exibir_ajuda_contextual() {
    local contexto="${1:-principal}"
    
    clear
    _linha "=" "${CYAN}"
    _mensagec "${CYAN}" "AJUDA - ${contexto^^}"
    _linha "=" "${CYAN}"
    printf "\n"
    
    case "$contexto" in
        principal)
            _help_menu_principal
            ;;
        programas)
            _help_menu_programas
            ;;
        biblioteca)
            _help_menu_biblioteca
            ;;
        ferramentas)
            _help_menu_ferramentas
            ;;
        temporarios)
            _help_menu_temporarios
            ;;
        recuperacao)
            _help_menu_recuperacao
            ;;
        backup)
            _help_menu_backup
            ;;
        transferencia)
            _help_menu_transferencia
            ;;
        setups)
            _help_menu_setups
            ;;
        lembretes)
            _help_menu_lembretes
            ;;
        *)
            _help_generico
            ;;
    esac
    
    printf "\n"
    _linha "-" "${GREEN}"
    _mensagec "${YELLOW}" "Pressione qualquer tecla para voltar ou 'M' para manual completo"
    _linha "-" "${GREEN}"
    
    read -rsn1 resposta
    if [[ "${resposta,,}" == "m" ]]; then
        _exibir_manual_completo
    fi
}

#---------- CONTEUDO DE AJUDA POR MENU ----------#

_help_menu_principal() {
    cat << 'EOF'
MENU PRINCIPAL
═══════════════════════════════════════════════════════════════════

O Menu Principal é o ponto de entrada do sistema SAV. A partir dele
você pode acessar todas as funcionalidades disponíveis.

OPCOES DISPONIVEIS:
───────────────────────────────────────────────────────────────────

1 - ATUALIZAR PROGRAMA(S)
    Permite baixar e instalar programas individuais ou em pacote.
    
    • Use esta opcao quando precisar atualizar programas específicos
    • Suporta atualizações online (via servidor) ou offline (via arquivo)
    • Permite compilacao normal ou em modo de depuracao
    • Cria backup automático antes de atualizar
    
    QUANDO USAR:
    - Correcao de bugs em programas específicos
    - Instalacao de novos recursos
    - Atualizacao de módulos individuais

2 - ATUALIZAR BIBLIOTECA
    Atualiza o conjunto completo de bibliotecas do sistema.
    
    • Transpc: Biblioteca de transporte entre sistemas
    • Savatu: Biblioteca principal do SAV
    • Modo Offline: Para ambientes sem conexao
    
    QUANDO USAR:
    - Atualizacao em massa de programas
    - Mudança de versao do sistema
    - Sincronizacao com versao do servidor
EOF
    
    printf "\n"
    printf "%s\n" "${RED}    IMPORTANTE: Esta operacao e mais abrangente e pode levar"
    printf "%s\n" "    mais tempo que a atualizacao de programas individuais.${NORM}"
    cat << 'EOF'

3 - VERSAO DO ISCOBOL
    Exibe informações sobre a versao do IsCOBOL instalada.
    
    • Mostra número da versao
    • Exibe data de compilacao
    • Lista recursos disponíveis
    
    Nota: Disponível apenas para sistemas IsCOBOL.

4 - VERSAO DO LINUX
    Mostra informações detalhadas do sistema operacional.
    
    INFORMACOES EXIBIDAS:
    • Distribuicao e versao do Linux
    • Hostname do servidor
    • IP interno e externo
    • Usuários logados
    • Uso de memória RAM e SWAP
    • Uso de disco
    • Tempo de atividade (uptime)

5 - FERRAMENTAS
    Acesso ao menu de ferramentas administrativas.
    
    • Limpeza de arquivos temporários
    • Recuperacao de arquivos de dados
    • Rotinas de backup
    • Transferência de arquivos
    • Expurgador automático
    • Configurações do sistema
    • Sistema de lembretes

9 - SAIR DO SISTEMA
    Encerra o sistema SAV de forma segura.

DICAS:
─────────────────────────────────────────────────────────────────
EOF
    printf "\n"
    printf "%s\n" "${YELLOW}• Use as setas do teclado para navegar (se disponivel)"
    printf "%s\n" "• Digite o número da opcao desejada"
    printf "%s\n" "• Pressione ? a qualquer momento para ajuda contextual"
    printf "%s\n" "• Use Ctrl+C para cancelar operações em andamento${NORM}"
    
    cat << 'EOF'

ATALHOS:
─────────────────────────────────────────────────────────────────
• ? = Ajuda contextual
• 9 = Sair/Voltar
• Ctrl+C = Cancelar operacao
EOF
}

_help_menu_programas() {
    cat << 'EOF'
MENU DE PROGRAMAS
═══════════════════════════════════════════════════════════════════

Este menu permite atualizar programas individuais do sistema SAV.

OPCOES DISPONIVEIS:
───────────────────────────────────────────────────────────────────

1 - PROGRAMA(S) ON-LINE
    Baixa e instala programas diretamente do servidor.
    
    PROCESSO:
EOF
    printf "\n"
    printf '%s\n' "${GREEN}    1. Informe o nome do programa (em MAIÚSCULAS)"
    printf '%s\n' "${GREEN}    2. Escolha o tipo de compilacao:"
    printf '%s\n' "${YELLOW}       • 1 = Normal (producao)"
    printf '%s\n' "       • 2 = Depuracao (debug, com símbolos)${NORM}"
    printf '%s\n' "${GREEN}    3. Repita para até 6 programas"
    printf '%s\n' "    4. Pressione ENTER para finalizar selecao"
    printf '%s\n' "    5. Aguarde o download e instalacao${NORM}"
    
    cat << 'EOF'
    
    EXEMPLO:
    Nome do programa: CADCLI
    Tipo de compilacao: 1
    
    Nome do programa: CADFOR
    Tipo de compilacao: 1
    
    Nome do programa: [ENTER para finalizar]

2 - PROGRAMA(S) OFF-LINE
    Instala programas a partir de arquivos locais.
    
    QUANDO USAR:
    - Servidor sem acesso à internet
    - Instalacao em ambiente isolado
    - Uso de arquivos previamente baixados
EOF
    printf "\n"
    printf "%s\n" "${RED}    PREREQUISITO:"
    printf "%s\n" "    Os arquivos .zip dos programas devem estar no diretório"
    printf "%s\n" "    configurado para modo offline (geralmente /portalsav/Atualiza)${NORM}"
    
    cat << 'EOF'

3 - PROGRAMA(S) EM PACOTE
    Instala múltiplos programas de uma vez através de pacotes.
    
    VANTAGENS:
    • Mais rápido para múltiplas atualizações
    • Garante compatibilidade entre programas relacionados
    • Menor chance de erros de dependência
    
    EXEMPLO DE PACOTE:
    - VENDAS (contém: PEDVEN, ORCVEN, NOTVEN, etc)
    - ESTOQUE (contém: MOVES, INVES, PROEST, etc)

4 - VOLTAR PROGRAMA ATUALIZADO
    Reverte programa para versao anterior.
    
    PROCESSO:
    1. Informe o nome do programa a reverter
    2. Sistema busca backup automático
    3. Restaura versao anterior
EOF
    printf "\n"
    printf "%s\n" "${RED}    IMPORTANTE:"
    printf "%s\n" "    • Apenas programas com backup podem ser revertidos"
    printf "%s\n" "    • Backup é criado automaticamente em cada atualizacao"
    printf "%s\n" "    • Backup fica em: tools/olds/[PROGRAMA]-anterior.zip${NORM}"
    
    cat << 'EOF'

INFORMACOES IMPORTANTES:
───────────────────────────────────────────────────────────────────

NOMES DE PROGRAMAS:
EOF

    printf "%s\n" "${NORM}• Sempre em MAIÚSCULAS (ex: CADCLI, nao cadcli)"
    printf "%s\n" "• Apenas letras e números"
    printf "%s\n" "• Sem espaços ou caracteres especiais${NORM}"
    
    cat << 'EOF'

TIPOS DE COMPILACAO:
• Normal (1): Para uso em producao
• Depuracao (2): Para desenvolvimento/testes
  - Inclui símbolos de debug
  - Permite rastreamento de erros
  - Arquivos maiores

BACKUP AUTOMATICO:
• Criado antes de cada atualizacao
• Inclui: .class, .int, .TEL
• Localizacao: tools/olds/
• Formato: [PROGRAMA]-anterior.zip

TROUBLESHOOTING:
───────────────────────────────────────────────────────────────────

PROBLEMA: "Arquivo nao encontrado"
SOLUCAO: Verifique se o nome está correto e em MAIÚSCULAS

PROBLEMA: "Erro ao descompactar"
SOLUCAO: Arquivo pode estar corrompido, baixe novamente

PROBLEMA: "Falha no backup"
SOLUCAO: Verifique espaço em disco no diretório tools/olds/

PROBLEMA: "Programa nao encontrado no servidor"
SOLUCAO: Verifique com suporte se programa está disponível
EOF
}

_help_menu_biblioteca() {
    cat << 'EOF'
MENU DA BIBLIOTECA
═══════════════════════════════════════════════════════════════════

Bibliotecas sao conjuntos completos de programas que formam o
sistema SAV. Atualizar a biblioteca é uma operacao mais ampla que
atualizar programas individuais.

OPCOES DISPONIVEIS:
───────────────────────────────────────────────────────────────────

1 - ATUALIZACAO DO TRANSPC
    Atualiza a biblioteca de transporte PC.
    
    O QUE E:
    Biblioteca responsável pela comunicacao e transporte de dados
    entre diferentes módulos do sistema.
    
    CONTEUDO:
    • Programas de interface
    • Drivers de comunicacao
    • Rotinas de conversao
    
    QUANDO ATUALIZAR:
    - Mudança de versao principal
    - Problemas de comunicacao
    - Orientacao do suporte técnico

2 - ATUALIZACAO DO SAVATU
    Atualiza a biblioteca principal do SAV.
    
    O QUE E:
    Conjunto completo de programas que compõem o sistema SAV.
    
    CONTEUDO:
    • Classes compiladas (.class)
    • Telas de interface (.TEL)
    • Arquivos XML de configuracao
    • Programas intermediários (.int)
    
    VERSOES DISPONIVEIS:
    • IsCOBOL 2018, 2020, 2023, 2024
    • MicroFocus COBOL
    
    IMPORTANTE:
    Esta é a atualizacao mais comum e completa do sistema.

3 - ATUALIZACAO OFF-LINE
    Instala biblioteca a partir de arquivos locais.
    
    PROCESSO:
    1. Copie os arquivos de atualizacao para o diretório offline
    2. Informe a versao da biblioteca
    3. Sistema localiza e instala os arquivos
    
    ARQUIVOS NECESSARIOS (IsCOBOL):
    • tempSAV_IS[ANO]_classA_[VERSAO].zip
    • tempSAV_IS[ANO]_classB_[VERSAO].zip
    • tempSAV_IS[ANO]_tel_isc_[VERSAO].zip
    • tempSAV_IS[ANO]_xml_[VERSAO].zip
    
    EXEMPLO:
    • tempSAV_IS2024_classA_5280.zip
    • tempSAV_IS2024_classB_5280.zip
    • tempSAV_IS2024_tel_isc_5280.zip
    • tempSAV_IS2024_xml_5280.zip

4 - VOLTAR PROGRAMA(S) DA BIBLIOTECA
    Reverte biblioteca para versao anterior.
    
    PROCESSO:
    1. Informe a versao a reverter
    2. Sistema busca backup dessa versao
    3. Escolha entre:
       • Reverter todos os programas
       • Reverter programa específico
    
    BACKUP DA BIBLIOTECA:
    • Local: tools/olds/backup-[VERSAO].zip
    • Criado automaticamente antes de atualizar
    • Contém todos os arquivos antigos

PROCESSO DE ATUALIZACAO DA BIBLIOTECA:
───────────────────────────────────────────────────────────────────

PASSO 1: INFORMAR VERSAO
Digite apenas o número da versao (ex: 0601, 0105, etc)

PASSO 2: VALIDACAO
Sistema verifica:
• Conectividade (modo online)
• Disponibilidade dos arquivos
• Espaço em disco

PASSO 3: BACKUP AUTOMATICO
Sistema cria backup completo:
• Classes (.class)
• Telas (.TEL)
• XML (.xml)
• MicroFocus (.int)

PASSO 4: DOWNLOAD (modo online)
Baixa arquivos do servidor:
• Exibe progresso
• Valida integridade
• Verifica checksums

PASSO 5: INSTALACAO
• Descompacta arquivos
• Move para diretórios corretos
• Atualiza registros de versao
• Remove temporários

PASSO 6: VERIFICACAO
Sistema verifica:
• Arquivos instalados corretamente
• Permissões adequadas
• Integridade dos dados

INFORMACOES IMPORTANTES:
───────────────────────────────────────────────────────────────────

VERSAO:
• Use apenas números (ex: 0601, 0105, etc)
• Nao use pontos ou espacos
• Confirme versao com o suporte

TEMPO DE ATUALIZACAO:
• Depende do tamanho da biblioteca
• Conexao de internet (modo online)
• IsCOBOL: aproximadamente 5-15 minutos
• MicroFocus: aproximadamente 3-10 minutos

ESPACO NECESSARIO:
• Backup: ~500MB - 2GB
• Biblioteca: ~500MB - 2GB
• Total recomendado: 5GB livres

INTERROMPER ATUALIZACAO:
• Use Ctrl+C com cuidado
• Sistema tenta fazer cleanup
• Pode deixar instalacao inconsistente
• Recomenda-se reverter se interrompido

POS-ATUALIZACAO:
• Teste funcionalidades criticas
• Verifique relatorios
• Confirme acesso aos modulos
• Em caso de problemas, reverta

TROUBLESHOOTING:
───────────────────────────────────────────────────────────────────

PROBLEMA: "Erro na compactacao de backup"
SOLUCAO: Verifique espaço em disco, pode estar cheio

PROBLEMA: "Falha no download"
SOLUCAO: Verifique conexao internet e firewall

PROBLEMA: "Erro ao descompactar"
SOLUCAO: Arquivo corrompido, baixe novamente

PROBLEMA: "Sistema lento apos atualizacao"
SOLUCAO: Normal nos primeiros acessos (cache)

PROBLEMA: "Programa nao inicia apos atualizacao"
SOLUCAO: Reverta para versao anterior e contate suporte
EOF
}

_help_menu_ferramentas() {
    cat << 'EOF'
MENU DE FERRAMENTAS
═══════════════════════════════════════════════════════════════════

O menu de Ferramentas fornece utilitários administrativos para
manutencao e gestao do sistema SAV.

OPCOES DISPONIVEIS:
───────────────────────────────────────────────────────────────────

1 - TEMPORARIOS
    Gerencia arquivos temporários do sistema.
    
    FUNCOES:
    • Limpeza automática de arquivos antigos
    • Compactacao antes de remover
    • Manutencao da lista de temporários
    
    BENEFICIOS:
    - Libera espaço em disco
    - Melhora performance
    - Organiza base de dados

2 - RECUPERAR ARQUIVOS
    Executa rebuild em arquivos de dados.
    
    O QUE FAZ:
    Reconstrói índices e reorganiza arquivos de dados,
    corrigindo possíveis inconsistências.
    
    QUANDO USAR:
    - Após queda de sistema
    - Erros de "arquivo corrompido"
    - Performance degradada
    - Manutencao preventiva
    
    DISPONIVEL APENAS PARA: Sistemas IsCOBOL

3 - ROTINAS DE BACKUP
    Gerencia backups da base de dados.
    
    TIPOS:
    • Completo: Todos os arquivos
    • Incremental: Apenas alterações
    
    OPCOES:
    - Criar novo backup
    - Restaurar backup
    - Enviar para servidor

4 - ENVIAR E RECEBER ARQUIVOS
    Transfere arquivos entre cliente e servidor.
    
    USOS:
    • Envio de relatórios
    • Recebimento de atualizações
    • Compartilhamento de dados
    • Transferência de logs
    
    PROTOCOLOS: SFTP, RSYNC

5 - EXPURGADOR DE ARQUIVOS
    Remove automaticamente arquivos antigos.
    
    DIRETORIOS LIMPOS:
    • Backups (>30 dias)
    • Logs (>30 dias)
    • Programas antigos (>30 dias)
    • Erros IsCOBOL (>30 dias)
    • Arquivos ZIP (>15 dias)
    
    EXECUCAO:
    • Manual: Via menu
    • Automática: Diária (primeira execucao)

6 - PARAMETROS
    Visualiza e edita configurações do sistema.
    
    ACESSO:
    • Consulta: Visualizacao apenas
    • Manutencao: Edicao de valores
    • Validacao: Testa configurações

7 - UPDATE
    Atualiza o próprio sistema de atualizacao.
    
    O QUE ATUALIZA:
    • Scripts do atualiza.sh
    • Módulos de biblioteca
    • Arquivos de configuracao
    • Sistema de ajuda
    
    FONTES:
    • Online: GitHub
    • Offline: Arquivos locais

8 - LEMBRETES
    Sistema de notas e lembretes.
    
    FUNCOES:
    • Criar novas notas
    • Visualizar notas
    • Editar notas existentes
    • Apagar notas
    
    USO:
    - Registrar pendências
    - Anotações de manutencao
    - Lembretes de atualizações

DICAS DE USO:
───────────────────────────────────────────────────────────────────

MANUTENCAO REGULAR:
1. Execute expurgador semanalmente
2. Faça backup antes de atualizações
3. Limpe temporários mensalmente
4. Recupere arquivos após problemas

ORGANIZACAO:
• Use lembretes para agendar tarefas
• Documente alterações importantes
• Mantenha logs organizados

PERFORMANCE:
• Limpeza regular melhora velocidade
• Recuperacao de arquivos otimiza índices
• Expurgador libera recursos
EOF
}

_help_menu_temporarios() {
    cat << 'EOF'
MENU DE LIMPEZA - TEMPORARIOS
═══════════════════════════════════════════════════════════════════

Gerencia arquivos temporários criados durante operacao do sistema.

OPCOES DISPONIVEIS:
───────────────────────────────────────────────────────────────────

1 - LIMPEZA DOS ARQUIVOS TEMPORARIOS
    Remove arquivos temporários de todas as bases.
    
    PROCESSO:
    1. Lê lista de padrões (arquivo atualizat)
    2. Busca arquivos correspondentes
    3. Compacta arquivos encontrados
    4. Move para backup
    5. Remove originais
    
    ARQUIVOS PROCESSADOS:
    • Relatórios temporários
    • Arquivos de trabalho
    • Impressões antigas
    • Cache de sistema
    
    DESTINO:
    Arquivos sao compactados em:
    tools/backup/Temps-[DATA].zip

2 - ADICIONAR ARQUIVOS NO ATUALIZAT
    Adiciona novo padrao à lista de limpeza.
    
    COMO USAR:
    1. Informe o nome/padrao do arquivo
    2. Use * para coringas
    
    EXEMPLOS:
    • REL*.TMP = Todos arquivos REL com extensao .TMP
    • TEMP* = Todos arquivos começando com TEMP
    • *.BAK = Todos arquivos .BAK
    
    ARQUIVO:
    Padrões sao salvos em: cfg/atualizat

3 - LISTAR ARQUIVOS DO ATUALIZAT
    Exibe lista de padrões configurados.
    
    VISUALIZACAO:
    • Numerada para referência
    • Um padrao por linha
    • Formato legível

ARQUIVO ATUALIZAT:
───────────────────────────────────────────────────────────────────

LOCALIZACAO:
cfg/atualizat

FORMATO:
Um padrao por linha, sem comentários
Exemplo:
REL*.TMP
TEMP*
*.BAK
WORK*.DAT

PADROES COMUNS:
• REL*.TMP - Relatórios temporários
• TEMP* - Arquivos de trabalho
• *.BAK - Backups automáticos
• WORK* - Arquivos de processamento
• PRINT*.SPL - Filas de impressao

INFORMACOES IMPORTANTES:
───────────────────────────────────────────────────────────────────

SEGURANCA:
• Arquivos sao compactados antes de remover
• Backup mantido por 10 dias
• Pode recuperar se necessário

PERFORMANCE:
• Execute regularmente (mensal)
• Libera espaço em disco
• Melhora velocidade de acesso
• Reduz fragmentacao

MULTIPLAS BASES:
Se configurado com múltiplas bases (base2, base3),
a limpeza processa todas automaticamente.

RECUPERACAO:
Para recuperar arquivo removido:
1. Localize backup: tools/backup/Temps-[DATA].zip
2. Descompacte o arquivo necessário
3. Restaure para local original
EOF
}

_help_menu_recuperacao() {
    cat << 'EOF'
MENU DE RECUPERACAO DE ARQUIVO(S)
═══════════════════════════════════════════════════════════════════

Executa rebuild (reconstrucao) em arquivos de dados IsCOBOL,
corrigindo índices e reorganizando registros.

DISPONIVEL APENAS PARA: Sistemas IsCOBOL

OPCOES DISPONIVEIS:
───────────────────────────────────────────────────────────────────

1 - UM ARQUIVO OU TODOS
    Recupera arquivo específico ou todos.
    
    PROCESSO:
    • Nome específico: Digite nome do arquivo (ex: CADCLI)
    • Todos: Pressione ENTER sem digitar nada
    
    ARQUIVOS PROCESSADOS (todos):
    • *.ARQ.dat - Arquivos de dados
    • *.DAT.dat - Arquivos de dados
    • *.LOG.dat - Logs do sistema
    • *.PAN.dat - Painéis/Telas
    
    COMANDO UTILIZADO:
    jutil -rebuild [ARQUIVO] -a -f
    
    PARAMETROS:
    • -rebuild: Reconstrói arquivo
    • -a: Modo automático
    • -f: Força reconstrucao

2 - ARQUIVOS PRINCIPAIS
    Recupera conjunto de arquivos principais.
    
    CRITERIOS:
    • Arquivos do ano atual (ATE[AA]*.dat)
    • Notas fiscais eletrônicas do ano (NFE?[AAAA].*.dat)
    • Arquivos da lista atualizaj
    
    LISTA ATUALIZAJ:
    Local: cfg/atualizaj
    Contém: Nomes de arquivos críticos do sistema

O QUE E REBUILD:
───────────────────────────────────────────────────────────────────

DEFINICAO:
Rebuild (reconstrucao) é o processo de reorganizar um arquivo
de dados indexed, reconstruindo seus índices e corrigindo
possíveis inconsistências.

O QUE FAZ:
1. Lê todos os registros do arquivo
2. Verifica integridade de cada registro
3. Reconstrói índices do zero
4. Reorganiza dados no disco
5. Remove registros marcados para exclusao
6. Otimiza espaço físico

QUANDO USAR:
───────────────────────────────────────────────────────────────────

OBRIGATORIO:
• Erro "File is locked" persistente
• Erro "Invalid key" ao acessar dados
• Mensagem "Corrupt index"
• Após queda abrupta do sistema
• Após falha de disco ou energia

RECOMENDADO:
• Performance degradada
• Arquivo cresceu muito sem reorganizacao
• Manutencao preventiva mensal
• Após importacao em massa de dados
• Antes de backup importante

PREVENCAO:
• Semanalmente nos arquivos principais
• Mensalmente em todos os arquivos
• Sempre após erros de acesso

PROCESSO DE RECUPERACAO:
───────────────────────────────────────────────────────────────────

PASSO 1: IDENTIFICACAO
Sistema identifica arquivos a processar

PASSO 2: VALIDACAO
Verifica se arquivo existe e nao está vazio

PASSO 3: VERIFICACAO JUTIL
Confirma disponibilidade do utilitário jutil

PASSO 4: EXECUCAO
Executa rebuild com progress indicator

PASSO 5: VERIFICACAO
Confirma sucesso da operacao

PASSO 6: LOG
Registra operacao em arquivo de log

TEMPO DE PROCESSAMENTO:
───────────────────────────────────────────────────────────────────

FATORES:
• Tamanho do arquivo
• Quantidade de registros
• Estado de fragmentacao
• Performance do disco

ESTIMATIVAS:
• Arquivo pequeno (<10MB): Segundos
• Arquivo médio (10-100MB): 1-5 minutos
• Arquivo grande (100MB-1GB): 5-30 minutos
• Arquivo muito grande (>1GB): 30+ minutos

MULTIPLAS BASES:
Se sistema possui múltiplas bases (base2, base3),
será solicitado escolher qual base processar.

INFORMACOES IMPORTANTES:
───────────────────────────────────────────────────────────────────

USUARIOS:
• Sistema deve estar sem usuários
• Ou pelo menos sem usar arquivo específico
• Rebuild em arquivo em uso pode falhar

BACKUP:
• Recomenda-se backup antes de rebuild
• Principalmente em arquivos críticos
• Pode usar: Menu Ferramentas > Backup

ESPACO EM DISCO:
• Necessário espaço = tamanho do arquivo
• Rebuild cria arquivo temporário
• Depois substitui o original

LOGS:
Operações registradas em:
tools/logs/atualiza.[DATA].log

TROUBLESHOOTING:
───────────────────────────────────────────────────────────────────

PROBLEMA: "jutil not found"
SOLUCAO: Verificar instalacao IsCOBOL

PROBLEMA: "File is locked"
SOLUCAO: Fechar sistema e tentar novamente

PROBLEMA: "Permission denied"
SOLUCAO: Verificar permissões do arquivo

PROBLEMA: "No space left on device"
SOLUCAO: Liberar espaço em disco

PROBLEMA: Rebuild travou
SOLUCAO: Aguardar ou verificar se processo está ativo
EOF
}

_help_menu_backup() {
    cat << 'EOF'
MENU DE BACKUP(S)
═══════════════════════════════════════════════════════════════════

Sistema completo de backup e restauracao da base de dados.

DISPONIVEL PARA: Sistemas sem banco de dados (BANCO=n)

OPCOES DISPONIVEIS:
───────────────────────────────────────────────────────────────────

1 - BACKUP DA BASE DE DADOS
    Cria backup completo ou incremental.
    
    TIPOS:
    
    COMPLETO:
    • Todos os arquivos da base
    • Exclui: *.zip, *.tar, *.tar.gz
    • Formato: [EMPRESA]_completo_[DATA_HORA].zip
    
    INCREMENTAL:
    • Apenas arquivos modificados
    • Baseado em data de referência
    • Formato: [EMPRESA]_incremental_[DATA_HORA].zip
    
    PROCESSO:
    1. Escolher base (se múltiplas)
    2. Escolher tipo de backup
    3. Verificar backups recentes
    4. Criar backup com progresso
    5. Opcionalmente enviar para servidor
    
    DESTINO:
    tools/backup/

2 - RESTAURAR BASE DE DADOS
    Restaura backup anterior.
    
    OPCOES:
    • Restauracao completa (todos arquivos)
    • Restauracao específica (um arquivo)
    
    PROCESSO COMPLETO:
    1. Listar backups disponíveis
    2. Selecionar backup
    3. Confirmar operacao
    4. Descompactar para base
    
    PROCESSO ESPECIFICO:
    1. Listar backups disponíveis
    2. Selecionar backup
    3. Informar nome do arquivo
    4. Extrair apenas esse arquivo
    
    IMPORTANTE:
    Restauracao sobrescreve arquivos existentes!

3 - ENVIAR BACKUP
    Envia backup para servidor remoto.
    
    PROCESSO:
    1. Listar backups locais
    2. Selecionar backup
    3. Confirmar envio
    4. Transferir via rsync/sftp
    5. Opcionalmente remover local

BACKUP COMPLETO:
───────────────────────────────────────────────────────────────────

O QUE INCLUI:
• Todos arquivos de dados (.dat)
• Arquivos de índice (.idx, .key)
• Arquivos de configuracao (.cfg)
• Logs importantes

O QUE EXCLUI:
• Arquivos já compactados (.zip, .tar)
• Backups antigos (*.bak)
• Temporários do sistema

QUANDO FAZER:
• Antes de atualizações importantes
• Diariamente (final do dia)
• Antes de manutenções
• Semanalmente (mínimo)

BACKUP INCREMENTAL:
───────────────────────────────────────────────────────────────────

O QUE INCLUI:
Apenas arquivos modificados após data especificada

VANTAGENS:
• Mais rápido
• Menor espaço
• Backup frequente viável

QUANDO FAZER:
• Durante o dia (várias vezes)
• Entre backups completos
• Para dados em constante mudança

ESTRATEGIA RECOMENDADA:
• Completo: Diário (noite)
• Incremental: A cada 2-4 horas

FORMATO DOS ARQUIVOS:
───────────────────────────────────────────────────────────────────

NOMENCLATURA:
[EMPRESA]_[TIPO]_[AAAAMMDDHHMMSS].zip

EXEMPLO:
MINHAEMP_completo_20260108120000.zip
MINHAEMP_incremental_20260108150000.zip

COMPONENTES:
• EMPRESA: Nome configurado no setup
• TIPO: completo ou incremental
• DATA: Ano, mês, dia, hora, minuto, segundo

LOCALIZACAO:
tools/backup/

RETENCAO:
• Local: 30 dias (expurgador)
• Servidor: Conforme política empresa

PROCESSO DE BACKUP:
───────────────────────────────────────────────────────────────────

PASSO 1: VERIFICACAO PREVIA
• Verifica backups recentes (últimos 2 dias)
• Alerta se já existe
• Permite criar adicional

PASSO 2: PREPARACAO
• Muda para diretório da base
• Define nome do arquivo
• Prepara comando de compactacao

PASSO 3: COMPACTACAO
• Executa em background
• Mostra progresso (spinner)
• Registra em log

PASSO 4: VERIFICACAO
• Confirma criacao do arquivo
• Verifica integridade do ZIP
• Valida tamanho mínimo

PASSO 5: ENVIO (opcional)
• Oferece enviar para servidor
• Usa rsync ou sftp
• Mantém ou remove local

PROCESSO DE RESTAURACAO:
───────────────────────────────────────────────────────────────────

PASSO 1: SELECAO
• Lista backups disponíveis
• Mostra data/hora e tamanho
• Permite filtrar por nome

PASSO 2: CONFIRMACAO
• Exibe backup selecionado
• Alerta sobre sobrescrita
• Solicita confirmacao

PASSO 3: DESCOMPACTACAO
• Extrai arquivos
• Mostra progresso
• Sobrescreve existentes

PASSO 4: VERIFICACAO
• Confirma arquivos restaurados
• Verifica integridade
• Registra em log

INFORMACOES IMPORTANTES:
───────────────────────────────────────────────────────────────────

ESPACO NECESSARIO:
• Backup: ~igual ao tamanho da base
• Compactacao reduz para 30-50%
• Manter espaço livre mínimo: 5GB

TEMPO DE PROCESSAMENTO:
• Completo: 5-30 minutos
• Incremental: 1-5 minutos
• Depende: tamanho, velocidade disco

MULTIPLAS BASES:
Se configurado múltiplas bases:
• Sistema solicita escolher qual
• Pode fazer backup de cada uma
• Nome do arquivo inclui identificacao

SEGURANCA:
• Backups nao criptografados
• Proteja com permissões adequadas
• Servidor remoto deve ser seguro

AUTOMACAO:
Para backup automático, use cron:
0 22 * * * /caminho/atualiza.sh --backup-auto

TROUBLESHOOTING:
───────────────────────────────────────────────────────────────────

PROBLEMA: "Backup muito lento"
SOLUCAO: Base muito grande, considere incremental

PROBLEMA: "No space left on device"
SOLUCAO: Limpe backups antigos ou aumente disco

PROBLEMA: "Arquivo corrompido"
SOLUCAO: Backup pode ter falhado, use anterior

PROBLEMA: "Erro ao enviar para servidor"
SOLUCAO: Verifique conectividade e credenciais
EOF
}

_help_menu_transferencia() {
    cat << 'EOF'
MENU DE ENVIAR E RECEBER ARQUIVO(S)
═══════════════════════════════════════════════════════════════════

Sistema de transferência de arquivos entre cliente e servidor.

OPCOES DISPONIVEIS:
───────────────────────────────────────────────────────────────────

1 - ENVIAR ARQUIVO(S)
    Envia arquivo para servidor remoto.
    
    PROCESSO:
    1. Informar diretório de origem
       • Caminho completo ou
       • ENTER para usar padrao (tools/envia)
    
    2. Informar nome do arquivo
       • Nome completo com extensao
       • Ex: relatorio.pdf
    
    3. Informar diretório destino no servidor
       • Caminho completo no servidor
       • Ex: /home/usuario/documentos
    
    4. Fornecer senha do usuário remoto
    
    5. Transferência via rsync
       • Mostra progresso
       • Mantém permissões
       • Compressao automática
    
    PROTOCOLOS:
    • RSYNC: Transferência eficiente
    • SSH: Segurança na conexao
    • Porta: Configurável (padrao 41122)

2 - RECEBER ARQUIVO(S)
    Baixa arquivo do servidor.
    
    PROCESSO:
    1. Informar diretório de origem (servidor)
       • Caminho completo no servidor
       • Ex: /home/usuario/backup
    
    2. Informar nome do arquivo
       • Nome completo com extensao
       • Ex: dados.zip
    
    3. Informar diretório destino (local)
       • Caminho completo ou
       • ENTER para usar padrao (tools/recebe)
    
    4. Fornecer senha do usuário remoto
    
    5. Transferência via sftp
       • Mostra progresso
       • Verifica integridade
    
    PROTOCOLOS:
    • SFTP: Protocolo seguro
    • SSH: Criptografia
    • Porta: Configurável

USO DE DIRETORIOS PADRAO:
───────────────────────────────────────────────────────────────────

ENVIO:
Origem padrao: tools/envia/
• Coloque arquivo neste diretório
• Pressione ENTER ao solicitar origem
• Sistema usa automaticamente

RECEBIMENTO:
Destino padrao: tools/recebe/
• Arquivo baixado neste diretório
• Pressione ENTER ao solicitar destino
• Facilita localizacao

VANTAGENS:
• Organizacao centralizada
• Fácil localizacao de arquivos
• Limpeza automática (expurgador)

CONFIGURACOES DE CONEXAO:
───────────────────────────────────────────────────────────────────

SERVIDOR:
• IP: Configurado no setup
• Porta: Padrao 41122 (SSH)
• Usuário: Configurado no setup

CREDENCIAIS:
• Senha solicitada em cada operacao
• Por segurança, nao é armazenada
• Ou use SSH keys (modo facilitado)

MODO FACILITADO:
Se configurado acessossh=s:
• Usa chaves SSH
• Sem solicitacao de senha
• Conexao persistente
• Mais rápido e seguro

TIPOS DE ARQUIVO:
───────────────────────────────────────────────────────────────────

SUPORTADOS:
• Documentos: .pdf, .doc, .docx, .txt
• Planilhas: .xls, .xlsx, .csv
• Imagens: .jpg, .png, .gif
• Compactados: .zip, .tar, .gz
• Backups: .bak, .backup
• Dados: .dat, .db
• Logs: .log
• Executáveis: .sh, .exe
• Todos os demais formatos

LIMITACOES:
• Tamanho: Limitado por disco
• Permissões: Requer acesso adequado
• Rede: Depende de conectividade

CASOS DE USO:
───────────────────────────────────────────────────────────────────

ENVIAR:
• Relatórios para análise
• Logs para suporte técnico
• Backups para servidor
• Documentacao atualizada
• Arquivos de configuracao
• Exports de dados

RECEBER:
• Atualizações do sistema
• Arquivos de configuracao
• Manuais e documentacao
• Templates e modelos
• Imports de dados
• Patches e correções

SEGURANCA:
───────────────────────────────────────────────────────────────────

CRIPTOGRAFIA:
• SSH: Todos dados criptografados
• Senhas: Nunca em texto claro
• Conexao: Protocolo seguro

VALIDACAO:
• Integridade: Checksums automáticos
• Permissões: Preservadas na transferência
• Sobrescrita: Confirmacao requerida

AUDITORIA:
• Logs: Todas operações registradas
• Data/Hora: Timestamp completo
• Usuário: Identificacao preservada

TROUBLESHOOTING:
───────────────────────────────────────────────────────────────────

PROBLEMA: "Connection refused"
SOLUCAO: Verificar IP, porta e firewall

PROBLEMA: "Permission denied"
SOLUCAO: Verificar credenciais e permissões

PROBLEMA: "No such file or directory"
SOLUCAO: Confirmar caminho completo e correto

PROBLEMA: "Disk quota exceeded"
SOLUCAO: Liberar espaço no destino

PROBLEMA: Transferência muito lenta
SOLUCAO: Verificar velocidade da rede

PROBLEMA: "Host key verification failed"
SOLUCAO: Limpar ~/.ssh/known_hosts ou aceitar novo
EOF
}

_help_menu_setups() {
    cat << 'EOF'
MENU DE SETUP DO SISTEMA
═══════════════════════════════════════════════════════════════════

Gerenciamento de configurações do sistema SAV.

OPCOES DISPONIVEIS:
───────────────────────────────────────────────────────────────────

1 - CONSULTA DE SETUP
    Visualiza todas as configurações atuais.
    
    INFORMACOES EXIBIDAS:
    • Sistema e versao
    • Diretórios configurados
    • Bibliotecas em uso
    • Conexao de rede
    • Modo online/offline
    • Parâmetros de backup
    
    USO:
    • Verificar configuracao atual
    • Documentar instalacao
    • Troubleshooting
    • Auditoria

2 - MANUTENCAO DE SETUP
    Permite editar configurações existentes.
    
    PARAMETROS EDITAVEIS:
    • sistema: iscobol ou cobol
    • verclass: Versao do IsCOBOL
    • BANCO: Sistema usa banco (s/n)
    • acessossh: Modo facilitado (s/n)
    • IPSERVER: IP do servidor
    • Offline: Modo offline (s/n)
    • ENVIABACK: Diretório backup servidor
    • EMPRESA: Nome da empresa
    • base, base2, base3: Diretórios dados
    
    PROCESSO:
    1. Sistema carrega valores atuais
    2. Para cada parâmetro:
       • Mostra valor atual
       • Pergunta se deseja alterar
       • Solicita novo valor
    3. Recria arquivos de configuracao
    4. Recarrega configurações
    
    BACKUP AUTOMATICO:
    Sistema cria .atualizac.bak antes de editar

3 - VALIDAR CONFIGURACAO
    Testa todas as configurações.
    
    VALIDACOES:
    • Arquivos de configuracao existem
    • Variáveis obrigatórias definidas
    • Diretórios existem e acessíveis
    • Comandos disponíveis
    • Conectividade (modo online)
    
    RESULTADO:
    • Erros: Problemas críticos
    • Avisos: Problemas nao críticos
    • OK: Tudo correto
    
    RECOMENDACAO:
    Execute após alterações ou problemas

ARQUIVO DE CONFIGURACAO:
───────────────────────────────────────────────────────────────────

LOCALIZACAO:
cfg/.atualizac

FORMATO:
Arquivo texto com pares chave=valor

EXEMPLO:
sistema=iscobol
verclass=2024
BANCO=n
EMPRESA=MINHAEMP
base=/dados_jisam
IPSERVER=192.168.1.100
Offline=n

IMPORTANTE:
• Nao adicionar espaços em volta do =
• Valores sensíveis a maiúsculas/minúsculas
• Sem aspas nos valores
• Comentários com #

PARAMETROS PRINCIPAIS:
───────────────────────────────────────────────────────────────────

sistema:
• iscobol: Sistema IsCOBOL
• cobol: Micro Focus COBOL
• Determina módulos a usar

verclass:
• 2018, 2020, 2023, 2024
• Versao do IsCOBOL
• Define compatibilidade biblioteca

BANCO:
• s: Sistema usa banco de dados
• n: Sistema file-based
• Afeta menus disponíveis

base:
• Diretório principal de dados
• Caminho relativo à raiz
• Ex: /dados_jisam

EMPRESA:
• Nome da empresa (sem espaços)
• Usado em backups
• Identificacao de instalacao

IPSERVER:
• IP do servidor SAV
• Para atualizações e backups
• Ex: 192.168.1.100

Offline:
• s: Modo offline (sem servidor)
• n: Modo online (com servidor)
• Determina fonte de atualizações

BIBLIOTECAS:
───────────────────────────────────────────────────────────────────

SAVATU1, SAVATU2, SAVATU3, SAVATU4:
Padrões de nome dos arquivos de biblioteca

FORMATO:
tempSAV_IS[ANO]_[TIPO]_

EXEMPLO (IsCOBOL 2024):
SAVATU1=tempSAV_IS2024_classA_
SAVATU2=tempSAV_IS2024_classB_
SAVATU3=tempSAV_IS2024_tel_isc_
SAVATU4=tempSAV_IS2024_xml_

ATUALIZACAO AUTOMATICA:
Ao mudar verclass, SAVATUs sao atualizados

DIRETORIOS FIXOS:
───────────────────────────────────────────────────────────────────

Definidos automaticamente em tools/:
• /progs - Programas atualizados
• /olds - Backups de reversao
• /logs - Arquivos de log
• /cfg - Configurações
• /backup - Backups da base
• /envia - Arquivos para enviar
• /recebe - Arquivos recebidos
• /libs - Bibliotecas do sistema

NAO MODIFICAR estes diretórios!

CONFIGURACAO INICIAL:
───────────────────────────────────────────────────────────────────

Para nova instalacao, use:
./libs/setup.sh

WIZARD INTERATIVO:
1. Escolhe sistema (IsCOBOL/Cobol)
2. Define versao
3. Configura banco de dados
4. Define diretórios
5. Configura rede
6. Define backup
7. Informações empresa
8. Cria configurações
9. Configura SSH (opcional)

RECONFIGURACAO:
Para modificar instalacao existente:
./libs/setup.sh --edit

TROUBLESHOOTING:
───────────────────────────────────────────────────────────────────

PROBLEMA: "Arquivo .atualizac nao encontrado"
SOLUCAO: Execute ./libs/setup.sh

PROBLEMA: "Variável nao definida"
SOLUCAO: Execute manutencao de setup

PROBLEMA: "Diretório nao encontrado"
SOLUCAO: Verifique paths no .atualizac

PROBLEMA: Alterações nao surtem efeito
SOLUCAO: Saia e entre novamente no sistema
EOF
}

_help_menu_lembretes() {
    cat << 'EOF'
MENU DE LEMBRETES - BLOCO DE NOTAS
═══════════════════════════════════════════════════════════════════

Sistema simples de anotações e lembretes.

OPCOES DISPONIVEIS:
───────────────────────────────────────────────────────────────────

1 - ESCREVER NOVA NOTA
    Cria nova anotacao.
    
    PROCESSO:
    1. Digite o conteúdo da nota
    2. Pode ser múltiplas linhas
    3. Pressione Ctrl+D para finalizar
    4. Nota é salva automaticamente
    
    FORMATO:
    Texto livre, sem formatacao especial
    
    EXEMPLO:
    Atualizar sistema dia 15/01
    Pendente: Testar módulo vendas
    Lembrar: Backup completo sexta

2 - VISUALIZAR NOTA
    Exibe notas salvas.
    
    APRESENTACAO:
    • Moldura ao redor do texto
    • Formatacao preservada
    • Fácil leitura
    
    USO:
    Consultar anotações e lembretes

3 - EDITAR NOTA
    Modifica nota existente.
    
    EDITOR:
    • nano (padrao)
    • ou editor definido em $EDITOR
    
    COMANDOS NANO:
    • Ctrl+O = Salvar
    • Ctrl+X = Sair
    • Ctrl+K = Recortar linha
    • Ctrl+U = Colar
    
    MODIFICACAO:
    • Adicionar linhas
    • Remover linhas
    • Alterar texto

4 - APAGAR NOTA
    Remove todas as notas.
    
    PROCESSO:
    1. Sistema solicita confirmacao
    2. Se confirmar (S), apaga tudo
    3. Se negar (N), cancela
    
    IMPORTANTE:
    Acao irreversível! Notas sao perdidas.

ARQUIVO DE NOTAS:
───────────────────────────────────────────────────────────────────

LOCALIZACAO:
cfg/atualizal

FORMATO:
Arquivo texto simples

CONTEUDO:
Todas as notas em sequência

PERSISTENCIA:
Notas sao mantidas entre sessões

CASOS DE USO:
───────────────────────────────────────────────────────────────────

TAREFAS PENDENTES:
[ ] Atualizar biblioteca versao 5280
[ ] Verificar espaço em disco
[ ] Testar recuperacao de arquivos

HISTORICO DE MANUTENCAO:
10/01 - Atualizado programa CADCLI
11/01 - Backup completo realizado
12/01 - Limpeza de temporários

PROBLEMAS CONHECIDOS:
- Programa RELVEN lento (investigar)
- Erro esporádico no CADFOR
- Aguardando correcao do suporte

CONTATOS IMPORTANTES:
Email: suporte@sav.com.br
Horário: 8h às 18h

SENHAS E ACESSOS:
(Nao recomendado para informações sensíveis!)

INFORMACOES IMPORTANTES:
───────────────────────────────────────────────────────────────────

SEGURANCA:
• Notas em texto simples
• Sem criptografia
• Evite dados sensíveis
• Qualquer usuário pode ler

TAMANHO:
• Sem limite de caracteres
• Sem limite de linhas
• Cuidado com arquivo muito grande

BACKUP:
• Arquivo nao é automaticamente backupado
• Inclua em backup manual se necessário
• Ou copie manualmente

ALTERNATIVAS:
Para anotações mais complexas:
• Use sistema externo de notas
• Software de gestao de tarefas
• Wiki ou documentacao colaborativa

EXIBICAO AUTOMATICA:
Na inicializacao do sistema:
• Se arquivo existe
• Notas sao exibidas automaticamente
• Útil para lembretes importantes
• Configure para nao exibir se preferir

DICAS:
───────────────────────────────────────────────────────────────────

ORGANIZACAO:
Use marcadores e seções:
=== PENDENCIAS ===
=== HISTORICO ===
=== CONTATOS ===

DATAS:
Sempre inclua data nas anotações:
[10/01/2026] Descricao do evento

PRIORIDADES:
Use marcadores:
!!! Urgente
!! Importante
! Normal

CHECKBOX:
Para listas de tarefas:
[ ] Tarefa pendente
[X] Tarefa concluída

LIMPEZA:
Remova informações antigas periodicamente
EOF
}

_help_generico() {
    cat << 'EOF'
AJUDA GERAL - SISTEMA SAV
═══════════════════════════════════════════════════════════════════

Sistema de Atualizacao SAV - Gerenciamento completo de programas,
bibliotecas e manutencao do sistema.

NAVEGACAO:
───────────────────────────────────────────────────────────────────

MENUS:
• Digite o número da opcao desejada
• Pressione ENTER para confirmar
• 9 = Voltar ao menu anterior
• Ctrl+C = Cancelar operacao

AJUDA CONTEXTUAL:
• Pressione H a qualquer momento
• Ou digite  para ajuda
• M = Manual completo

COMANDOS GERAIS:
───────────────────────────────────────────────────────────────────

CONFIRMACOES:
• S ou s = Sim
• N ou n = Nao
• ENTER = Usa valor padrao [maiúsculo]

ENTRADA DE DADOS:
• ENTER vazio = Cancelar ou usar padrao
• ESC = Cancelar (quando disponível)
• Ctrl+C = Interromper processo

ESTRUTURA DO SISTEMA:
───────────────────────────────────────────────────────────────────

DIRETORIOS PRINCIPAIS:
/raiz/
  classes/      - Programas compilados
  tel_isc/      - Telas do sistema
  xml/          - Configurações XML
  dados_jisam/  - Base de dados
  
tools/
  libs/         - Bibliotecas do atualiza
  cfg/          - Configurações
  logs/         - Arquivos de log
  backup/       - Backups da base
  olds/         - Backups de programas
  progs/        - Programas atualizados
  envia/        - Para envio
  recebe/       - Recebidos

ARQUIVOS IMPORTANTES:
───────────────────────────────────────────────────────────────────

cfg/.atualizac        - Configuracao principal
cfg/atualizat         - Lista de temporários
cfg/atualizaj         - Arquivos principais
cfg/atualizal         - Notas/lembretes
logs/atualiza.log     - Log de operações
logs/limpando.log     - Log de limpeza

CONCEITOS IMPORTANTES:
───────────────────────────────────────────────────────────────────

PROGRAMA:
Arquivo executável individual (.class ou .int)

BIBLIOTECA:
Conjunto completo de programas do sistema

BACKUP:
Cópia de segurança de dados

REBUILD:
Reorganizacao de arquivo de dados

TEMPORARIOS:
Arquivos gerados durante operacao

EXPURGADOR:
Limpeza automática de arquivos antigos

PARA MAIS INFORMACOES:
───────────────────────────────────────────────────────────────────

• Pressione M para manual completo
• Use ? em cada menu para ajuda específica
• Consulte documentacao online
• Entre em contato com suporte SAV
EOF
}

#---------- CRIACAO DO MANUAL PADRAO ----------#

_criar_manual_padrao() {
    cat > "$MANUAL_FILE" << 'MANUAL_EOF'
═══════════════════════════════════════════════════════════════════

INDICE:
───────────────────────────────────────────────────────────────────
1. Introducao
2. Menu Principal
3. Atualizacao de Programas
4. Atualizacao de Biblioteca
5. Ferramentas
6. Configurações
7. Resolucao de Problemas
8. Contatos e Suporte

═══════════════════════════════════════════════════════════════════
1. INTRODUCAO
═══════════════════════════════════════════════════════════════════

O Sistema SAV é uma ferramenta completa para gerenciamento,
atualizacao e manutencao de sistemas de gestao empresarial.


PRINCIPAIS FUNCIONALIDADES:
• Atualizacao de programas individuais ou em pacote
• Atualizacao completa de bibliotecas
• Backup e restauracao de dados
• Recuperacao de arquivos corrompidos
• Limpeza de arquivos temporários
• Transferência de arquivos cliente/servidor
• Gestao de configurações

REQUISITOS DO SISTEMA:
• Linux (qualquer distribuicao moderna)
• Bash 4.0 ou superior
• Utilitários: zip, unzip, rsync, ssh
• Espaço em disco: mínimo 5GB livres
• IsCOBOL ou Micro Focus COBOL (conforme instalacao)




═══════════════════════════════════════════════════════════════════
2. MENU PRINCIPAL
═══════════════════════════════════════════════════════════════════

Ponto de entrada do sistema com acesso a todas funcionalidades.

2.1 OPCOES DO MENU PRINCIPAL

[Para conteúdo detalhado, use ? no menu]

1 - Atualizar Programa(s)
2 - Atualizar Biblioteca
3 - Versao do IsCOBOL
4 - Versao do Linux
5 - Ferramentas
9 - Sair do Sistema

═══════════════════════════════════════════════════════════════════
3. ATUALIZACAO DE PROGRAMAS
═══════════════════════════════════════════════════════════════════

3.1 PROGRAMAS ONLINE

Atualiza programas diretamente do servidor SAV.

PASSO A PASSO:
1. Menu Principal > 1 > 1
2. Informe nome do programa (MAIUSCULAS)
3. Escolha tipo compilacao (1=Normal, 2=Debug)
4. Repita para até 6 programas
5. ENTER para finalizar
6. Aguarde download e instalacao

EXEMPLO PRATICO:
Nome do programa: CADCLI [ENTER]
Tipo de compilacao: 1 [ENTER]
Nome do programa: CADFOR [ENTER]
Tipo de compilacao: 2 [ENTER]
Nome do programa: [ENTER - finaliza]

3.2 PROGRAMAS OFFLINE

Para ambientes sem conexao com servidor.

PREPARACAO:
1. Copie arquivos .zip para diretório offline
2. Arquivos devem seguir padrao: [PROG]-class[VER].zip

PROCESSO:
1. Menu Principal > 1 > 2
2. Informe programas (igual modo online)
3. Sistema busca em diretório offline
4. Instala programas encontrados

3.3 PROGRAMAS EM PACOTE

Atualizacao em massa através de pacotes pré-definidos.

VANTAGENS:
• Mais rápido
• Garante compatibilidade
• Menos propenso a erros

PROCESSO:
Similar ao online/offline, mas usa nome do pacote.

3.4 REVERTER PROGRAMA

Volta programa para versao anterior usando backup automático.

QUANDO USAR:
• Problema após atualizacao
• Incompatibilidade detectada
• Necessidade de versao específica

LIMITACAO:
Apenas último backup disponível (última atualizacao).

═══════════════════════════════════════════════════════════════════
4. ATUALIZACAO DE BIBLIOTECA
═══════════════════════════════════════════════════════════════════

Atualizacao completa do sistema, incluindo todos programas,
telas, configurações XML e componentes auxiliares.

4.1 QUANDO ATUALIZAR BIBLIOTECA

OBRIGATORIO:
• Mudança de versao principal do sistema
• Orientacao do suporte técnico
• Correções críticas de segurança

RECOMENDADO:
• Atualizações mensais
• Novos recursos disponíveis
• Performance degradada

EVITAR:
• Horário comercial (usar noite/fim de semana)
• Sem backup recente
• Problemas nao resolvidos

4.2 TIPOS DE BIBLIOTECA

TRANSPC:
Biblioteca de transporte e comunicacao

SAVATU:
Biblioteca principal do sistema SAV
• Mais comum
• Mais abrangente
• Usado na maioria das atualizações

4.3 PROCESSO DE ATUALIZACAO

PREPARACAO:
1. Fazer backup completo
2. Verificar espaço em disco (5GB mínimo)
3. Avisar usuários (sistema ficará indisponível)
MANUAL_EOF

_mensagec "${GREEN}" "Manual padrao criado em: $MANUAL_FILE"
}

#---------- ATALHO RAPIDO DE AJUDA ----------#

# Exibe menu rápido de ajuda
_ajuda_rapida() {
    clear
    _linha "=" "${CYAN}"
    _mensagec "${CYAN}" "AJUDA RAPIDA"
    _linha "=" "${CYAN}"
    printf "\n"
    
    cat << EOF 
COMANDOS DE AJUDA:
───────────────────────────────────────────────────────────────────
? ou help    = Ajuda contextual do menu atual
M ou manual  = Manual completo do sistema

NAVEGACAO:
───────────────────────────────────────────────────────────────────
[Numero]     = Selecionar opcao
9            = Voltar ao menu anterior
Ctrl+C       = Cancelar operacao
ENTER        = Confirmar ou usar padrao

CONFIRMACOES:
───────────────────────────────────────────────────────────────────
S ou s       = Sim
N ou n       = Nao
ENTER vazio  = Usa valor padrao [indicado em maiúscula]

DICAS:
───────────────────────────────────────────────────────────────────
• Nomes de programas sempre em MAIÚSCULAS
• Leia mensagens com atencao
• Faça backup antes de atualizações importantes
• Em caso de dúvida, consulte o manual completo

SUPORTE:
───────────────────────────────────────────────────────────────────
Email: suporte@sav.com.br
Horário: Segunda a Sexta, 8h às 18h
EOF
    
    printf "\n"
    _press
}

#---------- BUSCA NO MANUAL ----------#

# Busca termo no manual
# Parametros opcionais nao utilizados; sempre solicita termo ao usuario
_buscar_manual() {
    local termo=""
    
    read -rp "${YELLOW}Termo para buscar: ${NORM}" termo
    
    if [[ -z "$termo" ]]; then
        _mensagec "${RED}" "Nenhum termo informado"
        return 1
    fi
    
    if [[ ! -f "$MANUAL_FILE" ]]; then
        _criar_manual_padrao
    fi
    
    clear
    _linha "=" "${CYAN}"
    _mensagec "${CYAN}" "RESULTADOS DA BUSCA: $termo"
    _linha "=" "${CYAN}"
    printf "\n"
    
    # Buscar e destacar resultados
    if grep -in "$termo" "$MANUAL_FILE"; then
        printf "\n"
        _mensagec "${GREEN}" "Busca concluída"
    else
        _mensagec "${YELLOW}" "Nenhum resultado encontrado para: $termo"
    fi
    
    printf "\n"
    _press
    
}

#---------- EXPORTAR MANUAL ----------#

# Exporta manual para arquivo externo
_exportar_manual() {
    local destino="${1:-$HOME/manual_sav.txt}"
    
    if [[ ! -f "$MANUAL_FILE" ]]; then
        _criar_manual_padrao
    fi
    
    if cp "$MANUAL_FILE" "$destino"; then
        _mensagec "${GREEN}" "Manual exportado para: $destino"
    else
        _mensagec "${RED}" "Erro ao exportar manual"
        return 1
    fi
    
    _press
}

#---------- MENU PRINCIPAL DE AJUDA ----------#

# Menu principal do sistema de ajuda
_menu_ajuda_principal() {
    while true; do
        clear
        _linha "=" "${CYAN}"
        _mensagec "${CYAN}" "SISTEMA DE AJUDA"
        _linha "=" "${CYAN}"
        printf "\n"
        
        printf "%s\n" "${GREEN}1${NORM} - Manual Completo"
        printf "%s\n" "${GREEN}2${NORM} - Ajuda Rápida"
        printf "%s\n" "${GREEN}3${NORM} - Buscar no Manual"
        printf "%s\n" "${GREEN}4${NORM} - Exportar Manual"
        printf "%s\n" "${GREEN}5${NORM} - Ajuda por Contexto"
        printf "\n"
        printf "%s\n" "${GREEN}9${NORM} - Voltar"
        printf "\n"
        _linha "=" "${CYAN}"
        
        local opcao
        read -rp "${YELLOW}Opcao: ${NORM}" opcao
        
        case "$opcao" in
            1) _exibir_manual_completo ;;
            2) _ajuda_rapida ;;
            3) _buscar_manual ;;
            4) _exportar_manual ;;
            5) _menu_selecao_contexto ;;
            9) return ;;
            *)
                _mensagec "${RED}" "Opcao inválida"
                sleep 1
                ;;
        esac
    done
}

# Menu para selecionar contexto de ajuda
_menu_selecao_contexto() {
    clear
    _linha "=" "${CYAN}"
    _mensagec "${CYAN}" "SELECIONE O CONTEXTO"
    _linha "=" "${CYAN}"

    printf "\n"
    printf "%s\n" "${GREEN}1${NORM} - Menu Principal"
    printf "%s\n" "${GREEN}2${NORM} - Programas"
    printf "%s\n" "${GREEN}3${NORM} - Biblioteca"
    printf "%s\n" "${GREEN}4${NORM} - Ferramentas"
    printf "%s\n" "${GREEN}5${NORM} - Temporarios"
    printf "%s\n" "${GREEN}6${NORM} - Recuperacao"
    printf "%s\n" "${GREEN}7${NORM} - Backup"
    printf "%s\n" "${GREEN}8${NORM} - Transferencia"
    printf "%s\n" "${GREEN}9${NORM} - Setups"
    printf "%s\n" "${GREEN}10${NORM} - Lembretes"
    printf "\n"
    _linha "=" "${CYAN}"
    
    local opcao
    read -rp "${YELLOW}Opcao: ${NORM}" opcao
    
    case "$opcao" in
        1) _exibir_ajuda_contextual "principal" ;;
        2) _exibir_ajuda_contextual "programas" ;;
        3) _exibir_ajuda_contextual "biblioteca" ;;
        4) _exibir_ajuda_contextual "ferramentas" ;;
        5) _exibir_ajuda_contextual "temporarios" ;;
        6) _exibir_ajuda_contextual "recuperacao" ;;
        7) _exibir_ajuda_contextual "backup" ;;
        8) _exibir_ajuda_contextual "transferencia" ;;
        9) _exibir_ajuda_contextual "setups" ;;
        10) _exibir_ajuda_contextual "lembretes" ;;
        *) _mensagec "${RED}" "Opcao inválida" ; sleep 1 ;;
    esac
}