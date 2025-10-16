# Documentação do Módulo biblioteca.sh

## Visão Geral
O módulo `biblioteca.sh` é responsável pela **gestão completa de bibliotecas** do **Sistema SAV (Script de Atualização Modular)**. Este módulo oferece funcionalidades avançadas para atualização, backup e reversão de bibliotecas Transpc e Savatu com tratamento robusto de interrupções e processamento paralelo.

## Funcionalidades Principais

### 1. Gestão de Bibliotecas
- **Transpc**: Biblioteca de transporte de dados
- **Savatu**: Biblioteca principal do sistema SAV
- **Múltiplos sistemas**: IsCobol e Micro Focus Cobol
- **Controle de versões**: Gestão específica por versão

### 2. Modos de Atualização
- **Online**: Download via SFTP com autenticação
- **Offline**: Processamento de arquivos locais
- **Interativo**: Interface completa com validações

### 3. Sistema de Backup
- **Backup automático**: Antes de qualquer atualização
- **Compactação paralela**: Processamento em background
- **Múltiplos diretórios**: E_EXEC, T_TELAS, X_XML
- **Controle de progresso**: Feedback visual durante operações

### 4. Reversão Avançada
- **Reversão completa**: Todos os programas da biblioteca
- **Reversão seletiva**: Programa específico por nome
- **Validação de backup**: Verificação antes da reversão

## Sistema de Tratamento de Interrupções

### Traps Configurados
```bash
# Tratamento de sinais críticos
trap '_limpar_interrupcao INT' INT    # Ctrl+C
trap '_limpar_interrupcao TERM' TERM  # kill
```

### Array Global de PIDs
```bash
declare -g pids=()  # Rastreamento de processos em background
```

### Função de Limpeza `_limpar_interrupcao()`
**Funcionalidades:**
1. **Interrupção de processos** pendentes
2. **Limpeza de arquivos** temporários
3. **Verificação de backups** parciais
4. **Sugestão de rollback** se necessário

## Estrutura do Código

### Variáveis Essenciais
```bash
# Diretórios e configurações
destino="${destino:-}"
sistema="${sistema:-}"
cmd_zip="${cmd_zip:-}"
cmd_unzip="${cmd_unzip:-}"

# Array global para PIDs
declare -g pids=()
```

## Funções Principais de Atualização

### `_atualizar_transpc()`
Atualização específica da biblioteca Transpc.

**Processo:**
1. **Solicitação de versão** interativa
2. **Configuração de destino** remoto
3. **Download via SFTP** com autenticação
4. **Processamento automático** da biblioteca

### `_atualizar_savatu()`
Atualização da biblioteca Savatu baseada no sistema.

**Lógica de seleção:**
```bash
# Seleção baseada no sistema
if [[ "${sistema}" = "iscobol" ]]; then
    DESTINO2="${DESTINO2SAVATUISC}"
else
    DESTINO2="${DESTINO2SAVATUMF}"
fi
```

### `_atualizar_biblioteca_offline()`
Processamento de biblioteca em modo offline.

**Características:**
- **Validação de modo** offline ativo
- **Movimentação de arquivos** do diretório offline
- **Processamento automático** após transferência

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
Controlador de salvamento e validação de bibliotecas.

**Validações:**
- **Existência de arquivos** de atualização
- **Permissões de leitura** adequadas
- **Integridade dos arquivos** ZIP

## Sistema de Backup Paralelo

### `_processar_atualizacao_biblioteca()`
Processamento avançado com compactação paralela.

**Etapas por sistema:**
1. **E_EXEC**: Arquivos `.class`, `.int`, `.jpg`, `.png`, etc.
2. **T_TELAS**: Arquivos `.TEL` (telas/interface)
3. **X_XML**: Arquivos `.xml` (apenas IsCobol)

**Características técnicas:**
```bash
# Execução em background com controle de PID
{
    "$cmd_find" "$E_EXEC"/ -type f \( -iname "*.class" -o -iname "*.int" \) \
    -exec "$cmd_zip" -r -q "${caminho_backup}" {} +
} &
pid_zip_exec=$!
pids+=("$pid_zip_exec")  # Registro para tratamento de interrupção
```

