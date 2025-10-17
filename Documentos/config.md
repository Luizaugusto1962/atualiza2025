# Documentação do Módulo config.sh

## Visão Geral
O módulo `config.sh` é responsável pela **configuração completa e validação** do **Sistema SAV (Script de Atualização Modular)**. Este módulo centraliza todas as variáveis de configuração, valida o ambiente do sistema e estabelece as bases para o funcionamento de todos os outros módulos.

## Funcionalidades Principais

### 1. Gestão de Variáveis Globais
- **Arrays organizados** por categoria funcional
- **Variáveis de sistema** com valores padrão
- **Configurações de ambiente** personalizáveis
- **Herança de variáveis** entre módulos

### 2. Sistema de Cores Avançado
- **Detecção automática** de suporte a cores no terminal
- **Definição de paleta** completa (RED, GREEN, YELLOW, BLUE, PURPLE, CYAN)
- **Configuração responsiva** baseada no terminal
- **Fallback automático** para terminais sem suporte

### 3. Validação de Ambiente
- **Verificação de comandos** externos necessários
- **Criação automática** de estrutura de diretórios
- **Validação de permissões** e acessos
- **Teste de conectividade** com servidores

### 4. Carregamento de Configurações
- **Arquivo `.atualizac`** como fonte de configuração
- **Validação de existência** e permissões
- **Carregamento seguro** com shellcheck
- **Configuração específica** por empresa

## Estrutura do Código

### Arrays de Organização
```bash
# Organização lógica das variáveis
declare -a cores=(RED GREEN YELLOW BLUE PURPLE CYAN NORM)
declare -a caminhos_base=(BASE1 BASE2 BASE3 tools DIR destino pasta base base2 base3 logs exec class telas xml olds progs backup sistema TEMPS UMADATA DIRB ENVIABACK ENVBASE SERACESOFF E_EXEC T_TELAS X_XML)
declare -a biblioteca=(SAVATU SAVATU1 SAVATU2 SAVATU3 SAVATU4)
declare -a comandos=(cmd_unzip cmd_zip cmd_find cmd_who)
declare -a outros=(NOMEPROG PEDARQ prog PORTA USUARIO IPSERVER DESTINO2 VBACKUP ARQUIVO VERSAO ARQUIVO2 VERSAOANT INI SAVISC DEFAULT_UNZIP DEFAULT_ZIP DEFAULT_FIND DEFAULT_WHO DEFAULT_VERSAO VERSAO DEFAULT_ARQUIVO DEFAULT_PEDARQ DEFAULT_PROG DEFAULT_PORTA DEFAULT_USUARIO DEFAULT_IPSERVER DEFAULT_DESTINO2 UPDATE DEFAULT_PEDARQ jut JUTIL ISCCLIENT ISCCLIENTT SAVISCC)
```

### Variáveis Essenciais do Sistema
```bash
# Diretórios principais
destino="${destino:-}"       # Raiz do sistema
pasta="${pasta:-}"           # Diretório de ferramentas
base="${base:-}"             # Base de dados principal
exec="${exec:-}"             # Executáveis compilados
telas="${telas:-}"           # Arquivos de interface

# Configurações de compilação
class="${class:-}"           # Extensão normal
mclass="${mclass:-}"         # Extensão debug
verclass="${verclass:-}"     # Ano da versão

# Configurações de rede
PORTA="${PORTA:-}"           # Porta SSH/SFTP
USUARIO="${USUARIO:-}"       # Usuário remoto
IPSERVER="${IPSERVER:-}"     # IP do servidor
```

## Sistema de Cores Avançado

### `_definir_cores()`
Configuração inteligente de cores baseada no terminal.

**Características:**
- **Detecção automática** de suporte a cores (`tput`)
- **Configuração responsiva** baseada na largura do terminal
- **Fallback seguro** para terminais sem suporte
- **Variáveis readonly** para proteção

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
    RED="" GREEN="" YELLOW="" # ... variáveis vazias
    COLUMNS=80
fi
```

## Configuração de Comandos

### `_configurar_comandos()`
Validação e configuração de comandos externos necessários.

**Comandos validados:**
- **`cmd_unzip`** - Descompactação de arquivos
- **`cmd_zip`** - Compactação de arquivos
- **`cmd_find`** - Busca avançada de arquivos
- **`cmd_who`** - Verificação de usuários logados

**Lógica de configuração:**
```bash
# Usar padrão se não definido
if [[ -z "${cmd_unzip}" ]]; then
    cmd_unzip="${DEFAULT_UNZIP}"
fi

# Validar existência do comando
if ! command -v "$cmd" >/dev/null 2>&1; then
    printf "Erro: Comando %s não encontrado.\n" "$cmd"
    exit 1
