% ====================================================================
% BASE DE DATOS (Ejemplo del PDF)
% ====================================================================

% paciente(dni(Dni), nombre(First, Last), tiempo_espera(Meses)).
paciente(dni(23100200), nombre("Juan", "Martínez"), tiempo_espera(18)).
paciente(dni(37123456), nombre("Ariel", "Lencina"), tiempo_espera(15)).
paciente(dni(27561894), nombre("Ana", "Ramos"), tiempo_espera(8)).
paciente(dni(25450295), nombre("Fernando", "Pérez"), tiempo_espera(20)).

% donante(dni(Dni), nombre(First, Last), dni_paciente(DniPaciente)).
donante(dni(25200100), nombre("Luis", "Martínez"), dni_paciente(23100200)).
donante(dni(33292500), nombre("Pedro", "Sánchez"), dni_paciente(37123456)).
donante(dni(26854963), nombre("María", "Ramos"), dni_paciente(27561894)).
donante(dni(24700600), nombre("Andrea", "Vera"), dni_paciente(25450295)).

% compatibilidad(DniDonante, DniPaciente, Porcentaje).
compatibilidad(25200100, 37123456, 80.0).
compatibilidad(25200100, 27561894, 55.0).
compatibilidad(25200100, 25450295, 75.0).
compatibilidad(33292500, 23100200, 90.0).
compatibilidad(33292500, 25450295, 58.0).
compatibilidad(26854963, 23100200, 60.0).
compatibilidad(26854963, 37123456, 72.0).
compatibilidad(26854963, 27561894, 20.0).
compatibilidad(26854963, 25450295, 65.0).
compatibilidad(24700600, 37123456, 70.0).
compatibilidad(24700600, 27561894, 85.0).

% Constante Delta para la prioridad
delta(2.0).

% ====================================================================

% Unir Nombre y Apellido
concat_nombre(Primero, Segundo, Completo) :-
    string_concat(Primero, " ", Temp),
    string_concat(Temp, Segundo, Completo).

member(X, [X|_]) :- !.
member(X, [_|T]) :- member(X, T).

% reverse/2: Invierte una lista
reverse(Lista, Invertida) :- reverse_acc(Lista, [], Invertida).
reverse_acc([], Acc, Acc).
reverse_acc([H|T], Acc, Invertida) :- reverse_acc(T, [H|Acc], Invertida).

% select/3: Extrae un elemento de una lista
select(E, [E|T], T).
select(E, [H|T], [H|R]) :- select(E, T, R).

% perm/2: Genera permutaciones
perm([], []).
perm(Lista, [H|T]) :-
    select(H, Lista, Resto),
    perm(Resto, T).

% append/3: Concatena dos listas
append([], L, L).
append([H|T], L, [H|R]) :- append(T, L, R).

% rotate_left/2: Rota la lista [1,2,3] -> [2,3,1]
rotate_left([H|T], R) :- append(T, [H], R).

% min_list/2: Encuentra el mínimo de una lista
min_list([H|T], Min) :- min_list_acc(T, H, Min).
min_list_acc([], Min, Min).
min_list_acc([H|T], Acc, Min) :- H < Acc, !, min_list_acc(T, H, Min).
min_list_acc([_|T], Acc, Min) :- min_list_acc(T, Acc, Min).

% ====================================================================
% PREDICADOS
% ====================================================================

% 1) registrado(Donante, Paciente)
registrado(donante(DniDon, FullDon), paciente(DniPac, FullPac)) :-
    donante(dni(DniDon), nombre(FirstD, LastD), dni_paciente(DniPac)),
    paciente(dni(DniPac), nombre(FirstP, LastP), _),
    concat_nombre(FirstD, LastD, FullDon),
    concat_nombre(FirstP, LastP, FullPac).

% 2) compatible(Donante, Paciente)
compatible(donante(DniDon, FullDon), paciente(DniPac, FullPac)) :-
    donante(dni(DniDon), nombre(FirstD, LastD), _), % Verifica que el donante existe
    paciente(dni(DniPac), nombre(FirstP, LastP), _), % Verifica que el paciente existe
    compatibilidad(DniDon, DniPac, Valor),
    Valor >= 50.0,
    concat_nombre(FirstD, LastD, FullDon),
    concat_nombre(FirstP, LastP, FullPac).

