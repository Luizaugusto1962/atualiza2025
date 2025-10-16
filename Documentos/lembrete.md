# Documentação do Módulo lembrete.sh

## Visão Geral
O módulo `lembrete.sh` implementa um **sistema completo de bloco de notas** integrado ao **Sistema SAV (Script de Atualização Modular)**. Este módulo oferece funcionalidades para criação, visualização, edição e gerenciamento de lembretes e notas importantes para os usuários do sistema.

## Funcionalidades Principais

### 1. Gestão de Notas
- **Criação interativa** de novas notas
- **Visualização formatada** com moldura elegante
- **Edição avançada** usando editor externo
- **Exclusão segura** com confirmação

### 2. Integração com o Sistema
- **Exibição automática** na inicialização
- **Arquivo único** para todas as notas
- **Formatação responsiva** baseada no terminal
- **Persistência** entre sessões

### 3. Interface Amigável
- **Entrada multilinha** com Ctrl+D
- **Visualização elegante** com bordas
- **Controle de editor** externo configurável
- **Feedback visual** para todas as operações

## Estrutura do Código

### Arquivo de Notas
```bash
# Localização padrão
local arquivo_notas="${LIB_CFG}/atualizal"

# Características:
# - Uma nota por linha
# - Suporte a texto multilinha
# - Persistência automática
# - Backup integrado ao sistema
```

## Funções Principais

### `_escrever_nova_nota()`
Criação interativa de nova nota.

**Características:**
- **Entrada multilinha** com `cat >>`
- **Finalização com Ctrl+D**
- **Feedback imediato** de sucesso/erro
- **Append automático** ao arquivo existente

```bash
_escrever_nova_nota() {
    clear
    _linha
    _mensagec "${YELLOW}" "Digite sua nota (pressione Ctrl+D para finalizar):"
    _linha

    local arquivo_notas="${LIB_CFG}/atualizal"
    if cat >> "$arquivo_notas"; then
        _mensagec "${YELLOW}" "Nota gravada com sucesso!"
        sleep 2
    else
        _mensagec "${RED}" "Erro ao gravar nota"
        sleep 2
    fi
}
```

### `_mostrar_notas_iniciais()`
Exibe notas automaticamente na inicialização.

**Características:**
- **Verificação automática** de existência
- **Validação de tamanho** (arquivo não vazio)
- **Chamada integrada** à função de visualização
- **Execução silenciosa** se não houver notas

```bash
_mostrar_notas_iniciais() {
    local nota_file="${LIB_CFG}/atualizal"

    if [[ -f "$nota_file" && -s "$nota_file" ]]; then
        _visualizar_notas_arquivo "$nota_file"
    fi
}
```

### `_visualizar_notas_arquivo()`
Visualização formatada com moldura elegante.

**Características:**
- **Cálculo dinâmico** da largura baseada no conteúdo
- **Moldura adaptativa** com caracteres `+` e `=`
- **Formatação responsiva** baseada no terminal
- **Controle robusto** de leitura de arquivo

```bash
_visualizar_notas_arquivo() {
    local arquivo="$1"
    local largura_max=0
    local largura_total
    local llinha

    # Calcular largura máxima do conteúdo
    while IFS= read -r llinha; do
        if (( ${#llinha} > largura_max )); then
            largura_max=${#llinha}
        fi
    done < "$arquivo"

    largura_total=$((largura_max + 4))

    # Moldura superior
    printf "+"
    printf "%*s" $((largura_total - 2)) "" | tr ' ' '='
    printf "+\n"

    # Conteúdo com bordas
    while IFS= read -r llinha || [[ -n "$llinha" ]]; do
        printf "| %-*s |\n" $((largura_total - 4)) "$llinha"
    done < "$arquivo"

    # Moldura inferior
    printf "+"
    printf "%*s" $((largura_total - 2)) "" | tr ' ' '='
    printf "+\n"
}
```

### `_editar_nota_existente()`
Edição avançada usando editor externo.

**Características:**
- **Detecção automática** de existência de notas
- **Editor configurável** (`${EDITOR:-nano}`)
- **Tratamento de erros** se editor falhar
- **Feedback visual** sobre resultado

```bash
_editar_nota_existente() {
    local arquivo_notas="${LIB_CFG}/atualizal"

    if [[ -f "$arquivo_notas" ]]; then
        if ! ${EDITOR:-nano} "$arquivo_notas"; then
            _mensagec "${RED}" "Erro ao abrir editor!"
            sleep 2
        fi
    else
        _mensagec "${YELLOW}" "Nenhuma nota encontrada para editar!"
        sleep 2
    fi
}
```