fi
```

## Sistema de Diretórios

### `_configurar_diretorios()`
Criação e configuração da estrutura completa de diretórios.

**Diretórios criados:**
```bash
readonly TOOLS="${destino}${pasta}"     # /sav/sav/tools
readonly BACKUP="${TOOLS}/backup"       # Diretório de backups
readonly OLDS="${TOOLS}/olds"           # Backups antigos
readonly PROGS="${TOOLS}/progs"         # Programas processados
readonly LOGS="${TOOLS}/logs"           # Arquivos de log
readonly ENVIA="${TOOLS}/envia"         # Arquivos para envio
readonly RECEBE="${TOOLS}/recebe"       # Arquivos recebidos
readonly LIBS="${TOOLS}/libs"           # Bibliotecas do sistema
```

**Características:**
- **Criação automática** se não existirem
- **Validação de acesso** após criação
- **Permissões adequadas** para operação
- **Estrutura hierárquica** bem definida

## Carregamento de Configurações

### `_carregar_config_empresa()`
Carregamento seguro do arquivo de configuração da empresa.

**Processo:**
1. **Verificação de existência** do arquivo `.atualizac`
2. **Validação de permissões** de leitura
3. **Carregamento seguro** com `source`/`dot`
4. **Tratamento de erros** com mensagens claras

```bash
# Carregamento com shellcheck
# shellcheck source=/dev/null
"." "${config_file}"
```

### `_carregar_configuracoes()`
Controlador principal de carregamento de configurações.

**Sequência de inicialização:**
1. **Definição de cores** do terminal
2. **Carregamento** do arquivo de configuração da empresa
3. **Configuração de comandos** externos
4. **Configuração de diretórios** do sistema
5. **Configuração de variáveis** do sistema
6. **Configuração de acesso** offline (se aplicável)

## Sistema de Validação

### `_validar_diretorios()`
Validação completa de todos os diretórios essenciais.

**Diretórios validados:**
- **`E_EXEC`** - Diretório de executáveis (obrigatório)
- **`T_TELAS`** - Diretório de telas (obrigatório)
- **`X_XML`** - Diretório XML (obrigatório para IsCobol)
- **`BASE1/BASE2/BASE3`** - Bases de dados (se configuradas)

```bash
_verifica_diretorio() {
    local caminho="$1"
    local mensagem_erro="$2"

    if [[ -n "${caminho}" ]] && [[ -d "${caminho}" ]]; then
        _mensagec "${CYAN}" "Diretório validado: ${caminho}"
    else
        _linha "*"
        _mensagec "${RED}" "${mensagem_erro}: ${caminho}"
        exit 1
    fi
}
```

### `_validar_configuracao()`
Validação abrangente de toda a configuração do sistema.

**Categorias validadas:**
1. **Arquivos de configuração** (`.atualizac`)
2. **Variáveis essenciais** (`sistema`, `destino`, `BANCO`)
3. **Diretórios críticos** (exec, telas, bases)
4. **Conectividade de rede** (se modo online)

**Relatório detalhado:**
```bash
# Estatísticas finais
_mensagec "${CYAN}" "Resumo:"
_mensagec "${RED}" "Erros: ${erros}"
_mensagec "${YELLOW}" "Avisos: ${warnings}"

if (( erros == 0 )); then
    _mensagec "${GREEN}" "Configuração válida!"
else
    _mensagec "${RED}" "Configuração com erros!"
fi
```

## Configuração de Variáveis do Sistema

### `_configurar_variaveis_sistema()`
Definição de todas as variáveis derivadas e caminhos completos.

**Variáveis configuradas:**
```bash
# Caminhos completos
export E_EXEC="${destino}/${exec}"
export T_TELAS="${destino}/${telas}"
export X_XML="${destino}/${xml}"

# Utilitários IsCobol
readonly SAVISCC="${destino}/sav/savisc/iscobol/bin/"
jut="${SAVISC}${JUTIL}"

# Configurações de rede
PORTA="${PORTA:-${DEFAULT_PORTA}}"      # 41122
USUARIO="${USUARIO:-${DEFAULT_USUARIO}}" # atualiza

