# Documentacao do Modulo lembrete.sh

## Visao Geral
O modulo `lembrete.sh` implementa um **sistema completo de bloco de notas** integrado ao **Sistema SAV (Script de Atualizacao Modular)**. Este modulo oferece funcionalidades para criacao, visualizacao, edicao e gerenciamento de lembretes e notas importantes para os usuarios do sistema.

## Funcionalidades Principais

### 1. Gestao de Notas
- **Criacao interativa** de novas notas
- **Visualizacao formatada** com moldura elegante
- **Edicao avancada** usando editor externo
- **Exclusao segura** com confirmacao

### 2. Integracao com o Sistema
- **Exibicao automatica** na inicializacao
- **Arquivo único** para todas as notas
- **Formatacao responsiva** baseada no terminal
- **Persistência** entre sessoes

### 3. Interface Amigavel
- **Entrada multilinha** com Ctrl+D
- **Visualizacao elegante** com bordas
- **Controle de editor** externo configuravel
- **Feedback visual** para todas as operacoes

## Estrutura do Codigo

### Arquivo de Notas
```bash
# Localizacao padrao
local arquivo_notas="${cfg_dir}/atualizal"

# Caracteristicas:
# - Uma nota por linha
# - Suporte a texto multilinha
# - Persistência automatica
# - Backup integrado ao sistema
```

## Funcoes Principais

### `_escrever_nova_nota()`
Criacao interativa de nova nota.

**Caracteristicas:**
- **Entrada multilinha** com `cat >>`
- **Finalizacao com Ctrl+D**
- **Feedback imediato** de sucesso/erro
- **Append automatico** ao arquivo existente

