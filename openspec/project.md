# Project Context

## Purpose
Sistema de atualização modular para sistemas SAV (Sistema de Automação Comercial). Gerencia atualizações de programas avulsos, bibliotecas, realiza backups, limpeza de arquivos temporários e manutenção de sistemas IsCOBOL/COBOL em ambiente Linux. Desenvolvido especificamente para estabelecimentos comerciais brasileiros que utilizam soluções SAV.

**Objetivos principais:**
- Automatizar processo de atualização de programas e bibliotecas
- Gerenciar backups de segurança antes de atualizações
- Realizar manutenção preventiva (limpeza de temporários, validações)
- Suporte a modos online (via servidor SAV) e offline
- Interface interativa com menus coloridos e validações robustas

## Tech Stack
- **Linguagem Principal:** Bash Shell Script
- **Linguagens de Aplicação:** IsCOBOL (Veryant) E Micro Focus COBOL
- **Sistema Operacional:** Linux (CentOS/RHEL baseado)
- **Ferramentas de Sistema:** zip, unzip, rsync, wget, scp
- **Terminal:** Suporte a cores ANSI e formatação avançada
- **Arquitetura:** Modular com módulos independentes carregáveis
- **Tipos de Sistema:** Suporte a ambos iscobol (IsCOBOL) e cobol (Micro Focus/ISAM)

## Project Conventions

### Code Style
- **Formatação:** Shell script com funções prefixadas por underscore (_)
- **Nomenclatura:** snake_case para variáveis e funções
- **Estrutura:** Módulos organizados por funcionalidade (config.sh, utils.sh, backup.sh, etc.)
- **Comentários:** Cabeçalhos descritivos em cada módulo e função
- **Indentação:** 4 espaços, sem tabs
- **Controle de Erros:** Validações rigorosas com códigos de saída apropriados

### Architecture Patterns
- **Arquitetura Modular:** Sistema dividido em módulos independentes carregados dinamicamente
- **Inicialização Sequencial:** Ordem específica de carregamento (utils → config → módulos específicos)
- **Tratamento de Sinais:** Captura de sinais para limpeza adequada (EXIT, INT, TERM)
- **Configuração Externa:** Variáveis de ambiente e arquivos de configuração separados
- **Logs Estruturados:** Sistema de logging com timestamps e níveis (erro, sucesso, info)

### Testing Strategy
- **Validações de Pré-requisitos:** Verificação de dependências no sistema (_check_instalado)
- **Testes de Conectividade:** Ping para servidor quando em modo online
- **Validação de Diretórios:** Verificação de permissões e existência de caminhos críticos
- **Testes de Configuração:** Validação completa antes da execução (_validar_configuracao)
- **Tratamento de Erros:** Retry limitado (máx 3 tentativas) com mensagens claras

### Git Workflow
- **Commits:** Mensagens descritivas incluindo versão e módulo alterado
- **Versões:** Formato "DD/MM/AAAA-VV" (ex: 10/10/2025-00)
- **Branches:** Desenvolvimento linear, sem estratégia complexa de branching
- **Controle de Versão:** Integração com sistema de atualização automática

## Domain Context
**SAV (Sistema de Automação Comercial):** Solução brasileira para automação de estabelecimentos comerciais, incluindo controle de estoque, vendas, financeiro e integração com sistemas legacy COBOL. O atualiza.sh é uma ferramenta crítica para manutenção e distribuição de atualizações nestes ambientes empresariais.

**Características específicas do domínio:**
- Ambiente altamente regulado (dados fiscais, comerciais)
- Necessidade de backups antes de qualquer alteração
- Sistemas críticos 24/7 com janela de manutenção limitada
- Suporte a múltiplas plataformas COBOL: IsCOBOL (Veryant) e Micro Focus COBOL
- Comunicação com servidor central SAV para distribuição de atualizações
- Diferenças técnicas: IsCOBOL usa .class/XML vs Micro Focus usa ISAM/-6

## Important Constraints
- **Disponibilidade:** Sistema crítico que não pode ficar indisponível por longos períodos
- **Dados Sensíveis:** Manipula dados comerciais e fiscais com requisitos de backup obrigatório
- **Compatibilidade:** Deve funcionar com diferentes versões de IsCOBOL/Micro Focus COBOL e configurações de sistema
- **Multi-plataforma:** Suporte a diferentes sistemas COBOL com características distintas (class/XML vs ISAM/-6)
- **Segurança:** Acesso via SCP com credenciais específicas e validações de integridade
- **Performance:** Operações de backup e transferência devem ser otimizadas para grandes volumes
- **Conectividade:** Dependente de conexão com servidor SAV (modo online) ou arquivos locais (modo offline)

## External Dependencies
- **Servidor SAV:** Sistema central para distribuição de atualizações via SCP
- **Runtime COBOL:** IsCOBOL Runtime (Veryant) E Micro Focus COBOL com suporte ISAM
- **Ferramentas de Sistema:** zip, unzip, rsync, wget obrigatórios
- **Bibliotecas SAV:** Múltiplos tipos (SAVATU, TRANSPC, etc.) com caminhos específicos por sistema
- **Infraestrutura:** Servidores com sistema operacional compatível e configurações padronizadas
- **Compiladores:** IsCOBOL compiler ou Micro Focus COBOL compiler dependendo do sistema

## Technical Differences by COBOL System

### IsCOBOL (sistema=iscobol)
- **Arquivos:** Extensão .class para programas compilados
- **Estrutura:** Usa diretório XML separado para recursos
- **Compilador:** IsCOBOL compiler da Veryant
- **Características:** 3 etapas de atualização (programas + XML)
- **Ferramentas:** Utiliza jutil e iscclient

### Micro Focus COBOL (sistema=cobol)
- **Arquivos:** Extensão -6 para programas compilados
- **Estrutura:** Sistema ISAM sem XML separado
- **Compilador:** Micro Focus COBOL compiler
- **Características:** 2 etapas de atualização (apenas programas)
- **Recursos:** Alguns recursos específicos não disponíveis (como recuperação avançada)
