# Documentacao do Modulo arquivos.sh

## Visao Geral
O modulo `arquivos.sh` e responsavel pela **gestao completa de arquivos** do **Sistema SAV (Script de Atualizacao Modular)**. Este modulo oferece funcionalidades avancadas para limpeza, recuperacao, transferência e manutencao de arquivos com integracao especifica ao ambiente IsCobol.

## Funcionalidades Principais

### 1. Sistema de Limpeza
- **Limpeza baseada em lista** de arquivos temporarios
- **Processamento múltiplas bases** de dados simultaneamente
- **Compactacao automatica** de arquivos removidos
- **Logs detalhados** de operacoes de limpeza

### 2. Recuperacao de Arquivos
- **Recuperacao especifica** por nome de arquivo
- **Recuperacao em lote** de arquivos principais
- **Integracao com jutil** para sistemas IsCobol
- **Validacao de existência** antes da recuperacao

### 3. Transferência de Arquivos
- **Envio avulso** via rsync com configuracoes SSH
- **Recebimento avulso** via SFTP
- **Interface interativa** para selecao de caminhos
- **Validacao de conectividade** antes da transferência

### 4. Sistema de Expurgo
- **Limpeza automatica** de arquivos antigos (>30 dias)
- **Tratamento especifico** para diferentes tipos de arquivo
- **Controle de retencao** diferenciado por diretorio
- **Relatorio detalhado** de arquivos removidos

## Estrutura do Codigo

### Variaveis Essenciais
```bash
# Diretorios de dados
destino="${destino:-}"
base="${base:-}"
base2="${base2:-}"
base3="${base3:-}"

# Ferramentas IsCobol
cmd_zip="${cmd_zip:-}"
jut="${jut:-}"

# Diretorios de trabalho
BASE_TRABALHO="${BASE_TRABALHO:-}"
```

## Sistema de Limpeza

### `_executar_limpeza_temporarios()`
Controlador principal do sistema de limpeza.

**Processo:**
1. **Validacao de arquivo** de lista (`atualizat`)
2. **Limpeza de temporarios antigos** do backup
3. **Processamento sequencial** de cada base configurada
4. **Compactacao automatica** de arquivos removidos

**Arquivo de lista:**
```bash
# ${cfg_dir}/atualizat
*.tmp
*.temp
*.log
backup_*.zip
```

### `_limpar_base_especifica()`
Processa limpeza de uma base especifica.

**Caracteristicas:**
- **Leitura dinamica** da lista de padroes
- **Compactacao integrada** com nome timestamp
- **Logs detalhados** de cada padrao processado
- **Tratamento robusto** de erros

```bash
# Processamento de cada padrao
for padrao_arquivo in "${arquivos_temp[@]}"; do
    find "$caminho_base" -type f -iname "$padrao_arquivo" \
        -exec "$cmd_zip" -m "${backup}/${zip_temporarios}" {} +
done
```

### `_adicionar_arquivo_lixo()`
Adiciona novos padroes à lista de limpeza.

**Funcionalidades:**
- **Interface interativa** para adicao de padroes
- **Validacao de entrada** obrigatoria
- **Feedback imediato** da operacao
- **Persistência automatica** no arquivo `atualizat`

## Sistema de Recuperacao

### `_recuperar_arquivo_especifico()`
Interface principal para recuperacao de arquivos.

**Caracteristicas:**
- **Selecao automatica de base** (se múltiplas disponiveis)
- **Opcao de arquivo especifico** ou todos os arquivos
- **Validacao especifica** para sistema IsCobol
- **Integracao com jutil** para rebuild

### `_recuperar_arquivo_individual()`
Recuperacao especifica por nome de arquivo.

**Validacoes:**
- **Nome valido** (maiúsculas e números apenas)
- **Padrao de busca** `${nome_arquivo}.*.dat`
- **Existência de arquivos** antes do processamento

```bash
# Validacao de nome
if [[ ! "$nome_arquivo" =~ ^[A-Z0-9]+$ ]]; then
    _mensagec "${RED}" "Nome de arquivo invalido. Use apenas letras maiúsculas e números."
    return 1
fi
```

### `_recuperar_todos_arquivos()`
Recuperacao em lote de arquivos principais.

