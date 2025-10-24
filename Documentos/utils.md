# Documentação do Módulo utils.sh

## Visão Geral
O módulo `utils.sh` é responsável pelas **funções utilitárias fundamentais** do **Sistema SAV (Script de Atualização Modular)**. Este módulo centraliza todas as funções básicas de formatação, validação, controle de fluxo e interface que são utilizadas por todos os outros módulos do sistema.

## Funcionalidades Principais

### 1. Sistema de Formatação de Tela
- **Posicionamento avançado** de texto no terminal
- **Sistema de cores responsivo** com detecção automática
- **Linhas horizontais** personalizáveis
- **Mensagens centralizadas** e alinhadas

### 2. Controle de Fluxo
- **Pausas controladas** com timeout
- **Tratamento de entrada** do usuário
- **Validações robustas** de dados
- **Confirmações interativas** S/N

### 3. Sistema de Validação
- **Validação de nomes** de programas
- **Verificação de diretórios** e arquivos
- **Validação de formato** de datas e versões
- **Controle de configuração** do sistema

### 4. Interface Interativa
- **Entrada com validação** automática
- **Sistema de retry** com limite de tentativas
- **Barra de progresso** com spinner animado
- **Feedback visual** durante operações

### 5. Sistema de Logs
- **Registro estruturado** com timestamp
- **Logs categorizados** (erro, sucesso, informação)
- **Múltiplos arquivos** de log suportados
- **Integração automática** com operações

## Estrutura do Código

### Funções de Formatação de Tela

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
Cria linha horizontal com caractere customizável.

```bash
_linha() {
    local Traco=${1:-'-'}  # Caractere padrão: '-'
    local CCC="${2:-}"     # Cor opcional
    local Espacos
    
    printf -v Espacos "%$(tput cols)s" ""
    linhas=${Espacos// /$Traco}
    printf "%s%*s\n" "${CCC}" $(((${#linhas} + COLUMNS) / 2)) "$linhas"
}
```

## Controle de Fluxo

### `_read_sleep()` - Pausa Controlada
Pausa execução por tempo especificado.

