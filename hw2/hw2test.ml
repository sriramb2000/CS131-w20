let accept_empty_suffix = (fun x -> match x with | [] -> Some [] | _ -> None)

(*This grammar is a simple grammar based on the example featured in lecture by Prof. Eggert
  and in the textbook *)

type eng_gram_nonterminals =
  | Sentence | NP | VP | Phrase | Conj | Noun | Verb

let eng_gram =
  (Sentence,
   function
     | Sentence ->
         [[N NP; N VP;];
          [N Phrase; N Conj; N Phrase]]
     | Phrase ->
     	   [[N NP];
         [N VP]]
     | NP ->
	     [[N Noun];
	      [N Noun; N Conj; N Phrase]]
     | Conj ->
        [[T "and"]; [T "or"]; [T "yet"]]
     | VP ->
        [[N Verb; N NP];
  	     [N Verb; N Conj; N Verb; N NP]]
     | Noun ->
        [[T "Eggert"]; [T "Smallberg"]; [T "Nachenberg"]]
     | Verb ->
        [[T "likes"]; [T "loves"]; [T "despises"]]
)

let frag = ["Eggert"; "loves"; "or"; "likes"; "Smallberg"; "yet"; "despises"; "Nachenberg"]

let make_matcher_test =
  ((make_matcher eng_gram accept_empty_suffix frag) = Some [])

let make_parser_test =
  match make_parser eng_gram frag with
    | Some tree -> parse_tree_leaves tree = frag
    | _ -> false