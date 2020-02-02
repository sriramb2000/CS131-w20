let my_subset_test0 = not (subset [1;2;1;1;1;1;1;] [1;])
let my_subset_test1 = subset [] []
let my_subset_test2 = subset [1;1;1;1;1;1;1;1;1;] [1;2;1;1;1;1;1;]

let my_equal_sets_test0 = equal_sets [] []
let my_equal_sets_test1 = equal_sets [1;3;] [3;1;3]

let my_set_union_test0 = equal_sets (set_union [] [1;2;3]) [1;2;3]
let my_set_union_test1 = equal_sets (set_union [3;1;3] [1;1;3]) [1;3;]

let my_set_intersection_test0 =
  equal_sets (set_intersection [] []) []
let my_set_intersection_test1 =
  equal_sets (set_intersection [3;13;3] [12;2;4]) []
let my_set_intersection_test2 =
  equal_sets (set_intersection [1;1;3;2;3;4] [3;1;3;2;1;2;4]) [4;3;2;1]

let my_set_diff_test0 = equal_sets (set_diff [1;3;3;3;1;1;1] [1;]) [3;]

let my_computed_fixed_point_test0 =
  computed_fixed_point (=) (fun x -> x / 1) 1 = 1

type giant_nonterminals =
  | Conversation | Sentence | Grunt | Snore | Shout | Quiet

let giant_grammar =
  Conversation,
  [Snore, [T"ZZZ"];
   Quiet, [];
   Grunt, [T"khrgh"];
   Shout, [T"aooogah!"];
   Sentence, [N Quiet];
   Sentence, [N Grunt];
   Sentence, [N Shout];
   Conversation, [N Snore];
   Conversation, [N Sentence; T","; N Conversation]]

let my_filter_reachable_test0 =
  filter_reachable (Snore, snd giant_grammar) = (Snore, [Snore, [T"ZZZ"]])

let my_filter_reachable_test1 =
  filter_reachable (Snore, List.tl (snd giant_grammar)) =
    (Snore,[])
