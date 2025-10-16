# Documentação do Módulo sistema.sh

## Visão Geral
O módulo `sistema.sh` é responsável pela gestão completa de informações do sistema, configurações e atualizações do **Sistema SAV (Script de Atualização Modular)**. Este é um dos módulos mais complexos, oferecendo funcionalidades para diagnóstico, configuração e manutenção do ambiente.

## Funcionalidades Principais

### 1. Informações de Sistema
- **Versão IsCOBOL**: Exibição da versão do ambiente IsCOBOL
- **Informações Linux**: Diagnóstico completo do sistema operacional
- **Parâmetros do Sistema**: Visualização de todas as configurações

### 2. Sistema de Atualização
- **Online**: Atualização via GitHub com wget
- **Offline**: Atualização via arquivos locais
- **Backup automático**: Criação de backups antes da atualização

### 3. Manutenção de Setup
- **Configuração interativa**: Interface para edição de variáveis
- **Persistência**: Salva configurações em arquivo `.atualizac`
- **Validação**: Verificação de parâmetros obrigatórios

### 4. Configuração SSH
- **Auto configuração**: Criação automática de configuração SSH
- **Multiplexação**: Controle de conexão persistente
- **Segurança**: Controle de permissões adequado

## Estrutura do Código

### Variáveis Globais
```bash
# Diretórios e caminhos
destino="${destino:-}"
sistema="${sistema:-}"
pasta="${pasta:-}"
base="${base:-}"

# Configurações de compilação
verclass="${verclass:-}"
class="${class:-}"
mclass="${mclass:-}"

# Diretórios específicos
exec="${exec:-}"
xml="${xml:-}"
olds="${olds:-}"
```

## Funções de Informação do Sistema

### `_mostrar_versao_iscobol()`
Exibe informações da versão do IsCOBOL instalado.

**Características:**
- Verificação de existência do executável
- Execução com parâmetro `-v` para versão
- Tratamento específico para sistema IsCOBOL

### `_mostrar_versao_linux()`
Realiza diagnóstico completo do sistema Linux.

**Informações coletadas:**
- **Conectividade**: Teste de conexão com internet
- **Sistema Operacional**: Tipo e distribuição
- **Hostname**: Nome do servidor
- **IPs**: Interno e externo (se online)
- **Usuários**: Sessões ativas
- **Memória**: Uso de RAM e SWAP
- **Disco**: Espaço em disco utilizado
- **Uptime**: Tempo de atividade do sistema

**Técnicas utilizadas:**
```bash
# Teste de conectividade
ping -c 1 google.com &>/dev/null

# Informações de SO
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

## Funções de Parâmetros

### `_mostrar_parametros()`
Exibe todas as configurações do sistema SAV.

**Grupos de informação:**
1. **Banco de dados e diretórios principais**
2. **Bibliotecas e versões**
3. **Configurações de rede**
4. **Parâmetros de conexão**

## Sistema de Atualização

### `_executar_update()`
Controlador principal do sistema de atualização.

**Lógica de decisão:**
```bash
if [[ "${SERACESOFF}" == "n" ]]; then
    _atualizar_online
else
    _atualizar_offline
fi
```

### `_atualizar_online()`
Atualização via GitHub usando wget.

**Processo:**
1. Definição do link de download
2. Criação de diretório temporário
3. Execução da função `_atualizando`

### `_atualizar_offline()`
Atualização via arquivo local no diretório offline.

**Características:**
- Usa variável `${SERACESOFF}` como caminho
- Move arquivo zip para diretório temporário
- Processa atualização local

### `_atualizando()`
Função principal de processamento de atualização.

**Etapas detalhadas:**

#### 1. Preparação e Backup
```bash
# Criar diretório de backup
mkdir -p "$backup"

# Backup de todos os arquivos .sh
for arquivo in *.sh; do
    cp -f "$arquivo" "${backup}/.$arquivo.bak"
done
```

#### 2. Download e Descompactação
```bash
# Download via wget
wget -q -c "$link"

# Descompactação com log
"${cmd_unzip}" -o -j "$zipfile" >>"$LOG_ATU" 2>&1
```

#### 3. Instalação de Arquivos
```bash
# Processar cada arquivo .sh
for arquivo in *.sh; do
    chmod +x "$arquivo"
    if [ "$arquivo" = "atualiza.sh" ]; then
        target="${TOOLS}"
    else
        target="${LIB_DIR}"
    fi
    mv -f "$arquivo" "$target"
done
```

#### 4. Limpeza
```bash
cd "$ENVIA" && rm -rf "$temp_dir"
```

## Sistema de Manutenção de Setup

### `editar_variavel()`
Interface interativa para edição de variáveis específicas.

**Variáveis especiais com menus:**
- **`sistema`**: Escolha entre IsCobol/Micro Focus Cobol
- **`BANCO`**: Uso de banco de dados (Sim/Não)
- **`acessossh`**: Método de acesso fácil (Sim/Não)
- **`IPSERVER`**: IP do servidor SAV
- **`SERACESOFF`**: Modo offline (Sim/Não)

**Tratamento de entrada:**
```bash
read -rp "Deseja alterar ${nome} (valor atual: ${valor_atual})? [s/N] " alterar
alterar=${alterar,,}  # Converte para minúsculo
```

### `_manutencao_setup()`
Controlador principal da manutenção de configuração.

**Funcionalidades:**
- Carregamento de configuração existente (`.atualizac`)
- Backup automático antes da edição
- Edição sequencial de variáveis
- Recriação do arquivo de configuração
- Configuração automática de SSH (se necessário)

## Configuração SSH Automática

### Variáveis de Configuração
```bash
SERVER_IP="${IPSERVER}"
SERVER_PORT="${SERVER_PORT:-41122}"
SERVER_USER="${SERVER_USER:-atualiza}"
CONTROL_PATH_BASE="${CONTROL_PATH_BASE:-${TOOLS}/.ssh/control}"
```

### Processo de Configuração

#### 1. Validação de Variáveis
```bash
if [[ -z "$SERVER_IP" || -z "$SERVER_PORT" || -z "$SERVER_USER" ]]; then
    echo "Erro: Variaveis obrigatorias nao definidas!"
    exit 1
