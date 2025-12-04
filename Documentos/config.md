# Documentacao do Modulo config.sh

## Visao Geral

O modulo `config.sh` e responsavel pela **configuracao completa e validacao** do **Sistema SAV (Script de Atualizacao Modular)**. Este modulo centraliza todas as variaveis de configuracao, valida o ambiente do sistema e estabelece as bases para o funcionamento de todos os outros modulos.

## Funcionalidades Principais

### 1. Gestao de Variaveis Globais

- **Arrays organizados** por categoria funcional
- **Variaveis de sistema** com valores padrao
- **Configuracoes de ambiente** personalizaveis
- **Heranca de variaveis** entre modulos

### 2. Sistema de Cores Avancado

- **Deteccao automatica** de suporte a cores no terminal
- **Definicao de paleta** completa (RED, GREEN, YELLOW, BLUE, PURPLE, CYAN)
- **Configuracao responsiva** baseada no terminal
- **Fallback automatico** para terminais sem suporte

### 3. Validacao de Ambiente

- **Verificacao de comandos** externos necessarios
- **Criacao automatica** de estrutura de diretorios
- **Validacao de permissoes** e acessos
- **Teste de conectividade** com servidores

### 4. Carregamento de Configuracoes

- **Arquivo `.atualizac`** como fonte de configuracao
- **Validacao de existência** e permissoes
- **Carregamento seguro** com shellcheck
- **Configuracao especifica** por empresa

## Estrutura do Codigo

### Arrays de Organizacao

```bash
# Organizacao logica das variaveis
declare -a cores=(RED GREEN YELLOW BLUE PURPLE CYAN NORM)
declare -a caminhos_base=(BASE1 BASE2 BASE3 TOOLS_DIR DIR destino pasta base base2 base3 logs exec class telas xml olds progs backup sistema TEMPS UMADATA DIRB ENVIABACK ENVBASE SERACESOFF E_EXEC T_TELAS X_XML)
declare -a biblioteca=(SAVATU SAVATU1 SAVATU2 SAVATU3 SAVATU4)
declare -a comandos=(cmd_unzip cmd_zip cmd_find cmd_who)
declare -a outros=(NOMEPROG PEDARQ prog PORTA USUARIO IPSERVER DESTINO2 VBACKUP ARQUIVO VERSAO ARQUIVO2 VERSAOANT INI SAVISC DEFAULT_UNZIP DEFAULT_ZIP DEFAULT_FIND DEFAULT_WHO DEFAULT_VERSAO VERSAO DEFAULT_ARQUIVO DEFAULT_PEDARQ DEFAULT_PROG DEFAULT_PORTA DEFAULT_USUARIO DEFAULT_IPSERVER DEFAULT_DESTINO2 UPDATE DEFAULT_PEDARQ jut JUTIL ISCCLIENT ISCCLIENTT SAVISCC)
```

### Variaveis Essenciais do Sistema

```bash
# Diretorios principais
destino="${destino:-}"       # Raiz do sistema
pasta="${pasta:-}"           # Diretorio de ferramentas
base="${base:-}"             # Base de dados principal
exec="${exec:-}"             # Executaveis compilados
telas="${telas:-}"           # Arquivos de interface

# Configuracoes de compilacao
class="${class:-}"           # Extensao normal
mclass="${mclass:-}"         # Extensao debug
verclass="${verclass:-}"     # Ano da versao

# Configuracoes de rede
PORTA="${PORTA:-}"           # Porta SSH/SFTP
USUARIO="${USUARIO:-}"       # Usuario remoto
IPSERVER="${IPSERVER:-}"     # IP do servidor
```

## Sistema de Cores Avancado

### `_definir_cores()`

Configuracao inteligente de cores baseada no terminal.

**Caracteristicas:**

- **Deteccao automatica** de suporte a cores (`tput`)
- **Configuracao responsiva** baseada na largura do terminal
- **Fallback seguro** para terminais sem suporte
- **Variaveis readonly** para protecao

