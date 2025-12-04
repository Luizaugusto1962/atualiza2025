# Documentacao do Modulo sistema.sh

## Visao Geral
O modulo `sistema.sh` e responsavel pela gestao completa de informacoes do sistema, configuracoes e atualizacoes do **Sistema SAV (Script de Atualizacao Modular)**. Este e um dos modulos mais complexos, oferecendo funcionalidades para diagnostico, configuracao e manutencao do ambiente.

## Funcionalidades Principais

### 1. Informacoes de Sistema
- **Versao IsCOBOL**: Exibicao da versao do ambiente IsCOBOL
- **Informacoes Linux**: Diagnostico completo do sistema operacional
- **Parametros do Sistema**: Visualizacao de todas as configuracoes

### 2. Sistema de Atualizacao
- **Online**: Atualizacao via GitHub com wget
- **Offline**: Atualizacao via arquivos locais
- **Backup automatico**: Criacao de backups antes da atualizacao

### 3. Manutencao de Setup
- **Configuracao interativa**: Interface para edicao de variaveis
- **Persistência**: Salva configuracoes em arquivo `.atualizac`
- **Validacao**: Verificacao de parametros obrigatorios

### 4. Configuracao SSH
- **Auto configuracao**: Criacao automatica de configuracao SSH
- **Multiplexacao**: Controle de conexao persistente
- **Seguranca**: Controle de permissoes adequado

## Estrutura do Codigo

### Variaveis Globais
```bash
# Diretorios e caminhos
destino="${destino:-}"
sistema="${sistema:-}"
pasta="${pasta:-}"
base="${base:-}"

# Configuracoes de compilacao
verclass="${verclass:-}"
class="${class:-}"
mclass="${mclass:-}"

# Diretorios especificos
exec="${exec:-}"
xml="${xml:-}"
olds="${olds:-}"
```

## Funcoes de Informacao do Sistema

### `_mostrar_versao_iscobol()`
Exibe informacoes da versao do IsCOBOL instalado.

**Caracteristicas:**
- Verificacao de existência do executavel
- Execucao com parametro `-v` para versao
- Tratamento especifico para sistema IsCOBOL

### `_mostrar_versao_linux()`
Realiza diagnostico completo do sistema Linux.

**Informacoes coletadas:**
- **Conectividade**: Teste de conexao com internet
- **Sistema Operacional**: Tipo e distribuicao
- **Hostname**: Nome do servidor
- **IPs**: Interno e externo (se online)
- **Usuarios**: Sessoes ativas
- **Memoria**: Uso de RAM e SWAP
- **Disco**: Espaco em disco utilizado
- **Uptime**: Tempo de atividade do sistema

**Tecnicas utilizadas:**
```bash
# Teste de conectividade
ping -c 1 google.com &>/dev/null

# Informacoes de SO
grep 'NAME\|VERSION' /etc/os-release

# IPs e hostname
hostname
ip route get 1 | awk '{print $7;exit}'
curl -s ipecho.net/plain

# Recursos do sistema
free | grep -v +
df -h | grep 'Filesystem\|/dev/sda*'
uptime -p
```

## Funcoes de Parametros

### `_mostrar_parametros()`
Exibe todas as configuracoes do sistema SAV.

**Grupos de informacao:**
1. **Banco de dados e diretorios principais**
2. **Bibliotecas e versoes**
3. **Configuracoes de rede**
4. **Parametros de conexao**

## Sistema de Atualizacao

### `_executar_update()`
Controlador principal do sistema de atualizacao.

**Logica de decisao:**
```bash
if [[ "${Offline}" == "n" ]]; then
    _atualizar_online
else
    _atualizar_offline
fi
```

### `_atualizar_online()`
Atualizacao via GitHub usando wget.

**Processo:**
1. Definicao do link de download
2. Criacao de diretorio temporario
3. Execucao da funcao `_atualizando`

### `_atualizar_offline()`
Atualizacao via arquivo local no diretorio offline.

**Caracteristicas:**
- Usa variavel `${Offline}` como caminho
- Move arquivo zip para diretorio temporario
- Processa atualizacao local

### `_atualizando()`
Funcao principal de processamento de atualizacao.

