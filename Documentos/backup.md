# Documentacao do Modulo backup.sh

## Visao Geral
O modulo `backup.sh` e responsavel pelo **sistema completo de backup e restauracao** do **Sistema SAV (Script de Atualizacao Modular)**. Este modulo oferece funcionalidades avancadas para criacao, gerenciamento e restauracao de backups com interface interativa completa.

## Funcionalidades Principais

### 1. Tipos de Backup
- **Backup Completo**: Todos os arquivos do diretorio selecionado
- **Backup Incremental**: Apenas arquivos modificados desde uma data especifica
- **Verificacao automatica**: Deteccao de backups recentes para evitar duplicatas

### 2. Restauracao de Dados
- **Restauracao completa**: Todos os arquivos do backup
- **Restauracao seletiva**: Arquivos especificos por nome
- **Busca inteligente**: Localizacao automatica por parte do nome

### 3. Transferência de Backups
- **Envio automatico**: Para servidor remoto via rsync
- **Modo offline**: Movimentacao para diretorio local
- **Confirmacao interativa**: Controle sobre manutencao de copias locais

### 4. Interface Interativa
- **Menus visuais**: Selecao clara de opcoes
- **Confirmacoes**: Validacao antes de operacoes criticas
- **Barra de progresso**: Feedback visual durante operacoes

## Estrutura do Codigo

### Variaveis Essenciais
```bash
# Diretorios de dados
destino="${destino:-}"
base="${base:-}"
base2="${base2:-}"
base3="${base3:-}"

# Configuracoes de backup
backup="${backup:-}"
cmd_zip="${cmd_zip:-}"
EMPRESA="${EMPRESA:-}"
```

### Validacoes Iniciais
```bash
# Verificar variaveis essenciais
if [[ -z "$destino" || -z "$sistema" || -z "$dirbackup" ]]; then
    _mensagec "${RED}" "Erro: Variaveis essenciais nao definidas"
    return 1
fi

# Verificar comandos externos
for cmd in zip unzip; do
    if ! command -v "${cmd}" &>/dev/null; then
        _mensagec "${RED}" "Erro: Comando ${cmd} nao encontrado"
        return 1
    fi
done
```

## Funcoes Principais de Backup

### `_executar_backup()`
Controlador principal do processo de backup.

**Fluxo de execucao:**
1. **Selecao de base** (se múltiplas disponiveis)
2. **Criacao de diretorio** de backup (se necessario)
3. **Escolha do tipo** de backup (completo/incremental)
4. **Geracao de nome** do arquivo de backup
5. **Verificacao de recentes** para evitar duplicatas
6. **Execucao em background** com barra de progresso
7. **Confirmacao de envio** para servidor remoto

### Tipos de Backup

#### Backup Completo (`_executar_backup_completo`)
```bash
# Exclusao de arquivos de backup existentes
"$cmd_zip" "$arquivo_destino" ./*.* -x ./*.zip ./*.tar ./*.tar.gz
```

#### Backup Incremental (`_executar_backup_incremental`)
```bash
# Busca arquivos modificados desde data especifica
find . -type f -newermt "$data_referencia" \
    ! -name "*.zip" ! -name "*.tar" ! -name "*.tar.gz" -print0 | \
xargs -0 "$cmd_zip" "$arquivo_destino"
```

## Sistema de Restauracao

### `_restaurar_backup()`
Interface principal para restauracao de backups.

**Funcionalidades:**
- **Listagem automatica** de backups disponiveis
- **Busca inteligente** por parte do nome
- **Selecao interativa** quando múltiplos encontrados
- **Escolha entre restauracao** completa ou seletiva

### Restauracao Completa (`_restaurar_backup_completo`)
```bash
# Restauracao de todos os arquivos
"${cmd_unzip:-unzip}" -o "$arquivo_backup" -d "${base_trabalho}"
```

### Restauracao Seletiva (`_restaurar_arquivo_especifico`)
```bash
# Extracao especifica por nome
"${cmd_unzip}" -o "$arquivo_backup" "${nome_arquivo}"*.* -d "${base_trabalho}"
```

## Sistema de Transferência

### Envio para Servidor (`_enviar_backup_servidor`)
Transferência via rsync com configuracoes SSH.

**Caracteristicas:**
- **Verificacao de dependências** (rsync disponivel)
- **Configuracao automatica** de destino remoto
- **Controle interativo** sobre manutencao de copia local
- **Feedback visual** durante transferência

```bash
rsync -avzP -e "ssh -p ${PORTA}" "${backup}/${nome_backup}" \
    "${USUARIO}@${IPSERVER}:/${destino_remoto}"
```

### Modo Offline (`_mover_backup_offline`)
Movimentacao para diretorio local configurado.

```bash
# Mover para diretorio offline
mv -f "${backup}/${nome_backup}" "$destino_offline"
```

## Funcionalidades Avancadas

### Verificacao de Backups Recentes
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

### Selecao Interativa de Backup
```bash
_selecionar_backup_menu() {
    select escolha in "${backups[@]}" "Cancelar"; do
        # Tratamento de selecao com validacao
    done
}
```

### Geracao de Nomes de Arquivo
```bash
nome_backup="${EMPRESA}_${base_trabalho}_${tipo_backup}_$(date +%Y%m%d%H%M).zip"
```

## Tratamento de Erros

### Validacoes Implementadas
- **Variaveis essenciais** antes da execucao
- **Comandos externos** necessarios
- **Existência de diretorios** de trabalho
- **Permissoes de escrita** nos diretorios
- **Datas validas** para backup incremental

