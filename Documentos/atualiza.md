# Documentação do Módulo atualiza.sh

## Visão Geral
O módulo `atualiza.sh` é o **ponto de entrada principal** do **Sistema SAV (Script de Atualização Modular)**. Este arquivo funciona como um bootstrap/loader responsável por inicializar todo o sistema de forma segura e controlada.

## Função Principal
Este arquivo implementa o padrão de **"Script Bootstrap"** em bash, sendo responsável por:
- Configuração inicial segura do ambiente
- Validação de dependências críticas
- Carregamento do sistema principal

## Características de Segurança

### Opções Bash Seguras
```bash
set -euo pipefail
export LC_ALL=C
```

**Explicação das opções:**
- **`set -e`**: Sai imediatamente se qualquer comando falhar
- **`set -u`**: Trata variáveis não definidas como erro
- **`set -o pipefail`**: Falha se qualquer comando em pipe falhar
- **`export LC_ALL=C`**: Configuração local para consistência

## Estrutura do Código

### Localização e Constantes
```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIBS_DIR="${SCRIPT_DIR}/libs"
readonly LIBS_DIR SCRIPT_DIR
```

**Características:**
- **`SCRIPT_DIR`**: Diretório onde o script está localizado
- **`LIBS_DIR`**: Diretório contendo os módulos (`libs/`)
- **`readonly`**: Proteção contra modificação acidental

## Sistema de Validação

### Validação de Dependências
```bash
# Verifica se o diretório libs existe
if [[ ! -d "${LIBS_DIR}" ]]; then
    echo "ERRO: Diretório ${LIBS_DIR} nao encontrado."
    exit 1
fi

# Verifica se o arquivo principal.sh existe
if [[ ! -f "${LIBS_DIR}/principal.sh" ]]; then
    echo "ERRO: Arquivo ${LIBS_DIR}/principal.sh nao encontrado."
    exit 1
fi
```

**Validações críticas:**
1. **Existência do diretório `libs/`**
2. **Presença do arquivo `principal.sh`**
3. **Permissões adequadas** para execução

## Processo de Inicialização

### Carregamento do Sistema
```bash
# Carrega o script principal
cd "${LIBS_DIR}" || exit 1
./principal.sh
```

**Sequência:**
1. **Navegação** para o diretório `libs/`
2. **Execução** do script `principal.sh`
3. **Transferência de controle** para o sistema principal

## Tratamento de Erros

### Estratégia de Falha
- **Saída imediata** (`exit 1`) em caso de erro
- **Mensagens claras** indicando o problema específico
- **Validação em pontos críticos** antes da execução

### Códigos de Saída
- `0` - Sucesso (herdado do script principal)
- `1` - Erro de validação ou execução

## Características de Segurança

### Proteções Implementadas
- **Variáveis readonly** para constantes críticas
- **Validação rigorosa** de dependências
- **Configuração segura** do ambiente bash
- **Controle de localização** preciso

### Prevenção de Ataques
- **Caminhos absolutos** para evitar path traversal
- **Validação de existência** antes da execução
- **Configuração local consistente** (`LC_ALL=C`)

## Boas Práticas Implementadas

### Organização do Código
- **Simplicidade**: Arquivo conciso e focado
- **Clareza**: Cada seção com responsabilidade única
- **Comentários**: Documentação inline clara

### Manutenibilidade
- **Dependências explícitas**: Validação clara do que é necessário
- **Mensagens de erro informativas**: Facilita diagnóstico
- **Estrutura modular**: Separação entre bootstrap e lógica principal

## Arquivos Relacionados

### Dependências Críticas
- **`libs/principal.sh`**: Sistema principal (obrigatório)
- **`libs/`**: Diretório contendo todos os módulos

### Arquivos Gerados
- **Nenhum arquivo gerado** (apenas executa o sistema)

## Exemplos de Uso

### Execução Normal
```bash
# Executar o sistema SAV
./atualiza.sh

# Ou via caminho absoluto
/sav/tools/atualiza.sh

# Ou via atalho global (se configurado)
atualiza
```

### Execução com Parâmetros
```bash
# Passar parâmetros para o sistema
./atualiza.sh parametro1 parametro2
```

## Variáveis de Ambiente

### Variáveis Internas
- `SCRIPT_DIR` - Diretório do script (readonly)
- `LIBS_DIR` - Diretório de bibliotecas (readonly)
- `LC_ALL` - Configuração local (C)

### Variáveis Herdadas
Todas as variáveis do sistema principal são carregadas através do `principal.sh`

## Considerações de Performance

### Otimizações
- **Inicialização mínima**: Apenas validações essenciais
- **Carregamento direto**: Sem processamento desnecessário
- **Transferência imediata**: Controle passado rapidamente

### Recursos
- **Memória mínima**: Apenas variáveis essenciais
- **I/O mínimo**: Apenas validações de existência
- **CPU mínimo**: Processamento direto sem loops

## Debugging e Desenvolvimento

### Estratégias para Debug
- **Mensagens claras** de erro com contexto
- **Validações em sequência** lógica
- **Saída imediata** em caso de problemas

### Diagnóstico de Problemas
```bash
# Verificar se arquivo existe
ls -la libs/principal.sh

# Verificar permissões
ls -ld libs/

# Executar com debug
bash -x atualiza.sh
```

## Casos de Uso Comuns

### Instalação Nova
```bash
# Primeiro uso após instalação
./atualiza.sh
# Irá carregar o sistema e mostrar menu principal
```

### Manutenção do Sistema
```bash
# Após modificações nos módulos
./atualiza.sh
# Recarrega todos os módulos atualizados
```

### Diagnóstico de Problemas
```bash
# Verificar se sistema está íntegro
./atualiza.sh
# Se falhar, mostrará exatamente o que está errado
```

## Integração com o Sistema

### Fluxo de Inicialização
```
atualiza.sh → principal.sh → módulos → sistema operacional
```

### Responsabilidades
- **`atualiza.sh`**: Bootstrap e validação
- **`principal.sh`**: Carregamento de módulos
- **Módulos**: Funcionalidades específicas
- **Sistema**: Execução das tarefas

---

*Documentação gerada automaticamente com base no código fonte e práticas de bash scripting.*