# Logs com timestamp
LOG_ATU="${LOGS}/atualiza.$(date +"%Y-%m-%d").log"
UMADATA=$(date +"%d-%m-%Y_%H%M%S")
```

## Sistema de Limpeza

### `_resetando()`
Função de limpeza e reset do ambiente.

**Funcionalidades:**
- **Limpeza de arrays** de variáveis
- **Reset de cores** do terminal (`tput sgr0`)
- **Saída controlada** com código de erro
- **Tratamento seguro** com `|| true` para evitar erros

```bash
_resetando() {
    # Limpeza segura de variáveis
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

## Características de Segurança

### Validações de Segurança
- **Verificação de comandos** externos antes do uso
- **Validação de permissões** em arquivos críticos
- **Controle de acesso** a diretórios sensíveis
- **Tratamento seguro** de variáveis de ambiente

### Tratamento Seguro de Configurações
- **Carregamento controlado** de arquivos de configuração
- **Validação de conteúdo** antes da aplicação
- **Backup implícito** através de validações
- **Logs de auditoria** para rastreabilidade

## Boas Práticas Implementadas

### Organização do Código
- **Arrays lógicos** para agrupamento de variáveis
- **Funções específicas** por responsabilidade
- **Comentários detalhados** sobre cada variável
- **Constantes bem definidas** para valores padrão

### Tratamento de Erros
- **Mensagens claras** sobre problemas específicos
- **Validações em múltiplas camadas**
- **Códigos de saída** apropriados
- **Recuperação graceful** quando possível

### Manutenibilidade
- **Configuração centralizada** de todas as variáveis
- **Validação automática** da configuração
- **Documentação inline** clara
- **Estrutura modular** bem definida

## Arquivos Relacionados

### Arquivo de Configuração Principal
- **`.atualizac`** - Configurações específicas da empresa
- **Localização**: `${LIB_CFG}/.atualizac`
- **Permissões**: Leitura obrigatória para funcionamento

### Diretórios Essenciais
- **`TOOLS`** - Diretório principal (`/sav/sav/tools`)
- **`LIBS`** - Bibliotecas do sistema (`/sav/sav/tools/libs`)
- **`LOGS`** - Arquivos de log (`/sav/sav/tools/logs`)
- **`BACKUP`** - Backups (`/sav/sav/tools/backup`)

## Exemplos de Uso

### Carregamento Básico de Configurações
```bash
# Carregar todas as configurações
_carregar_configuracoes

# As seguintes funções são executadas automaticamente:
# _definir_cores
# _carregar_config_empresa
# _configurar_comandos
# _configurar_diretorios
# _configurar_variaveis_sistema
# _configurar_acesso_offline
```

### Validação de Configuração
```bash
# Validar configuração atual
_validar_configuracao

# Verifica:
# - Arquivo .atualizac
# - Variáveis essenciais
# - Diretórios críticos
# - Conectividade de rede
```

### Configuração Manual de Diretórios
```bash
# Configurar estrutura de diretórios
_configurar_diretorios

# Cria automaticamente:
# /sav/sav/tools/backup
# /sav/sav/tools/olds
# /sav/sav/tools/progs
# /sav/sav/tools/logs
# /sav/sav/tools/envia
# /sav/sav/tools/recebe
# /sav/sav/tools/libs
```

## Variáveis de Ambiente

### Variáveis Suportadas
- `destino` - Diretório raiz do sistema SAV
- `sistema` - Tipo de sistema (iscobol/cobol)
- `BANCO` - Uso de banco de dados (s/n)
- `SERACESOFF` - Modo offline (s/n ou caminho)
- `acessossh` - Método de acesso SSH (s/n)

### Constantes Internas
- `DEFAULT_PORTA` - Porta padrão (41122)
- `DEFAULT_USUARIO` - Usuário padrão (atualiza)
- `DEFAULT_*` - Valores padrão para comandos
- `DESTINO2*` - Caminhos remotos para bibliotecas

## Considerações de Performance

### Otimizações Implementadas
- **Validação mínima** durante carregamento
- **Criação eficiente** de diretórios
- **Cache de configurações** carregadas
- **Processamento sequencial** controlado

### Recursos de Sistema
- **I/O otimizado** com verificações eficientes
- **Memória controlada** com variáveis locais
- **CPU mínima** durante configuração inicial

## Debugging e Desenvolvimento

### Estratégias para Debug
- **Validação visual** de cada etapa
- **Mensagens claras** sobre problemas encontrados
- **Logs detalhados** de configuração
- **Estados intermediários** mostrados durante carregamento

### Diagnóstico de Problemas
```bash
# Verificar arquivo de configuração
ls -la "${LIB_CFG}/.atualizac"

# Testar comandos externos
command -v zip unzip find who

# Verificar estrutura de diretórios
ls -la "${TOOLS}"

# Validar configuração completa
_validar_configuracao
```

## Casos de Uso Comuns

### Configuração Inicial
```bash
# Primeiro uso após instalação
_carregar_configuracoes

# Irá configurar:
# - Cores do terminal
# - Comandos externos
# - Estrutura de diretórios
# - Variáveis do sistema
# - Acesso offline (se aplicável)
```

### Validação de Ambiente
```bash
# Verificar se tudo está configurado corretamente
_validar_configuracao

# Especialmente útil após:
# - Modificações na configuração
# - Migração entre ambientes
# - Instalação de dependências
```

### Diagnóstico de Problemas
```bash
# Quando algo não está funcionando
_validar_configuracao

# Mostra exatamente:
# - O que está faltando
# - O que está com problema
# - O que precisa ser corrigido
```

## Integração com o Sistema

### Dependências de Módulos
- **Nenhuma dependência externa** - módulo base
- **Carregado automaticamente** pelo `principal.sh`
- **Base para todos os outros módulos**

### Fluxo de Integração
```
config.sh → validação → diretórios → variáveis → sistema operacional
```

---

*Documentação gerada automaticamente com base no código fonte e práticas de bash scripting.*