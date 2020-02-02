let rec subset a b =
    match a with
    | [] -> true
    | hd :: tl -> List.mem hd b && subset tl b
;;

let equal_sets a b =
    subset a b && subset b a
;;

let rec set_intersection a b =
match a with
    | [] -> []
    | hd :: tl -> match List.mem hd b with
                        | true -> hd::set_intersection tl b
                        | false -> set_intersection tl b
;;

let rec set_diff a b =
match a with
    | [] -> []
    | hd :: tl -> match not (List.mem hd b) with
                        | true -> hd::set_diff tl b
                        | false -> set_diff tl b
;;

let set_union a b =
    a @ (set_diff b a)
;;

let rec computed_fixed_point eq f x =
match (eq x (f x)) with
    | true -> x
    | false -> computed_fixed_point eq f (f x)
;;

type ('nonterminal, 'terminal) symbol = | N of 'nonterminal | T of 'terminal

let rec filter_symbol s g =
match g with
    | [] -> []
    | hd :: tl -> match (s = (fst hd)) with
                       | true -> [hd]@filter_symbol s tl
                       | false -> filter_symbol s tl
;;

let rec expand_rhs r g =
match r with
| [] -> []
| hd :: tl -> match hd with
               | T _ -> expand_rhs tl g
               | N s -> set_union (filter_symbol s g) (expand_rhs tl g)
;;

let rec expand_set s g =
match s with
| [] -> []
| hd :: tl -> let r = (snd hd) in
        set_union (set_union [hd] (expand_rhs r g)) (expand_set tl g)
;;

let filter_reachable g =
    let start = fst g in
    let g' = snd g in
    let start_set = filter_symbol start g' in
    let expand_set' s = expand_set s g' in
    let ans = computed_fixed_point (equal_sets) expand_set' start_set in    
    let ordered_rules = set_intersection g' ans in
    start, ordered_rules
;;