```bash
_escrever_nova_nota() {
    clear
    _linha
    _mensagec "${YELLOW}" "Digite sua nota (pressione Ctrl+D para finalizar):"
    _linha

    local arquivo_notas="${cfg_dir}/atualizal"
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
Exibe notas automaticamente na inicializacao.

**Caracteristicas:**
- **Verificacao automatica** de existência
- **Validacao de tamanho** (arquivo nao vazio)
- **Chamada integrada** à funcao de visualizacao
- **Execucao silenciosa** se nao houver notas

```bash
_mostrar_notas_iniciais() {
    local nota_file="${cfg_dir}/atualizal"

    if [[ -f "$nota_file" && -s "$nota_file" ]]; then
        _visualizar_notas_arquivo "$nota_file"
    fi
}
```

### `_visualizar_notas_arquivo()`
Visualizacao formatada com moldura elegante.

**Caracteristicas:**
- **Calculo dinamico** da largura baseada no conteúdo
- **Moldura adaptativa** com caracteres `+` e `=`
- **Formatacao responsiva** baseada no terminal
- **Controle robusto** de leitura de arquivo

```bash
_visualizar_notas_arquivo() {
    local arquivo="$1"
    local largura_max=0
    local largura_total
    local llinha

    # Calcular largura maxima do conteúdo
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
Edicao avancada usando editor externo.

**Caracteristicas:**
- **Deteccao automatica** de existência de notas
- **Editor configuravel** (`${EDITOR:-nano}`)
- **Tratamento de erros** se editor falhar
- **Feedback visual** sobre resultado

```bash
_editar_nota_existente() {
    local arquivo_notas="${cfg_dir}/atualizal"

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
Exclusao segura com confirmacao.

**Caracteristicas:**
- **Verificacao previa** de existência
- **Confirmacao obrigatoria** antes da exclusao
- **Remocao completa** do arquivo
- **Feedback visual** sobre resultado

```bash
_apagar_nota_existente() {
    local arquivo_notas="${cfg_dir}/atualizal"

    if [[ ! -f "$arquivo_notas" ]]; then
        _mensagec "${YELLOW}" "Nenhuma nota encontrada para excluir!"
        sleep 2
        return
    fi

    if _confirmar "Tem certeza que deseja apagar todas as notas?" "N"; then
        if rm -f "$arquivo_notas"; then
            _mensagec "${RED}" "Notas excluidas com sucesso!"
        else
            _mensagec "${RED}" "Erro ao excluir notas"
        fi
        sleep 2
    fi
}
```

## Caracteristicas de Interface

### Formatacao Visual Elegante
```bash
# Exemplo de saida formatada:
# +================================+
# | Esta e uma nota importante     |
# | sobre o sistema SAV            |
# |                                |
# | Lembrete: fazer backup mensal  |
# +================================+
```

### Controle de Editor Externo
```bash
# Usa variavel de ambiente EDITOR
${EDITOR:-nano} "$arquivo_notas"

# Exemplos:
# EDITOR=vim ./sistema.sh
# EDITOR=code ./sistema.sh
# (padrao: nano)
```

### Entrada Interativa
```bash
# Criacao de nota multilinha
cat >> "$arquivo_notas" << 'EOF'
Primeira linha da nota
Segunda linha da nota
...
EOF
```

## Caracteristicas de Seguranca

### Validacoes de Seguranca
- **Verificacao de permissoes** de leitura/escrita
- **Validacao de existência** antes de operacoes
- **Confirmacao obrigatoria** para exclusao
- **Tratamento seguro** de variaveis de ambiente

### Tratamento Seguro de Arquivos
- **Controle de acesso** ao arquivo de notas
- **Backup automatico** atraves do sistema de arquivos
- **Validacao de caminhos** seguros
- **Tratamento de erros** graceful

## Boas Praticas Implementadas

### Organizacao do Codigo
- **Funcoes especificas** por operacao
- **Validacoes centralizadas** antes de acoes
- **Comentarios claros** sobre cada funcao
- **Tratamento uniforme** de erros

### Interface do Usuario
- **Instrucoes claras** para entrada de dados
- **Feedback visual** constante
- **Controle intuitivo** de navegacao
- **Mensagens informativas** sobre estado

### Manutenibilidade
- **Arquivo único** para todas as notas
- **Formatacao responsiva** ao terminal
- **Editor configuravel** pelo usuario
- **Logs integrados** ao sistema

## Integracao com o Sistema

### Dependências de Modulos
- **`config.sh`** - Variaveis de configuracao (`cfg_dir`)
- **`utils.sh`** - Funcoes utilitarias (cores, mensagens, validacoes)
- **`menus.sh`** - Interface de navegacao integrada

### Arquivo de Notas
- **Localizacao**: `${cfg_dir}/atualizal`
- **Formato**: Texto simples, uma nota por linha
- **Backup**: Incluido automaticamente nos backups do sistema
- **Permissoes**: Controle de acesso integrado

## Exemplos de Uso

### Criacao de Nova Nota
```bash
# Chamar funcao de criacao
_escrever_nova_nota

# Interface mostrada:
# ============================================================
# Digite sua nota (pressione Ctrl+D para finalizar):
# ============================================================
# [usuario digita nota multilinha]
# [Ctrl+D para finalizar]
# ============================================================
# Nota gravada com sucesso!
```

### Visualizacao de Notas
```bash
# Visualizacao automatica na inicializacao
_mostrar_notas_iniciais

# Ou visualizacao manual
_visualizar_notas_arquivo "${cfg_dir}/atualizal"

# Saida formatada:
# +============================================================+
# | Lembrete: Fazer backup dos dados hoje                     |
# | Verificar atualizacao do sistema IsCobol versao 2024      |
# | Contatar administrador sobre nova versao da biblioteca    |
# +============================================================+
```

### Edicao de Notas
```bash
# Edicao com editor padrao
_editar_nota_existente

# Usa nano por padrao, mas pode ser configurado:
# EDITOR=vim _editar_nota_existente
# EDITOR=code _editar_nota_existente
```

### Exclusao de Notas
```bash
# Exclusao com confirmacao
_apagar_nota_existente

# Processo:
# 1. Verifica existência de notas
# 2. Solicita confirmacao
# 3. Remove arquivo se confirmado
# 4. Feedback do resultado
```

## Caracteristicas Avancadas

### Formatacao Responsiva
```bash
# Calculo dinamico baseado no conteúdo
while IFS= read -r llinha; do
    if (( ${#llinha} > largura_max )); then
        largura_max=${#llinha}
    fi
done < "$arquivo"

largura_total=$((largura_max + 4))
```

### Controle de Editor Inteligente
```bash
# Usa variavel de ambiente com fallback
${EDITOR:-nano} "$arquivo_notas"

# Beneficios:
# - Respeita preferência do usuario
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

### Estrategias Implementadas
- **Validacao previa** de arquivos e permissoes
- **Mensagens especificas** para diferentes tipos de erro
- **Confirmacoes importantes** antes de acoes destrutivas
- **Recuperacao automatica** quando possivel

### Codigos de Retorno
- `0` - Sucesso
- `1` - Erro de arquivo ou permissao

## Consideracoes de Performance

### Otimizacoes
- **Leitura eficiente** com `while IFS= read`
- **Calculo único** da largura maxima
- **Formatacao direta** sem processamento desnecessario
- **Controle minimo** de recursos

### Recursos de Sistema
- **Memoria minima** durante processamento
- **CPU otimizada** para formatacao
- **I/O controlado** com redirecionamento adequado

## Debugging e Desenvolvimento

### Estrategias para Debug
- **Verificacao visual** da formatacao
- **Teste de diferentes terminais** e larguras
- **Validacao de permissoes** de arquivo
- **Teste de editor externo** configurado

### Diagnostico de Problemas
```bash
# Verificar arquivo de notas
ls -la "${cfg_dir}/atualizal"

# Testar permissoes
touch "${cfg_dir}/atualizal"
echo "teste" >> "${cfg_dir}/atualizal"

# Verificar editor padrao
echo "Editor: $EDITOR"
which nano vim  # Verificar editores disponiveis
```

## Casos de Uso Comuns

### Anotacoes de Manutencao
```bash
# Registrar atividades de manutencao
_escrever_nova_nota
# Conteúdo:
# Backup realizado em 16/12/2024
# Verificacao de bibliotecas concluida
# Sistema atualizado para versao 2024
```

### Lembretes de Procedimentos
```bash
# Documentar procedimentos importantes
_escrever_nova_nota
# Conteúdo:
# Procedimento de atualizacao:
# 1. Fazer backup completo
# 2. Baixar nova versao
# 3. Testar em ambiente de desenvolvimento
# 4. Aplicar em producao
```

### Notas de Configuracao
```bash
# Registrar configuracoes especificas
_escrever_nova_nota
# Conteúdo:
# Sistema configurado para:
# - IsCobol 2024
# - Base principal: /sav/dados
# - Backup automatico: habilitado
# - Modo offline: desabilitado
```

## Integracao com o Sistema

### Fluxo de Inicializacao
```
principal.sh → _mostrar_notas_iniciais → _visualizar_notas_arquivo → interface do usuario
```

### Integracao com Menus
```
menus.sh → _menu_lembretes → funcoes de lembrete → retorno ao menu
```

## Variaveis de Ambiente

### Variaveis Utilizadas
- `cfg_dir` - Diretorio de configuracao (de config.sh)
- `EDITOR` - Editor externo para edicao (opcional)
- `COLUMNS` - Largura do terminal (de utils.sh)

### Arquivos Relacionados
- `${cfg_dir}/atualizal` - Arquivo principal de notas
- `${EDITOR:-nano}` - Editor para edicao avancada

## Caracteristicas Especiais

### Formatacao ASCII Art
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
# Adaptacao automatica à largura do terminal
largura_total=$((largura_max + 4))

# Funciona em diferentes ambientes:
# - Terminais largos (120+ colunas)
# - Terminais padrao (80 colunas)
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

## Exemplos Praticos

### Cenario de Uso Tipico
```bash
# 1. Sistema inicia e mostra notas existentes
_mostrar_notas_iniciais
# +================================+
# | Backup pendente para hoje      |
# | Verificar atualizacao IsCobol  |
# +================================+

# 2. Usuario acessa menu de lembretes
_menu_lembretes → 1 (Escrever nova nota)
_escrever_nova_nota
# Digita: "Sistema atualizado em 16/12/2024"

# 3. Visualiza todas as notas
_visualizar_notas_arquivo
# +================================+
# | Backup pendente para hoje      |
# | Verificar atualizacao IsCobol  |
# | Sistema atualizado em 16/12/2024 |
# +================================+
```

### Edicao Avancada
```bash
# Editar com Vim
EDITOR=vim _editar_nota_existente

# Ou com VS Code
EDITOR=code _editar_nota_existente
```

## Tratamento de Erros

### Estrategias Implementadas
- **Validacao de arquivo** antes de operacoes
- **Verificacao de permissoes** de leitura/escrita
- **Mensagens claras** sobre problemas encontrados
- **Fallback automatico** para situacoes de erro

### Recuperacao de Erros
```bash
# Tratamento especifico por situacao
if [[ ! -f "$arquivo_notas" ]]; then
    _mensagec "${YELLOW}" "Nenhuma nota encontrada para editar!"
    sleep 2
    return
fi
```

## Consideracoes de Performance

### Otimizacoes
- **Leitura única** para calculo de largura
- **Formatacao direta** sem armazenamento intermediario
- **Controle minimo** de recursos durante visualizacao
- **Processamento eficiente** de grandes arquivos

### Recursos de Sistema
- **Memoria proporcional** ao tamanho do arquivo
- **CPU minima** durante formatacao
- **I/O otimizado** com redirecionamento adequado

## Debugging e Desenvolvimento

### Estrategias para Debug
- **Teste visual** em diferentes terminais
- **Verificacao de largura** de conteúdo
- **Teste de editor externo** configurado
- **Validacao de permissoes** de arquivo

### Diagnostico de Problemas
```bash
# Verificar conteúdo do arquivo
cat "${cfg_dir}/atualizal"

# Testar formatacao
_visualizar_notas_arquivo "${cfg_dir}/atualizal"

# Verificar editor
echo "Editor padrao: ${EDITOR:-nano}"
```

## Casos de Uso Avancados

### Documentacao de Procedimentos
```bash
# Registrar procedimentos complexos
_escrever_nova_nota
# Conteúdo multilinha:
# Procedimento de recuperacao de emergência:
# 1. Identificar último backup valido
# 2. Parar servicos relacionados
# 3. Restaurar backup completo
# 4. Verificar integridade dos dados
# 5. Reiniciar servicos
# 6. Testar funcionalidades criticas
```

### Lista de Verificacao
```bash
# Criar checklist de manutencao
_escrever_nova_nota
# Conteúdo:
# ☑ Backup completo realizado
# ☐ Verificacao de logs de erro
# ☐ Teste de conectividade com servidor
# ☐ Validacao de bibliotecas atualizadas
# ☐ Limpeza de arquivos temporarios
```

### Notas de Configuracao
```bash
# Documentar configuracoes especificas
_escrever_nova_nota
# Conteúdo:
# Configuracao atual:
# Sistema: IsCobol 2024
# Base: /sav/dados
# Backup: automatico diario
# Modo: online
# Última atualizacao: 16/12/2024
```

## Integracao com o Sistema

### Fluxo Completo
```
inicializacao → _mostrar_notas_iniciais → usuario lê notas → menu → _menu_lembretes → operacoes de nota → retorno
```

### Backup e Recuperacao
- **Arquivo de notas** incluido automaticamente nos backups
- **Restauracao automatica** junto com configuracoes
- **Preservacao de historico** entre versoes

---

*Documentacao gerada automaticamente com base no codigo fonte e praticas de bash scripting.*