**Arquivos processados:**
```bash
local -a extensoes=('*.ARQ.dat' '*.DAT.dat' '*.LOG.dat' '*.PAN.dat')
```

### `_executar_jutil()`
Execucao especifica do jutil para rebuild de arquivos.

**Caracteristicas:**
- **Verificacao de existência** e tamanho do arquivo
- **Validacao de executavel** jutil
- **Execucao com parametros** especificos (`-rebuild -a -f`)
- **Logs detalhados** de sucesso/falha

```bash
# Execucao jutil
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
1. **Selecao de diretorio** de origem (com padrao)
2. **Especificacao do arquivo** a ser enviado
3. **Definicao do destino** remoto
4. **Transferência via rsync** com configuracoes SSH

**Caracteristicas:**
- **Interface em três etapas** clara
- **Validacao de existência** em cada etapa
- **Fallback automatico** para diretorios padrao
- **Listagem automatica** de arquivos disponiveis

### `_receber_arquivo_avulso()`
Recebimento interativo de arquivo via SFTP.

**Processo:**
1. **Especificacao de origem** remota
2. **Nome do arquivo** a receber
3. **Selecao de destino** local (com padrao)
4. **Download via SFTP** com autenticacao

## Sistema de Expurgo

### `_executar_expurgador()`
Limpeza automatica de arquivos antigos.

**Categorias de limpeza:**

#### Diretorios Gerais (>30 dias)
```bash
local diretorios_limpeza=(
    "${backup}/"           # Backups antigos
    "${OLDS}/"             # Arquivos antigos
    "${PROGS}/"            # Programas processados
    "${LOGS}/"             # Logs antigos
    "${destino}/sav/portalsav/log/"    # Logs do sistema
    "${destino}/sav/err_isc/"          # Erros IsCobol
    "${destino}/sav/savisc/viewvix/tmp/"  # Temporarios
)
```

#### Arquivos ZIP Especificos (>15 dias)
```bash
local diretorios_zip=(
    "${E_EXEC}/"           # Executaveis compactados
    "${T_TELAS}/"          # Telas compactadas
)
```

**Caracteristicas:**
- **Controle diferenciado** de retencao por tipo
- **Contagem automatica** de arquivos removidos
- **Relatorio detalhado** por diretorio
- **Tratamento seguro** com `2>/dev/null`

## Caracteristicas de Seguranca

### Validacoes de Seguranca
- **Verificacao de permissoes** em arquivos criticos
- **Validacao de nomes** de arquivo (maiúsculas/números)
- **Controle de acesso** a diretorios sensiveis
- **Tratamento seguro** de variaveis de ambiente

### Tratamento Seguro de Arquivos
- **Validacao de existência** antes de operacoes
- **Backup implicito** atraves de compactacao
- **Controle de permissoes** em operacoes de arquivo
- **Logs de auditoria** para rastreabilidade

## Boas Praticas Implementadas

### Organizacao do Codigo
- **Funcoes especificas** por tipo de operacao
- **Validacoes centralizadas** antes de acoes criticas
- **Tratamento uniforme** de erros
- **Comentarios claros** sobre logica especifica

### Performance
- **Processamento eficiente** com find e exec
- **Compactacao integrada** durante limpeza
- **Controle minimo** de progresso durante operacoes
- **Uso otimizado** de recursos do sistema

### Manutenibilidade
- **Interface interativa** bem estruturada
- **Validacoes robustas** em pontos criticos
- **Logs detalhados** para auditoria
- **Tratamento graceful** de diferentes cenarios

## Dependências Externas

### Comandos Utilizados
- `find` - Busca avancada de arquivos
- `zip` - Compactacao de arquivos removidos
- `rsync` - Transferência segura de arquivos
- `sftp` - Transferência interativa via SSH
- `jutil` - Ferramenta especifica IsCobol para rebuild

### Arquivos de Sistema
- `${cfg_dir}/atualizat` - Lista de padroes para limpeza
- `${jut}` - Caminho do utilitario jutil IsCobol
- `${backup}/Temps-${UMADATA}.zip` - Arquivo de temporarios removidos

## Exemplos de Uso

### Limpeza de Temporarios
```bash
# Executar limpeza baseada na lista
_executar_limpeza_temporarios