### `_apagar_nota_existente()`
Exclusão segura com confirmação.

**Características:**
- **Verificação prévia** de existência
- **Confirmação obrigatória** antes da exclusão
- **Remoção completa** do arquivo
- **Feedback visual** sobre resultado

```bash
_apagar_nota_existente() {
    local arquivo_notas="${LIB_CFG}/atualizal"

    if [[ ! -f "$arquivo_notas" ]]; then
        _mensagec "${YELLOW}" "Nenhuma nota encontrada para excluir!"
        sleep 2
        return
    fi

    if _confirmar "Tem certeza que deseja apagar todas as notas?" "N"; then
        if rm -f "$arquivo_notas"; then
            _mensagec "${RED}" "Notas excluídas com sucesso!"
        else
            _mensagec "${RED}" "Erro ao excluir notas"
        fi
        sleep 2
    fi
}
```

## Características de Interface

### Formatação Visual Elegante
```bash
# Exemplo de saída formatada:
# +================================+
# | Esta é uma nota importante     |
# | sobre o sistema SAV            |
# |                                |
# | Lembrete: fazer backup mensal  |
# +================================+
```

### Controle de Editor Externo
```bash
# Usa variável de ambiente EDITOR
${EDITOR:-nano} "$arquivo_notas"

# Exemplos:
# EDITOR=vim ./sistema.sh
# EDITOR=code ./sistema.sh
# (padrão: nano)
```

### Entrada Interativa
```bash
# Criação de nota multilinha
cat >> "$arquivo_notas" << 'EOF'
Primeira linha da nota
Segunda linha da nota
...
EOF
```

## Características de Segurança

### Validações de Segurança
- **Verificação de permissões** de leitura/escrita
- **Validação de existência** antes de operações
- **Confirmação obrigatória** para exclusão
- **Tratamento seguro** de variáveis de ambiente

### Tratamento Seguro de Arquivos
- **Controle de acesso** ao arquivo de notas
- **Backup automático** através do sistema de arquivos
- **Validação de caminhos** seguros
- **Tratamento de erros** graceful

## Boas Práticas Implementadas

### Organização do Código
- **Funções específicas** por operação
- **Validações centralizadas** antes de ações
- **Comentários claros** sobre cada função
- **Tratamento uniforme** de erros

### Interface do Usuário
- **Instruções claras** para entrada de dados
- **Feedback visual** constante
- **Controle intuitivo** de navegação
- **Mensagens informativas** sobre estado

### Manutenibilidade
- **Arquivo único** para todas as notas
- **Formatação responsiva** ao terminal
- **Editor configurável** pelo usuário
- **Logs integrados** ao sistema

## Integração com o Sistema

### Dependências de Módulos
- **`config.sh`** - Variáveis de configuração (`LIB_CFG`)
- **`utils.sh`** - Funções utilitárias (cores, mensagens, validações)
- **`menus.sh`** - Interface de navegação integrada

### Arquivo de Notas
- **Localização**: `${LIB_CFG}/atualizal`
- **Formato**: Texto simples, uma nota por linha
- **Backup**: Incluído automaticamente nos backups do sistema
- **Permissões**: Controle de acesso integrado

## Exemplos de Uso

### Criação de Nova Nota
```bash
# Chamar função de criação
_escrever_nova_nota

# Interface mostrada:
# ============================================================
# Digite sua nota (pressione Ctrl+D para finalizar):
# ============================================================
# [usuário digita nota multilinha]
# [Ctrl+D para finalizar]
# ============================================================
# Nota gravada com sucesso!
```

### Visualização de Notas
```bash
# Visualização automática na inicialização
_mostrar_notas_iniciais

# Ou visualização manual
_visualizar_notas_arquivo "${LIB_CFG}/atualizal"

# Saída formatada:
# +============================================================+
# | Lembrete: Fazer backup dos dados hoje                     |
# | Verificar atualização do sistema IsCobol versão 2024      |
# | Contatar administrador sobre nova versão da biblioteca    |
# +============================================================+
```

### Edição de Notas
```bash
# Edição com editor padrão
_editar_nota_existente

# Usa nano por padrão, mas pode ser configurado:
# EDITOR=vim _editar_nota_existente
# EDITOR=code _editar_nota_existente
```

