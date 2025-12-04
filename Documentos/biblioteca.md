# Documentacao do Modulo biblioteca.sh

## Visao Geral
O modulo `biblioteca.sh` e responsavel pela **gestao completa de bibliotecas** do **Sistema SAV (Script de Atualizacao Modular)**. Este modulo oferece funcionalidades avancadas para atualizacao, backup e reversao de bibliotecas Transpc e Savatu com tratamento robusto de interrupcoes e processamento paralelo.

## Funcionalidades Principais

### 1. Gestao de Bibliotecas
- **Transpc**: Biblioteca de transporte de dados
- **Savatu**: Biblioteca principal do sistema SAV
- **Múltiplos sistemas**: IsCobol e Micro Focus Cobol
- **Controle de versoes**: Gestao especifica por versao

### 2. Modos de Atualizacao
- **Online**: Download via SFTP com autenticacao
- **Offline**: Processamento de arquivos locais
- **Interativo**: Interface completa com validacoes

### 3. Sistema de Backup
- **Backup automatico**: Antes de qualquer atualizacao
- **Compactacao paralela**: Processamento em background
- **Múltiplos diretorios**: E_EXEC, T_TELAS, X_XML
- **Controle de progresso**: Feedback visual durante operacoes

### 4. Reversao Avancada
- **Reversao completa**: Todos os programas da biblioteca
- **Reversao seletiva**: Programa especifico por nome
- **Validacao de backup**: Verificacao antes da reversao

## Sistema de Tratamento de Interrupcoes

### Traps Configurados
```bash
# Tratamento de sinais criticos
trap '_limpar_interrupcao INT' INT    # Ctrl+C
trap '_limpar_interrupcao TERM' TERM  # kill
```

### Array Global de PIDs
```bash
declare -g pids=()  # Rastreamento de processos em background
```

### Funcao de Limpeza `_limpar_interrupcao()`
**Funcionalidades:**
1. **Interrupcao de processos** pendentes
2. **Limpeza de arquivos** temporarios
3. **Verificacao de backups** parciais
4. **Sugestao de rollback** se necessario

## Estrutura do Codigo

### Variaveis Essenciais
```bash
# Diretorios e configuracoes
destino="${destino:-}"
sistema="${sistema:-}"
cmd_zip="${cmd_zip:-}"
cmd_unzip="${cmd_unzip:-}"

# Array global para PIDs
declare -g pids=()
```

## Funcoes Principais de Atualizacao

### `_atualizar_transpc()`
Atualizacao especifica da biblioteca Transpc.

**Processo:**
1. **Solicitacao de versao** interativa
2. **Configuracao de destino** remoto
3. **Download via SFTP** com autenticacao
4. **Processamento automatico** da biblioteca

### `_atualizar_savatu()`
Atualizacao da biblioteca Savatu baseada no sistema.

**Logica de selecao:**
```bash
# Selecao baseada no sistema
if [[ "${sistema}" = "iscobol" ]]; then
    DESTINO2="${DESTINO2SAVATUISC}"
else
    DESTINO2="${DESTINO2SAVATUMF}"
fi
```

### `_atualizar_biblioteca_offline()`
Processamento de biblioteca em modo offline.

**Caracteristicas:**
- **Validacao de modo** offline ativo
- **Movimentacao de arquivos** do diretorio offline
- **Processamento automatico** apos transferência

## Sistema de Processamento

### `_processar_biblioteca_offline()`
Processa arquivos de biblioteca do servidor offline.

**Arquivos processados:**
```bash
# Para IsCobol
arquivos_update=(
    "${ATUALIZA1}"  # tempSAV_IS2024_classA_*.zip
    "${ATUALIZA2}"  # tempSAV_IS2024_classB_*.zip
    "${ATUALIZA3}"  # tempSAV_IS2024_tel_isc_*.zip
    "${ATUALIZA4}"  # tempSAV_IS2024_xml_*.zip
)

# Para Micro Focus
arquivos_update=(
    "${ATUALIZA1}"  # tempSAVintA_*.zip
    "${ATUALIZA2}"  # tempSAVintB_*.zip
    "${ATUALIZA3}"  # tempSAVtel_*.zip
)
```

### `_salvar_atualizacao_biblioteca()`
Controlador de salvamento e validacao de bibliotecas.

**Validacoes:**
- **Existência de arquivos** de atualizacao
- **Permissoes de leitura** adequadas
- **Integridade dos arquivos** ZIP

## Sistema de Backup Paralelo

### `_processar_atualizacao_biblioteca()`
Processamento avancado com compactacao paralela.

**Etapas por sistema:**
1. **E_EXEC**: Arquivos `.class`, `.int`, `.jpg`, `.png`, etc.
2. **T_TELAS**: Arquivos `.TEL` (telas/interface)
3. **X_XML**: Arquivos `.xml` (apenas IsCobol)