```bash
# Terminal com suporte a cores
if [[ -t 1 ]] && command -v tput >/dev/null 2>&1; then
    RED=$(tput bold)$(tput setaf 1)
    GREEN=$(tput bold)$(tput setaf 2)
    YELLOW=$(tput bold)$(tput setaf 3)
    # ... demais cores
    COLUMNS=$(tput cols)
    tput clear
else
    # Terminal sem suporte
    RED="" GREEN="" YELLOW="" # ... variaveis vazias
    COLUMNS=80
fi
```

## Configuracao de Comandos

### `_configurar_comandos()`

Validacao e configuracao de comandos externos necessarios.

**Comandos validados:**

- **`cmd_unzip`** - Descompactacao de arquivos
- **`cmd_zip`** - Compactacao de arquivos
- **`cmd_find`** - Busca avancada de arquivos
- **`cmd_who`** - Verificacao de usuarios logados

**Logica de configuracao:**

```bash
# Usar padrao se nao definido
if [[ -z "${cmd_unzip}" ]]; then
    cmd_unzip="${DEFAULT_UNZIP}"
fi

# Validar existência do comando
if ! command -v "$cmd" >/dev/null 2>&1; then
    printf "Erro: Comando %s nao encontrado.\n" "$cmd"
    exit 1
fi
```

## Sistema de Diretorios

### `_configurar_diretorios()`

Criacao e configuracao da estrutura completa de diretorios.

**Diretorios criados:**

```bash
readonly TOOLS_DIR="${destino}${pasta}"     # /sav/sav/TOOLS_DIR
readonly backup="${TOOLS_DIR}/backup"       # Diretorio de backups
readonly OLDS="${TOOLS_DIR}/olds"           # Backups antigos
readonly PROGS="${TOOLS_DIR}/progs"         # Programas processados
readonly LOGS="${TOOLS_DIR}/logs"           # Arquivos de log
readonly ENVIA="${TOOLS_DIR}/envia"         # Arquivos para envio
readonly RECEBE="${TOOLS_DIR}/recebe"       # Arquivos recebidos
readonly LIBS="${TOOLS_DIR}/libs"           # Bibliotecas do sistema
```

**Caracteristicas:**

- **Criacao automatica** se nao existirem
- **Validacao de acesso** apos criacao
- **Permissoes adequadas** para operacao
- **Estrutura hierarquica** bem definida

## Carregamento de Configuracoes

### `_carregar_config_empresa()`

Carregamento seguro do arquivo de configuracao da empresa.

**Processo:**

1. **Verificacao de existência** do arquivo `.atualizac`
2. **Validacao de permissoes** de leitura
3. **Carregamento seguro** com `source`/`dot`
4. **Tratamento de erros** com mensagens claras

```bash
# Carregamento com shellcheck
# shellcheck source=/dev/null
"." "${config_file}"
```

### `_carregar_configuracoes()`

Controlador principal de carregamento de configuracoes.

**Sequência de inicializacao:**

1. **Definicao de cores** do terminal
2. **Carregamento** do arquivo de configuracao da empresa
3. **Configuracao de comandos** externos
4. **Configuracao de diretorios** do sistema
5. **Configuracao de variaveis** do sistema
6. **Configuracao de acesso** offline (se aplicavel)

## Sistema de Validacao

### `_validar_diretorios()`

Validacao completa de todos os diretorios essenciais.

**Diretorios validados:**

- **`E_EXEC`** - Diretorio de executaveis (obrigatorio)
- **`T_TELAS`** - Diretorio de telas (obrigatorio)
- **`X_XML`** - Diretorio XML (obrigatorio para IsCobol)
- **`BASE1/BASE2/BASE3`** - Bases de dados (se configuradas)

```bash
_verifica_diretorio() {
    local caminho="$1"
    local mensagem_erro="$2"

    if [[ -n "${caminho}" ]] && [[ -d "${caminho}" ]]; then
        _mensagec "${CYAN}" "Diretorio validado: ${caminho}"
    else
        _linha "*"
        _mensagec "${RED}" "${mensagem_erro}: ${caminho}"
        exit 1
    fi
}
```

### `_validar_configuracao()`

Validacao abrangente de toda a configuracao do sistema.

**Categorias validadas:**

