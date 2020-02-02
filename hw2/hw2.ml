type ('nonterminal, 'terminal) symbol =
  | N of 'nonterminal
  | T of 'terminal

type ('nonterminal, 'terminal) parse_tree =
  | Node of 'nonterminal * ('nonterminal, 'terminal) parse_tree list
  | Leaf of 'terminal

let rec filter_symbol s g =
match g with
    | [] -> []
    | h::t -> match (s = (fst h)) with
                       | true -> [snd h]@filter_symbol s t
                       | false -> filter_symbol s t
;;

let convert_grammar gram1 =
  let s, g = gram1 in
  (s, function sym -> (sym, filter_symbol sym g))
;;

let rec apply_list lst f =
match lst with
     | [] -> []
     | h::t -> (f h)@(apply_list t f)

let rec parse_tree_leaves tree =
match tree with
     | Node (n, lst) -> apply_list lst parse_tree_leaves
     | Leaf s -> [s]
;;

let rec match_symbol generator symbol lambda accept frag = 
match symbol with
| N s -> matcher generator lambda (generator s) accept frag
| T s -> match frag with
          | h::t -> if (h = s) then accept t else None
          | [] -> None

and match_rule generator rule lambda accept = function
| f -> match rule with
  | [] -> (accept f)
  | h::t -> match_symbol generator h lambda (fun x -> match_rule generator t lambda accept x) f

and matcher generator lambda = function
| [] -> (fun accept frag -> None)
| h::t -> let mt = matcher generator lambda t
          and mh = match_rule generator h lambda
          in (
            fun accept frag -> match mh accept frag with
              | None -> mt accept frag
              | Some x -> (lambda x h)
          )

and make_matcher gram = 
let (start, generator) = gram in
matcher generator (fun x h -> Some x) (generator start)
;;

let rec deserialize_rule rule preorder =
  match rule with
    | [] -> ([], preorder)
    (* Works just like match_rule -> Process a symbol, then process the rest of the rule explicitly instead of through the acceptor *)
    | h::t -> let (child_fst, list_left) = deserialize_symbol h preorder in 
              let (child_rest, list_left') = (deserialize_rule t list_left) in
              (child_fst::child_rest, list_left')

  and deserialize_symbol symbol preorder =
    match symbol with
      | T s -> (Leaf s, preorder)
      | N s -> (match preorder with 
                  | [] -> (Node (s, []), [])
                  | h::t -> let (children, list_left) = (deserialize_rule h t) in
                            (Node(s, children), list_left))

  and deserialize_tree start preorder = 
    let start_rule = [N start] in
    let (root_nodes, _) = (deserialize_rule start_rule preorder) in
    match root_nodes with
      | root::_ -> Some (root)
      | _ -> None
;;

let accept_empty_suffix = (fun x -> match x with | [] -> Some [] | _ -> None);;

let make_parser gram = 
  let (start, generator) = gram in
  (
    fun frag -> 
      let m = make_matcher gram accept_empty_suffix in
      match m frag with
        | Some [] -> let preorder_traversal = (matcher generator (fun x h -> Some (h::x)) (generator start) accept_empty_suffix frag) in
                     (match preorder_traversal with
                      | Some p -> deserialize_tree start p
                      | _ -> None)
        | _ -> None
  )
;;