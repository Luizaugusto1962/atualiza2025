# Documentação do Módulo programas.sh

## Visão Geral
O módulo `programas.sh` é responsável pela gestão completa do ciclo de vida de programas em um sistema SAV (Sistema de Atualização Modular). Este módulo oferece funcionalidades para atualização, instalação e reversão de programas através de diferentes métodos.

## Funcionalidades Principais

### 1. Atualização de Programas
- **Online**: Atualização via conexão remota (RSYNC/SFTP)
- **Offline**: Atualização via arquivos locais
- **Pacotes**: Atualização em lote de múltiplos programas

### 2. Sistema de Reversão
- Restauração de programas para versões anteriores
- Backup automático antes das atualizações
- Confirmação interativa para múltiplas reversões

### 3. Gestão de Arquivos
- Arrays para controle de programas selecionados
- Validação de nomes de programas
- Controle de tipos de compilação (Normal/Debug)

## Estrutura do Código

### Variáveis Globais
```bash
# Arrays para armazenar programas e arquivos
declare -a PROGRAMAS_SELECIONADOS=()
declare -a ARQUIVOS_PROGRAMA=()

# Variáveis de configuração externa
destino="${destino:-}"
sistema="${sistema:-}"
acessossh="${acessossh:-}"
```

### Funções de Atualização

#### `_atualizar_programa_online()`
Realiza atualização de programas via conexão remota.

**Fluxo:**
1. Verifica se servidor está OFF
2. Solicita programas para atualização
3. Baixa arquivos via RSYNC
4. Processa atualização

#### `_atualizar_programa_offline()`
Atualização via arquivos locais no diretório TOOLS.

#### `_atualizar_programa_pacote()`
Atualização de programas em pacotes via conexão remota.

### Funções de Reversão

#### `_reverter_programa()`
Interface interativa para seleção de programas a reverter.

**Características:**
- Máximo de 6 repetições
- Validação de nomes de programas
- Lista visual dos programas selecionados

#### `_processar_reversao_programas()`
Processa a reversão dos programas selecionados.

### Funções de Solicitação

#### `_solicitar_programas_atualizacao()`
Coleta programas para atualização com seleção interativa.

**Funcionalidades:**
- Loop com máximo 6 tentativas
- Validação de nomes (letras maiúsculas e números)
- Seleção de tipo de compilação (1-Normal, 2-Debug)
- Arrays para armazenar seleções

#### `_solicitar_pacotes_atualizacao()`
Similar à função anterior, mas para pacotes.

### Funções de Download

#### `_baixar_programas_rsync()`
Realiza download via RSYNC ou SFTP.

**Métodos suportados:**
- SFTP com senha interativa
- SFTP com chave SSH automática
- Verificação de integridade dos arquivos

#### `_baixar_pacotes_rsync()`
Download de pacotes para diretório específico.

### Funções de Processamento

#### `_processar_atualizacao_programas()`
Processa a atualização dos programas baixados.

**Etapas:**
1. Verificação de existência dos arquivos
2. Criação de backups automáticos
3. Descompactação dos arquivos
4. Movimentação para diretórios corretos
5. Renomeação de arquivos .zip para .bkp

#### `_processar_atualizacao_pacotes()`
Processamento específico para pacotes.

### Funções Auxiliares

#### `_obter_data_arquivo()`
Obtém data de modificação dos arquivos compilados.

#### `_mensagem_conclusao_reversao()`
Interface de conclusão com opção de mais reversões.

## Padrões de Nomenclatura

### Arquivos Suportados
- `.class` - Arquivos compilados (Java/COBOL)
- `.int` - Arquivos interpretados
- `.TEL` - Arquivos de tela/interface
- `.zip` - Pacotes de distribuição

### Convenções de Backup
- `{programa}-anterior.zip` - Backup da versão anterior
- `{data}-{programa}-anterior.zip` - Backup com timestamp
- `.bkp` - Extensão para arquivos processados

## Tratamento de Erros

### Validações Implementadas
- Verificação de existência de arquivos
- Validação de nomes de programas
- Controle de tipos de compilação
- Verificação de conectividade

### Códigos de Retorno
- `0` - Sucesso
- `1` - Erro/Falha

## Logs e Auditoria

### Arquivo de Log
- `${LOG_ATU}` - Arquivo de log das atualizações
- Registra operações de descompactação
- Movimentação de arquivos

## Dependências Externas

### Comandos Utilizados
- `zip`/`unzip` - Compactação/descompactação
- `rsync` - Sincronização remota
- `sftp` - Transferência segura
- `find` - Busca de arquivos
- `stat` - Informações de arquivos
- `mv`/`cp` - Movimentação/cópia

### Variáveis de Ambiente
- `TOOLS` - Diretório de ferramentas
- `E_EXEC` - Diretório de executáveis
- `T_TELAS` - Diretório de telas
- `OLDS` - Diretório de backups
- `RECEBE` - Diretório de recepção
- `PROGS` - Diretório de programas

## Boas Práticas Implementadas

### Organização do Código
- Funções bem documentadas
- Separação clara de responsabilidades
- Tratamento consistente de erros

### Interface do Usuário
- Mensagens coloridas informativas
- Confirmações interativas
- Listas visuais de seleção

### Manutenibilidade
- Arrays para controle de estado
- Funções reutilizáveis
- Logs detalhados

## Exemplos de Uso

### Atualização Online
```bash
# Chamar função de atualização online
_atualizar_programa_online
```

### Reversão de Programa
```bash
# Chamar função de reversão
_reverter_programa
```

### Limpeza de Seleção
```bash
# Limpar arrays de seleção
_limpar_selecao_programas
```

## Considerações de Segurança

- Backup automático antes de alterações
- Validação de nomes de programas
- Verificação de integridade de downloads
- Logs de auditoria

## Performance

- Processamento eficiente com arrays
- Controle de loops para evitar excesso
- Movimentação otimizada de arquivos
- Verificações mínimas necessárias

---

*Documentação gerada automaticamente com base no código fonte e práticas de bash scripting.*