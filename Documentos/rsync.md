# Documentacao do Modulo rsync.sh

## Visao Geral
O modulo `rsync.sh` e responsavel pelas **operacoes de sincronizacao e transferência de arquivos** via rede no **Sistema SAV (Script de Atualizacao Modular)**. Este modulo oferece funcionalidades avancadas para download, upload e sincronizacao usando múltiplos protocolos com tratamento robusto de erros.

## Funcionalidades Principais

### 1. Protocolos Suportados
- **SFTP** (Secure File Transfer Protocol)
- **RSYNC** (Remote Synchronization)
- **SSH** (Secure Shell) para conexoes autenticadas

### 2. Operacoes de Rede
- **Download** de arquivos individuais ou bibliotecas completas
- **Upload** de arquivos locais para servidor remoto
- **Sincronizacao** de bibliotecas do sistema SAV
- **Listagem** de arquivos remotos

### 3. Recursos Avancados
- **Verificacao de conectividade** antes das operacoes
- **Sistema de retry** automatico com configuracao personalizavel
- **Verificacao de integridade** de arquivos transferidos
- **Limpeza automatica** de arquivos temporarios

## Estrutura do Codigo

### Variaveis Essenciais
```bash
# Configuracoes de conexao
destino="${destino:-}"
sistema="${sistema:-}"
acessossh="${acessossh:-}"

# Comandos externos
cmd_zip="${cmd_zip:-}"
cmd_unzip="${cmd_unzip:-}"
cmd_find="${cmd_find:-}"
```

### Parametros Obrigatorios
```bash
# Validacao de parametros essenciais
local parametros_obrigatorios=(
    "PORTA"
    "USUARIO"
    "IPSERVER"
)
```

## Funcoes de Configuracao

### `_configurar_conexao()`
Configura parametros de conexao e valida dependências.

**Funcionalidades:**
- **Validacao de parametros** obrigatorios (PORTA, USUARIO, IPSERVER)
- **Configuracao automatica** de destinos baseada no sistema
- **Definicao de caminhos** especificos para IsCobol/Micro Focus

```bash
# Configuracao baseada no sistema
case "${sistema}" in
    "iscobol") DESTINO2="${DESTINO2SAVATUISC}" ;;
    *) DESTINO2="${DESTINO2SAVATUMF}" ;;
esac
```

### `_testar_conexao()`
Testa conectividade com servidor remoto.

**Metodos utilizados:**
1. **netcat (nc)** - Metodo preferencial
2. **telnet** - Metodo alternativo
3. **timeout** - Controle de tempo limite

```bash
# Teste com netcat
nc -z -w"$timeout" "$servidor" "$porta"

# Teste alternativo com telnet
timeout "$timeout" telnet "$servidor" "$porta"
```

## Funcoes de Download

### `_download_sftp()`
Download via SFTP com autenticacao interativa.

**Caracteristicas:**
- **Verificacao de conectividade** antes do download
- **Logs detalhados** de todas as operacoes
- **Tratamento de erros** especifico
- **Parametros configuraveis** (servidor, porta, usuario)

```bash
# Execucao SFTP
sftp -P "$porta" "${usuario}@${servidor}:${arquivo_remoto}" "$destino_local"
```

### `_download_sftp_ssh()`
Download via SFTP usando configuracao SSH existente.

**Caracteristicas:**
- **Uso de configuracao** `sav_servidor` existente
- **Here document** para comandos automatizados
- **Controle de status** de saida

```bash
sftp sav_servidor <<EOF
get "${arquivo_remoto}" "${destino_local}"
quit
EOF
```

### `_download_rsync()`
Download via RSYNC com sincronizacao avancada.

**Caracteristicas:**
- **Sincronizacao incremental** automatica
- **Preservacao de permissoes** e timestamps
- **Progresso detalhado** com `-P`
- **Compressao** durante transferência com `-z`

```bash
rsync -avzP -e "ssh -p ${porta}" "$origem_completa" "$destino_local"
```

## Funcoes de Upload

### `_upload_sftp()`
Upload via SFTP para servidor remoto.

**Caracteristicas:**
- **Validacao de existência** do arquivo local
- **Verificacao de conectividade** antes do upload
- **Here document** para comandos automatizados
- **Logs detalhados** do processo

### `_upload_rsync()`
Upload via RSYNC com recursos avancados.

**Caracteristicas:**
- **Sincronizacao bidirecional** possivel
- **Compressao automatica** durante transferência
- **Preservacao completa** de atributos de arquivo
- **Relatorio de progresso** detalhado

## Sistema de Sincronizacao de Biblioteca

### `_sincronizar_biblioteca()`
Sincronizacao completa de bibliotecas SAV.

**Processo:**
1. **Configuracao de conexao** e validacao
2. **Definicao de variaveis** especificas da biblioteca
3. **Sincronizacao sequencial** de todos os arquivos
4. **Controle de falhas** com contador
5. **Feedback visual** durante o processo