1. **Arquivos de configuracao** (`.atualizac`)
2. **Variaveis essenciais** (`sistema`, `destino`, `BANCO`)
3. **Diretorios criticos** (exec, telas, bases)
4. **Conectividade de rede** (se modo online)

**Relatorio detalhado:**

```bash
# Estatisticas finais
_mensagec "${CYAN}" "Resumo:"
_mensagec "${RED}" "Erros: ${erros}"
_mensagec "${YELLOW}" "Avisos: ${warnings}"

if (( erros == 0 )); then
    _mensagec "${GREEN}" "Configuracao valida!"
else
    _mensagec "${RED}" "Configuracao com erros!"
fi
```

## Configuracao de Variaveis do Sistema

### `_configurar_variaveis_sistema()`

Definicao de todas as variaveis derivadas e caminhos completos.

**Variaveis configuradas:**

```bash
# Caminhos completos
export E_EXEC="${destino}/${exec}"
export T_TELAS="${destino}/${telas}"
export X_XML="${destino}/${xml}"

# Utilitarios IsCobol
readonly SAVISCC="${destino}/sav/savisc/iscobol/bin/"
jut="${SAVISC}${JUTIL}"

# Configuracoes de rede
PORTA="${PORTA:-${DEFAULT_PORTA}}"      # 41122
USUARIO="${USUARIO:-${DEFAULT_USUARIO}}" # atualiza

# Logs com timestamp
LOG_ATU="${LOGS}/atualiza.$(date +"%Y-%m-%d").log"
UMADATA=$(date +"%d-%m-%Y_%H%M%S")
```

## Sistema de Limpeza

### `_resetando()`

Funcao de limpeza e reset do ambiente.

**Funcionalidades:**

- **Limpeza de arrays** de variaveis
- **Reset de cores** do terminal (`tput sgr0`)
- **Saida controlada** com codigo de erro
- **Tratamento seguro** com `|| true` para evitar erros

```bash
_resetando() {
    # Limpeza segura de variaveis
    unset -v "${cores[@]}" 2>/dev/null || true
    unset -v "${caminhos_base[@]}" 2>/dev/null || true
    unset -v "${biblioteca[@]}" 2>/dev/null || true
    unset -v "${comandos[@]}" 2>/dev/null || true
    unset -v "${outros[@]}" 2>/dev/null || true

    # Reset do terminal
    tput sgr0 2>/dev/null || true
    exit 1
}
```

## Caracteristicas de Seguranca

### Validacoes de Seguranca

- **Verificacao de comandos** externos antes do uso
- **Validacao de permissoes** em arquivos criticos
- **Controle de acesso** a diretorios sensiveis
- **Tratamento seguro** de variaveis de ambiente

### Tratamento Seguro de Configuracoes

- **Carregamento controlado** de arquivos de configuracao
- **Validacao de conteúdo** antes da aplicacao
- **Backup implicito** atraves de validacoes
- **Logs de auditoria** para rastreabilidade

## Boas Praticas Implementadas

### Organizacao do Codigo

- **Arrays logicos** para agrupamento de variaveis
- **Funcoes especificas** por responsabilidade
- **Comentarios detalhados** sobre cada variavel
- **Constantes bem definidas** para valores padrao

### Tratamento de Erros

- **Mensagens claras** sobre problemas especificos
- **Validacoes em múltiplas camadas**
- **Codigos de saida** apropriados
- **Recuperacao graceful** quando possivel

### Manutenibilidade

- **Configuracao centralizada** de todas as variaveis
- **Validacao automatica** da configuracao
- **Documentacao inline** clara
- **Estrutura modular** bem definida

## Arquivos Relacionados

### Arquivo de Configuracao Principal

- **`.atualizac`** - Configuracoes especificas da empresa
- **Localizacao**: `${cfg_dir}/.atualizac`
- **Permissoes**: Leitura obrigatoria para funcionamento

### Diretorios Essenciais

- **`TOOLS_DIR`** - Diretorio principal (`/sav/sav/TOOLS_DIR`)
- **`LIBS`** - Bibliotecas do sistema (`/sav/sav/TOOLS_DIR/libs`)
- **`LOGS`** - Arquivos de log (`/sav/sav/TOOLS_DIR/logs`)
- **`backup`** - Backups (`/sav/sav/TOOLS_DIR/backup`)

