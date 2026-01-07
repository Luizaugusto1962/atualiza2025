# Documentacao do Modulo utils.sh

## Visao Geral
O modulo `utils.sh` e responsavel pelas **funcoes utilitarias fundamentais** do **Sistema SAV (Script de Atualizacao Modular)**. Este modulo centraliza todas as funcoes basicas de formatacao, validacao, controle de fluxo e interface que sao utilizadas por todos os outros modulos do sistema.

## Funcionalidades Principais

### 1. Sistema de Formatacao de Tela
- **Posicionamento avancado** de texto no terminal
- **Sistema de cores responsivo** com deteccao automatica
- **Linhas horizontais** personalizaveis
- **Mensagens centralizadas** e alinhadas

### 2. Controle de Fluxo
- **Pausas controladas** com timeout
- **Tratamento de entrada** do usuario
- **Validacoes robustas** de dados
- **Confirmacoes interativas** S/N

### 3. Sistema de Validacao
- **Validacao de nomes** de programas
- **Verificacao de diretorios** e arquivos
- **Validacao de formato** de datas e versoes
- **Controle de configuracao** do sistema

### 4. Interface Interativa
- **Entrada com validacao** automatica
- **Sistema de retry** com limite de tentativas
- **Barra de progresso** com spinner animado
- **Feedback visual** durante operacoes

### 5. Sistema de Logs
- **Registro estruturado** com timestamp
- **Logs categorizados** (erro, sucesso, informacao)
- **Múltiplos arquivos** de log suportados
- **Integracao automatica** com operacoes

## Estrutura do Codigo

### Funcoes de Formatacao de Tela

#### `_meiodatela()`
Posiciona cursor no centro da tela.

```bash
# Posicionamento ANSI
printf "\033c\033[10;10H\n"
```

#### `_mensagec()` - Mensagem Centralizada
Centraliza mensagem no terminal com cor.

```bash
_mensagec() {
    local color="${1}"
    local message="${2}"
    printf "%s%*s%s\n" "${color}" $(((${#message} + $(tput cols)) / 2)) "${message}" "${NORM}"
}
```

#### `_mensaged()` - Mensagem Alinhada à Direita
Alinha mensagem à direita do terminal.

```bash
_mensaged() {
    local color="${1}"
    local mensagem="${2}"
    local largura_terminal=$(tput cols)
    local largura_mensagem=${#mensagem}
    local posicao_inicio=$((largura_terminal - largura_mensagem))
    
    printf "%s%*s%s${NORM}\n" "${color}" "${posicao_inicio}" "" "$mensagem"
}
```

#### `_linha()` - Linha Horizontal
Cria linha horizontal com caractere customizavel.

```bash
_linha() {
    local Traco=${1:-'-'}  # Caractere padrao: '-'
    local CCC="${2:-}"     # Cor opcional
    local Espacos
    
    printf -v Espacos "%$(tput cols)s" ""
    linhas=${Espacos// /$Traco}
    printf "%s%*s\n" "${CCC}" $(((${#linhas} + COLUMNS) / 2)) "$linhas"
}
```

## Controle de Fluxo

### `_read_sleep()` - Pausa Controlada
Pausa execucao por tempo especificado.

```bash
_read_sleep() {
    if [[ -z "${1}" ]]; then
        printf "Erro: Nenhum argumento passado para _read_sleep.\n"
        return 1
    fi

    if ! [[ "${1}" =~ ^[0-9.]+$ ]]; then
        printf "Erro: Argumento invalido para _read_sleep: %s\n" "${1}"
        return 1
    fi

    read -rt "${1}" <> <(:) || :
}
```

### `_press()` - Aguardar Tecla
Aguarda pressionar qualquer tecla com timeout.

```bash
_press() {
    printf "%s%*s\n" "${YELLOW}" $(((36 + COLUMNS) / 2)) "<< ... Pressione qualquer tecla para continuar ... >>"
    read -rt 15 || :  # Timeout de 15 segundos
}
```

### `_opinvalida()` - Opcao Invalida
Mensagem padronizada para opcao invalida.

```bash
_opinvalida() {
    _linha
    _mensagec "${RED}" "Opcao Invalida"
    _linha
}
```

## Sistema de Validacao

### Validacoes Basicas

#### `_validar_nome_programa()`
Valida nomes de programa (maiúsculas e números).

```bash
_validar_nome_programa() {
    local programa="$1"
    [[ -n "$programa" && "$programa" =~ ^[A-Z0-9]+$ ]]
}
```

#### `_validar_diretorio()`
Valida existência e acessibilidade de diretorio.

