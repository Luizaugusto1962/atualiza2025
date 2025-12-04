# Documentacao do Modulo setup.sh

## Visao Geral
Modulo responsavel pela configuracao inicial e manutencao dos arquivos de configuracao do Sistema SAV.

## Funcionalidades Principais

### 1. Configuracao Inicial (`_initial_setup`)
- Setup interativo para novos sistemas
- Cria arquivos `.atualizac` e `.atualizac`
- Configuracao especifica por sistema (IsCobol/Micro Focus)
- Criacao de atalho global `/usr/local/bin/atualiza`

### 2. Edicao de Configuracoes (`_edit_setup`)
- Modo `--edit` para modificar parametros existentes
- Backup automatico antes de alteracoes
- Validacao interativa de cada parametro

### 3. Configuracao por Sistema
- **IsCobol**: Versoes 2018-2024 com parametros especificos
- **Micro Focus Cobol**: Configuracao alternativa

## Modos de Operacao

```bash
# Configuracao inicial
./setup.sh

# Edicao de configuracoes existentes
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
Offline=n
```

### `.atualizac` (Constantes)
```bash
exec=sav/classes
telas=sav/tel_isc
xml=sav/xml
SAVATU=tempSAV_IS2024_*_
pasta=/sav/TOOLS_DIR
progs=/progs
olds=/olds
logs=/logs
cfg=/cfg
backup=/backup
```

## Caracteristicas de Seguranca

### Controle de Permissoes
```bash
chmod 700 "$SSH_CONFIG_DIR"    # rwx para owner apenas
chmod 600 "/root/.ssh/config"  # rw para owner apenas
chmod +x /usr/local/bin/atualiza  # Executavel global
```

### Backup Automatico
```bash
cp .atualizac .atualizac.bak  # Backup antes da edicao
```

## Tratamento de Erros

### Validacoes
- Existência de diretorios obrigatorios
- Permissoes de arquivos e diretorios
- Variaveis obrigatorias para SSH
- Escolhas validas nos menus

### Codigos de Retorno
- `0` - Sucesso
- `1` - Erro/Falha

## Boas Praticas

### Interface do Usuario
- Menus claros com opcoes numeradas
- Separadores visuais (`#-------------------------------------------------------------------#`)
- Confirmacoes antes de operacoes criticas
- Mensagens informativas durante o processo

### Organizacao do Codigo
- Funcoes especificas por responsabilidade
- Tratamento uniforme de erros
- Comentarios claros sobre cada secao

## Exemplos de Uso

### Configuracao Inicial
```bash
./setup.sh
# Sistema: 1 (IsCobol)
# Versao: 4 (2024)
# Banco: S
# Destino: /sav
# Base: sav/dados
# Acesso SSH: S
# IP Servidor: 177.45.80.10
```

### Edicao de Parametros
```bash
./setup.sh --edit
# Cada variavel e apresentada para edicao interativa
```

## Variaveis de Ambiente

### Variaveis Suportadas
- `TOOLS_DIR` - Diretorio de ferramentas
- `cfg_dir` - Diretorio de configuracao
- `SERVER_IP` - IP do servidor
- `SERVER_PORT` - Porta SSH (padrao: 41122)
- `SERVER_USER` - Usuario SSH (padrao: atualiza)

---

*Documentacao gerada automaticamente com base no codigo fonte e praticas de bash scripting.*