fi
```

#### 2. Criação de Diretórios
```bash
mkdir -p "$SSH_CONFIG_DIR"
chmod 700 "$SSH_CONFIG_DIR"
```

#### 3. Geração de Configuração SSH
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

### Estratégia de Backup
- **Arquivos originais**: `.bak` no diretório de backup
- **Configuração**: `.atualizac.bak` antes da edição
- **Controle de erros**: Contadores de sucesso/erro

### Logs e Auditoria
- **Arquivo de log**: `${LOG_ATU}` para operações de atualização
- **Logs temporários**: `${LOG_TMP}*` para operações intermediárias
- **Limpeza automática**: Remoção de arquivos temporários

## Tratamento de Erros

### Validações Implementadas
- **Existência de arquivos**: Verificação antes de operações
- **Permissões**: Controle de acesso a arquivos e diretórios
- **Conectividade**: Teste de internet para funcionalidades online
- **Parâmetros obrigatórios**: Validação antes da configuração SSH

### Códigos de Retorno
- `0` - Sucesso
- `1` - Erro/Falha

## Características de Segurança

### Controle de Permissões
```bash
chmod 700 "$SSH_CONFIG_DIR"    # rwx para owner apenas
chmod 600 "/root/.ssh/config"  # rw para owner apenas
```

### Variáveis Sensíveis
- **IPs de servidores**: Protegidos em variáveis de ambiente
- **Credenciais SSH**: Configuração segura com permissões restritas
- **Dados de sistema**: Tratamento seguro de informações sensíveis

## Boas Práticas Implementadas

### Organização do Código
- **Separação clara**: Funções bem definidas por responsabilidade
- **Tratamento robusto**: Múltiplas camadas de validação
- **Logs detalhados**: Rastreabilidade completa das operações

### Interface do Usuário
- **Menus interativos**: Escolhas claras para variáveis complexas
- **Feedback visual**: Mensagens coloridas informativas
- **Confirmações**: Validação antes de alterações críticas

### Manutenibilidade
- **Comentários claros**: Documentação inline das funções
- **Tratamento de erros**: Recuperação graceful de falhas
- **Backup automático**: Proteção contra perda de dados

## Dependências Externas

### Comandos Utilizados
- `wget` - Download de arquivos
- `unzip` - Descompactação
- `ping` - Teste de conectividade
- `curl` - Obtenção de IP externo
- `free` - Informações de memória
- `df` - Uso de disco
- `uptime` - Tempo de atividade
- `chmod`/`mkdir` - Gerenciamento de permissões

### Arquivos de Sistema
- `/etc/os-release` - Informações do sistema operacional
- `/root/.ssh/config` - Configuração SSH
- `.atualizac` - Arquivo de configuração local

## Exemplos de Uso

### Verificação de Sistema
```bash
# Mostrar informações do IsCOBOL
_mostrar_versao_iscobol

# Diagnóstico completo do Linux
_mostrar_versao_linux

# Exibir parâmetros do sistema
_mostrar_parametros
```

### Atualização do Sistema
```bash
# Atualização online
_atualizar_online

# Atualização offline
_atualizar_offline

# Execução automática baseada na configuração
_executar_update
```

### Manutenção de Configuração
```bash
# Interface interativa de configuração
_manutencao_setup

# Edição específica de variável
editar_variavel "IPSERVER"
```

## Variáveis de Ambiente

### Variáveis Suportadas
- `SERACESOFF` - Modo offline (n/online, caminho/offline)
- `LOG_TMP` - Diretório para arquivos temporários
- `LOG_ATU` - Arquivo de log de atualizações
- `TOOLS` - Diretório de ferramentas
- `LIB_DIR` - Diretório de bibliotecas
- `ENVIA` - Diretório de envio/recepção

### Constantes Internas
- `tracejada` - Separador visual para interface
- `UPDATE` - Versão do sistema

## Considerações de Performance

### Otimizações Implementadas
- **Processamento eficiente**: Loops controlados com contadores
- **Limpeza automática**: Remoção de arquivos temporários
- **Cache de conexões**: SSH com ControlPersist
- **Download incremental**: Uso de `-c` (continue) no wget

### Recursos de Sistema
- **Monitoramento**: Coleta não intrusiva de informações
- **Logs rotativos**: Controle de tamanho de logs
- **Limpeza automática**: Manutenção de espaço em disco

## Debugging e Desenvolvimento

### Estratégias para Debug
- **Logs detalhados**: Todas as operações são registradas
- **Validações em pontos críticos**: Verificação antes de ações
- **Feedback imediato**: Mensagens de erro informativas
- **Backups automáticos**: Recuperação de estado anterior

### Testes
- **Conectividade**: Ping antes de operações de rede
- **Permissões**: Verificação antes de escrita
- **Existência**: Validação antes de processamento
- **Integridade**: Checksums implícitos via tamanho de arquivo

---

*Documentação gerada automaticamente com base no código fonte e práticas de bash scripting.*