```bash
_validar_diretorio() {
    local dir="$1"
    [[ -n "$dir" && -d "$dir" && -r "$dir" ]]
}
```

#### `_validar_arquivo()`
Valida existência e legibilidade de arquivo.

```bash
_validar_arquivo() {
    local arquivo="$1"
    [[ -n "$arquivo" && -f "$arquivo" && -r "$arquivo" ]]
}
```

#### `_validar_data()`
Valida formato de data (DD-MM-AAAA).

```bash
_validar_data() {
    local data="$1"
    [[ "$data" =~ ^[0-9]{2}-[0-9]{2}-[0-9]{4}$ ]]
}
```

#### `_validar_versao()`
Valida formato de versao numerica.

```bash
_validar_versao() {
    local versao="$1"
    [[ -n "$versao" && "$versao" =~ ^[0-9]+([.-][0-9]+)*$ ]]
}
```

### Validacao Completa do Sistema

#### `_validar_configuracao_sistema()`
Validacao abrangente da configuracao do sistema.

**Verificacoes realizadas:**
1. **Arquivos de configuracao** (`.atualizac`)
2. **Variaveis essenciais** (`sistema`, `destino`, `pasta`)
3. **Diretorios criticos** (exec, telas, logs, backup, etc.)
4. **Contagem de erros** para relatorio final

```bash
_validar_configuracao_sistema() {
    local erros=0
    
    # Verificar arquivos de configuracao
    if [[ ! -f "${cfg_dir}/.atualizac" ]]; then
        _log_erro "Arquivo .atualizac nao encontrado"
        ((erros++))
    fi
    
    # Verificar variaveis essenciais
    if [[ -z "${sistema}" ]]; then
        _log_erro "Variavel 'sistema' nao definida"
        ((erros++))
    fi
    
    # Retorno baseado em erros encontrados
    return $(( erros > 0 ? 1 : 0 ))
}
```

## Sistema de Entrada de Dados

### `_solicitar_entrada()`
Entrada interativa com validacao automatica.

**Caracteristicas:**
- **Funcao de validacao** customizavel
- **Número maximo de tentativas** (3 por padrao)
- **Mensagem de erro** personalizavel
- **Suporte a entrada vazia** (ENTER)

```bash
_solicitar_entrada() {
    local prompt="$1"
    local funcao_validacao="$2"
    local mensagem_erro="${3:-Entrada invalida}"
    local entrada
    local tentativas=0
    local max_tentativas=3
    
    while (( tentativas < max_tentativas )); do
        read -rp "${YELLOW}${prompt}: ${NORM}" entrada
        
        # Validacao usando funcao fornecida
        if [[ -n "$funcao_validacao" ]]; then
            if "$funcao_validacao" "$entrada"; then
                echo "$entrada"
                return 0
            else
                _mensagec "${RED}" "$mensagem_erro"
                ((tentativas++))
            fi
        else
            echo "$entrada"
            return 0
        fi
    done
    
    return 1
}
```

### `_confirmar()`
Solicitacao de confirmacao S/N com padrao configuravel.

**Caracteristicas:**
- **Padrao configuravel** (S/N)
- **Múltiplas formas de resposta** (s/n, sim/nao, y/n, yes/no)
- **Recursao automatica** para respostas invalidas
- **Case insensitive**

```bash
_confirmar() {
    local mensagem="$1"
    local padrao="${2:-N}"
    local opcoes
    local resposta
    
    case "$padrao" in
        [Ss]) opcoes="[S/n]" ;;
        [Nn]) opcoes="[N/s]" ;;
        *) opcoes="[S/N]" ;;
    esac
    
    read -rp "${YELLOW}${mensagem} ${opcoes}: ${NORM}" resposta
    
    case "${resposta,,}" in
        s|sim|y|yes) return 0 ;;
        n|nao|nao|no) return 1 ;;
        *) _confirmar "$mensagem" "$padrao" ;;
    esac
}
```

## Sistema de Progresso

### `_barra_progresso()`
Barra de progresso simples baseada em porcentagem.

```bash
_barra_progresso() {
    local atual="$1"
    local total="$2"
    local largura="${3:-20}"
    local percent=$(( atual * 100 / total ))
    local preenchido=$(( percent * largura / 100 ))
    local vazio=$(( largura - preenchido ))
    
    barra=$(printf "%${preenchido}s" | tr ' ' '#')
    barra+=$(printf "%${vazio}s" | tr ' ' '-')
    
    printf "\r${YELLOW}[%s] %d%%${NORM}" "$barra" "$percent"
}
```