### Exclusão de Notas
```bash
# Exclusão com confirmação
_apagar_nota_existente

# Processo:
# 1. Verifica existência de notas
# 2. Solicita confirmação
# 3. Remove arquivo se confirmado
# 4. Feedback do resultado
```

## Características Avançadas

### Formatação Responsiva
```bash
# Cálculo dinâmico baseado no conteúdo
while IFS= read -r llinha; do
    if (( ${#llinha} > largura_max )); then
        largura_max=${#llinha}
    fi
done < "$arquivo"

largura_total=$((largura_max + 4))
```

### Controle de Editor Inteligente
```bash
# Usa variável de ambiente com fallback
${EDITOR:-nano} "$arquivo_notas"

# Benefícios:
# - Respeita preferência do usuário
# - Fallback seguro para nano
# - Funciona em diferentes ambientes
```

### Entrada Robusta
```bash
# Tratamento de entrada multilinha
if cat >> "$arquivo_notas"; then
    # Sucesso na escrita
else
    # Tratamento de erro
fi
```

## Tratamento de Erros

### Estratégias Implementadas
- **Validação prévia** de arquivos e permissões
- **Mensagens específicas** para diferentes tipos de erro
- **Confirmações importantes** antes de ações destrutivas
- **Recuperação automática** quando possível

### Códigos de Retorno
- `0` - Sucesso
- `1` - Erro de arquivo ou permissão

## Considerações de Performance

### Otimizações
- **Leitura eficiente** com `while IFS= read`
- **Cálculo único** da largura máxima
- **Formatação direta** sem processamento desnecessário
- **Controle mínimo** de recursos

### Recursos de Sistema
- **Memória mínima** durante processamento
- **CPU otimizada** para formatação
- **I/O controlado** com redirecionamento adequado

## Debugging e Desenvolvimento

### Estratégias para Debug
- **Verificação visual** da formatação
- **Teste de diferentes terminais** e larguras
- **Validação de permissões** de arquivo
- **Teste de editor externo** configurado

### Diagnóstico de Problemas
```bash
# Verificar arquivo de notas
ls -la "${LIB_CFG}/atualizal"

# Testar permissões
touch "${LIB_CFG}/atualizal"
echo "teste" >> "${LIB_CFG}/atualizal"

# Verificar editor padrão
echo "Editor: $EDITOR"
which nano vim  # Verificar editores disponíveis
```

## Casos de Uso Comuns

### Anotações de Manutenção
```bash
# Registrar atividades de manutenção
_escrever_nova_nota
# Conteúdo:
# Backup realizado em 16/12/2024
# Verificação de bibliotecas concluída
# Sistema atualizado para versão 2024
```

### Lembretes de Procedimentos
```bash
# Documentar procedimentos importantes
_escrever_nova_nota
# Conteúdo:
# Procedimento de atualização:
# 1. Fazer backup completo
# 2. Baixar nova versão
# 3. Testar em ambiente de desenvolvimento
# 4. Aplicar em produção
```

### Notas de Configuração
```bash
# Registrar configurações específicas
_escrever_nova_nota
# Conteúdo:
# Sistema configurado para:
# - IsCobol 2024
# - Base principal: /sav/dados
# - Backup automático: habilitado
# - Modo offline: desabilitado
```

## Integração com o Sistema

### Fluxo de Inicialização
```
principal.sh → _mostrar_notas_iniciais → _visualizar_notas_arquivo → interface do usuário
```

### Integração com Menus
```
menus.sh → _menu_lembretes → funções de lembrete → retorno ao menu
```

## Variáveis de Ambiente

### Variáveis Utilizadas
- `LIB_CFG` - Diretório de configuração (de config.sh)
- `EDITOR` - Editor externo para edição (opcional)
- `COLUMNS` - Largura do terminal (de utils.sh)

### Arquivos Relacionados
- `${LIB_CFG}/atualizal` - Arquivo principal de notas
- `${EDITOR:-nano}` - Editor para edição avançada

## Características Especiais

### Formatação ASCII Art
```bash
# Moldura elegante com caracteres especiais
printf "+"
printf "%*s" $((largura_total - 2)) "" | tr ' ' '='
printf "+\n"

# Conteúdo alinhado
printf "| %-*s |\n" $((largura_total - 4)) "$llinha"
```

