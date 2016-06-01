open Cryptominisat

let s = create ()

let clauses = 
  [
    [1];
    [-2];
    [3];
    [-1;2;3]
  ]

let () = List.iter (add_clause s) clauses

let soln assumptions = 
  let res = solve ~assumptions s in
  Printf.printf "result=%s\n" (string_of_lbool res);
  if res = T then begin
    Array.iteri (fun i x ->
      Printf.printf " %i=%s\n" i (string_of_lbool x))
      (get_all_models s)
  end

let () = soln []
let () = soln [-3]
let () = soln []

let () = print_stats s