**Etapas detalhadas:**

#### 1. Preparacao e Backup
```bash
# Criar diretorio de backup
mkdir -p "$backup"

# Backup de todos os arquivos .sh
for arquivo in *.sh; do
    cp -f "$arquivo" "${backup}/.$arquivo.bak"
done
```

#### 2. Download e Descompactacao
```bash
# Download via wget
wget -q -c "$link"

# Descompactacao com log
"${cmd_unzip}" -o -j "$zipfile" >>"$LOG_ATU" 2>&1
```

#### 3. Instalacao de Arquivos
```bash
# Processar cada arquivo .sh
for arquivo in *.sh; do
    chmod +x "$arquivo"
    if [ "$arquivo" = "atualiza.sh" ]; then
        target="${TOOLS_DIR}"
    else
        target="${lib_dir}"
    fi
    mv -f "$arquivo" "$target"
done
```

#### 4. Limpeza
```bash
cd "$ENVIA" && rm -rf "$temp_dir"
```

## Sistema de Manutencao de Setup

### `editar_variavel()`
Interface interativa para edicao de variaveis especificas.

**Variaveis especiais com menus:**
- **`sistema`**: Escolha entre IsCobol/Micro Focus Cobol
- **`BANCO`**: Uso de banco de dados (Sim/Nao)
- **`acessossh`**: Metodo de acesso facil (Sim/Nao)
- **`IPSERVER`**: IP do servidor SAV
- **`Offline`**: Modo offline (Sim/Nao)

**Tratamento de entrada:**
```bash
read -rp "Deseja alterar ${nome} (valor atual: ${valor_atual})? [s/N] " alterar
alterar=${alterar,,}  # Converte para minúsculo
```

### `_manutencao_setup()`
Controlador principal da manutencao de configuracao.

**Funcionalidades:**
- Carregamento de configuracao existente (`.atualizac`)
- Backup automatico antes da edicao
- Edicao sequencial de variaveis
- Recriacao do arquivo de configuracao
- Configuracao automatica de SSH (se necessario)

## Configuracao SSH Automatica

### Variaveis de Configuracao
```bash
SERVER_IP="${IPSERVER}"
SERVER_PORT="${SERVER_PORT:-41122}"
SERVER_USER="${SERVER_USER:-atualiza}"
CONTROL_PATH_BASE="${CONTROL_PATH_BASE:-${TOOLS_DIR}/.ssh/control}"
```

### Processo de Configuracao

#### 1. Validacao de Variaveis
```bash
if [[ -z "$SERVER_IP" || -z "$SERVER_PORT" || -z "$SERVER_USER" ]]; then
    echo "Erro: Variaveis obrigatorias nao definidas!"
    exit 1
fi
```

#### 2. Criacao de Diretorios
```bash
mkdir -p "$SSH_CONFIG_DIR"
chmod 700 "$SSH_CONFIG_DIR"
```

#### 3. Geracao de Configuracao SSH
```bash
cat << EOF >> "/root/.ssh/config"
Host sav_servidor
    HostName $SERVER_IP
    Port $SERVER_PORT
    User $SERVER_USER
    ControlMaster auto
    ControlPath $CONTROL_PATH/%r@%h:%p
    ControlPersist 10m
EOF
```

## Sistema de Backup

### Estrategia de Backup
- **Arquivos originais**: `.bak` no diretorio de backup
- **Configuracao**: `.atualizac.bak` antes da edicao
- **Controle de erros**: Contadores de sucesso/erro

### Logs e Auditoria
- **Arquivo de log**: `${LOG_ATU}` para operacoes de atualizacao
- **Logs temporarios**: `${LOG_TMP}*` para operacoes intermediarias
- **Limpeza automatica**: Remocao de arquivos temporarios

## Tratamento de Erros

### Validacoes Implementadas
- **Existência de arquivos**: Verificacao antes de operacoes
- **Permissoes**: Controle de acesso a arquivos e diretorios
- **Conectividade**: Teste de internet para funcionalidades online
- **Parametros obrigatorios**: Validacao antes da configuracao SSH

### Codigos de Retorno
- `0` - Sucesso
- `1` - Erro/Falha