## Exemplos de Uso

### Carregamento Basico de Configuracoes

```bash
# Carregar todas as configuracoes
_carregar_configuracoes

# As seguintes funcoes sao executadas automaticamente:
# _definir_cores
# _carregar_config_empresa
# _configurar_comandos
# _configurar_diretorios
# _configurar_variaveis_sistema
# _configurar_acesso_servidor
```

### Validacao de Configuracao

```bash
# Validar configuracao atual
_validar_configuracao

# Verifica:
# - Arquivo .atualizac
# - Variaveis essenciais
# - Diretorios criticos
# - Conectividade de rede
```

### Configuracao Manual de Diretorios

```bash
# Configurar estrutura de diretorios
_configurar_diretorios

# Cria automaticamente:
# /sav/sav/TOOLS_DIR/backup
# /sav/sav/TOOLS_DIR/olds
# /sav/sav/TOOLS_DIR/progs
# /sav/sav/TOOLS_DIR/logs
# /sav/sav/TOOLS_DIR/envia
# /sav/sav/TOOLS_DIR/recebe
# /sav/sav/TOOLS_DIR/libs
```

## Variaveis de Ambiente

### Variaveis Suportadas

- `destino` - Diretorio raiz do sistema SAV
- `sistema` - Tipo de sistema (iscobol/cobol)
- `BANCO` - Uso de banco de dados (s/n)
- `Offline` - Modo offline (s/n ou caminho)
- `acessossh` - Metodo de acesso SSH (s/n)

### Constantes Internas

- `DEFAULT_PORTA` - Porta padrao (41122)
- `DEFAULT_USUARIO` - Usuario padrao (atualiza)
- `DEFAULT_*` - Valores padrao para comandos
- `DESTINO2*` - Caminhos remotos para bibliotecas

## Consideracoes de Performance

### Otimizacoes Implementadas

- **Validacao minima** durante carregamento
- **Criacao eficiente** de diretorios
- **Cache de configuracoes** carregadas
- **Processamento sequencial** controlado

### Recursos de Sistema

- **I/O otimizado** com verificacoes eficientes
- **Memoria controlada** com variaveis locais
- **CPU minima** durante configuracao inicial

## Debugging e Desenvolvimento

### Estrategias para Debug

- **Validacao visual** de cada etapa
- **Mensagens claras** sobre problemas encontrados
- **Logs detalhados** de configuracao
- **Estados intermediarios** mostrados durante carregamento

### Diagnostico de Problemas

```bash
# Verificar arquivo de configuracao
ls -la "${cfg_dir}/.atualizac"

# Testar comandos externos
command -v zip unzip find who

# Verificar estrutura de diretorios
ls -la "${TOOLS_DIR}"

# Validar configuracao completa
_validar_configuracao
```

## Casos de Uso Comuns

### Configuracao Inicial

```bash
# Primeiro uso apos instalacao
_carregar_configuracoes

# Ira configurar:
# - Cores do terminal
# - Comandos externos
# - Estrutura de diretorios
# - Variaveis do sistema
# - Acesso offline (se aplicavel)
```

### Validacao de Ambiente

```bash
# Verificar se tudo esta configurado corretamente
_validar_configuracao

# Especialmente útil apos:
# - Modificacoes na configuracao
# - Migracao entre ambientes
# - Instalacao de dependências
```

### Diagnostico de Problemas

```bash
# Quando algo nao esta funcionando
_validar_configuracao

# Mostra exatamente:
# - O que esta faltando
# - O que esta com problema
# - O que precisa ser corrigido
```

## Integracao com o Sistema

### Dependências de Modulos

- **Nenhuma dependência externa** - modulo base
- **Carregado automaticamente** pelo `principal.sh`
- **Base para todos os outros modulos**

### Fluxo de Integracao

```
config.sh → validacao → diretorios → variaveis → sistema operacional
```

---

_Documentacao gerada automaticamente com base no codigo fonte e praticas de bash scripting._
