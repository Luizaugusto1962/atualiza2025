# Documentação do Módulo backup.sh

## Visão Geral
O módulo `backup.sh` é responsável pelo **sistema completo de backup e restauração** do **Sistema SAV (Script de Atualização Modular)**. Este módulo oferece funcionalidades avançadas para criação, gerenciamento e restauração de backups com interface interativa completa.

## Funcionalidades Principais

### 1. Tipos de Backup
- **Backup Completo**: Todos os arquivos do diretório selecionado
- **Backup Incremental**: Apenas arquivos modificados desde uma data específica
- **Verificação automática**: Detecção de backups recentes para evitar duplicatas

### 2. Restauração de Dados
- **Restauração completa**: Todos os arquivos do backup
- **Restauração seletiva**: Arquivos específicos por nome
- **Busca inteligente**: Localização automática por parte do nome

### 3. Transferência de Backups
- **Envio automático**: Para servidor remoto via rsync
- **Modo offline**: Movimentação para diretório local
- **Confirmação interativa**: Controle sobre manutenção de cópias locais

### 4. Interface Interativa
- **Menus visuais**: Seleção clara de opções
- **Confirmações**: Validação antes de operações críticas
- **Barra de progresso**: Feedback visual durante operações

## Estrutura do Código

### Variáveis Essenciais
```bash
# Diretórios de dados
destino="${destino:-}"
base="${base:-}"
base2="${base2:-}"
base3="${base3:-}"

# Configurações de backup
backup="${backup:-}"
cmd_zip="${cmd_zip:-}"
EMPRESA="${EMPRESA:-}"
```

### Validações Iniciais
```bash
# Verificar variáveis essenciais
if [[ -z "$destino" || -z "$sistema" || -z "$backup" ]]; then
    _mensagec "${RED}" "Erro: Variáveis essenciais não definidas"
    return 1
fi

# Verificar comandos externos
for cmd in zip unzip; do
    if ! command -v "${cmd}" &>/dev/null; then
        _mensagec "${RED}" "Erro: Comando ${cmd} não encontrado"
        return 1
    fi
done
```

## Funções Principais de Backup

### `_executar_backup()`
Controlador principal do processo de backup.

**Fluxo de execução:**
1. **Seleção de base** (se múltiplas disponíveis)
2. **Criação de diretório** de backup (se necessário)
3. **Escolha do tipo** de backup (completo/incremental)
4. **Geração de nome** do arquivo de backup
5. **Verificação de recentes** para evitar duplicatas
6. **Execução em background** com barra de progresso
7. **Confirmação de envio** para servidor remoto

### Tipos de Backup

#### Backup Completo (`_executar_backup_completo`)
```bash
# Exclusão de arquivos de backup existentes
"$cmd_zip" "$arquivo_destino" ./*.* -x ./*.zip ./*.tar ./*.tar.gz
```

#### Backup Incremental (`_executar_backup_incremental`)
```bash
# Busca arquivos modificados desde data específica
find . -type f -newermt "$data_referencia" \
    ! -name "*.zip" ! -name "*.tar" ! -name "*.tar.gz" -print0 | \
xargs -0 "$cmd_zip" "$arquivo_destino"
```

## Sistema de Restauração

### `_restaurar_backup()`
Interface principal para restauração de backups.

**Funcionalidades:**
- **Listagem automática** de backups disponíveis
- **Busca inteligente** por parte do nome
- **Seleção interativa** quando múltiplos encontrados
- **Escolha entre restauração** completa ou seletiva

### Restauração Completa (`_restaurar_backup_completo`)
```bash
# Restauração de todos os arquivos
"${cmd_unzip:-unzip}" -o "$arquivo_backup" -d "${base_trabalho}"
```

### Restauração Seletiva (`_restaurar_arquivo_especifico`)
```bash
# Extração específica por nome
"${cmd_unzip}" -o "$arquivo_backup" "${nome_arquivo}"*.* -d "${base_trabalho}"
```

## Sistema de Transferência

### Envio para Servidor (`_enviar_backup_servidor`)
Transferência via rsync com configurações SSH.

**Características:**
- **Verificação de dependências** (rsync disponível)
- **Configuração automática** de destino remoto
- **Controle interativo** sobre manutenção de cópia local
- **Feedback visual** durante transferência

```bash
rsync -avzP -e "ssh -p ${PORTA}" "${backup}/${nome_backup}" \
    "${USUARIO}@${IPSERVER}:/${destino_remoto}"
```

### Modo Offline (`_mover_backup_offline`)
Movimentação para diretório local configurado.

```bash
# Mover para diretório offline
mv -f "${backup}/${nome_backup}" "$destino_offline"
```

## Funcionalidades Avançadas

### Verificação de Backups Recentes
```bash
_verificar_backups_recentes() {
    if find "$backup" -maxdepth 1 -ctime -2 -name "${EMPRESA}*zip" -print -quit | grep -q .; then
        # Mostra backups dos últimos 2 dias
        ls -ltrh "${backup}/${EMPRESA}"_*.zip
        return 0
    fi
    return 1
}
```

### Seleção Interativa de Backup
```bash
_selecionar_backup_menu() {
    select escolha in "${backups[@]}" "Cancelar"; do
        # Tratamento de seleção com validação
    done
}
```

### Geração de Nomes de Arquivo
```bash
nome_backup="${EMPRESA}_${base_trabalho}_${tipo_backup}_$(date +%Y%m%d%H%M).zip"
```

## Tratamento de Erros

### Validações Implementadas
- **Variáveis essenciais** antes da execução
- **Comandos externos** necessários
- **Existência de diretórios** de trabalho
- **Permissões de escrita** nos diretórios
- **Datas válidas** para backup incremental

