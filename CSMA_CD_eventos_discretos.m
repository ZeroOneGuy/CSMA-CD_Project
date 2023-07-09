clc;
clear all;
close all;

% Inicia o gerador de números aleatórios
rand("state", 0);

% Parâmetros de simulação
tempo_simulacao = 100; % tempo de simulação
n = 20; % número de nós da rede

% Configuração do CSMA/CD 1-persistente
dist = 100; % 100m
taxa_dados = 1e5; % 100kbps

tempo_prop = dist / taxa_dados; % Tempo de propagação = distância / velocidade do sinal
%tempo_prop = tempo_prop / 2; % Divide by 2 to account for round trip propagation time

% Lista de eventos executados
global Log_eventos;
Log_eventos = [];
global eventos_executados;
eventos_executados = 0;

global msg;
msg = {"hello"};
global rede; % matriz de conectividade da rede
rede = ~eye(n);
global nos;
nos = [];

% Configura a simulação
tempo_inicial = clock();
%tempo_inicial = datetime("now");
Lista_eventos = config_sim(n, tempo_simulacao);

% Executa a simulação
%Log_eventos = exec_simulador(Lista_eventos, Log_eventos, tempo_simulacao);
%Log_eventos = exec_simulador(Lista_eventos, Log_eventos, tempo_simulacao,tempo_prop);
Log_eventos = exec_simulador(Lista_eventos, Log_eventos, tempo_simulacao,tempo_prop,taxa_dados);


disp(['---Total de eventos=' num2str(eventos_executados)]);
fprintf('---Tempo da simulação=%g segundos\n', etime(clock, tempo_inicial));

function [t, tipo, id, pct] = evento_desmonta(e)
  t = e.instante;
  tipo = e.tipo;
  id = e.id;
  pct = e.pct;
end

function e = evento_monta(t, tipo, id, pct)
  if nargin < 4, pct = []; end
  e = struct('instante', t, 'tipo', tipo, 'id', id);
  e.pct = pct;
end

function Lista_eventos = config_sim(n, tempo_simulacao)
  Lista_eventos = [];
  for k = 1:n
    e = evento_monta(0, 'N_cfg', k);
    Lista_eventos = [Lista_eventos; e];
  end

  ev_fim = evento_monta(tempo_simulacao, 'S_fim', 0);
  Lista_eventos = [Lista_eventos; ev_fim];
end

function Log_eventos = exec_simulador(Lista_eventos, Log_eventos, tempo_final,tempo_prop,taxa_dados)
  global eventos_executados;

  % Simulação discreta por eventos
  while 1
    [min_instante, min_indice] = min([Lista_eventos(:).instante]);
    if isempty(min_instante)
        break;
    end
    if min_instante > tempo_final
        break;
    end
    ev = Lista_eventos(min_indice);
    Lista_eventos(min_indice) = []; % Remove o evento da lista, pois será executado.
    tempo_atual = min_instante;
    Log_eventos = [Log_eventos; ev];

    Novos_eventos = executa_evento(ev, tempo_atual,tempo_prop,taxa_dados);    % Retorna os novos eventos após executar o último evento
    eventos_executados = eventos_executados + 1;

    if ~isempty(Novos_eventos) % Adiciona novos eventos na lista
      Lista_eventos = [Lista_eventos; Novos_eventos];
    end
  end
end

function [NovosEventos] = executa_evento(evento, tempo_atual,tempo_prop,taxa_dados)
    global msg, global rede, global nos;
    
    NovosEventos = [];

    [t, tipo_evento, id, pct] = evento_desmonta(evento); % Retorna os campos do evento
    disp(['EV: ' tipo_evento ' @t=' num2str(t) ' id=' num2str(id)]);

    switch tipo_evento
        case 'N_cfg' % Configuração dos nós, inicia variáveis de estado, etc.
            nos(id).Tx = 'desocupado';
            nos(id).Rx = 'desocupado';
            nos(id).ocupado_ate = 0;
            nos(id).stat = struct("tx", 0, "rx", 0, "rxok", 0, "col", 0);

            % Adiciona uma transmissão na fila
            pct = struct('src', id, 'dst', 0, 'tam', 20, 'dados', msg);

            e = evento_monta(tempo_atual + rand(1), 'T_ini', id, pct);
            NovosEventos = [NovosEventos; e];
      case 'T_ini' % Início de transmissão
           if strcmp(nos(id).Tx, 'ocupado') % Transmissor ocupado?
             tempo_entre_quadros = 0.2 * 8 * pct.tam / taxa_dados; % 20% do tempo de transmissão
             e = evento_monta(nos(id).ocupado_ate + tempo_entre_quadros, 'T_ini', id, pct);
             NovosEventos = [NovosEventos; e];
           else
             if pct.dst == 0 % Pacote de broadcast
                for nid = find(rede(id,:)>0) % Envia uma cópia do pacote para cada vizinho
                  disp(['INI T de ' num2str(id) ' para ' num2str(nid)]);
                  e = evento_monta((tempo_atual + tempo_prop), 'R_ini', nid, pct);
                  NovosEventos = [NovosEventos; e];
                end
             else % Envia um pacote para o vizinho, se conectado
                if find(rede(id,:) == pct.dst)
                  disp(['INI T de ' num2str(id) ' para ' num2str(pct.dst)]);
                  e = evento_monta((tempo_atual + tempo_prop), 'R_ini', pct.dst, pct);
                  NovosEventos = [NovosEventos; e];
                end
             end
             tempo_transmissao = 8 * pct.tam / taxa_dados + tempo_prop * 2;
             e = evento_monta((tempo_atual + tempo_transmissao), 'T_fim', id, pct);
             NovosEventos = [NovosEventos; e];
             nos(id).Tx = 'ocupado';
             nos(id).ocupado_ate = tempo_atual + tempo_transmissao;
        end
      case 'T_fim' % Fim de transmissão
             nos(id).stat.tx = nos(id).stat.tx + 1;
             nos(id).Tx = 'desocupado';
             nos(id).ocupado_ate = 0;
      case 'R_ini' % Início de recepção
             if strcmp(nos(id).Rx, 'ocupado') || strcmp(nos(id).Rx, 'colisao')
               nos(id).Rx  = 'colisao';
               nos(id).stat.rx = nos(id).stat.rx + 1;
             else
               nos(id).Rx  = 'ocupado';
               nos(id).stat.rx = 1;
             end
             e = evento_monta((tempo_atual + 8 * pct.tam / taxa_dados), 'R_fim', id, pct);
             NovosEventos = [NovosEventos; e];
    case 'R_fim' % Fim de recepção
            nos(id).stat.rx = nos(id).stat.rx - 1;
            if strcmp(nos(id).Rx, 'ocupado')
                disp(['FIM R de ' num2str(pct.src) ' para ' num2str(pct.dst)]);
                nos(id).Rx  = 'desocupado';
                nos(id).stat.rxok = nos(id).stat.rxok + 1;
                nos(id).stat.rx = 0;
            elseif strcmp(nos(id).Rx, 'colisao')
                if(nos(id).stat.rx == 0)
                  nos(id).Rx  = 'desocupado';
                  nos(id).stat.col = nos(id).stat.col + 1;
                end
            else
              disp("ERRO: Estado Rx errado.");
            end
       case 'S_fim' % Fim de simulação
             disp('Simulação encerrada!');
        otherwise
            disp(['exec_evento: Evento desconhecido: ' tipo_evento]);
    end
end