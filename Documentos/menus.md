# Documentacao do Modulo menus.sh

## Visao Geral
Modulo responsavel pela interface completa de navegacao do Sistema SAV, implementando menus hierarquicos interativos.

## Funcionalidades Principais

### 1. Sistema de Navegacao Hierarquica
- **Menu principal** com acesso a todas as funcionalidades
- **Submenus especializados** (programas, bibliotecas, ferramentas)
- **Navegacao bidirecional** entre niveis
- **Adaptacao contextual** baseada no sistema

### 2. Interface Responsiva
- **Deteccao de sistema** (IsCobol vs Micro Focus)
- **Configuracao condicional** baseada em variaveis
- **Exibicao contextual** de informacoes
- **Ocultacao automatica** de opcoes indisponiveis

## Estrutura de Menus

### Menu Principal (`_principal`)
**Cabecalho:**
```
============================================================
                    Menu Principal
============================================================
.. Empresa: EMPRESA_NAME ..
_| Sistema: iscobol - Versao do Iscobol: 2024 |_
============================================================
```

**Opcoes:**
1. **Atualizar Programa(s)** → `_menu_programas`
2. **Atualizar Biblioteca** → `_menu_biblioteca`
3. **Versao do IsCobol** (condicional)
4. **Versao do Linux**
5. **Ferramentas** → `_menu_ferramentas`
9. **Sair**

### Menu de Programas (`_menu_programas`)
**Atualizacao:**
1. Programa(s) ON-Line
2. Programa(s) OFF-Line
3. Programa(s) em Pacote

**Reversao:**
4. Voltar programa Atualizado

### Menu de Biblioteca (`_menu_biblioteca`)
**Atualizacao:**
1. Atualizacao do Transpc
2. Atualizacao do Savatu
3. Atualizacao OFF-Line

**Reversao:**
4. Voltar Programa(s) da Biblioteca

### Menu de Ferramentas (`_menu_ferramentas`)
**Opcoes (variam com configuracao de banco):**
1. Temporarios
2. Recuperar Arquivos (se banco != "s")
3. Rotinas de Backup (se banco != "s")
4. Enviar e Receber Arquivos
5. Expurgador de Arquivos
6. Parametros
7. Update
8. Lembretes

## Caracteristicas de Interface

### Sistema de Cores
```bash
# Cores contextuais
_linha "=" "${GREEN}"           # Separadores verdes
_mensagec "${RED}" "Titulo"     # Titulos em vermelho
_mensagec "${CYAN}" "Info"      # Informacoes em ciano
_mensagec "${GREEN}" "1 - Opcao" # Opcoes numeradas
```

### Elementos Visuais
- **Separadores**: `=` para linhas principais
- **Indicadores**: `_|` para informacoes importantes
- **Layout responsivo** baseado no terminal

## Tratamento de Entrada

### Validacao de Opcoes
```bash
case "${opcao}" in
    1) _funcao_correspondente ;;
    2) _outra_funcao ;;
    9) return ;;
    *)
        _opinvalida      # Tratamento padronizado
        _read_sleep 1    # Pausa antes de retry
        ;;
esac
```

### Adaptacao Contextual
```bash
# Sistema adapta opcoes automaticamente
if [[ "${BANCO}" = "s" ]]; then
    # Sistema com banco - opcoes especificas
else
    # Sistema sem banco - opcoes expandidas
fi
```

## Funcoes Auxiliares

### `_definir_base_trabalho()`
Define dinamicamente a base de trabalho atual.

```bash
_definir_base_trabalho() {
    local base_var="$1"
    export base_trabalho="${destino}${!base_var}"
}
```

### `_menu_escolha_base()`
Menu especializado para selecao de base de dados quando múltiplas estao configuradas.

### `_menu_tipo_backup()`
Selecao interativa do tipo de backup (completo/incremental).

## Caracteristicas de Seguranca

### Validacoes
- **Verificacao de variaveis** essenciais
- **Controle de fluxo** entre menus
- **Tratamento seguro** de entrada do usuario
- **Prevencao de navegacao** invalida

## Boas Praticas

### Interface do Usuario
- **Hierarquia clara** de navegacao
- **Feedback visual** constante
- **Mensagens informativas** sobre opcoes
- **Tratamento graceful** de erros

### Organizacao do Codigo
- **Funcoes modulares** bem definidas
- **Logica condicional** estruturada
- **Comentarios claros** sobre cada menu
- **Reutilizacao de padroes** visuais

## Exemplos de Uso

### Navegacao Tipica
```bash
_principal → 1 (Programas) → 1 (Online) → _atualizar_programa_online
```

### Selecao de Base
```bash
_menu_escolha_base → 2 (Base 2) → Define base_trabalho
```

### Configuracao Responsiva
```bash
# Sistema adapta automaticamente baseado em variaveis
if [[ "${sistema}" = "iscobol" ]]; then
    # Mostra opcao especifica do IsCobol
else
    # Mostra alternativa ou oculta opcao
fi
```

## Variaveis Utilizadas

### Variaveis Contextuais
- `sistema` - Tipo de sistema
- `EMPRESA` - Nome da empresa
- `verclass` - Versao do IsCobol
- `VERSAOANT` - Versao anterior
- `BANCO` - Configuracao de banco

### Variaveis de Estado
- `base_trabalho` - Base selecionada
- `tipo_backup` - Tipo escolhido
- `opcao` - Entrada do usuario

---

*Documentacao gerada automaticamente com base no codigo fonte e praticas de bash scripting.*