**Arquivos sincronizados:**
```bash
# Para IsCobol
arquivos_sync=(
    "${SYNC_ATUALIZA1}"  # tempSAV_IS2024_classA_*.zip
    "${SYNC_ATUALIZA2}"  # tempSAV_IS2024_classB_*.zip
    "${SYNC_ATUALIZA3}"  # tempSAV_IS2024_tel_isc_*.zip
    "${SYNC_ATUALIZA4}"  # tempSAV_IS2024_xml_*.zip
)
```

### `_definir_variaveis_biblioteca_rsync()`
Define variaveis especificas para sincronizacao baseada na versao e sistema.

**Logica de definicao:**
- **trans_pc**: Caminho especifico para transferência PC
- **ISCobol**: Caminho padrao IsCobol
- **Padrao**: Caminho alternativo para outros sistemas

## Funcoes de Verificacao

### `_verificar_integridade()`
Verificacao completa de integridade de arquivos baixados.

**Verificacoes realizadas:**
1. **Existência do arquivo**
2. **Tamanho nao-zero**
3. **Tamanho minimo** (1KB por padrao)
4. **Validade do ZIP** (se aplicavel)

```bash
# Verificacoes de tamanho
local tamanho_arquivo
tamanho_arquivo=$(stat -c%s "$arquivo" 2>/dev/null || echo "0")

# Teste de ZIP
"${cmd_unzip}" -t "$arquivo" >/dev/null 2>&1
```

### `_listar_arquivos_remotos()`
Lista arquivos em diretorio remoto via SFTP.

**Caracteristicas:**
- **Comandos interativos** via here document
- **Formatacao detalhada** (`ls -la`)
- **Navegacao remota** (`cd` remoto)

## Funcoes de Limpeza

### `_limpar_temporarios_sync()`
Remove arquivos e diretorios temporarios de sincronizacao.

**Diretorios limpos:**
- `${TOOLS_DIR}/temp_sync`
- `${ENVIA}/temp_update`
- `${RECEBE}/temp_download`

**Arquivos removidos:**
- **Arquivos `.part`** (downloads incompletos)
- **Diretorios temporarios** criados durante operacoes

## Sistema de Configuracao SSH

### `_configurar_ssh()`
Verifica e configura chaves SSH se necessario.

**Funcionalidades:**
- **Criacao automatica** de diretorio `.ssh`
- **Verificacao de configuracao** existente
- **Permissoes adequadas** (700 para diretorios, 600 para arquivos)
- **Deteccao automatica** de configuracao `sav_servidor`

## Sistema de Retry

### `_executar_com_retry()`
Executa comandos com tentativas automaticas de recuperacao.

**Caracteristicas:**
- **Configuracao personalizavel** de tentativas e intervalos
- **Logs detalhados** de cada tentativa
- **Pausa progressiva** entre tentativas
- **Controle de sucesso/falha** preciso

```bash
# Configuracao padrao: 3 tentativas, 5 segundos de intervalo
local max_tentativas="${2:-3}"
local intervalo="${3:-5}"
```

## Tratamento de Logs

### Sistema de Logging
O modulo implementa três niveis de logging:

#### `_log()` - Informacao geral
```bash
_log "Iniciando download RSYNC: ${origem_remota}"
```

#### `_log_sucesso()` - Operacoes bem-sucedidas
```bash
_log_sucesso "Download RSYNC concluido: ${origem_remota}"
```

#### `_log_erro()` - Erros e falhas
```bash
_log_erro "Falha no download RSYNC: ${origem_remota}"
```

## Caracteristicas de Seguranca

### Validacoes de Seguranca
- **Verificacao de conectividade** antes de operacoes
- **Validacao de parametros** obrigatorios
- **Controle de permissoes** em arquivos SSH
- **Sanitizacao de caminhos** de arquivo

### Tratamento Seguro de Conexoes
- **Teste de conectividade** antes de transferências
- **Configuracao segura** de SSH
- **Controle de timeout** em operacoes de rede
- **Logs de auditoria** para rastreabilidade

## Boas Praticas Implementadas

### Organizacao do Codigo
- **Funcoes especificas** por protocolo/metodo
- **Validacoes centralizadas** na configuracao
- **Tratamento uniforme** de erros
- **Logs estruturados** para auditoria

### Performance
- **Múltiplos protocolos** para diferentes cenarios
- **Sistema de retry** para redes instaveis
- **Limpeza automatica** de temporarios
- **Verificacao eficiente** de integridade

### Manutenibilidade
- **Comentarios claros** sobre cada funcao
- **Parametros bem documentados**
- **Tratamento robusto** de diferentes cenarios
- **Configuracao flexivel** baseada em variaveis

## Dependências Externas

