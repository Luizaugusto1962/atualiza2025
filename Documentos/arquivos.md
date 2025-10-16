# Documentação do Módulo arquivos.sh

## Visão Geral
O módulo `arquivos.sh` é responsável pela **gestão completa de arquivos** do **Sistema SAV (Script de Atualização Modular)**. Este módulo oferece funcionalidades avançadas para limpeza, recuperação, transferência e manutenção de arquivos com integração específica ao ambiente IsCobol.

## Funcionalidades Principais

### 1. Sistema de Limpeza
- **Limpeza baseada em lista** de arquivos temporários
- **Processamento múltiplas bases** de dados simultaneamente
- **Compactação automática** de arquivos removidos
- **Logs detalhados** de operações de limpeza

### 2. Recuperação de Arquivos
- **Recuperação específica** por nome de arquivo
- **Recuperação em lote** de arquivos principais
- **Integração com jutil** para sistemas IsCobol
- **Validação de existência** antes da recuperação

### 3. Transferência de Arquivos
- **Envio avulso** via rsync com configurações SSH
- **Recebimento avulso** via SFTP
- **Interface interativa** para seleção de caminhos
- **Validação de conectividade** antes da transferência

### 4. Sistema de Expurgo
- **Limpeza automática** de arquivos antigos (>30 dias)
- **Tratamento específico** para diferentes tipos de arquivo
- **Controle de retenção** diferenciado por diretório
- **Relatório detalhado** de arquivos removidos

## Estrutura do Código

### Variáveis Essenciais
```bash
# Diretórios de dados
destino="${destino:-}"
base="${base:-}"
base2="${base2:-}"
base3="${base3:-}"

# Ferramentas IsCobol
cmd_zip="${cmd_zip:-}"
jut="${jut:-}"

# Diretórios de trabalho
BASE_TRABALHO="${BASE_TRABALHO:-}"
```

## Sistema de Limpeza

### `_executar_limpeza_temporarios()`
Controlador principal do sistema de limpeza.

**Processo:**
1. **Validação de arquivo** de lista (`atualizat`)
2. **Limpeza de temporários antigos** do backup
3. **Processamento sequencial** de cada base configurada
4. **Compactação automática** de arquivos removidos

**Arquivo de lista:**
```bash
# ${LIB_CFG}/atualizat
*.tmp
*.temp
*.log
backup_*.zip
```

### `_limpar_base_especifica()`
Processa limpeza de uma base específica.

**Características:**
- **Leitura dinâmica** da lista de padrões
- **Compactação integrada** com nome timestamp
- **Logs detalhados** de cada padrão processado
- **Tratamento robusto** de erros

```bash
# Processamento de cada padrão
for padrao_arquivo in "${arquivos_temp[@]}"; do
    find "$caminho_base" -type f -iname "$padrao_arquivo" \
        -exec "$cmd_zip" -m "${BACKUP}/${zip_temporarios}" {} +
done
```

### `_adicionar_arquivo_lixo()`
Adiciona novos padrões à lista de limpeza.

**Funcionalidades:**
- **Interface interativa** para adição de padrões
- **Validação de entrada** obrigatória
- **Feedback imediato** da operação
- **Persistência automática** no arquivo `atualizat`

## Sistema de Recuperação

### `_recuperar_arquivo_especifico()`
Interface principal para recuperação de arquivos.

**Características:**
- **Seleção automática de base** (se múltiplas disponíveis)
- **Opção de arquivo específico** ou todos os arquivos
- **Validação específica** para sistema IsCobol
- **Integração com jutil** para rebuild

### `_recuperar_arquivo_individual()`
Recuperação específica por nome de arquivo.

**Validações:**
- **Nome válido** (maiúsculas e números apenas)
- **Padrão de busca** `${nome_arquivo}.*.dat`
- **Existência de arquivos** antes do processamento

```bash
# Validação de nome
if [[ ! "$nome_arquivo" =~ ^[A-Z0-9]+$ ]]; then
    _mensagec "${RED}" "Nome de arquivo inválido. Use apenas letras maiúsculas e números."
    return 1
fi
```

### `_recuperar_todos_arquivos()`
Recuperação em lote de arquivos principais.

**Arquivos processados:**
```bash
local -a extensoes=('*.ARQ.dat' '*.DAT.dat' '*.LOG.dat' '*.PAN.dat')
```

### `_executar_jutil()`
Execução específica do jutil para rebuild de arquivos.

