# Documentação do Módulo rsync.sh

## Visão Geral
O módulo `rsync.sh` é responsável pelas **operações de sincronização e transferência de arquivos** via rede no **Sistema SAV (Script de Atualização Modular)**. Este módulo oferece funcionalidades avançadas para download, upload e sincronização usando múltiplos protocolos com tratamento robusto de erros.

## Funcionalidades Principais

### 1. Protocolos Suportados
- **SFTP** (Secure File Transfer Protocol)
- **RSYNC** (Remote Synchronization)
- **SSH** (Secure Shell) para conexões autenticadas

### 2. Operações de Rede
- **Download** de arquivos individuais ou bibliotecas completas
- **Upload** de arquivos locais para servidor remoto
- **Sincronização** de bibliotecas do sistema SAV
- **Listagem** de arquivos remotos

### 3. Recursos Avançados
- **Verificação de conectividade** antes das operações
- **Sistema de retry** automático com configuração personalizável
- **Verificação de integridade** de arquivos transferidos
- **Limpeza automática** de arquivos temporários

## Estrutura do Código

### Variáveis Essenciais
```bash
# Configurações de conexão
destino="${destino:-}"
sistema="${sistema:-}"
acessossh="${acessossh:-}"

# Comandos externos
cmd_zip="${cmd_zip:-}"
cmd_unzip="${cmd_unzip:-}"
cmd_find="${cmd_find:-}"
```

### Parâmetros Obrigatórios
```bash
# Validação de parâmetros essenciais
local parametros_obrigatorios=(
    "PORTA"
    "USUARIO"
    "IPSERVER"
)
```

## Funções de Configuração

### `_configurar_conexao()`
Configura parâmetros de conexão e valida dependências.

**Funcionalidades:**
- **Validação de parâmetros** obrigatórios (PORTA, USUARIO, IPSERVER)
- **Configuração automática** de destinos baseada no sistema
- **Definição de caminhos** específicos para IsCobol/Micro Focus

```bash
# Configuração baseada no sistema
case "${sistema}" in
    "iscobol") DESTINO2="${DESTINO2SAVATUISC}" ;;
    *) DESTINO2="${DESTINO2SAVATUMF}" ;;
esac
```

### `_testar_conexao()`
Testa conectividade com servidor remoto.

**Métodos utilizados:**
1. **netcat (nc)** - Método preferencial
2. **telnet** - Método alternativo
3. **timeout** - Controle de tempo limite

```bash
# Teste com netcat
nc -z -w"$timeout" "$servidor" "$porta"

# Teste alternativo com telnet
timeout "$timeout" telnet "$servidor" "$porta"
```

## Funções de Download

### `_download_sftp()`
Download via SFTP com autenticação interativa.

**Características:**
- **Verificação de conectividade** antes do download
- **Logs detalhados** de todas as operações
- **Tratamento de erros** específico
- **Parâmetros configuráveis** (servidor, porta, usuário)

```bash
# Execução SFTP
sftp -P "$porta" "${usuario}@${servidor}:${arquivo_remoto}" "$destino_local"
```

### `_download_sftp_ssh()`
Download via SFTP usando configuração SSH existente.

**Características:**
- **Uso de configuração** `sav_servidor` existente
- **Here document** para comandos automatizados
- **Controle de status** de saída

```bash
sftp sav_servidor <<EOF
get "${arquivo_remoto}" "${destino_local}"
quit
EOF
```

### `_download_rsync()`
Download via RSYNC com sincronização avançada.

**Características:**
- **Sincronização incremental** automática
- **Preservação de permissões** e timestamps
- **Progresso detalhado** com `-P`
- **Compressão** durante transferência com `-z`

```bash
rsync -avzP -e "ssh -p ${porta}" "$origem_completa" "$destino_local"
```

## Funções de Upload

### `_upload_sftp()`
Upload via SFTP para servidor remoto.

**Características:**
- **Validação de existência** do arquivo local
- **Verificação de conectividade** antes do upload
- **Here document** para comandos automatizados
- **Logs detalhados** do processo

