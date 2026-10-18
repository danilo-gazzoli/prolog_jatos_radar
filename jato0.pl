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

% Dica:
% Você pode transformar um vetor com qualquer coisa para string assim:
% term_string(VETOR, MSG).
% Assim, MSG passa a ser uma string do seu vetor
% Ex.:
% ?- term_string([1,2,"teste",oi], MSG.
% MSG = "[1,2,\"teste\",oi]".

% Procura o elemento no início da lista; depois tenta o restante.
membro(ELEMENTO, [ELEMENTO | _ ]).

membro(ELEMENTO, [_ | RESTO]) :-
    membro(ELEMENTO, RESTO).

% Junta a decisão de movimento, a decisão de tiro e a mensagem para o jogo.
obter_controles(INFORMACAO, ADVERSARIOS, MISSEIS, CONTROLES) :-
    CONTROLES = [FORWARD, REVERSE, LEFT, RIGHT, BOOM, MSG],
    movimentacao(INFORMACAO, ADVERSARIOS, MISSEIS, [FORWARD, REVERSE, LEFT, RIGHT], MOTIVO),
    disparo(INFORMACAO, ADVERSARIOS, BOOM),
    menssagem(MOTIVO, MSG).

% Se nenhuma resposta anterior servir, mantém a velocidade, sem girar nem atirar.
obter_controles(_, _, _, [0, 0, 0, 0, 0, "Nenhuma regra aplicada"]).

% O jato está em perigo quando existe um míssil a até 50 unidades.
perigo(INFORMACAO, MISSEIS, AMEACAS) :-
    INFORMACAO = [X, Y, _ANGLE, _SCORE, _SPEED],
    misseis_proximos([X, Y], MISSEIS, AMEACAS),
    AMEACAS = [_ | _].

% Caso Base: sem misseis para verificar, não há ameaça.
misseis_proximos(_COORDENADAS, [], []).

% Inclui o missil próximo e continua procurando os demais.
misseis_proximos(COORDENADAS, [MISSIL | RESTO], [MISSIL | AMEACAS]) :-
    distancia(COORDENADAS, MISSIL, D),
    D =< 50,
    misseis_proximos(COORDENADAS, RESTO, AMEACAS).

% Descarta missil distante e continua procurando os demais.
misseis_proximos(COORDENADAS, [MISSIL | RESTO], AMEACAS) :-
    distancia(COORDENADAS, MISSIL, D),
    D > 50,
    misseis_proximos(COORDENADAS, RESTO, AMEACAS).

% Procura na lista um adversário a até 200 unidades para perseguir.
adversario_perto(COORDENADAS, [PRIMEIRO | RESTO], ADVERSARIO) :-
    distancia(COORDENADAS, PRIMEIRO, D),
    adversario_mais_proximo(COORDENADAS, RESTO, PRIMEIRO, D, ADVERSARIO),
    distancia(COORDENADAS, ADVERSARIO, MENOR_D),
    MENOR_D =< 200.

% Caso Base: terminou a lista; devolve o adversário mais próximo encontrado.
adversario_mais_proximo(_COORDENADAS, [], MELHOR, _MENOR_D, MELHOR).

% Encontrou alguem mais proximo: atualiza o melhor candidato.
adversario_mais_proximo(COORDENADAS, [ATUAL | RESTO], MELHOR, MENOR_D, ADVERSARIO) :-
    distancia(COORDENADAS, ATUAL, D),
    D < MENOR_D,
    adversario_mais_proximo(COORDENADAS, RESTO, ATUAL, D, ADVERSARIO).

% Não encontrou alguém mais próximo: mantém o candidato anterior.
adversario_mais_proximo(COORDENADAS, [ATUAL | RESTO], MELHOR, MENOR_D, ADVERSARIO) :-
    distancia(COORDENADAS, ATUAL, D),
    D >= MENOR_D,
    adversario_mais_proximo(COORDENADAS, RESTO, MELHOR, MENOR_D, ADVERSARIO).

% Calcula a distância em linha reta entre dois pontos, sem atravessar as bordas.
distancia([X1, Y1], [X2, Y2], D) :-
    LARGURA = 1024,
    ALTURA = 768,
    DX is abs(X2 - X1),
    DY is abs(Y2 - Y1),
    DX_BORDA is LARGURA - DX,
    DY_BORDA is ALTURA - DY,
    MENOR_DX is min(DX, DX_BORDA),
    MENOR_DY is min(DY, DY_BORDA),
    D is MENOR_DX + MENOR_DY.

% Escolhe entre seis manobras.
esquiva(INFORMACAO, AMEACAS, CONTROLES) :-
    AMEACAS = [_ | _], % Lista não vazia: há ameaça.
    OPCOES = [
        [0,0,0,0], [0,0,1,0], [0,0,0,1],
        [1,0,0,0], [1,0,1,0], [1,0,0,1],
        [0,1,0,0], [0,1,1,0], [0,1,0,1]
    ],
    escolher_esquiva(INFORMACAO, AMEACAS, OPCOES, [CONTROLES, _SEGURANCA, _FINAL]).

% Avalia cada opção e compara com a melhor das restantes.
escolher_esquiva(INFORMACAO, AMEACAS, [CONTROLES], [CONTROLES, SEGURANCA, FINAL]) :-
    avaliar_trajetoria(12, INFORMACAO, CONTROLES, AMEACAS, SEGURANCA, FINAL).
escolher_esquiva(INFORMACAO, AMEACAS, [CONTROLES | RESTO], MELHOR) :-
    RESTO = [_ | _], % Lista não vazia: há mais opções para avaliar.
    avaliar_trajetoria(12, INFORMACAO, CONTROLES, AMEACAS, SEGURANCA, FINAL),
    escolher_esquiva(INFORMACAO, AMEACAS, RESTO, OUTRA),
    comparar_avaliacoes([CONTROLES, SEGURANCA, FINAL], OUTRA, MELHOR).

% Prioriza segurança; depois, distância final. No empate, mantém a primeira.
comparar_avaliacoes([C1,S1,F1], [_,S2,_], [C1,S1,F1]) :- S1 > S2. % Se a primeira opção for mais segura, mantém ela.
comparar_avaliacoes([_,S1,_], [C2,S2,F2], [C2,S2,F2]) :- S1 < S2. % Se a segunda opção for mais segura, mantém ela.
comparar_avaliacoes([C1,S1,F1], [_,S2,F2], [C1,S1,F1]) :- S1 =:= S2, F1 >= F2. % Se a primeira opção for mais distante, mantém ela.
comparar_avaliacoes([_,S1,F1], [C2,S2,F2], [C2,S2,F2]) :- S1 =:= S2, F1 < F2. % Se a segunda opção for mais distante, mantém ela.

% Guarda a menor distância encontrada durante a trajetória.
avaliar_trajetoria(0, [X, Y, _, _, _], _, AMEACAS, FINAL, FINAL) :- % Base: não há mais passos a avaliar; devolve a menor distância encontrada.
    menor_distancia([X, Y], AMEACAS, FINAL).
avaliar_trajetoria(PASSOS, INFORMACAO, CONTROLES, AMEACAS, SEGURANCA, FINAL) :- % Avalia a trajetória do jato, passo a passo, atualizando a menor distância encontrada.
    PASSOS > 0, INFORMACAO = [X,Y,_,_,_],
    menor_distancia([X, Y], AMEACAS, ATUAL),
    proximo_estado(INFORMACAO, CONTROLES, PROXIMO), RESTANTES is PASSOS - 1,
    avaliar_trajetoria(RESTANTES, PROXIMO, CONTROLES, AMEACAS, OUTRA, FINAL),
    SEGURANCA is min(ATUAL, OUTRA).

% Encontra a distância até a ameaça mais próxima de uma posição.
menor_distancia(COORDENADAS, [MISSIL], D) :- distancia(COORDENADAS, MISSIL, D).
menor_distancia(COORDENADAS, [MISSIL | RESTO], D) :-
    RESTO = [_ | _], distancia(COORDENADAS, MISSIL, ATUAL),
    menor_distancia(COORDENADAS, RESTO, OUTRA), D is min(ATUAL, OUTRA).

% Simula um quadro e ajusta a posição nas bordas.
proximo_estado([X,Y,ANGLE,SCORE,SPEED], [FORWARD,REVERSE,LEFT,RIGHT], [X_FINAL,Y_FINAL,ANGLE_FINAL,SCORE,SPEED_FINAL]) :-
    SPEED_FINAL is max(min(SPEED + FORWARD * 0.05, 2) - REVERSE * 0.05, 0.3),
    ANGULO is ANGLE + (LEFT - RIGHT) * 0.03,
    ANGLE_FINAL is ANGULO - floor(ANGULO / (2*pi)) * (2*pi),
    NOVO_X is X - sin(ANGLE_FINAL) * SPEED_FINAL,
    NOVO_Y is Y - cos(ANGLE_FINAL) * SPEED_FINAL,
    X_FINAL is NOVO_X - floor(NOVO_X / 1024) * 1024,
    Y_FINAL is NOVO_Y - floor(NOVO_Y / 768) * 768.

% Primeiro tenta fugir de um míssil próximo.
movimentacao(INFORMACAO, _ADVERSARIOS, MISSEIS, CONTROLES, fuga) :-
    perigo(INFORMACAO, MISSEIS, AMEACAS),
    esquiva(INFORMACAO, AMEACAS, CONTROLES).

% Se a fuga falhar, tenta encontrar e perseguir um adversário próximo.
movimentacao(INFORMACAO, ADVERSARIOS, _MISSEIS, CONTROLES, perseguicao) :-
    INFORMACAO = [X, Y, _ANGLE, _SCORE, _SPEED],
    adversario_perto([X, Y], ADVERSARIOS, ADVERSARIO),
    movimentacao_perseguicao(INFORMACAO, ADVERSARIO, CONTROLES).

% Se as opções anteriores falharem, acelera em linha reta para patrulhar.
movimentacao(_INFORMACAO, _ADVERSARIOS, _MISSEIS, [1, 0, 0, 0], patrulha).

% Descobre para qual lado virar; se já estiver alinhado, segue reto.
% A tolerância permite pequeno desvio: 10 unidades para uma distância de 100.
movimentacao_perseguicao(INFORMACAO, ADVERSARIO, CONTROLES) :-
    OPCOES = [
    [0,0,0,0], [0,0,1,0], [0,0,0,1], % Não acelera nem freia: mantém a velocidade atual, seguindo reto ou girando
    [1,0,0,0], [1,0,1,0], [1,0,0,1], % Acelera: aumenta a velocidade, seguindo reto ou girando
    [0,1,0,0], [0,1,1,0], [0,1,0,1] % Freia: diminui a velocidade, seguindo reto ou girando
    ],
    escolher_perseguicao(INFORMACAO, ADVERSARIO, OPCOES, [CONTROLES, _, _]).

% Avalia cada opção e compara com a melhor das restantes.
escolher_perseguicao(INFORMACAO, ADVERSARIO, [CONTROLES], AVALIACAO) :-
    avaliar_perseguicao(12, INFORMACAO, ADVERSARIO, CONTROLES, AVALIACAO).
escolher_perseguicao(INFORMACAO, ADVERSARIO, [CONTROLES | RESTO], MELHOR) :-
    RESTO = [_ | _], % Lista não vazia: há mais opções para avaliar.
    avaliar_perseguicao(12, INFORMACAO, ADVERSARIO, CONTROLES, ATUAL),
    escolher_perseguicao(INFORMACAO, ADVERSARIO, RESTO, OUTRA),
    comparar_avaliacoes(ATUAL, OUTRA, MELHOR).

% Avalia a trajetória do jato, passo a passo, atualizando o alinhamento e a aproximação do adversário.
avaliar_perseguicao(0, INFORMACAO, ADVERSARIO, CONTROLES, [CONTROLES, ALINHAMENTO, APROXIMACAO]) :- % Base: não há mais passos a avaliar; devolve a menor distância encontrada.
    INFORMACAO = [X, Y, _ANGLE, _SCORE, _SPEED],
    posicao_relativa(INFORMACAO, ADVERSARIO, FRENTE, LADO),
    NORMA is max(sqrt(FRENTE * FRENTE + LADO * LADO), 0.000001), % Evita divisão por zero.
    ALINHAMENTO is min(0.995, FRENTE / NORMA), % Quanto mais próximo de 1, mais alinhado à frente.
    distancia([X, Y], ADVERSARIO, D),
    APROXIMACAO is -abs(D - 80). % Quanto mais próximo de 80, melhor; o sinal negativo inverte a ordem para maximizar.

% Experimenta os controles por mais um quadro.
avaliar_perseguicao(PASSOS, INFORMACAO, ADVERSARIO, CONTROLES, AVALIACAO) :-
    PASSOS > 0,
    proximo_estado(INFORMACAO, CONTROLES, PROXIMO),
    RESTANTES is PASSOS - 1,
    avaliar_perseguicao(RESTANTES, PROXIMO, ADVERSARIO, CONTROLES, AVALIACAO).

% Escolhe os controles pela posição do alvo em relação ao nariz do jato.
controles_perseguicao(FRENTE, LADO, TOLERANCIA, [1, 0, 0, 0]) :- FRENTE > 0, LADO >= -TOLERANCIA, LADO =< TOLERANCIA. % Alvo alinhado à frente: segue reto.
controles_perseguicao(_FRENTE, LADO, TOLERANCIA, [1, 0, 1, 0]) :- LADO > TOLERANCIA. % Alvo à esquerda: vira à esquerda.
controles_perseguicao(_FRENTE, LADO, TOLERANCIA, [1, 0, 0, 1]) :- LADO < -TOLERANCIA. % Alvo à direita: vira à direita.
% Se o alvo estiver atrás e quase no centro, escolhe a esquerda para dar a volta.
controles_perseguicao(FRENTE, LADO, TOLERANCIA, [1, 0, 1, 0]) :- FRENTE =< 0, LADO >= -TOLERANCIA, LADO =< TOLERANCIA.

% Usa o ângulo para calcular onde o alvo está em relação ao avião.
% FRENTE: positivo = adiante, negativo = atrás. LADO: positivo = esquerda, negativo = direita.
posicao_relativa(INFORMACAO, [AX, AY], FRENTE, LADO) :-
    INFORMACAO = [X, Y, ANGLE, _SCORE, _SPEED],
    DX_BRUTO is AX - X, DY_BRUTO is AY - Y,
    DX is DX_BRUTO - floor((DX_BRUTO + 512) / 1024) * 1024, % Ajusta a diferença horizontal para o menor caminho, considerando a borda.
    DY is DY_BRUTO - floor((DY_BRUTO + 384) / 768) * 768, % Ajusta a diferença vertical para o menor caminho, considerando a borda.
    FRENTE is DX * (-sin(ANGLE)) + DY * (-cos(ANGLE)), % Calcula a posição relativa do alvo em relação ao nariz do jato, considerando o ângulo de inclinação.
    LADO is DX * (-cos(ANGLE)) + DY * sin(ANGLE). % Calcula a posição relativa do alvo em relação ao nariz do jato, considerando o ângulo de inclinação.


% Confirma que o alvo está à frente, verificando se FRENTE é positivo.
inimigo_na_frente(INFORMACAO, ADVERSARIO) :-
    posicao_relativa(INFORMACAO, ADVERSARIO, FRENTE, _LADO),
    FRENTE > 0.

% O alvo está na mira quando está à frente, perto da linha de tiro e a até 200 unidades.
alvo_na_mira(INFORMACAO, ADVERSARIO) :-
    INFORMACAO = [X, Y, _ANGLE, _SCORE, _SPEED],
    ADVERSARIO = [AX, AY],
    inimigo_na_frente(INFORMACAO, ADVERSARIO),
    posicao_relativa(INFORMACAO, ADVERSARIO, _FRENTE, LADO),
    distancia([X, Y], [AX, AY], D),
    D =< 200,
    TOLERANCIA is D * 0.1,
    LADO >= -TOLERANCIA,
    LADO =< TOLERANCIA.

% BOOM vale 1 para pedir um tiro e 0 para não atirar.
disparo(_INFORMACAO, [], 0) :- !. % Lista vazia: não atira; o corte encerra as alternativas desta chamada.

disparo(INFORMACAO, [ADVERSARIO | _RESTO], 1) :- % Primeiro adversário na mira: pede um tiro.
    alvo_na_mira(INFORMACAO, ADVERSARIO).

disparo(INFORMACAO, [ADVERSARIO | RESTO], BOOM) :- % Fora da mira: procura outro adversário no restante da lista.
    \+ alvo_na_mira(INFORMACAO, ADVERSARIO),
    disparo(INFORMACAO, RESTO, BOOM).

% Mensagem de depuração correspondente à ação escolhida.
menssagem(fuga, "Jato em perigo! Fugindo do missil.").
menssagem(perseguicao, "Jato perseguindo adversario.").
menssagem(patrulha, "Jato patrulhando.").