% 3) prioridad(Donante, Paciente, P)
prioridad(donante(DniDon, FullDon), paciente(DniPac, FullPac), P) :-
    compatibilidad(DniDon, DniPac, Comp),
    Comp >= 50.0,
    paciente(dni(DniPac), nombre(FirstP, LastP), tiempo_espera(Meses)),
    delta(Delta),
    Anios is Meses / 12.0,
    P is Comp + Delta * Anios,
    donante(dni(DniDon), nombre(FirstD, LastD), _),
    concat_nombre(FirstD, LastD, FullDon),
    concat_nombre(FirstP, LastP, FullPac).

% 4) lista_pacientes(Umbral, ListaPacientes)
lista_pacientes(Umbral, ListaPacientes) :-
    lista_pacientes_acc(Umbral, [], ListaInvertida),
    reverse(ListaInvertida, ListaPacientes).

lista_pacientes_acc(Umbral, Acc, ListaFinal) :-
    paciente(dni(Dni), nombre(F, L), tiempo_espera(M)),
    M >= Umbral,
    concat_nombre(F, L, FullName),
    Paciente = paciente(Dni, FullName),
    \+ member(Paciente, Acc),
    !,
    lista_pacientes_acc(Umbral, [Paciente|Acc], ListaFinal).
lista_pacientes_acc(_, Acc, Acc).


% 5) trasplantes(ListaPacientes, ListaTrasplantes)
trasplantes([PrimerPac|RestoPacs], ListaTrasplantes) :-
    perm(RestoPacs, PermResto),
    ListaPacientesPermutada = [PrimerPac|PermResto],
    rotate_left(ListaPacientesPermutada, PacientesReceptores),
    es_cadena_valida(ListaPacientesPermutada, PacientesReceptores),
    construir_lista_trasplantes(ListaPacientesPermutada, PacientesReceptores, ListaTrasplantes).

es_cadena_valida([], []).
es_cadena_valida([PacDador|RestoD], [PacReceptor|RestoR]) :-
    PacDador = paciente(DniDador, _),
    donante(dni(DniDon), _, dni_paciente(DniDador)),
    PacReceptor = paciente(DniReceptor, _),
    compatibilidad(DniDon, DniReceptor, Valor),
    Valor >= 50.0,
    es_cadena_valida(RestoD, RestoR).

construir_lista_trasplantes([], [], []).
construir_lista_trasplantes([PacDador|RestoD], [PacReceptor|RestoR], [[DonanteStruct, PacReceptor]|RestoT]) :-
    PacDador = paciente(DniDador, _),
    donante(dni(DniDon), nombre(FD, LD), dni_paciente(DniDador)),
    concat_nombre(FD, LD, FullDon),
    DonanteStruct = donante(DniDon, FullDon),
    construir_lista_trasplantes(RestoD, RestoR, RestoT).


% 6) prioridad_minima(ListaTrasplantes, Min)
prioridad_minima(ListaTrasplantes, Min) :-
    lista_prioridades(ListaTrasplantes, Prioridades),
    min_list(Prioridades, Min).

% Helper para (6): Obtiene la lista de prioridades de una cadena
lista_prioridades([], []).
lista_prioridades([[Donante, Paciente]|RestoT], [P|RestoP]) :-
    prioridad(Donante, Paciente, P),
    lista_prioridades(RestoT, RestoP).


% 7) cadena_trasplantes_optima(ListaPacientes, ListaTrasplantes)
cadena_trasplantes_optima(ListaPacientes, MejorCadena) :-
    trasplantes(ListaPacientes, PrimeraCadena),
    !,
    prioridad_minima(PrimeraCadena, PrioridadMin),
    buscar_mejor(ListaPacientes, PrimeraCadena, PrioridadMin, MejorCadena).


buscar_mejor(ListaPacientes, MejorCadenaHastaAhora, MejorMinHastaAhora, MejorCadenaFinal) :-
    trasplantes(ListaPacientes, CadenaNueva),
    CadenaNueva \== MejorCadenaHastaAhora, 
    prioridad_minima(CadenaNueva, MinNuevo),
    MinNuevo > MejorMinHastaAhora,
    !,
    buscar_mejor(ListaPacientes, CadenaNueva, MinNuevo, MejorCadenaFinal).

buscar_mejor(_, MejorCadenaHastaAhora, _, MejorCadenaHastaAhora).


% 8) cadena_trasplantes_completa(Umbral, ListaTrasplantes)
cadena_trasplantes_completa(Umbral, ListaTrasplantes) :-
    lista_pacientes(Umbral, ListaPacientes),
    ListaPacientes \= [], % Falla si no hay pacientes que cumplan el umbral
    cadena_trasplantes_optima(ListaPacientes, ListaTrasplantes).