### Recuperacao de Erros
- **Mensagens informativas** sobre problemas especificos
- **Opcoes alternativas** quando possivel
- **Logs detalhados** das operacoes (`${LOG_ATU}`)
- **Confirmacoes** antes de operacoes criticas

## Caracteristicas de Seguranca

### Protecoes Implementadas
- **Validacao rigorosa** de entradas do usuario
- **Controle de permissoes** em operacoes de arquivo
- **Confirmacoes interativas** antes de operacoes destrutivas
- **Logs de auditoria** para rastreabilidade

### Sanitizacao de Dados
- **Nomes de arquivo validados** (maiúsculas e números apenas)
- **Caminhos seguros** com validacao de existência
- **Tratamento seguro** de variaveis de ambiente

## Boas Praticas Implementadas

### Organizacao do Codigo
- **Funcoes especificas** por responsabilidade
- **Tratamento uniforme** de erros
- **Comentarios claros** sobre cada funcao
- **Separacao logica** entre tipos de operacao

### Interface do Usuario
- **Menus intuitivos** com opcoes numeradas
- **Feedback visual** constante durante operacoes
- **Confirmacoes claras** antes de acoes importantes
- **Mensagens coloridas** informativas

### Performance
- **Execucao em background** para operacoes longas
- **Barra de progresso** para feedback visual
- **Processamento eficiente** com find e xargs
- **Verificacao minima** antes de operacoes

## Dependências Externas

### Comandos Utilizados
- `zip`/`unzip` - Compactacao e descompactacao
- `rsync` - Transferência segura de arquivos
- `find` - Busca avancada de arquivos
- `date` - Geracao de timestamps
- `ls` - Listagem formatada de arquivos

### Variaveis de Ambiente
- `backup` - Diretorio de armazenamento de backups
- `EMPRESA` - Nome da empresa para identificacao
- `USUARIO` - Usuario para conexao remota
- `IPSERVER` - Endereco do servidor remoto
- `PORTA` - Porta SSH para conexao

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
# Backup desde data especifica
_executar_backup
# Tipo: incremental
# Data referência: 12/2024
# Apenas arquivos modificados desde 01/12/2024
```

### Restauracao de Arquivo
```bash
# Restaurar arquivo especifico
_restaurar_backup
# Backup: backup_20241216.zip
# Restauracao: seletiva
# Arquivo: PROGRAMA
```

## Caracteristicas Avancadas

### Processamento em Background
```bash
# Execucao assincrona com controle de PID
_executar_backup_completo "$caminho_backup" &
backup_pid=$!

# Monitoramento do processo
wait "$backup_pid"
```

### Busca Inteligente de Arquivos
```bash
# Arrays para armazenar resultados
mapfile -t arquivos_backup < <(printf '%s\n' "${backup}"/*.zip)

# Busca por padrao
mapfile -t backups_encontrados < <(ls -1 "${backup}"/*"${nome_backup}"*.zip 2>/dev/null)
```

### Controle de Diretorios Múltiplos
```bash
# Selecao automatica baseada em configuracao
if [[ -n "${base2}" ]]; then
    _menu_escolha_base || return 1
    base_trabalho="${BASE_TRABALHO}"
else
    base_trabalho="${destino}${base}"
fi
```

## Logs e Auditoria

### Arquivo de Log
- `${LOG_ATU}` - Registro de operacoes de backup/restauracao
- Captura saida de unzip e outras operacoes
- Rastreabilidade completa das acoes

### Informacoes de Debug
- **Comandos executados** registrados
- **Arquivos processados** listados
- **Erros especificos** detalhados
- **Timestamps** para auditoria

## Consideracoes de Performance

### Otimizacoes Implementadas
- **find com -print0** para arquivos com espacos
- **xargs -0** para processamento eficiente
- **Execucao em background** para operacoes longas
- **Verificacoes minimas** antes do processamento

### Recursos de Sistema
- **Memoria controlada** com arrays locais
- **I/O eficiente** com redirecionamento adequado
- **CPU otimizada** com processamento paralelo quando possivel

## Debugging e Desenvolvimento

### Estrategias para Debug
- **Validacoes em pontos criticos** com mensagens claras
- **Logs detalhados** de todas as operacoes
- **Variaveis essenciais** verificadas no inicio
- **Estados intermediarios** mostrados ao usuario

### Diagnostico de Problemas
```bash
# Verificar backups existentes
ls -la "${backup}"

# Testar comandos externos
command -v zip unzip rsync

# Verificar permissoes
ls -ld "${backup}"
```

## Casos de Uso Comuns

### Backup Diario Automatizado
```bash
# Backup completo diario
_executar_backup
# Tipo: completo
# Nome: EMPRESA_savdados_completo_20241216.zip
```

### Backup Pre-atualizacao
```bash
# Backup antes de atualizacao do sistema
_executar_backup
# Confirmacao: enviar para servidor automaticamente
```

### Recuperacao de Arquivo Especifico
```bash
# Restaurar programa especifico
_restaurar_backup
# Selecao: arquivo especifico
# Nome: PROGRAMA
```

### Migracao Entre Bases
```bash
# Backup de uma base e restauracao em outra
_executar_backup  # Base 1
_restaurar_backup # Base 2
```

## Integracao com o Sistema

### Dependências de Modulos
- **`config.sh`** - Carregado automaticamente para configuracoes
- **`utils.sh`** - Funcoes utilitarias (mensagens, confirmacoes)
- **`rsync.sh`** - Funcionalidades de rede (se disponivel)

### Fluxo de Integracao
```
backup.sh → config.sh → sistema de arquivos → rsync/ssh → servidor remoto
```

---

*Documentacao gerada automaticamente com base no codigo fonte e praticas de bash scripting.*