# Atualiza

## Shell Script para atualizar o sistema da SAV

- Atualiza programas avulsos
- Atualiza Biblioteca
- Volta de programa ou biblioteca
- Limpa arquivos Temporarios
- Recupera arquivos avulso ou os principais

Rotina para atualizar programas e bibliotecas da SAV.

Feito por Luiz Augusto.

email [luizaugusto@sav.com.br](mailto:luizaugusto@sav.com.br)

Menus

### 1 - Atualizacao de Programas Avulsos

### 2 - Atualizacao de Biblioteca

### 3 - Versao do Iscobol

### 4 - Versao do Linux

### 5 - Ferramentas

     1 - Atualizacao de Programas
           1.1 - Programa ou Pacote ON-Line
     Acessa o servidor da SAV via scp com o usuario ATUALIZA
     Faz um backup do programa que esta em uso e salva na pasta ?/sav/tmp/olds
     com o nome "Nome do programa-anterior.zip" descompacta o novo no diretorio
     dos programa e salva o a atualizacao na pasta ?/sav/tmp/progs.

           1.2 - Programa ou Pacote OFF-Line
     Atualiza o arquivo de programa ".zip" que deve ter sido colocado em ?/sav/tmp.
     O processo de atualizacao e idêntico ao passo acima.

           1.3 - Voltar programa Atualizado
     Descompacta o arquivo salvo anteriormente em ?/sav/tmp/olds com o nome de ("programa"-anterior.zip)
     na pasta dos programas.

     2 - Atualizacao de Biblioteca

           2.1 - Atualizacao do Transpc
     Atualiza a biblioteca que esta no diretorio /u/varejo/trans_pc/ do servidor da SAV.
     Faz um backup de todos os programas que esta em uso e salva na pasta ?/sav/tmp/olds
     com o nome "backup-(versao Informada).zip" descompacta os novos no diretorio
     dos programas e salva os zips da biblioteca na pasta ?/sav/tmp/biblioteca mudando a
     extensao de .zip para .bkp.

           2.2 - Atualizacao do Savatu
     Atualiza a biblioteca que esta no diretorio /home/savatu/biblioteca/temp/(diretorio
     conforme  sistema que esta sendo usado.
     Mesmo procedimento acima.

           2.3 - Atualizacao  OFF-Line
     Atualiza a biblioteca que deve estar salva no diretorio ?/sav/tmp
     Mesmo procedimento acima.

           2.4 - Voltar antes da Biblioteca
     Descompacta o arquivo salvo anteriormente em ?/sav/tmp/olds com nome ("backup-Versao da biblioteca".zip
     na pasta dos programas.

     3 - Versao do Iscobol
           Verifica qual a Versao do iscobol que esta sendo usada.

     4 - Versao do Linux
           Verifica qual o Linux em uso.

     5 - Ferramentas
          5.1 - Limpar Temporarios
              5.1.1 - Le os arquivos da lista "atualizat" compactando na pasta ?/sav/tmp/backup
                      com o nome de Temp(dia+mes+ano) e excluindo da pasta de dados.

              5.1.2 - Adiciona arquivos no "ATUALIZAT"

          5.2 - Recuperar arquivos
              5.2.1 - Um arquivo ou Todos
                  Opcao pede para informa um arquivo especifico, somente o nome sem a extensao
                  ou se deixar em branco o nome do arquivo vai recuperar todos os arquivos com as extensoes,
                  "*.ARQ.dat" "*.DAT.dat" "*.LOG.dat" "*.PAN.dat"

              5.2.2 - Arquivos Principais
                  Roda o Jtuil somente nos arquivos que estao na lista "atualizaj".

          5.3 - Backup da base de dados
              5.3.1 - Faz um backup da pasta de dados  com a opcao de enviar para o servidor da SAV.

              5.3.2 - Restaura Backup da base de dados.

              5.3.3 - Enviar Backup selecionado.

          5.4 - Envia e Recebe Arquivos "Avulsos".
              5.4.1 - Enviar arquivo(s).

              5.4.2 - Receber arquivo(s).

          5.5 - Expurgador de arquivos
              Excluir, zips e bkps com mais de 30 dias processado dos diretorios:
               /backup, /olds /progs e /logs.

          5.6 - Parametros
                Variaveis e caminhos necessarios para o funcionamento do atualiza.sh

          5.7 - Update
              Atualizacao do programa atualiza.sh.

          5.8 - Lembretes

            5.8.1 - Escrever uma nova nota

            5.8.2 - Visualiza nota

            5.8.3 - Editar nota

            5.8.4 - Apagar nota

Arquivos de trabalho:

".atualizac" = Configuracao do parametro do sistema.

"atualizaj" = Lista de arquivos principais para dar rebuild.

"atualizat = Lista de arquivos temporarios a ser excluidos da pasta de dados.
Sao zipados em /backup/Temps-dia-mes-ano-horario.zip.

"setup.sh" = Configurador para criar os arquivos .atualizac e .atualizac.