## Caracteristicas de Seguranca

### Controle de Permissoes
```bash
chmod 700 "$SSH_CONFIG_DIR"    # rwx para owner apenas
chmod 600 "/root/.ssh/config"  # rw para owner apenas
```

### Variaveis Sensiveis
- **IPs de servidores**: Protegidos em variaveis de ambiente
- **Credenciais SSH**: Configuracao segura com permissoes restritas
- **Dados de sistema**: Tratamento seguro de informacoes sensiveis

## Boas Praticas Implementadas

### Organizacao do Codigo
- **Separacao clara**: Funcoes bem definidas por responsabilidade
- **Tratamento robusto**: Múltiplas camadas de validacao
- **Logs detalhados**: Rastreabilidade completa das operacoes

### Interface do Usuario
- **Menus interativos**: Escolhas claras para variaveis complexas
- **Feedback visual**: Mensagens coloridas informativas
- **Confirmacoes**: Validacao antes de alteracoes criticas

### Manutenibilidade
- **Comentarios claros**: Documentacao inline das funcoes
- **Tratamento de erros**: Recuperacao graceful de falhas
- **Backup automatico**: Protecao contra perda de dados

## Dependências Externas

### Comandos Utilizados
- `wget` - Download de arquivos
- `unzip` - Descompactacao
- `ping` - Teste de conectividade
- `curl` - Obtencao de IP externo
- `free` - Informacoes de memoria
- `df` - Uso de disco
- `uptime` - Tempo de atividade
- `chmod`/`mkdir` - Gerenciamento de permissoes

### Arquivos de Sistema
- `/etc/os-release` - Informacoes do sistema operacional
- `/root/.ssh/config` - Configuracao SSH
- `.atualizac` - Arquivo de configuracao local

## Exemplos de Uso

### Verificacao de Sistema
```bash
# Mostrar informacoes do IsCOBOL
_mostrar_versao_iscobol

# Diagnostico completo do Linux
_mostrar_versao_linux

# Exibir parametros do sistema
_mostrar_parametros
```

### Atualizacao do Sistema
```bash
# Atualizacao online
_atualizar_online

# Atualizacao offline
_atualizar_offline

# Execucao automatica baseada na configuracao
_executar_update
```

### Manutencao de Configuracao
```bash
# Interface interativa de configuracao
_manutencao_setup

# Edicao especifica de variavel
editar_variavel "IPSERVER"
```

## Variaveis de Ambiente

### Variaveis Suportadas
- `Offline` - Modo offline (n/offline, s/online)
- `LOG_TMP` - Diretorio para arquivos temporarios
- `LOG_ATU` - Arquivo de log de atualizacoes
- `TOOLS_DIR` - Diretorio de ferramentas
- `lib_dir` - Diretorio de bibliotecas
- `ENVIA` - Diretorio de envio/recepcao

### Constantes Internas
- `tracejada` - Separador visual para interface
- `UPDATE` - Versao do sistema

## Consideracoes de Performance

### Otimizacoes Implementadas
- **Processamento eficiente**: Loops controlados com contadores
- **Limpeza automatica**: Remocao de arquivos temporarios
- **Cache de conexoes**: SSH com ControlPersist
- **Download incremental**: Uso de `-c` (continue) no wget

### Recursos de Sistema
- **Monitoramento**: Coleta nao intrusiva de informacoes
- **Logs rotativos**: Controle de tamanho de logs
- **Limpeza automatica**: Manutencao de espaco em disco

## Debugging e Desenvolvimento

### Estrategias para Debug
- **Logs detalhados**: Todas as operacoes sao registradas
- **Validacoes em pontos criticos**: Verificacao antes de acoes
- **Feedback imediato**: Mensagens de erro informativas
- **Backups automaticos**: Recuperacao de estado anterior

### Testes
- **Conectividade**: Ping antes de operacoes de rede
- **Permissoes**: Verificacao antes de escrita
- **Existência**: Validacao antes de processamento
- **Integridade**: Checksums implicitos via tamanho de arquivo

---

*Documentacao gerada automaticamente com base no codigo fonte e praticas de bash scripting.*