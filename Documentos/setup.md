# Documentação do Módulo setup.sh

## Visão Geral
Módulo responsável pela configuração inicial e manutenção dos arquivos de configuração do Sistema SAV.

## Funcionalidades Principais

### 1. Configuração Inicial (`_initial_setup`)
- Setup interativo para novos sistemas
- Cria arquivos `.atualizac` e `.atualizac`
- Configuração específica por sistema (IsCobol/Micro Focus)
- Criação de atalho global `/usr/local/bin/atualiza`

### 2. Edição de Configurações (`_edit_setup`)
- Modo `--edit` para modificar parâmetros existentes
- Backup automático antes de alterações
- Validação interativa de cada parâmetro

### 3. Configuração por Sistema
- **IsCobol**: Versões 2018-2024 com parâmetros específicos
- **Micro Focus Cobol**: Configuração alternativa

## Modos de Operação

```bash
# Configuração inicial
./setup.sh

# Edição de configurações existentes
./setup.sh --edit
```

## Arquivos Gerados

### `.atualizac` (Principal)
```bash
sistema=iscobol
verclass=2024
class=-class24
mclass=-mclass24
BANCO=s
destino=/sav
base=/sav/dados
IPSERVER=177.45.80.10
acessossh=s
SERACESOFF=n
```

### `.atualizac` (Constantes)
```bash
exec=sav/classes
telas=sav/tel_isc
xml=sav/xml
SAVATU=tempSAV_IS2024_*_
pasta=/sav/tools
progs=/progs
olds=/olds
logs=/logs
cfg=/cfg
backup=/backup
```

## Características de Segurança

### Controle de Permissões
```bash
chmod 700 "$SSH_CONFIG_DIR"    # rwx para owner apenas
chmod 600 "/root/.ssh/config"  # rw para owner apenas
chmod +x /usr/local/bin/atualiza  # Executável global
```

### Backup Automático
```bash
cp .atualizac .atualizac.bak  # Backup antes da edição
```

## Tratamento de Erros

### Validações
- Existência de diretórios obrigatórios
- Permissões de arquivos e diretórios
- Variáveis obrigatórias para SSH
- Escolhas válidas nos menus

### Códigos de Retorno
- `0` - Sucesso
- `1` - Erro/Falha

## Boas Práticas

### Interface do Usuário
- Menus claros com opções numeradas
- Separadores visuais (`#-------------------------------------------------------------------#`)
- Confirmações antes de operações críticas
- Mensagens informativas durante o processo

### Organização do Código
- Funções específicas por responsabilidade
- Tratamento uniforme de erros
- Comentários claros sobre cada seção

## Exemplos de Uso

### Configuração Inicial
```bash
./setup.sh
# Sistema: 1 (IsCobol)
# Versão: 4 (2024)
# Banco: S
# Destino: /sav
# Base: sav/dados
# Acesso SSH: S
# IP Servidor: 177.45.80.10
```

### Edição de Parâmetros
```bash
./setup.sh --edit
# Cada variável é apresentada para edição interativa
```

## Variáveis de Ambiente

### Variáveis Suportadas
- `TOOLS` - Diretório de ferramentas
- `LIB_CFG` - Diretório de configuração
- `SERVER_IP` - IP do servidor
- `SERVER_PORT` - Porta SSH (padrão: 41122)
- `SERVER_USER` - Usuário SSH (padrão: atualiza)

---

*Documentação gerada automaticamente com base no código fonte e práticas de bash scripting.*