### Controle de Progresso
```bash
# Monitoramento de cada processo
_mostrar_progresso_backup "$pid_zip_exec"
if wait "$pid_zip_exec"; then
    _mensagec "${GREEN}" "Compactação de $E_EXEC concluída [Etapa ${contador}/${total_etapas}]"
fi
```

## Sistema de Reversão

### `_reverter_biblioteca()`
Interface principal para reversão de bibliotecas.

**Funcionalidades:**
- **Solicitação interativa** da versão
- **Validação de existência** do backup
- **Escolha entre reversão** completa ou seletiva

### Reversão Completa (`_reverter_biblioteca_completa`)
```bash
# Restauração de todos os arquivos
"${cmd_unzip}" -o "${arquivo_backup}" -d "${raiz}"
```

### Reversão Seletiva (`_reverter_programa_especifico_biblioteca`)
```bash
# Extração específica por programa
"${cmd_unzip}" -o "${arquivo_backup}" "${padrao}${programa_reverter}*" -d "/"
```

## Sistema de Download

### `_baixar_biblioteca_rsync()`
Download via SFTP com métodos alternativos.

**Métodos suportados:**
1. **SFTP interativo** (acessossh="n")
2. **SFTP com chave SSH** (acessossh="s")

**Lógica de processamento:**
```bash
# Para IsCobol - arquivo único
sftp -P "$PORTA" "${USUARIO}@${IPSERVER}:${DESTINO2}${SAVATU}${VERSAO}.zip" "."

# Para Micro Focus - múltiplos arquivos
for arquivo in "${arquivos_update[@]}"; do
    sftp -P "$PORTA" "${USUARIO}@${IPSERVER}:${DESTINO2}${arquivo}" "."
done
```

## Funções Auxiliares

### `_solicitar_versao_biblioteca()`
Solicitação interativa da versão da biblioteca.

**Características:**
- **Validação de entrada** obrigatória
- **Mensagens informativas** claras
- **Tratamento de entrada vazia**

### `_definir_variaveis_biblioteca()`
Definição dinâmica de variáveis baseada na versão.

**Padrão de nomenclatura:**
```bash
ATUALIZA1="${SAVATU1}${VERSAO}.zip"
ATUALIZA2="${SAVATU2}${VERSAO}.zip"
ATUALIZA3="${SAVATU3}${VERSAO}.zip"
ATUALIZA4="${SAVATU4}${VERSAO}.zip"
```

## Características de Segurança

### Tratamento de Interrupções
```bash
_limpar_interrupcao() {
    # Mata todos os processos pendentes
    for pid in "${pids[@]}"; do
        if kill -0 "$pid" 2>/dev/null; then
            kill "$pid" 2>/dev/null
        fi
    done

    # Limpeza de arquivos temporários
    for temp_file in *"${VERSAO}".zip *"${VERSAO}".bkp; do
        [[ -f "$temp_file" ]] && rm -f "$temp_file"
    done
}
```

### Validações de Segurança
- **Verificação de existência** de arquivos críticos
- **Controle de permissões** em operações de arquivo
- **Validação de versões** antes do processamento
- **Backup automático** antes de alterações

## Boas Práticas Implementadas

### Processamento Paralelo
- **Compactação simultânea** de múltiplos diretórios
- **Controle de PIDs** para limpeza adequada
- **Monitoramento individual** de cada processo
- **Tratamento de falhas** específico por etapa

### Interface do Usuário
- **Feedback visual** durante operações longas
- **Controle de progresso** com etapas claras
- **Confirmações importantes** antes de ações críticas
- **Mensagens informativas** sobre o estado atual

### Manutenibilidade
- **Funções bem definidas** por responsabilidade
- **Tratamento robusto** de diferentes cenários
- **Logs detalhados** para auditoria
- **Comentários claros** sobre lógica complexa

## Dependências Externas

### Comandos Utilizados
- `zip`/`unzip` - Compactação e descompactação
- `find` - Busca avançada de arquivos
- `sftp` - Transferência segura via SSH
- `mv`/`rm` - Movimentação e remoção de arquivos
- `cd` - Navegação entre diretórios

### Variáveis de Ambiente
- `SAVATU*` - Variáveis específicas da biblioteca
- `DESTINO2*` - Caminhos remotos para diferentes sistemas
- `E_EXEC` - Diretório de executáveis
- `T_TELAS` - Diretório de telas
- `X_XML` - Diretório XML (IsCobol)
- `OLDS` - Diretório de backups