### `_upload_rsync()`
Upload via RSYNC com recursos avançados.

**Características:**
- **Sincronização bidirecional** possível
- **Compressão automática** durante transferência
- **Preservação completa** de atributos de arquivo
- **Relatório de progresso** detalhado

## Sistema de Sincronização de Biblioteca

### `_sincronizar_biblioteca()`
Sincronização completa de bibliotecas SAV.

**Processo:**
1. **Configuração de conexão** e validação
2. **Definição de variáveis** específicas da biblioteca
3. **Sincronização sequencial** de todos os arquivos
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
Define variáveis específicas para sincronização baseada na versão e sistema.

**Lógica de definição:**
- **trans_pc**: Caminho específico para transferência PC
- **ISCobol**: Caminho padrão IsCobol
- **Padrão**: Caminho alternativo para outros sistemas

## Funções de Verificação

### `_verificar_integridade()`
Verificação completa de integridade de arquivos baixados.

**Verificações realizadas:**
1. **Existência do arquivo**
2. **Tamanho não-zero**
3. **Tamanho mínimo** (1KB por padrão)
4. **Validade do ZIP** (se aplicável)

```bash
# Verificações de tamanho
local tamanho_arquivo
tamanho_arquivo=$(stat -c%s "$arquivo" 2>/dev/null || echo "0")

# Teste de ZIP
"${cmd_unzip}" -t "$arquivo" >/dev/null 2>&1
```

### `_listar_arquivos_remotos()`
Lista arquivos em diretório remoto via SFTP.

**Características:**
- **Comandos interativos** via here document
- **Formatação detalhada** (`ls -la`)
- **Navegação remota** (`cd` remoto)

## Funções de Limpeza

### `_limpar_temporarios_sync()`
Remove arquivos e diretórios temporários de sincronização.

**Diretórios limpos:**
- `${TOOLS}/temp_sync`
- `${ENVIA}/temp_update`
- `${RECEBE}/temp_download`

**Arquivos removidos:**
- **Arquivos `.part`** (downloads incompletos)
- **Diretórios temporários** criados durante operações

## Sistema de Configuração SSH

### `_configurar_ssh()`
Verifica e configura chaves SSH se necessário.

**Funcionalidades:**
- **Criação automática** de diretório `.ssh`
- **Verificação de configuração** existente
- **Permissões adequadas** (700 para diretórios, 600 para arquivos)
- **Detecção automática** de configuração `sav_servidor`

## Sistema de Retry

### `_executar_com_retry()`
Executa comandos com tentativas automáticas de recuperação.

**Características:**
- **Configuração personalizável** de tentativas e intervalos
- **Logs detalhados** de cada tentativa
- **Pausa progressiva** entre tentativas
- **Controle de sucesso/falha** preciso

```bash
# Configuração padrão: 3 tentativas, 5 segundos de intervalo
local max_tentativas="${2:-3}"
local intervalo="${3:-5}"
```

## Tratamento de Logs

### Sistema de Logging
O módulo implementa três níveis de logging:

#### `_log()` - Informação geral
```bash
_log "Iniciando download RSYNC: ${origem_remota}"
```

#### `_log_sucesso()` - Operações bem-sucedidas
```bash
_log_sucesso "Download RSYNC concluído: ${origem_remota}"
```

#### `_log_erro()` - Erros e falhas
```bash
_log_erro "Falha no download RSYNC: ${origem_remota}"
```

## Características de Segurança

### Validações de Segurança
- **Verificação de conectividade** antes de operações
- **Validação de parâmetros** obrigatórios
- **Controle de permissões** em arquivos SSH
- **Sanitização de caminhos** de arquivo

### Tratamento Seguro de Conexões
- **Teste de conectividade** antes de transferências
- **Configuração segura** de SSH
- **Controle de timeout** em operações de rede
- **Logs de auditoria** para rastreabilidade

## Boas Práticas Implementadas

### Organização do Código
- **Funções específicas** por protocolo/método
- **Validações centralizadas** na configuração
- **Tratamento uniforme** de erros
- **Logs estruturados** para auditoria