# Processa:
# - Arquivo atualizat para padroes
# - Todas as bases configuradas
# - Compactacao automatica dos removidos
# - Logs detalhados da operacao
```

### Recuperacao de Arquivo Especifico
```bash
# Recuperar arquivo individual
_recuperar_arquivo_especifico
# Base: automatica (se múltiplas)
# Sistema: IsCobol (obrigatorio)
# Arquivo: nome especifico ou todos
# Processo: jutil -rebuild automatico
```

### Transferência Avulsa
```bash
# Enviar arquivo
_enviar_arquivo_avulso
# 1. Diretorio origem: /sav/envia
# 2. Arquivo: arquivo.zip
# 3. Destino remoto: /cliente/dados/
# Processo: rsync via SSH
```

### Expurgo Automatico
```bash
# Limpeza de arquivos antigos
_executar_expurgador "ferramentas"

# Remove automaticamente:
# - Arquivos >30 dias em diretorios gerais
# - Arquivos ZIP >15 dias em diretorios especificos
# - Relatorio detalhado de arquivos removidos
```

## Caracteristicas Avancadas

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

# Logs de sucesso especifico
_log_sucesso "Rebuild executado: $(basename "$arquivo")"
```

### Controle de Diretorios Dinamicos
```bash
# Definicao baseada em variaveis
local caminho_base="${destino}${base_dir}/"
local arquivos_temp=()
mapfile -t arquivos_temp < "$arquivo_lista"
```

## Tratamento de Erros

### Estrategias Implementadas
- **Validacao previa** de todos os parametros
- **Verificacao de existência** antes de operacoes
- **Tratamento especifico** para diferentes tipos de erro
- **Mensagens informativas** sobre problemas encontrados

### Codigos de Retorno
- `0` - Sucesso
- `1` - Erro de parametro ou arquivo
- `1` - Falha na transferência ou processamento

## Consideracoes de Performance

### Otimizacoes
- **Find eficiente** com padroes especificos
- **Compactacao integrada** durante limpeza
- **Processamento paralelo** quando possivel
- **Controle minimo** de I/O durante operacoes

### Recursos de Sistema
- **Memoria controlada** com arrays locais
- **CPU otimizada** com processamento direto
- **I/O eficiente** com redirecionamento adequado
- **Limpeza automatica** de recursos temporarios

## Debugging e Desenvolvimento

### Estrategias para Debug
- **Validacoes visuais** durante operacoes
- **Logs detalhados** de todas as acoes
- **Verificacao de variaveis** em pontos criticos
- **Estados intermediarios** mostrados ao usuario

### Diagnostico de Problemas
```bash
# Verificar arquivo de lista
cat "${cfg_dir}/atualizat"

# Testar jutil
"${jut}" -rebuild arquivo.dat -a -f

# Verificar estrutura de diretorios
find "${backup}" -name "Temps*" -mtime +10

# Verificar logs de limpeza
tail -f "${LOG_LIMPA}"
```

## Casos de Uso Comuns

### Manutencao Diaria
```bash
# Limpeza automatica de temporarios
_executar_limpeza_temporarios
# Baseada no arquivo atualizat
# Todas as bases configuradas
# Compactacao automatica
```

### Recuperacao de Emergência
```bash
# Recuperar arquivo especifico
_recuperar_arquivo_especifico
# Sistema: IsCobol obrigatorio
# Arquivo: nome especifico
# Processo: jutil rebuild automatico
```

### Transferência Manual
```bash
# Enviar arquivo especifico
_enviar_arquivo_avulso
# Interface: três etapas claras
# Metodo: rsync com SSH
# Validacao: completa antes do envio
```

### Limpeza Periodica
```bash
# Expurgo automatico mensal
_executar_expurgador "principal"
# Remove: arquivos >30 dias
# Relatorio: detalhado por diretorio
# Retencao: diferenciada por tipo
```

## Integracao com o Sistema

### Dependências de Modulos
- **`config.sh`** - Variaveis de configuracao e caminhos
- **`utils.sh`** - Funcoes utilitarias (mensagens, validacoes)
- **`menus.sh`** - Interface de navegacao
- **Sistema IsCobol** - jutil para operacoes especificas

### Fluxo de Integracao
```
arquivos.sh → validacao → jutil/transferência → limpeza → logs/auditoria
```

---

*Documentacao gerada automaticamente com base no codigo fonte e praticas de bash scripting.*