### `_mostrar_progresso_backup()`
Sistema avancado de progresso com spinner animado.

**Caracteristicas:**
- **Spinner animado** com 10 caracteres diferentes
- **Contador de tempo** decorrido
- **Controle de cursor** (ocultar/mostrar)
- **Deteccao automatica** de conclusao do processo
- **Feedback visual** colorido

```bash
_mostrar_progresso_backup() {
    local pid="$1"
    local delay=0.2
    local spin=( '⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏' )
    local i=0
    local elapsed=0
    
    # Controle de cursor
    tput civis  # Ocultar cursor
    tput sc     # Salvar posicao
    
    while kill -0 "$pid" 2>/dev/null; do
        tput rc  # Restaurar posicao
        printf "${YELLOW}%s... [%3ds] ${NORM}${GREEN}%s${NORM}" \
            "$msg" "$elapsed" "${spin[i]}"
        ((i = (i + 1) % ${#spin[@]}))
        ((elapsed += 1))
        sleep "$delay"
    done
    
    tput cnorm  # Mostrar cursor
}
```

## Sistema de Logs

### `_log()` - Log Basico
Registro estruturado com timestamp.

```bash
_log() {
    local mensagem="$1"
    local arquivo_log="${2:-$LOG_ATU}"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $mensagem" >> "$arquivo_log" 2>/dev/null
}
```

### `_log_erro()` - Log de Erro
Registro especifico de erros.

```bash
_log_erro() {
    local erro="$1"
    local arquivo_log="${2:-$LOG_ATU}"
    _log "ERRO: $erro" "$arquivo_log"
}
```

### `_log_sucesso()` - Log de Sucesso
Registro especifico de operacoes bem-sucedidas.

```bash
_log_sucesso() {
    local sucesso="$1"
    local arquivo_log="${2:-$LOG_ATU}"
    _log "SUCESSO: $sucesso" "$arquivo_log"
}
```

## Formatacao de Dados

### `_formatar_tamanho()`
Converte bytes para formato legivel.

```bash
_formatar_tamanho() {
    local tamanho="$1"
    local unidades=('B' 'KB' 'MB' 'GB' 'TB')
    local unidade=0
    
    while (( tamanho >= 1024 && unidade < ${#unidades[@]} - 1 )); do
        tamanho=$(( tamanho / 1024 ))
        ((unidade++))
    done
    
    printf "%d %s" "$tamanho" "${unidades[$unidade]}"
}
```

### `_formatar_duracao()`
Converte segundos para formato legivel.

```bash
_formatar_duracao() {
    local segundos="$1"
    local horas=$(( segundos / 3600 ))
    local minutos=$(( (segundos % 3600) / 60 ))
    local segs=$(( segundos % 60 ))
    
    if (( horas > 0 )); then
        printf "%02d:%02d:%02d" "$horas" "$minutos" "$segs"
    elif (( minutos > 0 )); then
        printf "%02d:%02d" "$minutos" "$segs"
    else
        printf "%ds" "$segs"
    fi
}
```

## Funcoes de Sistema

### `_info_sistema()`
Coleta informacoes basicas do sistema.

```bash
_info_sistema() {
    echo "OS: $(uname -s)"
    echo "Versao: $(uname -r)"
    echo "Arquitetura: $(uname -m)"
    echo "Hostname: $(hostname)"
    echo "Usuario: $(whoami)"
    echo "Diretorio: $(pwd)"
}
```

### `_espaco_livre()`
Verifica espaco disponivel em disco.

```bash
_espaco_livre() {
    local caminho="${1:-.}"
    df -m "$caminho" | awk 'NR==2 {print $4}'
}
```

### `_verificar_espaco()`
Valida se ha espaco suficiente.

```bash
_verificar_espaco() {
    local caminho="$1"
    local necessario="$2"
    local livre=$(_espaco_livre "$caminho")
    (( livre >= necessario ))
}
```

## Gestao de Arquivos

### `_backup_arquivo()`
Cria backup de arquivo com timestamp.

```bash
_backup_arquivo() {
    local arquivo="$1"
    local dir_backup="${2:-${backup:-./backup}}"
    local nome_base=$(basename "$arquivo")
    local extensao=""
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    
    # Extrair extensao se existir
    if [[ "$nome_base" == *.* ]]; then
        extensao=".${nome_base##*.}"
        nome_base="${nome_base%.*}"
    fi
    
    local arquivo_backup="${BACKUP}/${nome_base}_${timestamp}${extensao}"
    
    if cp "$arquivo" "$arquivo_backup"; then
        _log_sucesso "Backup criado: $arquivo_backup"
        echo "$arquivo_backup"
        return 0
    fi
}
```

