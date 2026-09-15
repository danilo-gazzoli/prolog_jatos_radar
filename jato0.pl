% Jato 0
:- module(jato0, [obter_controles/4]).

%% Explicacao:
% Informacao:
%   X: posição horizontal do jato
%   Y: posiçao vertical do jato
%   ANGLE: angulo de inclinacao do jato: 0 para virado para frente até PI*2 (~6.28)
%   SCORE: inteiro com a "vida" do jato. Em zero, ele perdeu
%   SPEED: velocidade do jato
% Adversarios:
%   vetor com a posicao de todos os adversarios, [ [X1,Y1], [X2,Y2], ... ]
% Misseis:
%   vetor com a posicao de todos os misseis, [ [X1,Y1], [X2,Y2], ... ]
% Controles:
%   FORWARD: 1 para acelerar e 0 para continuar a velocidade atual
%   REVERSE: 1 para desacelerar e 0 para continuar a velocidade atual
%   LEFT: 1 para ir pra esquerda e 0 para não ir
%   RIGHT: 1 para ir pra direita e 0 para não ir
%   BOOM: 1 para tentar disparar (BOOM). Obs.: ele só pode disparar uma bala a cada segundo
%   MSG: mensagem para DEBUG

%%% Faça seu codigo a partir daqui, sendo necessario sempre ter o predicado:
%%%% obter_controles([X,Y,ANGLE,SCORE,SPEED], ADVERSARIOS, MISSEIS, [FORWARD, REVERSE, LEFT, RIGHT, BOOM, MSG]) :- ...

% troca(0, 1).
% troca(1, 0).

% [FORWARD, REVERSE, LEFT, RIGHT, BOOM, MSG]
% obter_controles(INFORMACAO, ADVERSARIOS, MISSEIS, CONTROLES) :-
%     INFORMACAO = [X, Y, ANGLE, SCORE, SPEED],
%     CONTROLES = [FORWARD, REVERSE, LEFT, RIGHT, BOOM, MSG],
%     random_between(0,1,AA),
%     troca(AA, BB),
%     random_between(0,1,CC),
%     FORWARD is AA,
%     REVERSE is 0,
%     LEFT is AA,
%     RIGHT is BB,
%     BOOM is CC,
%     MSG = "Regra padrao aplicada".
    %opcao:
    %term_string([ADVERSARIOS| [MISSEIS]], MSG).

% Para evitar erros, o jato para:
obter_controles(_, _, _, [0,0,0,0,0,"nenhuma regra aplicada"]).

% Dica:
% Você pode transformar um vetor com qualquer coisa para string assim:
% term_string(VETOR, MSG).
% Assim, MSG passa a ser uma string do seu vetor
% Ex.:
% ?- term_string([1,2,"teste",oi], MSG.
% MSG = "[1,2,\"teste\",oi]".

obter_controles(IFORMACAO, ADVERSARIOS, MISSEIS, CONTROLES) :-
    INFORMACAO = [X, Y, ANGLE, SCORE, SPEED],
    CONTROLES = [FORWARD, REVERSE, LEFT, RIGHT, BOOM, MSG].


% Regra: Define se o jato está em perigo.
perigo(INFORMACAO, ADVERSARIOS, MISSEIS) :-
    INFORMACAO = [X, Y, _ANGLE, _SCORE, _SPEED],
    missil_perto([X, Y], MISSEIS). 

perigo(INFORMACAO, ADVERSARIOS, MISSEIS) :-
    INFORMACAO = [X, Y, _ANGLE, _SCORE, _SPEED],
    adversario_perto([X, Y], ADVERSARIOS).

% Regra: Encontra o primeiro míssel dentro de um raio de distância.
missil_perto(COORDENADAS, MISSEIS, [MX, MY]) :-
    COORDENADAS = [X, Y],
    member([MX, MY], MISSEIS),
    distancia([X, Y], [MX, MY], D),
    D =< 50.

% Regra: Encontra o primeiro adversário dentro de um raio de distância.
adversario_perto(COORDENADAS, ADVERSARIOS, [AX, AY]) :-
    COORDENADAS = [X, Y],
    member([AX, AY], ADVERSARIOS),
    distancia([X, Y], [AX, AY], D),
    D =< 50.

% Regra: Calcula a distância entre dois pontos.
distancia([X1, Y1], [X2, Y2], D) :-
    DX is X2 - X1,
    DY is Y2 - Y1,
    D is sqrt(DX * DX + DY * DY).

