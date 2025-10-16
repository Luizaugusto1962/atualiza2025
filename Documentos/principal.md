# Documentação do Módulo principal.sh

## Visão Geral
O módulo `principal.sh` é o arquivo principal do **Sistema SAV (Script de Atualização Modular)**. Funciona como um orquestrador central responsável pelo carregamento sequencial de módulos, inicialização do sistema e controle do fluxo principal da aplicação.

## Função Principal
Este arquivo implementa o padrão de design **"Main Guard"** em bash, onde o script pode ser executado diretamente ou incluído como módulo por outros scripts.

## Estrutura do Sistema

### Constantes e Configurações
```bash
# Versão do sistema
UPDATE="15/10/2024-00"
readonly UPDATE

# Diretórios do sistema
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/libs"
LIB_CFG="${SCRIPT_DIR}/cfg"
```

### Características dos Diretórios
- **`SCRIPT_DIR`**: Diretório onde o script está localizado
- **`LIB_DIR`**: Diretório contendo os módulos do sistema (`libs/`)
- **`LIB_CFG`**: Diretório de configurações (`cfg/`)

## Sistema de Carregamento de Módulos

### Função `_carregar_modulo()`
Carrega dinamicamente módulos bash com validações de segurança.

**Parâmetros:**
- `$1` - Nome do módulo a ser carregado

**Validações:**
- Existência do arquivo
- Permissões de leitura
- Tratamento de erros com saída do programa

**Sintaxe utilizada:**
```bash
_carregar_modulo "utils.sh"
```

### Ordem de Carregamento
A ordem de carregamento é crítica para o funcionamento do sistema:

1. **`utils.sh`** - Utilitários básicos (funções essenciais)
2. **`config.sh`** - Configurações do sistema
3. **`lembrete.sh`** - Sistema de lembretes
4. **`rsync.sh`** - Operações de rede e sincronização
5. **`sistema.sh`** - Informações do sistema operacional
6. **`arquivos.sh`** - Gestão e manipulação de arquivos
7. **`backup.sh`** - Sistema de backup e restauração
8. **`programas.sh`** - Gestão de programas e atualizações
9. **`biblioteca.sh`** - Gestão de bibliotecas
10. **`menus.sh`** - Sistema de menus e interface

## Funções de Inicialização

### `_inicializar_sistema()`
Inicializa completamente o ambiente do sistema SAV.

**Processo de inicialização:**
1. **Carregamento de configurações** - `_carregar_configuracoes`
2. **Verificação de dependências** - `_check_instalado`
3. **Validação de diretórios** - `_validar_diretorios`
4. **Configuração do ambiente** - `_configurar_ambiente`
5. **Limpeza automática** - `_executar_expurgador_diario`

### `main()`
Função principal que controla o fluxo da aplicação.

**Características:**
- **Tratamento de sinais** - `trap '_resetando' EXIT INT TERM`
- **Inicialização sequencial** - Chama `_inicializar_sistema`
- **Interface inicial** - `_mostrar_notas_iniciais`
- **Menu principal** - `_principal`

## Padrão Main Guard

### Implementação
```bash
# Verificar se está sendo executado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

**Funcionamento:**
- Quando executado diretamente: `bash principal.sh` → chama `main()`
- Quando incluído como módulo: `. principal.sh` → apenas carrega funções

## Tratamento de Erros

### Estratégias Implementadas

#### Validação de Diretórios
```bash
if [[ ! -d "${LIB_DIR}" ]]; then
    echo "ERRO: Diretório ${LIB_DIR} nao encontrado."
    echo "Certifique-se de que todos os módulos estao instalados corretamente."
    exit 1
fi
```

#### Carregamento Seguro de Módulos
```bash
if [[ ! -f "${caminho}" ]]; then
    echo "ERRO: Modulo ${modulo} nao encontrado em ${caminho}"
    exit 1
fi

if [[ ! -r "${caminho}" ]]; then
    echo "ERRO: Modulo ${modulo} nao pode ser lido"
    exit 1
fi
```

## Características de Segurança

### Imutabilidade
- Uso de `readonly` para constantes críticas
- Proteção contra modificação acidental

### Tratamento de Sinais
- Limpeza automática no término (`trap '_resetando'`)
- Tratamento de interrupções (Ctrl+C)

### Validações de Permissões
- Verificação de existência de arquivos
- Controle de permissões de leitura
- Validação de estrutura de diretórios

## Dependências do Sistema

### Diretórios Obrigatórios
- `libs/` - Contém todos os módulos do sistema
- `cfg/` - Arquivos de configuração

### Módulos Essenciais
Todos os módulos listados na ordem de carregamento são considerados críticos para o funcionamento do sistema.

## Logs e Auditoria

### ShellCheck
- Uso de `# shellcheck source=/dev/null` para evitar warnings
- Compatibilidade com análise estática de código

## Boas Práticas Implementadas

### Organização Modular
- Separação clara de responsabilidades
- Carregamento sequencial controlado
- Dependências bem definidas

### Tratamento de Erros Robusto
- Validações em múltiplas camadas
- Mensagens de erro informativas
- Saída controlada em caso de falhas

### Manutenibilidade
- Código bem documentado
- Funções com responsabilidades únicas
- Estrutura clara e lógica

## Exemplo de Uso

### Execução Direta
```bash
# Executar o sistema SAV
./principal.sh

# Ou especificar caminho completo
bash /caminho/para/principal.sh
```

### Como Módulo
```bash
# Incluir como módulo em outro script
source principal.sh
# ou
. principal.sh

# Usar funções carregadas
_inicializar_sistema
```

## Variáveis de Ambiente

### Variáveis Suportadas
- `UPDATE` - Versão do sistema (sobrescrita internamente)

### Constantes Internas
- `SCRIPT_DIR` - Diretório do script (readonly)
- `LIB_DIR` - Diretório de bibliotecas (readonly)
- `LIB_CFG` - Diretório de configuração (readonly)

## Considerações de Performance

### Carregamento Otimizado
- Carregamento único de cada módulo
- Verificações mínimas necessárias
- Tratamento eficiente de erros

### Gerenciamento de Memória
- Uso adequado de variáveis locais
- Limpeza automática de recursos
- Tratamento de sinais para limpeza

## Debugging e Desenvolvimento

### Estratégias para Debug
- Mensagens de erro detalhadas
- Validações em pontos críticos
- Logs estruturados

### Testes
- Verificação de dependências na inicialização
- Validação de estrutura de diretórios
- Teste de carregamento de módulos

---

*Documentação gerada automaticamente com base no código fonte e práticas de bash scripting.*