```bash
_read_sleep() {
    if [[ -z "${1}" ]]; then
        printf "Erro: Nenhum argumento passado para _read_sleep.\n"
        return 1
    fi

    if ! [[ "${1}" =~ ^[0-9.]+$ ]]; then
        printf "Erro: Argumento inválido para _read_sleep: %s\n" "${1}"
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

### `_opinvalida()` - Opção Inválida
Mensagem padronizada para opção inválida.

```bash
_opinvalida() {
    _linha
    _mensagec "${RED}" "Opção Inválida"
    _linha
}
```

## Sistema de Validação

### Validações Básicas

#### `_validar_nome_programa()`
Valida nomes de programa (maiúsculas e números).

```bash
_validar_nome_programa() {
    local programa="$1"
    [[ -n "$programa" && "$programa" =~ ^[A-Z0-9]+$ ]]
}
```

#### `_validar_diretorio()`
Valida existência e acessibilidade de diretório.

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
Valida formato de versão numérica.

```bash
_validar_versao() {
    local versao="$1"
    [[ -n "$versao" && "$versao" =~ ^[0-9]+([.-][0-9]+)*$ ]]
}
```

### Validação Completa do Sistema

#### `_validar_configuracao_sistema()`
Validação abrangente da configuração do sistema.

**Verificações realizadas:**
1. **Arquivos de configuração** (`.atualizac`)
2. **Variáveis essenciais** (`sistema`, `destino`, `pasta`)
3. **Diretórios críticos** (exec, telas, logs, backup, etc.)
4. **Contagem de erros** para relatório final

```bash
_validar_configuracao_sistema() {
    local erros=0
    
    # Verificar arquivos de configuração
    if [[ ! -f "${LIB_CFG}/.atualizac" ]]; then
        _log_erro "Arquivo .atualizac não encontrado"
        ((erros++))
    fi
    
    # Verificar variáveis essenciais
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
Entrada interativa com validação automática.

**Características:**
- **Função de validação** customizável
- **Número máximo de tentativas** (3 por padrão)
- **Mensagem de erro** personalizável
- **Suporte a entrada vazia** (ENTER)

```bash
_solicitar_entrada() {
    local prompt="$1"
    local funcao_validacao="$2"
    local mensagem_erro="${3:-Entrada inválida}"
    local entrada
    local tentativas=0
    local max_tentativas=3
    
    while (( tentativas < max_tentativas )); do
        read -rp "${YELLOW}${prompt}: ${NORM}" entrada
        
        # Validação usando função fornecida
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
Solicitação de confirmação S/N com padrão configurável.

**Características:**
- **Padrão configurável** (S/N)
- **Múltiplas formas de resposta** (s/n, sim/não, y/n, yes/no)
- **Recursão automática** para respostas inválidas
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
        n|nao|não|no) return 1 ;;
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
Sistema avançado de progresso com spinner animado.

**Características:**
- **Spinner animado** com 10 caracteres diferentes
- **Contador de tempo** decorrido
- **Controle de cursor** (ocultar/mostrar)
- **Detecção automática** de conclusão do processo
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
    tput sc     # Salvar posição
    
    while kill -0 "$pid" 2>/dev/null; do
        tput rc  # Restaurar posição
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

### `_log()` - Log Básico
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
Registro específico de erros.

```bash
_log_erro() {
    local erro="$1"
    local arquivo_log="${2:-$LOG_ATU}"
    _log "ERRO: $erro" "$arquivo_log"
}
```

### `_log_sucesso()` - Log de Sucesso
Registro específico de operações bem-sucedidas.

```bash
_log_sucesso() {
    local sucesso="$1"
    local arquivo_log="${2:-$LOG_ATU}"
    _log "SUCESSO: $sucesso" "$arquivo_log"
}
```

## Formatação de Dados

### `_formatar_tamanho()`
Converte bytes para formato legível.

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
Converte segundos para formato legível.

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

## Funções de Sistema

### `_info_sistema()`
Coleta informações básicas do sistema.

```bash
_info_sistema() {
    echo "OS: $(uname -s)"
    echo "Versao: $(uname -r)"
    echo "Arquitetura: $(uname -m)"
    echo "Hostname: $(hostname)"
    echo "Usuário: $(whoami)"
    echo "Diretório: $(pwd)"
}
```

### `_espaco_livre()`
Verifica espaço disponível em disco.

```bash
_espaco_livre() {
    local caminho="${1:-.}"
    df -m "$caminho" | awk 'NR==2 {print $4}'
}
```

### `_verificar_espaco()`
Valida se há espaço suficiente.

```bash
_verificar_espaco() {
    local caminho="$1"
    local necessario="$2"
    local livre=$(_espaco_livre "$caminho")
    (( livre >= necessario ))
}
```

## Gestão de Arquivos

### `_backup_arquivo()`
Cria backup de arquivo com timestamp.

```bash
_backup_arquivo() {
    local arquivo="$1"
    local dir_backup="${2:-${backup:-./backup}}"
    local nome_base=$(basename "$arquivo")
    local extensao=""
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    
    # Extrair extensão se existir
    if [[ "$nome_base" == *.* ]]; then
        extensao=".${nome_base##*.}"
        nome_base="${nome_base%.*}"
    fi
    
    local arquivo_backup="${dir_backup}/${nome_base}_${timestamp}${extensao}"
    
    if cp "$arquivo" "$arquivo_backup"; then
        _log_sucesso "Backup criado: $arquivo_backup"
        echo "$arquivo_backup"
        return 0
    fi
}
```

### `_limpar_arquivos_antigos()`
Remove arquivos antigos baseado em critérios.

```bash
_limpar_arquivos_antigos() {
    local diretorio="$1"
    local dias="$2"
    local padrao="${3:-*}"
    
    if [[ ! -d "$diretorio" ]]; then
        _log_erro "Diretório não encontrado: $diretorio"
        return 1
    fi
    
    local count=$(find "$diretorio" -name "$padrao" -type f -mtime +"$dias" -print | wc -l)
    
    if (( count > 0 )); then
        find "$diretorio" -name "$padrao" -type f -mtime +"$dias" -delete
    fi
}
```

## Inicialização Automática

### `_executar_expurgador_diario()`
Limpeza automática diária do sistema.

**Características:**
- **Controle de flag** para evitar múltiplas execuções
- **Limpeza de flags antigas** (>3 dias)
- **Processamento de múltiplos diretórios**
- **Logs de execução** para auditoria

```bash
_executar_expurgador_diario() {
    local flag_file="${LOGS}/.expurgador_$(date +%Y%m%d)"
    
    # Controle de execução única por dia
    if [[ -f "$flag_file" ]]; then
        return 0
    fi
    
    # Limpeza de diferentes diretórios
    _limpar_arquivos_antigos "${LOGS}" 30 "*.log"
    _limpar_arquivos_antigos "${backup}" 30 "Temps*"
    # ... demais diretórios
    
    touch "$flag_file"
}
```

### `_check_instalado()`
Verificação de dependências essenciais.

**Programas verificados:**
- **zip/unzip** - Compactação de arquivos
- **rsync** - Sincronização remota
- **wget** - Download de arquivos

```bash
_check_instalado() {
    local missing=""
    for app in zip unzip rsync wget; do
        if ! command -v "$app" &>/dev/null; then
            missing="$missing $app"
            # Mensagens específicas por aplicativo
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

## Características de Segurança

### Validações de Segurança
- **Verificação rigorosa** de entradas do usuário
- **Validação de caminhos** antes de operações
- **Controle de permissões** em arquivos e diretórios
- **Tratamento seguro** de variáveis de ambiente

### Tratamento Seguro de Terminal
- **Controle de cursor** durante operações longas
- **Restauração de estado** do terminal
- **Detecção de suporte** a recursos avançados
- **Fallback automático** para terminais simples

## Boas Práticas Implementadas

### Organização do Código
- **Funções atômicas** com responsabilidades únicas
- **Parâmetros bem documentados** com exemplos
- **Tratamento uniforme** de erros e validações
- **Comentários claros** sobre lógica complexa

### Performance
- **Operações eficientes** com comandos otimizados
- **Controle mínimo** de recursos durante execução
- **Processamento assíncrono** quando apropriado
- **Cache inteligente** de informações do sistema

### Manutenibilidade
- **Funções reutilizáveis** em todos os módulos
- **Interface consistente** em todas as funções
- **Documentação inline** clara
- **Tratamento robusto** de diferentes cenários

## Exemplos de Uso

### Formatação de Tela
```bash
# Mensagem centralizada
_mensagec "${RED}" "Erro crítico"

# Linha horizontal
_linha "=" "${GREEN}"

# Mensagem à direita
_mensaged "${BLUE}" "Versão 2024"
```

### Controle de Fluxo
```bash
# Pausa de 3 segundos
_read_sleep 3

# Aguardar tecla
_press

# Confirmação
if _confirmar "Deseja continuar?" "S"; then
    echo "Continuando..."
fi
```

### Validação de Dados
```bash
# Validar nome de programa
if _validar_nome_programa "PROGRAMA01"; then
    echo "Nome válido"
fi

# Validar diretório
if _validar_diretorio "/sav/dados"; then
    echo "Diretório válido"
fi
```

### Sistema de Progresso
```bash
# Barra de progresso simples
_barra_progresso 50 100 20

# Progresso avançado com spinner
_mostrar_progresso_backup $pid_processo
```

### Sistema de Logs
```bash
# Logs categorizados
_log "Operação iniciada"
_log_erro "Falha na operação"
_log_sucesso "Operação concluída"
```

## Integração com o Sistema

### Dependências de Módulos
- **Nenhuma dependência externa** - módulo base
- **Utilizado por todos os módulos** do sistema
- **Carregado automaticamente** pelo `principal.sh`

### Variáveis de Ambiente Utilizadas
- `COLUMNS` - Largura do terminal
- `LOG_ATU` - Arquivo de log padrão
- `backup` - Diretório de backup
- `LOGS` - Diretório de logs
- `TOOLS` - Diretório de ferramentas

## Características Avançadas

### Terminal Responsivo
```bash
# Detecção automática de recursos
if [[ -t 1 ]] && command -v tput >/dev/null 2>&1; then
    # Terminal avançado - usar recursos completos
    RED=$(tput bold)$(tput setaf 1)
    COLUMNS=$(tput cols)
else
    # Terminal básico - variáveis vazias
    RED="" COLUMNS=80
fi
```

### Controle Inteligente de Cursor
```bash
# Durante operações longas
tput civis  # Ocultar cursor
# ... operação ...
tput cnorm  # Mostrar cursor
tput sgr0   # Reset terminal
```

### Formatação Dinâmica
```bash
# Centralização baseada na largura do terminal
printf "%s%*s%s\n" "${color}" $(((${#message} + $(tput cols)) / 2)) "${message}" "${NORM}"
```

## Tratamento de Erros

### Estratégias Implementadas
- **Validação prévia** de todos os parâmetros
- **Mensagens específicas** para diferentes tipos de erro
- **Recuperação automática** quando possível
- **Logs detalhados** para auditoria

### Códigos de Retorno
- `0` - Sucesso
- `1` - Erro de parâmetro ou validação
- `1` - Falha na operação

## Considerações de Performance

### Otimizações
- **Cálculos eficientes** de posicionamento
- **Controle mínimo** de I/O durante formatação
- **Cache de informações** do terminal
- **Processamento direto** sem loops desnecessários

### Recursos de Sistema
- **CPU mínima** durante operações simples
- **Memória controlada** com variáveis locais
- **I/O otimizado** com redirecionamento adequado

## Debugging e Desenvolvimento

### Estratégias para Debug
- **Teste visual** de formatação em diferentes terminais
- **Validação de funções** individualmente
- **Logs detalhados** durante desenvolvimento
- **Teste de edge cases** (terminais pequenos/grandes)

### Diagnóstico de Problemas
```bash
# Verificar suporte a cores
echo "Cores suportadas: $(tput colors 2>/dev/null || echo 'não')"

# Verificar tamanho do terminal
echo "Terminal: $(tput cols)x$(tput lines)"

# Testar funções específicas
_mensagec "${GREEN}" "Teste de mensagem"
_linha "=" "${BLUE}"
```

## Casos de Uso Comuns

### Interface de Usuário
```bash
# Formatação típica de menu
_linha "=" "${GREEN}"
_mensagec "${RED}" "Título do Menu"
_linha
_mensagec "${CYAN}" "Opções disponíveis:"
_mensagec "${GREEN}" "1 - Opção 1"
_mensagec "${GREEN}" "2 - Opção 2"
_linha "=" "${GREEN}"
```

### Controle de Operações Longas
```bash
# Durante backup ou sincronização
_mostrar_progresso_backup $pid_processo &
# Processo em background
wait $pid_processo
```

### Validação de Entrada
```bash
# Solicitar entrada com validação
versao=$(_solicitar_entrada "Digite a versão" "_validar_versao" "Versão inválida")
```

### Confirmações Importantes
```bash
# Antes de operações críticas
if _confirmar "Deseja excluir arquivos antigos?" "N"; then
    _limpar_arquivos_antigos "/caminho" 30
fi
```

## Integração com o Sistema

### Fluxo de Inicialização
```
utils.sh → config.sh → validações → formatação → sistema operacional
```

### Utilização Universal
- **Todas as funções** são utilizadas por outros módulos
- **Interface consistente** em todo o sistema
- **Dependência zero** de módulos externos

---

*Documentação gerada automaticamente com base no código fonte e práticas de bash scripting.*