### `_limpar_arquivos_antigos()`
Remove arquivos antigos baseado em criterios.

```bash
_limpar_arquivos_antigos() {
    local diretorio="$1"
    local dias="$2"
    local padrao="${3:-*}"
    
    if [[ ! -d "$diretorio" ]]; then
        _log_erro "Diretorio nao encontrado: $diretorio"
        return 1
    fi
    
    local count=$(find "$diretorio" -name "$padrao" -type f -mtime +"$dias" -print | wc -l)
    
    if (( count > 0 )); then
        find "$diretorio" -name "$padrao" -type f -mtime +"$dias" -delete
    fi
}
```

## Inicializacao Automatica

### `_executar_expurgador_diario()`
Limpeza automatica diaria do sistema.

**Caracteristicas:**
- **Controle de flag** para evitar múltiplas execucoes
- **Limpeza de flags antigas** (>3 dias)
- **Processamento de múltiplos diretorios**
- **Logs de execucao** para auditoria

```bash
_executar_expurgador_diario() {
    local flag_file="${LOGS}/.expurgador_$(date +%Y%m%d)"
    
    # Controle de execucao única por dia
    if [[ -f "$flag_file" ]]; then
        return 0
    fi
    
    # Limpeza de diferentes diretorios
    _limpar_arquivos_antigos "${LOGS}" 30 "*.log"
    _limpar_arquivos_antigos "${backup}" 30 "Temps*"
    # ... demais diretorios
    
    touch "$flag_file"
}
```

### `_check_instalado()`
Verificacao de dependências essenciais.

**Programas verificados:**
- **zip/unzip** - Compactacao de arquivos
- **rsync** - Sincronizacao remota
- **wget** - Download de arquivos

```bash
_check_instalado() {
    local missing=""
    for app in zip unzip rsync wget; do
        if ! command -v "$app" &>/dev/null; then
            missing="$missing $app"
            # Mensagens especificas por aplicativo
            case "$app" in
                zip | unzip) echo "  Sugestao: Instale o zip, unzip." ;;
                rsync) echo "  Sugestao: Instale o rsync." ;;
                wget) echo "  Sugestao: Instale o wget." ;;
            esac
        fi
    done
    
    if [ -n "$missing" ]; then
        _mensagec "${YELLOW}" "Instale os programas ausentes ($missing) e tente novamente."
        exit 1
    fi
}
```

## Caracteristicas de Seguranca

### Validacoes de Seguranca
- **Verificacao rigorosa** de entradas do usuario
- **Validacao de caminhos** antes de operacoes
- **Controle de permissoes** em arquivos e diretorios
- **Tratamento seguro** de variaveis de ambiente

### Tratamento Seguro de Terminal
- **Controle de cursor** durante operacoes longas
- **Restauracao de estado** do terminal
- **Deteccao de suporte** a recursos avancados
- **Fallback automatico** para terminais simples

## Boas Praticas Implementadas

### Organizacao do Codigo
- **Funcoes atômicas** com responsabilidades únicas
- **Parametros bem documentados** com exemplos
- **Tratamento uniforme** de erros e validacoes
- **Comentarios claros** sobre logica complexa

### Performance
- **Operacoes eficientes** com comandos otimizados
- **Controle minimo** de recursos durante execucao
- **Processamento assincrono** quando apropriado
- **Cache inteligente** de informacoes do sistema

### Manutenibilidade
- **Funcoes reutilizaveis** em todos os modulos
- **Interface consistente** em todas as funcoes
- **Documentacao inline** clara
- **Tratamento robusto** de diferentes cenarios

## Exemplos de Uso

### Formatacao de Tela
```bash
# Mensagem centralizada
_mensagec "${RED}" "Erro critico"

# Linha horizontal
_linha "=" "${GREEN}"

# Mensagem à direita
_mensaged "${BLUE}" "Versao 2024"
```

### Controle de Fluxo
```bash
# Pausa de 3 segundos
_read_sleep 3

# Aguardar tecla
_press

# Confirmacao
if _confirmar "Deseja continuar?" "S"; then
    echo "Continuando..."
fi
```

### Validacao de Dados
```bash
# Validar nome de programa
if _validar_nome_programa "PROGRAMA01"; then
    echo "Nome valido"
fi

# Validar diretorio
if _validar_diretorio "/sav/dados"; then
    echo "Diretorio valido"
fi
```