**Caracteristicas tecnicas:**
```bash
# Execucao em background com controle de PID
{
    "$cmd_find" "$E_EXEC"/ -type f \( -iname "*.class" -o -iname "*.int" \) \
    -exec "$cmd_zip" -r -q "${caminho_backup}" {} +
} &
pid_zip_exec=$!
pids+=("$pid_zip_exec")  # Registro para tratamento de interrupcao
```

### Controle de Progresso
```bash
# Monitoramento de cada processo
_mostrar_progresso_backup "$pid_zip_exec"
if wait "$pid_zip_exec"; then
    _mensagec "${GREEN}" "Compactacao de $E_EXEC concluida [Etapa ${contador}/${total_etapas}]"
fi
```

## Sistema de Reversao

### `_reverter_biblioteca()`
Interface principal para reversao de bibliotecas.

**Funcionalidades:**
- **Solicitacao interativa** da versao
- **Validacao de existência** do backup
- **Escolha entre reversao** completa ou seletiva

### Reversao Completa (`_reverter_biblioteca_completa`)
```bash
# Restauracao de todos os arquivos
"${cmd_unzip}" -o "${arquivo_backup}" -d "${raiz}"
```

### Reversao Seletiva (`_reverter_programa_especifico_biblioteca`)
```bash
# Extracao especifica por programa
"${cmd_unzip}" -o "${arquivo_backup}" "${padrao}${programa_reverter}*" -d "/"
```

## Sistema de Download

### `_baixar_biblioteca_rsync()`
Download via SFTP com metodos alternativos.

**Metodos suportados:**
1. **SFTP interativo** (acessossh="n")
2. **SFTP com chave SSH** (acessossh="s")

**Logica de processamento:**
```bash
# Para IsCobol - arquivo único
sftp -P "$PORTA" "${USUARIO}@${IPSERVER}:${DESTINO2}${SAVATU}${VERSAO}.zip" "."

# Para Micro Focus - múltiplos arquivos
for arquivo in "${arquivos_update[@]}"; do
    sftp -P "$PORTA" "${USUARIO}@${IPSERVER}:${DESTINO2}${arquivo}" "."
done
```

## Funcoes Auxiliares

### `_solicitar_versao_biblioteca()`
Solicitacao interativa da versao da biblioteca.

**Caracteristicas:**
- **Validacao de entrada** obrigatoria
- **Mensagens informativas** claras
- **Tratamento de entrada vazia**

### `_definir_variaveis_biblioteca()`
Definicao dinamica de variaveis baseada na versao.

**Padrao de nomenclatura:**
```bash
ATUALIZA1="${SAVATU1}${VERSAO}.zip"
ATUALIZA2="${SAVATU2}${VERSAO}.zip"
ATUALIZA3="${SAVATU3}${VERSAO}.zip"
ATUALIZA4="${SAVATU4}${VERSAO}.zip"
```

## Caracteristicas de Seguranca

### Tratamento de Interrupcoes
```bash
_limpar_interrupcao() {
    # Mata todos os processos pendentes
    for pid in "${pids[@]}"; do
        if kill -0 "$pid" 2>/dev/null; then
            kill "$pid" 2>/dev/null
        fi
    done

    # Limpeza de arquivos temporarios
    for temp_file in *"${VERSAO}".zip *"${VERSAO}".bkp; do
        [[ -f "$temp_file" ]] && rm -f "$temp_file"
    done
}
```

### Validacoes de Seguranca
- **Verificacao de existência** de arquivos criticos
- **Controle de permissoes** em operacoes de arquivo
- **Validacao de versoes** antes do processamento
- **Backup automatico** antes de alteracoes

## Boas Praticas Implementadas

### Processamento Paralelo
- **Compactacao simultanea** de múltiplos diretorios
- **Controle de PIDs** para limpeza adequada
- **Monitoramento individual** de cada processo
- **Tratamento de falhas** especifico por etapa

### Interface do Usuario
- **Feedback visual** durante operacoes longas
- **Controle de progresso** com etapas claras
- **Confirmacoes importantes** antes de acoes criticas
- **Mensagens informativas** sobre o estado atual

### Manutenibilidade
- **Funcoes bem definidas** por responsabilidade
- **Tratamento robusto** de diferentes cenarios
- **Logs detalhados** para auditoria
- **Comentarios claros** sobre logica complexa

## Dependências Externas

### Comandos Utilizados
- `zip`/`unzip` - Compactacao e descompactacao
- `find` - Busca avancada de arquivos
- `sftp` - Transferência segura via SSH
- `mv`/`rm` - Movimentacao e remocao de arquivos
- `cd` - Navegacao entre diretorios