### Recuperação de Erros
- **Mensagens informativas** sobre problemas específicos
- **Opções alternativas** quando possível
- **Logs detalhados** das operações (`${LOG_ATU}`)
- **Confirmações** antes de operações críticas

## Características de Segurança

### Proteções Implementadas
- **Validação rigorosa** de entradas do usuário
- **Controle de permissões** em operações de arquivo
- **Confirmações interativas** antes de operações destrutivas
- **Logs de auditoria** para rastreabilidade

### Sanitização de Dados
- **Nomes de arquivo validados** (maiúsculas e números apenas)
- **Caminhos seguros** com validação de existência
- **Tratamento seguro** de variáveis de ambiente

## Boas Práticas Implementadas

### Organização do Código
- **Funções específicas** por responsabilidade
- **Tratamento uniforme** de erros
- **Comentários claros** sobre cada função
- **Separação lógica** entre tipos de operação

### Interface do Usuário
- **Menus intuitivos** com opções numeradas
- **Feedback visual** constante durante operações
- **Confirmações claras** antes de ações importantes
- **Mensagens coloridas** informativas

### Performance
- **Execução em background** para operações longas
- **Barra de progresso** para feedback visual
- **Processamento eficiente** com find e xargs
- **Verificação mínima** antes de operações

## Dependências Externas

### Comandos Utilizados
- `zip`/`unzip` - Compactação e descompactação
- `rsync` - Transferência segura de arquivos
- `find` - Busca avançada de arquivos
- `date` - Geração de timestamps
- `ls` - Listagem formatada de arquivos

### Variáveis de Ambiente
- `backup` - Diretório de armazenamento de backups
- `EMPRESA` - Nome da empresa para identificação
- `USUARIO` - Usuário para conexão remota
- `IPSERVER` - Endereço do servidor remoto
- `PORTA` - Porta SSH para conexão

## Exemplos de Uso

### Backup Completo
```bash
# Executar backup completo interativo
_executar_backup
# Tipo: completo
# Base: /sav/sav/dados
# Nome: EMPRESA_savdados_completo_202412161430.zip
```

### Backup Incremental
```bash
# Backup desde data específica
_executar_backup
# Tipo: incremental
# Data referência: 12/2024
# Apenas arquivos modificados desde 01/12/2024
```

### Restauração de Arquivo
```bash
# Restaurar arquivo específico
_restaurar_backup
# Backup: backup_20241216.zip
# Restauração: seletiva
# Arquivo: PROGRAMA
```

## Características Avançadas

### Processamento em Background
```bash
# Execução assíncrona com controle de PID
_executar_backup_completo "$caminho_backup" &
backup_pid=$!

# Monitoramento do processo
wait "$backup_pid"
```

### Busca Inteligente de Arquivos
```bash
# Arrays para armazenar resultados
mapfile -t arquivos_backup < <(printf '%s\n' "${backup}"/*.zip)

# Busca por padrão
mapfile -t backups_encontrados < <(ls -1 "${backup}"/*"${nome_backup}"*.zip 2>/dev/null)
```

### Controle de Diretórios Múltiplos
```bash
# Seleção automática baseada em configuração
if [[ -n "${base2}" ]]; then
    _menu_escolha_base || return 1
    base_trabalho="${BASE_TRABALHO}"
else
    base_trabalho="${destino}${base}"
fi
```

## Logs e Auditoria

### Arquivo de Log
- `${LOG_ATU}` - Registro de operações de backup/restauração
- Captura saída de unzip e outras operações
- Rastreabilidade completa das ações

### Informações de Debug
- **Comandos executados** registrados
- **Arquivos processados** listados
- **Erros específicos** detalhados
- **Timestamps** para auditoria

## Considerações de Performance

### Otimizações Implementadas
- **find com -print0** para arquivos com espaços
- **xargs -0** para processamento eficiente
- **Execução em background** para operações longas
- **Verificações mínimas** antes do processamento

### Recursos de Sistema
- **Memória controlada** com arrays locais
- **I/O eficiente** com redirecionamento adequado
- **CPU otimizada** com processamento paralelo quando possível

## Debugging e Desenvolvimento

### Estratégias para Debug
- **Validações em pontos críticos** com mensagens claras
- **Logs detalhados** de todas as operações
- **Variáveis essenciais** verificadas no início
- **Estados intermediários** mostrados ao usuário

### Diagnóstico de Problemas
```bash
# Verificar backups existentes
ls -la "${backup}"

# Testar comandos externos
command -v zip unzip rsync

# Verificar permissões
ls -ld "${backup}"
```

## Casos de Uso Comuns

### Backup Diário Automatizado
```bash
# Backup completo diário
_executar_backup
# Tipo: completo
# Nome: EMPRESA_savdados_completo_20241216.zip
```

### Backup Pré-atualização
```bash
# Backup antes de atualização do sistema
_executar_backup
# Confirmação: enviar para servidor automaticamente
```

### Recuperação de Arquivo Específico
```bash
# Restaurar programa específico
_restaurar_backup
# Seleção: arquivo específico
# Nome: PROGRAMA
```

### Migração Entre Bases
```bash
# Backup de uma base e restauração em outra
_executar_backup  # Base 1
_restaurar_backup # Base 2
```

## Integração com o Sistema

### Dependências de Módulos
- **`config.sh`** - Carregado automaticamente para configurações
- **`utils.sh`** - Funções utilitárias (mensagens, confirmações)
- **`rsync.sh`** - Funcionalidades de rede (se disponível)

### Fluxo de Integração
```
backup.sh → config.sh → sistema de arquivos → rsync/ssh → servidor remoto
```

---

*Documentação gerada automaticamente com base no código fonte e práticas de bash scripting.*