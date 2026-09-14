%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Servidor em prolog

% Módulos:
:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_files)).
:- use_module(library(http/json)).
:- use_module(library(http/http_json)).
:- use_module(library(http/json_convert)).
:- use_module(library(http/http_parameters)).
:- use_module(library(http/http_dirindex)).
:- use_module(library(http/http_path)).
:- use_module(library(http/http_server_files)).
%DEBUG:
%:- use_module(library(http/http_error)).
%:- debug.

:- use_module(jatos_controle, [vez/5]).

% GET
:- http_handler(
    root(action), % Alias /action
    action,       % Predicado 'action'
    []).

:- http_handler(root(.), http_reply_from_files('.', []), [prefix]).

:- json_object
    controles(forward:integer, reverse: integer, left:integer, right:integer, boom:integer, msg: string).

start_server(Port) :-
    http_server(http_dispatch, [port(Port)]).

stop_server(Port) :-
    http_stop_server(Port, []).

action(Request) :-
    http_parameters(Request,
                    % informacoes do ambiente:
                    [ id(VEZ, [integer]), %identificacao do agente
                      x(X, [float]), % posicao X
                      y(Y, [float]), % posicao Y
                      angle(ANGLE, [float]), % angulo de rotacao
                      score(SCORE, [integer]), % vida
                      speed(SPEED, [float]), % velocidade
                      adversarios(ADVERSARIOS_JSON, [atom]), % vetor de adversarios
                      misseis(MISSEIS_JSON, [atom]) % vetor de misseis
                    ]),
    atom_json_term(ADVERSARIOS_JSON, ADVERSARIOS_JSON_TERM, []),
    normalizar_posicoes(ADVERSARIOS_JSON_TERM, ADVERSARIOS),
    atom_json_term(MISSEIS_JSON, MISSEIS_JSON_TERM, []),
    normalizar_posicoes(MISSEIS_JSON_TERM, MISSEIS),
    INFORMACAO = [X,Y,ANGLE,SCORE,SPEED],
    vez(VEZ, INFORMACAO, ADVERSARIOS, MISSEIS, CONTROLES),
    %DEBUG:
    %FORWARD is 0, REVERSE is 1, LEFT is 0, RIGHT is 1, BOOM is 1,
    CONTROLES = [FORWARD, REVERSE, LEFT, RIGHT, BOOM, MSG],
    prolog_to_json( controles(FORWARD, REVERSE, LEFT, RIGHT, BOOM, MSG), JOut),
    reply_json( JOut ).

para_numero(V, N) :- number(V), !, N is V.
para_numero(V, N) :- atom(V), !, atom_number(V, N).
para_numero(V, N) :- string(V), !, number_string(N, V).


% =========================================================
% Converte: [["468","380"],["489","539"],...]
% para:     [[468.0,380.0],[489.0,539.0],...]
% =========================================================
normalizar_posicoes([], []).

normalizar_posicoes(
    [[X0,Y0]|Rest],
    [[X,Y]|RestNormalizado]
) :-
    para_numero(X0, X),
    para_numero(Y0, Y),
    normalizar_posicoes(Rest, RestNormalizado).

% Inicia o servidor
start :- format('~n~n--========================================--~n~n'),
         start_server(8080),
         format('~n~n--========================================--~n~n').

:- initialization start.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