### Variaveis de Ambiente
- `SAVATU*` - Variaveis especificas da biblioteca
- `DESTINO2*` - Caminhos remotos para diferentes sistemas
- `E_EXEC` - Diretorio de executaveis
- `T_TELAS` - Diretorio de telas
- `X_XML` - Diretorio XML (IsCobol)
- `OLDS` - Diretorio de backups

## Exemplos de Uso

### Atualizacao Transpc
```bash
# Atualizacao interativa
_atualizar_transpc
# Versao: 2024
# Sistema: Transpc
# Metodo: SFTP com autenticacao
```

### Atualizacao Savatu IsCobol
```bash
# Atualizacao para IsCobol
_atualizar_savatu
# Sistema: IsCobol
# Versao: 2024
# Destino: DESTINO2SAVATUISC
```

### Reversao de Biblioteca
```bash
# Reversao interativa
_reverter_biblioteca
# Versao: 2024
# Tipo: completa
# Backup: /olds/backup-2024.zip
```

### Modo Offline
```bash
# Processamento offline
_atualizar_biblioteca_offline
# Fonte: /sav/portalsav/Atualiza
# Destino: /sav/TOOLS_DIR
```

## Caracteristicas Avancadas

### Processamento em Background
```bash
# Controle avancado de processos
{
    "$cmd_find" "$E_EXEC"/ -type f -exec "$cmd_zip" -r -q "${caminho_backup}" {} +
} &
pid_zip_exec=$!
pids+=("$pid_zip_exec")  # Registro para interrupcao
```

### Sistema de Logs
```bash
# Logs detalhados de todas as operacoes
>>"${LOG_ATU}" 2>&1  # Captura saida e erro
```

### Controle de Diretorios
```bash
# Validacao de múltiplos caminhos
local diretorios_validar=(
    "DESTINO2SERVER"
    "DESTINO2SAVATUISC"
    "DESTINO2SAVATUMF"
    "DESTINO2TRANSPC"
)
```

## Tratamento de Erros

### Estrategias Implementadas
- **Validacao previa** de todos os parametros
- **Tratamento de interrupcoes** com cleanup
- **Controle de PIDs** para processos orfaos
- **Mensagens especificas** para diferentes tipos de erro
- **Recuperacao automatica** quando possivel

### Codigos de Retorno
- `0` - Sucesso
- `1` - Erro de parametro ou arquivo
- `1` - Falha na transferência ou processamento

## Consideracoes de Performance

### Otimizacoes
- **Processamento paralelo** de múltiplos diretorios
- **Find otimizado** com padroes especificos
- **Compactacao eficiente** com `-r -q`
- **Controle minimo** de progresso durante operacoes

### Recursos de Sistema
- **Memoria controlada** com arrays locais
- **CPU distribuida** entre processos paralelos
- **I/O eficiente** com redirecionamento adequado
- **Limpeza automatica** de recursos temporarios

## Debugging e Desenvolvimento

### Estrategias para Debug
- **Controle de PIDs** visivel durante execucao
- **Logs detalhados** de todas as operacoes
- **Validacoes em pontos criticos** com mensagens claras
- **Estado dos processos** monitorado continuamente

### Diagnostico de Problemas
```bash
# Verificar processos ativos
ps aux | grep -E "(zip|unzip|find)"

# Verificar arquivos temporarios
ls -la *"${VERSAO}".zip *"${VERSAO}".bkp

# Verificar logs
tail -f "${LOG_ATU}"

# Verificar backups
ls -la "${OLDS}/"
```

## Casos de Uso Comuns

### Atualizacao de Producao
```bash
# Atualizacao completa com backup
_atualizar_savatu
# Sistema: IsCobol
# Versao: 2024
# Backup: automatico antes da atualizacao
# Processos: paralelo em background
```

### Recuperacao de Emergência
```bash
# Reversao rapida de biblioteca
_reverter_biblioteca
# Versao: 2024
# Tipo: completa
# Restauracao: todos os arquivos automaticamente
```

### Manutencao Offline
```bash
# Processamento sem conexao
_atualizar_biblioteca_offline
# Fonte: servidor offline local
# Processo: automatico apos movimentacao
```

### Desenvolvimento/Testes
```bash
# Teste de nova versao
_atualizar_transpc
# Versao: teste
# Sistema: desenvolvimento
# Backup: preservado para rollback
```

## Integracao com o Sistema

### Dependências de Modulos
- **`config.sh`** - Configuracoes de conexao e caminhos
- **`utils.sh`** - Funcoes utilitarias (mensagens, progresso)
- **`rsync.sh`** - Funcionalidades de rede (se necessario)

### Fluxo de Integracao
```
biblioteca.sh → config.sh → validacao → processamento paralelo → backup → atualizacao
```

---

*Documentacao gerada automaticamente com base no codigo fonte e praticas de bash scripting.*