### Comandos Utilizados
- `rsync` - Sincronizacao remota de arquivos
- `sftp` - Transferência segura de arquivos
- `ssh` - Conexoes seguras (via rsync -e)
- `nc`/`telnet` - Teste de conectividade
- `stat` - Informacoes de arquivos
- `find` - Busca avancada (em outros modulos)

### Variaveis de Ambiente
- `IPSERVER` - Endereco do servidor remoto
- `PORTA` - Porta para conexao
- `USUARIO` - Usuario para autenticacao
- `DESTINO2` - Caminho remoto base
- `SAVATU*` - Variaveis especificas da biblioteca

## Exemplos de Uso

### Download de Arquivo Individual
```bash
# Download via SFTP
_download_sftp "caminho/remoto/arquivo.zip"

# Download via SFTP com SSH configurado
_download_sftp_ssh "caminho/remoto/arquivo.zip"

# Download via RSYNC
_download_rsync "caminho/remoto/arquivo.zip"
```

### Upload de Arquivo
```bash
# Upload via SFTP
_upload_sftp "arquivo_local.zip" "destino/remoto/"

# Upload via RSYNC
_upload_rsync "arquivo_local.zip" "destino/remoto/"
```

### Sincronizacao de Biblioteca
```bash
# Sincronizar biblioteca versao 2024
_sincronizar_biblioteca "2024"

# Para sistema especifico
_sincronizar_biblioteca "2024" "iscobol"
```

### Verificacao de Conectividade
```bash
# Teste basico
_testar_conexao "$IPSERVER" "$PORTA"

# Teste com timeout personalizado
_testar_conexao "$IPSERVER" "$PORTA" "10"
```

## Caracteristicas Avancadas

### Configuracao Dinamica de Destinos
```bash
# Definicao baseada no caminho remoto
case "${DESTINO2}" in
    *"trans_pc"*)
        SYNC_ATUALIZA1="${DESTINO2TRANSPC}${SAVATU1}${versao}.zip"
        ;;
    *"ISCobol"*)
        SYNC_ATUALIZA1="${DESTINO2SAVATUISC}${SAVATU1}${versao}.zip"
        ;;
    *)
        SYNC_ATUALIZA1="${DESTINO2SAVATUMF}${SAVATU1}${versao}.zip"
        ;;
esac
```

### Controle de Metodo de Acesso
```bash
# Escolha automatica baseada na configuracao
if [[ "${acessossh}" == "n" ]]; then
    _download_sftp "$arquivo"    # Metodo interativo
else
    _download_sftp_ssh "$arquivo" # Metodo com chave SSH
fi
```

### Sistema de Logs Estruturado
```bash
# Cada operacao gera logs detalhados
_log "Iniciando operacao..."
_log_sucesso "Operacao concluida com sucesso"
_log_erro "Falha na operacao: motivo"
```

## Tratamento de Erros

### Estrategias Implementadas
- **Validacao previa** de todos os parametros
- **Teste de conectividade** antes de operacoes
- **Sistema de retry** para falhas temporarias
- **Mensagens especificas** para diferentes tipos de erro
- **Logs detalhados** para auditoria e debug

### Codigos de Retorno
- `0` - Sucesso
- `1` - Erro de parametro ou conectividade
- `1` - Falha na transferência
- `1` - Arquivo nao encontrado ou corrompido

## Consideracoes de Performance

### Otimizacoes
- **RSYNC eficiente** com compressao e progresso
- **SFTP direto** para arquivos individuais
- **Sistema de retry** para redes instaveis
- **Limpeza automatica** de arquivos temporarios

### Recursos de Rede
- **Teste de conectividade** antes de operacoes longas
- **Timeout controlado** em operacoes de rede
- **Múltiplos protocolos** para diferentes cenarios
- **Relatorio de progresso** para operacoes longas

## Debugging e Desenvolvimento

### Estrategias para Debug
- **Logs detalhados** de todas as operacoes
- **Teste de conectividade** independente
- **Validacao de parametros** em pontos criticos
- **Mensagens claras** sobre falhas especificas

### Diagnostico de Problemas
```bash
# Testar conectividade
_testar_conexao "$IPSERVER" "$PORTA"

# Verificar configuracao SSH
_configurar_ssh

# Listar arquivos remotos
_listar_arquivos_remotos "caminho/remoto/"

# Verificar integridade de arquivo
_verificar_integridade "arquivo.zip"
```

## Integracao com o Sistema

### Dependências de Modulos
- **`config.sh`** - Configuracoes de conexao
- **`utils.sh`** - Funcoes utilitarias (logs, mensagens)
- **Sistema de arquivos** - Validacao de caminhos locais

### Fluxo de Integracao
```
rsync.sh → config.sh → validacao → protocolos (SFTP/RSYNC) → servidor remoto
```

---

*Documentacao gerada automaticamente com base no codigo fonte e praticas de bash scripting.*