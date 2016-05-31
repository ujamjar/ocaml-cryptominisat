open Cryptominisat
open L

let s = create ~verbose:2 ~threads:1 ()
let () = new_vars s 3

let v = Vec.create ()

let cl x = 
  Vec.clear v;
  List.iter (fun (x,b) -> Vec.push_back v x b) x;
  add_clause s v

let () = cl [ 0,false ]
let () = cl [ 1,true ]
let () = cl [ 0,true; 1,false; 2,false ]

let ret = solve s

let () = 
  Printf.printf "solve=%s\n 0 = %s\n 1 = %s\n 2 = %s\n"
    (string_of_lbool ret)
    (string_of_lbool @@ get_model s 0)
    (string_of_lbool @@ get_model s 1)
    (string_of_lbool @@ get_model s 2)