## Exemplos de Uso

### Atualização Transpc
```bash
# Atualização interativa
_atualizar_transpc
# Versão: 2024
# Sistema: Transpc
# Método: SFTP com autenticação
```

### Atualização Savatu IsCobol
```bash
# Atualização para IsCobol
_atualizar_savatu
# Sistema: IsCobol
# Versão: 2024
# Destino: DESTINO2SAVATUISC
```

### Reversão de Biblioteca
```bash
# Reversão interativa
_reverter_biblioteca
# Versão: 2024
# Tipo: completa
# Backup: /olds/backup-2024.zip
```

### Modo Offline
```bash
# Processamento offline
_atualizar_biblioteca_offline
# Fonte: /sav/portalsav/Atualiza
# Destino: /sav/tools
```

## Características Avançadas

### Processamento em Background
```bash
# Controle avançado de processos
{
    "$cmd_find" "$E_EXEC"/ -type f -exec "$cmd_zip" -r -q "${caminho_backup}" {} +
} &
pid_zip_exec=$!
pids+=("$pid_zip_exec")  # Registro para interrupção
```

### Sistema de Logs
```bash
# Logs detalhados de todas as operações
>>"${LOG_ATU}" 2>&1  # Captura saída e erro
```

### Controle de Diretórios
```bash
# Validação de múltiplos caminhos
local diretorios_validar=(
    "DESTINO2SERVER"
    "DESTINO2SAVATUISC"
    "DESTINO2SAVATUMF"
    "DESTINO2TRANSPC"
)
```

## Tratamento de Erros

### Estratégias Implementadas
- **Validação prévia** de todos os parâmetros
- **Tratamento de interrupções** com cleanup
- **Controle de PIDs** para processos órfãos
- **Mensagens específicas** para diferentes tipos de erro
- **Recuperação automática** quando possível

### Códigos de Retorno
- `0` - Sucesso
- `1` - Erro de parâmetro ou arquivo
- `1` - Falha na transferência ou processamento

## Considerações de Performance

### Otimizações
- **Processamento paralelo** de múltiplos diretórios
- **Find otimizado** com padrões específicos
- **Compactação eficiente** com `-r -q`
- **Controle mínimo** de progresso durante operações

### Recursos de Sistema
- **Memória controlada** com arrays locais
- **CPU distribuída** entre processos paralelos
- **I/O eficiente** com redirecionamento adequado
- **Limpeza automática** de recursos temporários

## Debugging e Desenvolvimento

### Estratégias para Debug
- **Controle de PIDs** visível durante execução
- **Logs detalhados** de todas as operações
- **Validações em pontos críticos** com mensagens claras
- **Estado dos processos** monitorado continuamente

### Diagnóstico de Problemas
```bash
# Verificar processos ativos
ps aux | grep -E "(zip|unzip|find)"

# Verificar arquivos temporários
ls -la *"${VERSAO}".zip *"${VERSAO}".bkp

# Verificar logs
tail -f "${LOG_ATU}"

# Verificar backups
ls -la "${OLDS}/"
```

## Casos de Uso Comuns

### Atualização de Produção
```bash
# Atualização completa com backup
_atualizar_savatu
# Sistema: IsCobol
# Versão: 2024
# Backup: automático antes da atualização
# Processos: paralelo em background
```

### Recuperação de Emergência
```bash
# Reversão rápida de biblioteca
_reverter_biblioteca
# Versão: 2024
# Tipo: completa
# Restauração: todos os arquivos automaticamente
```

### Manutenção Offline
```bash
# Processamento sem conexão
_atualizar_biblioteca_offline
# Fonte: servidor offline local
# Processo: automático após movimentação
```

### Desenvolvimento/Testes
```bash
# Teste de nova versão
_atualizar_transpc
# Versão: teste
# Sistema: desenvolvimento
# Backup: preservado para rollback
```

## Integração com o Sistema

### Dependências de Módulos
- **`config.sh`** - Configurações de conexão e caminhos
- **`utils.sh`** - Funções utilitárias (mensagens, progresso)
- **`rsync.sh`** - Funcionalidades de rede (se necessário)

### Fluxo de Integração
```
biblioteca.sh → config.sh → validação → processamento paralelo → backup → atualização
```

---

*Documentação gerada automaticamente com base no código fonte e práticas de bash scripting.*