# Documentacao do Modulo principal.sh

## Visao Geral
O modulo `principal.sh` e o arquivo principal do **Sistema SAV (Script de Atualizacao Modular)**. Funciona como um orquestrador central responsavel pelo carregamento sequencial de modulos, inicializacao do sistema e controle do fluxo principal da aplicacao.

## Funcao Principal
Este arquivo implementa o padrao de design **"Main Guard"** em bash, onde o script pode ser executado diretamente ou incluido como modulo por outros scripts.

## Estrutura do Sistema

### Constantes e Configuracoes
```bash
# Versao do sistema
UPDATE="15/10/2024-00"
readonly UPDATE

# Diretorios do sistema
TOOLS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
lib_dir="${TOOLS_DIR}/libs"
cfg_dir="${TOOLS_DIR}/cfg"
```

### Caracteristicas dos Diretorios
- **`TOOLS_DIR`**: Diretorio onde o script esta localizado
- **`lib_dir`**: Diretorio contendo os modulos do sistema (`libs/`)
- **`cfg_dir`**: Diretorio de configuracoes (`cfg/`)

## Sistema de Carregamento de Modulos

### Funcao `_carregar_modulo()`
Carrega dinamicamente modulos bash com validacoes de seguranca.

**Parametros:**
- `$1` - Nome do modulo a ser carregado

**Validacoes:**
- Existência do arquivo
- Permissoes de leitura
- Tratamento de erros com saida do programa

**Sintaxe utilizada:**
```bash
_carregar_modulo "utils.sh"
```

### Ordem de Carregamento
A ordem de carregamento e critica para o funcionamento do sistema:

1. **`utils.sh`** - Utilitarios basicos (funcoes essenciais)
2. **`config.sh`** - Configuracoes do sistema
3. **`lembrete.sh`** - Sistema de lembretes
4. **`rsync.sh`** - Operacoes de rede e sincronizacao
5. **`sistema.sh`** - Informacoes do sistema operacional
6. **`arquivos.sh`** - Gestao e manipulacao de arquivos
7. **`backup.sh`** - Sistema de backup e restauracao
8. **`programas.sh`** - Gestao de programas e atualizacoes
9. **`biblioteca.sh`** - Gestao de bibliotecas
10. **`menus.sh`** - Sistema de menus e interface

## Funcoes de Inicializacao

### `_inicializar_sistema()`
Inicializa completamente o ambiente do sistema SAV.

**Processo de inicializacao:**
1. **Carregamento de configuracoes** - `_carregar_configuracoes`
2. **Verificacao de dependências** - `_check_instalado`
3. **Validacao de diretorios** - `_validar_diretorios`
4. **Configuracao do ambiente** - `_configurar_ambiente`
5. **Limpeza automatica** - `_executar_expurgador_diario`

### `main()`
Funcao principal que controla o fluxo da aplicacao.

**Caracteristicas:**
- **Tratamento de sinais** - `trap '_resetando' EXIT INT TERM`
- **Inicializacao sequencial** - Chama `_inicializar_sistema`
- **Interface inicial** - `_mostrar_notas_iniciais`
- **Menu principal** - `_principal`

## Padrao Main Guard

### Implementacao
```bash
# Verificar se esta sendo executado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

**Funcionamento:**
- Quando executado diretamente: `bash principal.sh` → chama `main()`
- Quando incluido como modulo: `. principal.sh` → apenas carrega funcoes

## Tratamento de Erros

### Estrategias Implementadas

#### Validacao de Diretorios
```bash
if [[ ! -d "${lib_dir}" ]]; then
    echo "ERRO: Diretorio ${lib_dir} nao encontrado."
    echo "Certifique-se de que todos os modulos estao instalados corretamente."
    exit 1
fi
```

#### Carregamento Seguro de Modulos
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

## Caracteristicas de Seguranca

### Imutabilidade
- Uso de `readonly` para constantes criticas
- Protecao contra modificacao acidental

### Tratamento de Sinais
- Limpeza automatica no termino (`trap '_resetando'`)
- Tratamento de interrupcoes (Ctrl+C)

### Validacoes de Permissoes
- Verificacao de existência de arquivos
- Controle de permissoes de leitura
- Validacao de estrutura de diretorios

## Dependências do Sistema

### Diretorios Obrigatorios
- `libs/` - Contem todos os modulos do sistema
- `cfg/` - Arquivos de configuracao

### Modulos Essenciais
Todos os modulos listados na ordem de carregamento sao considerados criticos para o funcionamento do sistema.

## Logs e Auditoria

### ShellCheck
- Uso de `# shellcheck source=/dev/null` para evitar warnings
- Compatibilidade com analise estatica de codigo

## Boas Praticas Implementadas

### Organizacao Modular
- Separacao clara de responsabilidades
- Carregamento sequencial controlado
- Dependências bem definidas

### Tratamento de Erros Robusto
- Validacoes em múltiplas camadas
- Mensagens de erro informativas
- Saida controlada em caso de falhas

### Manutenibilidade
- Codigo bem documentado
- Funcoes com responsabilidades únicas
- Estrutura clara e logica

## Exemplo de Uso

### Execucao Direta
```bash
# Executar o sistema SAV
./principal.sh

# Ou especificar caminho completo
bash /caminho/para/principal.sh
```

### Como Modulo
```bash
# Incluir como modulo em outro script
source principal.sh
# ou
. principal.sh

# Usar funcoes carregadas
_inicializar_sistema
```

## Variaveis de Ambiente

### Variaveis Suportadas
- `UPDATE` - Versao do sistema (sobrescrita internamente)

### Constantes Internas
- `TOOLS_DIR` - Diretorio do script (readonly)
- `lib_dir` - Diretorio de bibliotecas (readonly)
- `cfg_dir` - Diretorio de configuracao (readonly)

## Consideracoes de Performance

### Carregamento Otimizado
- Carregamento único de cada modulo
- Verificacoes minimas necessarias
- Tratamento eficiente de erros

### Gerenciamento de Memoria
- Uso adequado de variaveis locais
- Limpeza automatica de recursos
- Tratamento de sinais para limpeza

## Debugging e Desenvolvimento

### Estrategias para Debug
- Mensagens de erro detalhadas
- Validacoes em pontos criticos
- Logs estruturados

### Testes
- Verificacao de dependências na inicializacao
- Validacao de estrutura de diretorios
- Teste de carregamento de modulos

---

*Documentacao gerada automaticamente com base no codigo fonte e praticas de bash scripting.*