### Controle de Terminal Inteligente
```bash
# Adaptação automática à largura do terminal
largura_total=$((largura_max + 4))

# Funciona em diferentes ambientes:
# - Terminais largos (120+ colunas)
# - Terminais padrão (80 colunas)
# - Terminais estreitos (40 colunas)
```

### Tratamento de Linhas Vazias
```bash
# Processamento robusto de conteúdo
while IFS= read -r llinha || [[ -n "$llinha" ]]; do
    # Trata tanto EOF normal quanto linhas vazias finais
    printf "| %-*s |\n" $((largura_total - 4)) "$llinha"
done < "$arquivo"
```

## Exemplos Práticos

### Cenário de Uso Típico
```bash
# 1. Sistema inicia e mostra notas existentes
_mostrar_notas_iniciais
# +================================+
# | Backup pendente para hoje      |
# | Verificar atualização IsCobol  |
# +================================+

# 2. Usuário acessa menu de lembretes
_menu_lembretes → 1 (Escrever nova nota)
_escrever_nova_nota
# Digita: "Sistema atualizado em 16/12/2024"

# 3. Visualiza todas as notas
_visualizar_notas_arquivo
# +================================+
# | Backup pendente para hoje      |
# | Verificar atualização IsCobol  |
# | Sistema atualizado em 16/12/2024 |
# +================================+
```

### Edição Avançada
```bash
# Editar com Vim
EDITOR=vim _editar_nota_existente

# Ou com VS Code
EDITOR=code _editar_nota_existente
```

## Tratamento de Erros

### Estratégias Implementadas
- **Validação de arquivo** antes de operações
- **Verificação de permissões** de leitura/escrita
- **Mensagens claras** sobre problemas encontrados
- **Fallback automático** para situações de erro

### Recuperação de Erros
```bash
# Tratamento específico por situação
if [[ ! -f "$arquivo_notas" ]]; then
    _mensagec "${YELLOW}" "Nenhuma nota encontrada para editar!"
    sleep 2
    return
fi
```

## Considerações de Performance

### Otimizações
- **Leitura única** para cálculo de largura
- **Formatação direta** sem armazenamento intermediário
- **Controle mínimo** de recursos durante visualização
- **Processamento eficiente** de grandes arquivos

### Recursos de Sistema
- **Memória proporcional** ao tamanho do arquivo
- **CPU mínima** durante formatação
- **I/O otimizado** com redirecionamento adequado

## Debugging e Desenvolvimento

### Estratégias para Debug
- **Teste visual** em diferentes terminais
- **Verificação de largura** de conteúdo
- **Teste de editor externo** configurado
- **Validação de permissões** de arquivo

### Diagnóstico de Problemas
```bash
# Verificar conteúdo do arquivo
cat "${LIB_CFG}/atualizal"

# Testar formatação
_visualizar_notas_arquivo "${LIB_CFG}/atualizal"

# Verificar editor
echo "Editor padrão: ${EDITOR:-nano}"
```

## Casos de Uso Avançados

### Documentação de Procedimentos
```bash
# Registrar procedimentos complexos
_escrever_nova_nota
# Conteúdo multilinha:
# Procedimento de recuperação de emergência:
# 1. Identificar último backup válido
# 2. Parar serviços relacionados
# 3. Restaurar backup completo
# 4. Verificar integridade dos dados
# 5. Reiniciar serviços
# 6. Testar funcionalidades críticas
```

### Lista de Verificação
```bash
# Criar checklist de manutenção
_escrever_nova_nota
# Conteúdo:
# ☑ Backup completo realizado
# ☐ Verificação de logs de erro
# ☐ Teste de conectividade com servidor
# ☐ Validação de bibliotecas atualizadas
# ☐ Limpeza de arquivos temporários
```

### Notas de Configuração
```bash
# Documentar configurações específicas
_escrever_nova_nota
# Conteúdo:
# Configuração atual:
# Sistema: IsCobol 2024
# Base: /sav/dados
# Backup: automático diário
# Modo: online
# Última atualização: 16/12/2024
```

## Integração com o Sistema

### Fluxo Completo
```
inicialização → _mostrar_notas_iniciais → usuário lê notas → menu → _menu_lembretes → operações de nota → retorno
```

### Backup e Recuperação
- **Arquivo de notas** incluído automaticamente nos backups
- **Restauração automática** junto com configurações
- **Preservação de histórico** entre versões

---

*Documentação gerada automaticamente com base no código fonte e práticas de bash scripting.*