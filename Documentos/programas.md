# Documentacao do Modulo programas.sh

## Visao Geral
O modulo `programas.sh` e responsavel pela gestao completa do ciclo de vida de programas em um sistema SAV (Sistema de Atualizacao Modular). Este modulo oferece funcionalidades para atualizacao, instalacao e reversao de programas atraves de diferentes metodos.

## Funcionalidades Principais

### 1. Atualizacao de Programas
- **Online**: Atualizacao via conexao remota (RSYNC/SFTP)
- **Offline**: Atualizacao via arquivos locais
- **Pacotes**: Atualizacao em lote de múltiplos programas

### 2. Sistema de Reversao
- Restauracao de programas para versoes anteriores
- Backup automatico antes das atualizacoes
- Confirmacao interativa para múltiplas reversoes

### 3. Gestao de Arquivos
- Arrays para controle de programas selecionados
- Validacao de nomes de programas
- Controle de tipos de compilacao (Normal/Debug)

## Estrutura do Codigo

### Variaveis Globais
```bash
# Arrays para armazenar programas e arquivos
declare -a PROGRAMAS_SELECIONADOS=()
declare -a ARQUIVOS_PROGRAMA=()

# Variaveis de configuracao externa
destino="${destino:-}"
sistema="${sistema:-}"
acessossh="${acessossh:-}"
```

### Funcoes de Atualizacao

#### `_atualizar_programa_online()`
Realiza atualizacao de programas via conexao remota.

**Fluxo:**
1. Verifica se servidor esta OFF
2. Solicita programas para atualizacao
3. Baixa arquivos via RSYNC
4. Processa atualizacao

#### `_atualizar_programa_offline()`
Atualizacao via arquivos locais no diretorio TOOLS_DIR.

#### `_atualizar_programa_pacote()`
Atualizacao de programas em pacotes via conexao remota.

### Funcoes de Reversao

#### `_reverter_programa()`
Interface interativa para selecao de programas a reverter.

**Caracteristicas:**
- Maximo de 6 repeticoes
- Validacao de nomes de programas
- Lista visual dos programas selecionados

#### `_processar_reversao_programas()`
Processa a reversao dos programas selecionados.

### Funcoes de Solicitacao

#### `_solicitar_programas_atualizacao()`
Coleta programas para atualizacao com selecao interativa.

**Funcionalidades:**
- Loop com maximo 6 tentativas
- Validacao de nomes (letras maiúsculas e números)
- Selecao de tipo de compilacao (1-Normal, 2-Debug)
- Arrays para armazenar selecoes

#### `_solicitar_pacotes_atualizacao()`
Similar à funcao anterior, mas para pacotes.

### Funcoes de Download

#### `_baixar_programas_rsync()`
Realiza download via RSYNC ou SFTP.

**Metodos suportados:**
- SFTP com senha interativa
- SFTP com chave SSH automatica
- Verificacao de integridade dos arquivos

#### `_baixar_pacotes_rsync()`
Download de pacotes para diretorio especifico.

### Funcoes de Processamento

#### `_processar_atualizacao_programas()`
Processa a atualizacao dos programas baixados.

**Etapas:**
1. Verificacao de existência dos arquivos
2. Criacao de backups automaticos
3. Descompactacao dos arquivos
4. Movimentacao para diretorios corretos
5. Renomeacao de arquivos .zip para .bkp

#### `_processar_atualizacao_pacotes()`
Processamento especifico para pacotes.

### Funcoes Auxiliares

#### `_obter_data_arquivo()`
Obtem data de modificacao dos arquivos compilados.

#### `_mensagem_conclusao_reversao()`
Interface de conclusao com opcao de mais reversoes.

## Padroes de Nomenclatura

### Arquivos Suportados
- `.class` - Arquivos compilados (Java/COBOL)
- `.int` - Arquivos interpretados
- `.TEL` - Arquivos de tela/interface
- `.zip` - Pacotes de distribuicao

### Convencoes de Backup
- `{programa}-anterior.zip` - Backup da versao anterior
- `{data}-{programa}-anterior.zip` - Backup com timestamp
- `.bkp` - Extensao para arquivos processados

## Tratamento de Erros

### Validacoes Implementadas
- Verificacao de existência de arquivos
- Validacao de nomes de programas
- Controle de tipos de compilacao
- Verificacao de conectividade

### Codigos de Retorno
- `0` - Sucesso
- `1` - Erro/Falha

## Logs e Auditoria

### Arquivo de Log
- `${LOG_ATU}` - Arquivo de log das atualizacoes
- Registra operacoes de descompactacao
- Movimentacao de arquivos

## Dependências Externas

### Comandos Utilizados
- `zip`/`unzip` - Compactacao/descompactacao
- `rsync` - Sincronizacao remota
- `sftp` - Transferência segura
- `find` - Busca de arquivos
- `stat` - Informacoes de arquivos
- `mv`/`cp` - Movimentacao/copia

### Variaveis de Ambiente
- `TOOLS_DIR` - Diretorio de ferramentas
- `E_EXEC` - Diretorio de executaveis
- `T_TELAS` - Diretorio de telas
- `OLDS` - Diretorio de backups
- `RECEBE` - Diretorio de recepcao
- `PROGS` - Diretorio de programas

## Boas Praticas Implementadas

### Organizacao do Codigo
- Funcoes bem documentadas
- Separacao clara de responsabilidades
- Tratamento consistente de erros

### Interface do Usuario
- Mensagens coloridas informativas
- Confirmacoes interativas
- Listas visuais de selecao

### Manutenibilidade
- Arrays para controle de estado
- Funcoes reutilizaveis
- Logs detalhados

## Exemplos de Uso

### Atualizacao Online
```bash
# Chamar funcao de atualizacao online
_atualizar_programa_online
```

### Reversao de Programa
```bash
# Chamar funcao de reversao
_reverter_programa
```

### Limpeza de Selecao
```bash
# Limpar arrays de selecao
_limpar_selecao_programas
```

## Consideracoes de Seguranca

- Backup automatico antes de alteracoes
- Validacao de nomes de programas
- Verificacao de integridade de downloads
- Logs de auditoria

## Performance

- Processamento eficiente com arrays
- Controle de loops para evitar excesso
- Movimentacao otimizada de arquivos
- Verificacoes minimas necessarias

---

*Documentacao gerada automaticamente com base no codigo fonte e praticas de bash scripting.*