### Sistema de Progresso
```bash
# Barra de progresso simples
_barra_progresso 50 100 20

# Progresso avancado com spinner
_mostrar_progresso_backup $pid_processo
```

### Sistema de Logs
```bash
# Logs categorizados
_log "Operacao iniciada"
_log_erro "Falha na operacao"
_log_sucesso "Operacao concluida"
```

## Integracao com o Sistema

### Dependências de Modulos
- **Nenhuma dependência externa** - modulo base
- **Utilizado por todos os modulos** do sistema
- **Carregado automaticamente** pelo `principal.sh`

### Variaveis de Ambiente Utilizadas
- `COLUMNS` - Largura do terminal
- `LOG_ATU` - Arquivo de log padrao
- `backup` - Diretorio de backup
- `LOGS` - Diretorio de logs
- `TOOLS_DIR` - Diretorio de ferramentas

## Caracteristicas Avancadas

### Terminal Responsivo
```bash
# Deteccao automatica de recursos
if [[ -t 1 ]] && command -v tput >/dev/null 2>&1; then
    # Terminal avancado - usar recursos completos
    RED=$(tput bold)$(tput setaf 1)
    COLUMNS=$(tput cols)
else
    # Terminal basico - variaveis vazias
    RED="" COLUMNS=80
fi
```

### Controle Inteligente de Cursor
```bash
# Durante operacoes longas
tput civis  # Ocultar cursor
# ... operacao ...
tput cnorm  # Mostrar cursor
tput sgr0   # Reset terminal
```

### Formatacao Dinamica
```bash
# Centralizacao baseada na largura do terminal
printf "%s%*s%s\n" "${color}" $(((${#message} + $(tput cols)) / 2)) "${message}" "${NORM}"
```

## Tratamento de Erros

### Estrategias Implementadas
- **Validacao previa** de todos os parametros
- **Mensagens especificas** para diferentes tipos de erro
- **Recuperacao automatica** quando possivel
- **Logs detalhados** para auditoria

### Codigos de Retorno
- `0` - Sucesso
- `1` - Erro de parametro ou validacao
- `1` - Falha na operacao

## Consideracoes de Performance

### Otimizacoes
- **Calculos eficientes** de posicionamento
- **Controle minimo** de I/O durante formatacao
- **Cache de informacoes** do terminal
- **Processamento direto** sem loops desnecessarios

### Recursos de Sistema
- **CPU minima** durante operacoes simples
- **Memoria controlada** com variaveis locais
- **I/O otimizado** com redirecionamento adequado

## Debugging e Desenvolvimento

### Estrategias para Debug
- **Teste visual** de formatacao em diferentes terminais
- **Validacao de funcoes** individualmente
- **Logs detalhados** durante desenvolvimento
- **Teste de edge cases** (terminais pequenos/grandes)

### Diagnostico de Problemas
```bash
# Verificar suporte a cores
echo "Cores suportadas: $(tput colors 2>/dev/null || echo 'nao')"

# Verificar tamanho do terminal
echo "Terminal: $(tput cols)x$(tput lines)"

# Testar funcoes especificas
_mensagec "${GREEN}" "Teste de mensagem"
_linha "=" "${BLUE}"
```

## Casos de Uso Comuns

### Interface de Usuario
```bash
# Formatacao tipica de menu
_linha "=" "${GREEN}"
_mensagec "${RED}" "Titulo do Menu"
_linha
_mensagec "${CYAN}" "Opcoes disponiveis:"
_mensagec "${GREEN}" "1 - Opcao 1"
_mensagec "${GREEN}" "2 - Opcao 2"
_linha "=" "${GREEN}"
```

### Controle de Operacoes Longas
```bash
# Durante backup ou sincronizacao
_mostrar_progresso_backup $pid_processo &
# Processo em background
wait $pid_processo
```

### Validacao de Entrada
```bash
# Solicitar entrada com validacao
versao=$(_solicitar_entrada "Digite a versao" "_validar_versao" "Versao invalida")
```

### Confirmacoes Importantes
```bash
# Antes de operacoes criticas
if _confirmar "Deseja excluir arquivos antigos?" "N"; then
    _limpar_arquivos_antigos "/caminho" 30
fi
```

## Integracao com o Sistema

### Fluxo de Inicializacao
```
utils.sh → config.sh → validacoes → formatacao → sistema operacional
```

### Utilizacao Universal
- **Todas as funcoes** sao utilizadas por outros modulos
- **Interface consistente** em todo o sistema
- **Dependência zero** de modulos externos

---

*Documentacao gerada automaticamente com base no codigo fonte e praticas de bash scripting.*