**Características:**
- **Verificação de existência** e tamanho do arquivo
- **Validação de executável** jutil
- **Execução com parâmetros** específicos (`-rebuild -a -f`)
- **Logs detalhados** de sucesso/falha

```bash
# Execução jutil
if [[ -x "${jut}" ]]; then
    if "${jut}" -rebuild "$arquivo" -a -f; then
        _log_sucesso "Rebuild executado: $(basename "$arquivo")"
    else
        _mensagec "${RED}" "Erro no rebuild: $(basename "$arquivo")"
        return 1
    fi
fi
```

## Sistema de Transferência

### `_enviar_arquivo_avulso()`
Envio interativo de arquivo via rsync.

**Processo:**
1. **Seleção de diretório** de origem (com padrão)
2. **Especificação do arquivo** a ser enviado
3. **Definição do destino** remoto
4. **Transferência via rsync** com configurações SSH

**Características:**
- **Interface em três etapas** clara
- **Validação de existência** em cada etapa
- **Fallback automático** para diretórios padrão
- **Listagem automática** de arquivos disponíveis

### `_receber_arquivo_avulso()`
Recebimento interativo de arquivo via SFTP.

**Processo:**
1. **Especificação de origem** remota
2. **Nome do arquivo** a receber
3. **Seleção de destino** local (com padrão)
4. **Download via SFTP** com autenticação

## Sistema de Expurgo

### `_executar_expurgador()`
Limpeza automática de arquivos antigos.

**Categorias de limpeza:**

#### Diretórios Gerais (>30 dias)
```bash
local diretorios_limpeza=(
    "${BACKUP}/"           # Backups antigos
    "${OLDS}/"             # Arquivos antigos
    "${PROGS}/"            # Programas processados
    "${LOGS}/"             # Logs antigos
    "${destino}/sav/portalsav/log/"    # Logs do sistema
    "${destino}/sav/err_isc/"          # Erros IsCobol
    "${destino}/sav/savisc/viewvix/tmp/"  # Temporários
)
```

#### Arquivos ZIP Específicos (>15 dias)
```bash
local diretorios_zip=(
    "${E_EXEC}/"           # Executáveis compactados
    "${T_TELAS}/"          # Telas compactadas
)
```

**Características:**
- **Controle diferenciado** de retenção por tipo
- **Contagem automática** de arquivos removidos
- **Relatório detalhado** por diretório
- **Tratamento seguro** com `2>/dev/null`

## Características de Segurança

### Validações de Segurança
- **Verificação de permissões** em arquivos críticos
- **Validação de nomes** de arquivo (maiúsculas/números)
- **Controle de acesso** a diretórios sensíveis
- **Tratamento seguro** de variáveis de ambiente

### Tratamento Seguro de Arquivos
- **Validação de existência** antes de operações
- **Backup implícito** através de compactação
- **Controle de permissões** em operações de arquivo
- **Logs de auditoria** para rastreabilidade

## Boas Práticas Implementadas

### Organização do Código
- **Funções específicas** por tipo de operação
- **Validações centralizadas** antes de ações críticas
- **Tratamento uniforme** de erros
- **Comentários claros** sobre lógica específica

### Performance
- **Processamento eficiente** com find e exec
- **Compactação integrada** durante limpeza
- **Controle mínimo** de progresso durante operações
- **Uso otimizado** de recursos do sistema

### Manutenibilidade
- **Interface interativa** bem estruturada
- **Validações robustas** em pontos críticos
- **Logs detalhados** para auditoria
- **Tratamento graceful** de diferentes cenários

## Dependências Externas

### Comandos Utilizados
- `find` - Busca avançada de arquivos
- `zip` - Compactação de arquivos removidos
- `rsync` - Transferência segura de arquivos
- `sftp` - Transferência interativa via SSH
- `jutil` - Ferramenta específica IsCobol para rebuild

### Arquivos de Sistema
- `${LIB_CFG}/atualizat` - Lista de padrões para limpeza
- `${jut}` - Caminho do utilitário jutil IsCobol
- `${BACKUP}/Temps-${UMADATA}.zip` - Arquivo de temporários removidos

## Exemplos de Uso

### Limpeza de Temporários
```bash
# Executar limpeza baseada na lista
_executar_limpeza_temporarios

# Processa:
# - Arquivo atualizat para padrões
# - Todas as bases configuradas
# - Compactação automática dos removidos
# - Logs detalhados da operação
```

