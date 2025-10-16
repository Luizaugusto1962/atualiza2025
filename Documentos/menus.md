# Documentação do Módulo menus.sh

## Visão Geral
Módulo responsável pela interface completa de navegação do Sistema SAV, implementando menus hierárquicos interativos.

## Funcionalidades Principais

### 1. Sistema de Navegação Hierárquica
- **Menu principal** com acesso a todas as funcionalidades
- **Submenus especializados** (programas, bibliotecas, ferramentas)
- **Navegação bidirecional** entre níveis
- **Adaptação contextual** baseada no sistema

### 2. Interface Responsiva
- **Detecção de sistema** (IsCobol vs Micro Focus)
- **Configuração condicional** baseada em variáveis
- **Exibição contextual** de informações
- **Ocultação automática** de opções indisponíveis

## Estrutura de Menus

### Menu Principal (`_principal`)
**Cabeçalho:**
```
============================================================
                    Menu Principal
============================================================
.. Empresa: EMPRESA_NAME ..
_| Sistema: iscobol - Versao do Iscobol: 2024 |_
============================================================
```

**Opções:**
1. **Atualizar Programa(s)** → `_menu_programas`
2. **Atualizar Biblioteca** → `_menu_biblioteca`
3. **Versão do IsCobol** (condicional)
4. **Versão do Linux**
5. **Ferramentas** → `_menu_ferramentas`
9. **Sair**

### Menu de Programas (`_menu_programas`)
**Atualização:**
1. Programa(s) ON-Line
2. Programa(s) OFF-Line
3. Programa(s) em Pacote

**Reversão:**
4. Voltar programa Atualizado

### Menu de Biblioteca (`_menu_biblioteca`)
**Atualização:**
1. Atualização do Transpc
2. Atualização do Savatu
3. Atualização OFF-Line

**Reversão:**
4. Voltar Programa(s) da Biblioteca

### Menu de Ferramentas (`_menu_ferramentas`)
**Opções (variam com configuração de banco):**
1. Temporários
2. Recuperar Arquivos (se banco != "s")
3. Rotinas de Backup (se banco != "s")
4. Enviar e Receber Arquivos
5. Expurgador de Arquivos
6. Parâmetros
7. Update
8. Lembretes

## Características de Interface

### Sistema de Cores
```bash
# Cores contextuais
_linha "=" "${GREEN}"           # Separadores verdes
_mensagec "${RED}" "Título"     # Títulos em vermelho
_mensagec "${CYAN}" "Info"      # Informações em ciano
_mensagec "${GREEN}" "1 - Opção" # Opções numeradas
```

### Elementos Visuais
- **Separadores**: `=` para linhas principais
- **Indicadores**: `_|` para informações importantes
- **Layout responsivo** baseado no terminal

## Tratamento de Entrada

### Validação de Opções
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

### Adaptação Contextual
```bash
# Sistema adapta opções automaticamente
if [[ "${BANCO}" = "s" ]]; then
    # Sistema com banco - opções específicas
else
    # Sistema sem banco - opções expandidas
fi
```

## Funções Auxiliares

### `_definir_base_trabalho()`
Define dinamicamente a base de trabalho atual.

```bash
_definir_base_trabalho() {
    local base_var="$1"
    export base_trabalho="${destino}${!base_var}"
}
```

### `_menu_escolha_base()`
Menu especializado para seleção de base de dados quando múltiplas estão configuradas.

### `_menu_tipo_backup()`
Seleção interativa do tipo de backup (completo/incremental).

## Características de Segurança

### Validações
- **Verificação de variáveis** essenciais
- **Controle de fluxo** entre menus
- **Tratamento seguro** de entrada do usuário
- **Prevenção de navegação** inválida

## Boas Práticas

### Interface do Usuário
- **Hierarquia clara** de navegação
- **Feedback visual** constante
- **Mensagens informativas** sobre opções
- **Tratamento graceful** de erros

### Organização do Código
- **Funções modulares** bem definidas
- **Lógica condicional** estruturada
- **Comentários claros** sobre cada menu
- **Reutilização de padrões** visuais

## Exemplos de Uso

### Navegação Típica
```bash
_principal → 1 (Programas) → 1 (Online) → _atualizar_programa_online
```

### Seleção de Base
```bash
_menu_escolha_base → 2 (Base 2) → Define base_trabalho
```

### Configuração Responsiva
```bash
# Sistema adapta automaticamente baseado em variáveis
if [[ "${sistema}" = "iscobol" ]]; then
    # Mostra opção específica do IsCobol
else
    # Mostra alternativa ou oculta opção
fi
```

## Variáveis Utilizadas

### Variáveis Contextuais
- `sistema` - Tipo de sistema
- `EMPRESA` - Nome da empresa
- `verclass` - Versão do IsCobol
- `VERSAOANT` - Versão anterior
- `BANCO` - Configuração de banco

### Variáveis de Estado
- `base_trabalho` - Base selecionada
- `tipo_backup` - Tipo escolhido
- `opcao` - Entrada do usuário

---

*Documentação gerada automaticamente com base no código fonte e práticas de bash scripting.*