### Performance
- **Múltiplos protocolos** para diferentes cenários
- **Sistema de retry** para redes instáveis
- **Limpeza automática** de temporários
- **Verificação eficiente** de integridade

### Manutenibilidade
- **Comentários claros** sobre cada função
- **Parâmetros bem documentados**
- **Tratamento robusto** de diferentes cenários
- **Configuração flexível** baseada em variáveis

## Dependências Externas

### Comandos Utilizados
- `rsync` - Sincronização remota de arquivos
- `sftp` - Transferência segura de arquivos
- `ssh` - Conexões seguras (via rsync -e)
- `nc`/`telnet` - Teste de conectividade
- `stat` - Informações de arquivos
- `find` - Busca avançada (em outros módulos)

### Variáveis de Ambiente
- `IPSERVER` - Endereço do servidor remoto
- `PORTA` - Porta para conexão
- `USUARIO` - Usuário para autenticação
- `DESTINO2` - Caminho remoto base
- `SAVATU*` - Variáveis específicas da biblioteca

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

### Sincronização de Biblioteca
```bash
# Sincronizar biblioteca versão 2024
_sincronizar_biblioteca "2024"

# Para sistema específico
_sincronizar_biblioteca "2024" "iscobol"
```

### Verificação de Conectividade
```bash
# Teste básico
_testar_conexao "$IPSERVER" "$PORTA"

# Teste com timeout personalizado
_testar_conexao "$IPSERVER" "$PORTA" "10"
```

## Características Avançadas

### Configuração Dinâmica de Destinos
```bash
# Definição baseada no caminho remoto
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

### Controle de Método de Acesso
```bash
# Escolha automática baseada na configuração
if [[ "${acessossh}" == "n" ]]; then
    _download_sftp "$arquivo"    # Método interativo
else
    _download_sftp_ssh "$arquivo" # Método com chave SSH
fi
```

### Sistema de Logs Estruturado
```bash
# Cada operação gera logs detalhados
_log "Iniciando operação..."
_log_sucesso "Operação concluída com sucesso"
_log_erro "Falha na operação: motivo"
```

## Tratamento de Erros

### Estratégias Implementadas
- **Validação prévia** de todos os parâmetros
- **Teste de conectividade** antes de operações
- **Sistema de retry** para falhas temporárias
- **Mensagens específicas** para diferentes tipos de erro
- **Logs detalhados** para auditoria e debug

### Códigos de Retorno
- `0` - Sucesso
- `1` - Erro de parâmetro ou conectividade
- `1` - Falha na transferência
- `1` - Arquivo não encontrado ou corrompido

## Considerações de Performance

### Otimizações
- **RSYNC eficiente** com compressão e progresso
- **SFTP direto** para arquivos individuais
- **Sistema de retry** para redes instáveis
- **Limpeza automática** de arquivos temporários

### Recursos de Rede
- **Teste de conectividade** antes de operações longas
- **Timeout controlado** em operações de rede
- **Múltiplos protocolos** para diferentes cenários
- **Relatório de progresso** para operações longas

## Debugging e Desenvolvimento

### Estratégias para Debug
- **Logs detalhados** de todas as operações
- **Teste de conectividade** independente
- **Validação de parâmetros** em pontos críticos
- **Mensagens claras** sobre falhas específicas

### Diagnóstico de Problemas
```bash
# Testar conectividade
_testar_conexao "$IPSERVER" "$PORTA"

# Verificar configuração SSH
_configurar_ssh

# Listar arquivos remotos
_listar_arquivos_remotos "caminho/remoto/"

# Verificar integridade de arquivo
_verificar_integridade "arquivo.zip"
```

## Integração com o Sistema

### Dependências de Módulos
- **`config.sh`** - Configurações de conexão
- **`utils.sh`** - Funções utilitárias (logs, mensagens)
- **Sistema de arquivos** - Validação de caminhos locais

### Fluxo de Integração
```
rsync.sh → config.sh → validação → protocolos (SFTP/RSYNC) → servidor remoto
```

---

*Documentação gerada automaticamente com base no código fonte e práticas de bash scripting.*