### Recuperação de Arquivo Específico
```bash
# Recuperar arquivo individual
_recuperar_arquivo_especifico
# Base: automática (se múltiplas)
# Sistema: IsCobol (obrigatório)
# Arquivo: nome específico ou todos
# Processo: jutil -rebuild automático
```

### Transferência Avulsa
```bash
# Enviar arquivo
_enviar_arquivo_avulso
# 1. Diretório origem: /sav/envia
# 2. Arquivo: arquivo.zip
# 3. Destino remoto: /cliente/dados/
# Processo: rsync via SSH
```

### Expurgo Automático
```bash
# Limpeza de arquivos antigos
_executar_expurgador "ferramentas"

# Remove automaticamente:
# - Arquivos >30 dias em diretórios gerais
# - Arquivos ZIP >15 dias em diretórios específicos
# - Relatório detalhado de arquivos removidos
```

## Características Avançadas

### Processamento Multi-Base
```bash
# Processa todas as bases configuradas
for base_dir in "$base" "$base2" "$base3"; do
    if [[ -n "$base_dir" ]]; then
        local caminho_base="${destino}${base_dir}/"
        if [[ -d "$caminho_base" ]]; then
            _limpar_base_especifica "$caminho_base" "$arquivo_lista"
        fi
    fi
done
```

### Sistema de Logs Integrado
```bash
# Logs de limpeza
>>"${LOG_LIMPA}" 2>&1

# Logs de sucesso específico
_log_sucesso "Rebuild executado: $(basename "$arquivo")"
```

### Controle de Diretórios Dinâmicos
```bash
# Definição baseada em variáveis
local caminho_base="${destino}${base_dir}/"
local arquivos_temp=()
mapfile -t arquivos_temp < "$arquivo_lista"
```

## Tratamento de Erros

### Estratégias Implementadas
- **Validação prévia** de todos os parâmetros
- **Verificação de existência** antes de operações
- **Tratamento específico** para diferentes tipos de erro
- **Mensagens informativas** sobre problemas encontrados

### Códigos de Retorno
- `0` - Sucesso
- `1` - Erro de parâmetro ou arquivo
- `1` - Falha na transferência ou processamento

## Considerações de Performance

### Otimizações
- **Find eficiente** com padrões específicos
- **Compactação integrada** durante limpeza
- **Processamento paralelo** quando possível
- **Controle mínimo** de I/O durante operações

### Recursos de Sistema
- **Memória controlada** com arrays locais
- **CPU otimizada** com processamento direto
- **I/O eficiente** com redirecionamento adequado
- **Limpeza automática** de recursos temporários

## Debugging e Desenvolvimento

### Estratégias para Debug
- **Validações visuais** durante operações
- **Logs detalhados** de todas as ações
- **Verificação de variáveis** em pontos críticos
- **Estados intermediários** mostrados ao usuário

### Diagnóstico de Problemas
```bash
# Verificar arquivo de lista
cat "${LIB_CFG}/atualizat"

# Testar jutil
"${jut}" -rebuild arquivo.dat -a -f

# Verificar estrutura de diretórios
find "${BACKUP}" -name "Temps*" -mtime +10

# Verificar logs de limpeza
tail -f "${LOG_LIMPA}"
```

## Casos de Uso Comuns

### Manutenção Diária
```bash
# Limpeza automática de temporários
_executar_limpeza_temporarios
# Baseada no arquivo atualizat
# Todas as bases configuradas
# Compactação automática
```

### Recuperação de Emergência
```bash
# Recuperar arquivo específico
_recuperar_arquivo_especifico
# Sistema: IsCobol obrigatório
# Arquivo: nome específico
# Processo: jutil rebuild automático
```

### Transferência Manual
```bash
# Enviar arquivo específico
_enviar_arquivo_avulso
# Interface: três etapas claras
# Método: rsync com SSH
# Validação: completa antes do envio
```

### Limpeza Periódica
```bash
# Expurgo automático mensal
_executar_expurgador "principal"
# Remove: arquivos >30 dias
# Relatório: detalhado por diretório
# Retenção: diferenciada por tipo
```

## Integração com o Sistema

### Dependências de Módulos
- **`config.sh`** - Variáveis de configuração e caminhos
- **`utils.sh`** - Funções utilitárias (mensagens, validações)
- **`menus.sh`** - Interface de navegação
- **Sistema IsCobol** - jutil para operações específicas

### Fluxo de Integração
```
arquivos.sh → validação → jutil/transferência → limpeza → logs/auditoria
```

---

*Documentação gerada automaticamente com base no código fonte e práticas de bash scripting.*