verify_count(Rows, counts(Top, Bottom, Left, Right)) :-
        verify_top(Rows, Top), 
        verify_bottom(Rows, Bottom), 
        verify_left(Rows, Left),
        verify_right(Rows, Right),!.

verify_left([], []).
verify_left(Rows, Counts) :-
        maplist(count, Rows, Counts).

verify_right(Rows, Counts) :-
        reverseRows(Rows, Reverse), verify_left(Reverse, Counts).

verify_top(Rows, Counts) :-
        transpose(Rows, Columns), verify_left(Columns, Counts).
        
verify_bottom(Rows, Counts) :-
        transpose(Rows, Columns), verify_right(Columns, Counts).

reverseRows([], []).
reverseRows([R|Rows], [Rev|Reverses]) :-
        reverse(R, Rev),
        reverseRows(Rows, Reverses).

verify_row([], 0, _).
verify_row([X|Y], C, Max) :-
        X > Max,
        verify_row(Y, P, X),
        C is (P + 1),!.
verify_row([X|Y], C, Max) :-
        X < Max,
        verify_row(Y, C, Max),!.

count(Row, C) :-
        verify_row(Row, C, 0).


tower(0, [], counts([],[],[],[])).
tower(N, T, C) :-
        values_check(N, T),
        verify_count(T, C).

values_check(N, Rows) :-
        length(Rows, N),
        length(Columns, N),
        maplist(within_domain(N), Rows),
        maplist(fd_all_different, Rows),
        transpose(Rows, Columns),
        maplist(fd_all_different, Columns),
        maplist(fd_labeling, Rows).

within_domain(N, Row):- length(Row, N), fd_domain(Row, 1, N).


plain_tower(N, T, C) :-
        values_check_plain(N, T, C),
        verify_count(T, C).

values_check_plain(N, Rows, counts(_, _, Left, _)) :-
        length(Rows, N),
        length(Base_list, N),
        generate_n(N, Base_list),
        length(Columns, N),
        transpose(Rows, Columns), !,
        maplist(row_helper(N, Base_list), Rows, Left),
        maplist(col_helper(N, Base_list), Columns).

generate_n(N, L) :- 
        findall(Num, between(1, N, Num), L).

row_helper(N, Base_List, Row, Left) :-
        length(Row, N), !,
        permutation(Base_List, Row),
        count(Row, Left).

col_helper(N, Base_List, Col):-
        length(Col, N), !,
        permutation(Base_List, Col).


ambiguous(N, C, T1, T2):-
        tower(N, T1, C),
        tower(N, T2, C),
        T1 \= T2.

profile_tower(T):-
        statistics(cpu_time, [Start|_]),
        tower(4, _, counts([4,2,1,2], [1,2,3,3], [3,3,2,1], [2,1,2,4])),
        statistics(cpu_time, [End|_]), !, 
        T is End - Start + 1. %add 1 to prevent divide by 0

profile_plain_tower(T):-
        statistics(cpu_time, [Start|_]),
        plain_tower(4, _, counts([4,2,1,2], [1,2,3,3], [3,3,2,1], [2,1,2,4])),
        statistics(cpu_time, [End|_]),
        T is End - Start + 1. %add 1 to prevent divide by 0

speedup(Speed):-
        profile_tower(T),
        profile_plain_tower(TP),
        Speed is TP / T.

% This is SWI-prolog's old implementation
% https://stackoverflow.com/questions/4280986/how-to-transpose-a-matrix-in-prolog
transpose([], []).
transpose([F|Fs], Ts) :-
    transpose(F, [F|Fs], Ts).
transpose([], _, []).
transpose([_|Rs], Ms, [Ts|Tss]) :-
        lists_firsts_rests(Ms, Ts, Ms1),
        transpose(Rs, Ms1, Tss).
lists_firsts_rests([], [], []).
lists_firsts_rests([[F|Os]|Rest], [F|Fs], [Os|Oss]) :-
        lists_firsts_rests(Rest, Fs, Oss).
