# CSMA-CD_Project
# README - Simulação de Rede CSMA/CD 1-persistente

Este projeto consiste em uma simulação de uma rede de computadores utilizando o protocolo CSMA/CD 1-persistente. O código foi implementado em MATLAB e permite visualizar o funcionamento dessa técnica de acesso ao meio.

## Requisitos

- MATLAB (versão compatível com o código)

## Como utilizar

1. Abra o MATLAB e certifique-se de que o diretório de trabalho esteja definido para a pasta onde o código-fonte está localizado.

2. Execute o arquivo `csma_cd_simulacao.m`.

3. A simulação será iniciada e você poderá acompanhar o progresso no console do MATLAB.

4. Ao final da simulação, será exibido o número total de eventos executados e o tempo total da simulação.

## Configuração da Rede

A rede é configurada pelos parâmetros `tempo_simulacao` e `n`. O parâmetro `tempo_simulacao` define a duração da simulação em segundos, e o parâmetro `n` define o número de nós na rede.

## Parâmetros do CSMA/CD 1-persistente

O protocolo CSMA/CD 1-persistente utiliza os seguintes parâmetros de configuração:

- `dist`: distância entre os nós da rede (em metros).
- `taxa_dados`: taxa de transmissão de dados (em bps).

Com base na distância e na taxa de dados, o tempo de propagação (`tempo_prop`) é calculado dividindo a distância pela taxa de dados. Esse valor representa o tempo necessário para que um sinal percorra a distância entre dois nós.

## Funcionamento da Simulação

A simulação é baseada em eventos discretos. Cada evento representa uma ação que ocorre em um determinado instante de tempo na rede. Os eventos são executados de acordo com a ordem de seus instantes de tempo.

A função `exec_simulador` realiza a simulação, processando os eventos e executando as ações correspondentes a cada evento. A função `executa_evento` é responsável por tratar os diferentes tipos de eventos e realizar as ações apropriadas.

Os eventos disponíveis na simulação são:

- `N_cfg`: configuração dos nós, inicialização de variáveis de estado, etc.
- `T_ini`: início de transmissão.
- `T_fim`: fim de transmissão.
- `R_ini`: início de recepção.
- `R_fim`: fim de recepção.
- `S_fim`: finalização da simulação.

## Registro de Eventos

Durante a simulação, todos os eventos são registrados em uma lista de log. O log de eventos (`Log_eventos`) armazena informações sobre cada evento executado, incluindo o tipo de evento, o instante de tempo e o ID do nó envolvido.

## Resultados da Simulação

Ao final da simulação, o número total de eventos executados e o tempo total da simulação são exibidos no console do MATLAB.

## Personalização da Simulação

Você pode personalizar a simulação ajustando os parâmetros da rede, como tempo de simulação, número de nós, distância e taxa de dados. Além disso, você pode adicionar ou modificar os tipos de eventos e suas ações correspondentes na função `executa_evento`.

## Limitações

Este código é uma implementação simplificada do protocolo CSMA/CD 1-persistente e da simulação da rede. Algumas características e detalhes do protocolo podem não estar incluídos. Além disso, a simulação não leva em conta possíveis erros de transmissão ou colisões persistentes.

## Conclusão

Este projeto oferece uma simulação básica do protocolo CSMA/CD 1-persistente em uma rede de computadores. Ao executar o código fornecido, você poderá observar o comportamento dos nós da rede em relação à transmissão e recepção de dados. Isso pode ser útil para entender os desafios e a dinâmica de uma rede utilizando esse protocolo de acesso ao meio.

Se você tiver alguma dúvida ou precisar de mais informações, sinta-se à vontade para entrar em contato. Aproveite a simulação!

