
open Ctypes
open Foreign
open PosixTypes

(* hack - force library to link *)
external bind : unit -> unit = "bind"
let () = bind()

type lbool = T | F | U
exception Cryptominisat_bad_result_value
let string_of_lbool = function
  | T -> "true"
  | F -> "false"
  | U -> "undef"

module L = struct

  module Vec = struct
    (* literal clauses *)
    type vec_s
    let vec_s : vec_s structure typ = structure "vec"
    type t = vec_s structure ptr
    let t = ptr vec_s

    let create = foreign "vec_create" (void @-> returning t)
    let destroy = foreign "vec_destroy" (t @-> returning void)
    let clear = foreign "vec_clear" (t @-> returning void)
    let push_back = foreign "vec_push_back" (t @-> int @-> bool @-> returning void)
  end

  (* low level interface *)
  type sat_solver_s
  let sat_solver_s : sat_solver_s structure typ = structure "SATSolver"
  type t = sat_solver_s structure ptr
  let t = ptr sat_solver_s

  let lbool_of_int = function
    | 0 -> T
    | 1 -> F
    | 2 -> U
    | _ -> raise Cryptominisat_bad_result_value

  (* min-1 = max *)
  let max_long = Signed.Long.(sub min_int (of_int 1))

  let create =
    let create = foreign "create" (int @-> long @-> int @-> returning t) in
    (fun ?(verbose=0) ?(conflict_limit=max_long) ?(threads=1) () ->
      create verbose conflict_limit threads)
  let destroy = foreign "destroy" (t @-> returning void)

  let new_vars = foreign "new_vars" (t @-> int @-> returning void)
  let new_var = foreign "new_var" (t @-> returning void)

  let add_clause = foreign "add_clause" (t @-> Vec.t @-> returning void)
  let solve = 
    let solve = foreign "solve" (t @-> returning int) in
    (fun t -> lbool_of_int (solve t))
  let solve_with_assumptions = 
    let solve = foreign "solve_with_assumptions" (t @-> Vec.t @-> returning int) in
    (fun t a -> lbool_of_int (solve t a))
  let get_model = 
    let get_model = foreign "get_model" (t @-> int @-> returning int) in
    (fun t i -> lbool_of_int (get_model t i))

  let print_stats = foreign "print_stats" (t @-> returning void)

end

type t = 
  {
    solver : L.t;
    mutable num_vars : int;
    vec : L.Vec.t;
  }

exception Cryptominisat_zero_literal

let create ?verbose ?conflict_limit ?threads () = 
  let solver = L.create ?verbose ?conflict_limit ?threads () in
  {
    solver;
    num_vars = 0;
    vec = L.Vec.create ();
  }

let destroy s = L.destroy s.solver

let vec_of_lits v l = 
  L.Vec.clear v;
  List.iter 
    (fun i ->
      let sgn = i < 0 in
      let i = abs i in
      if i = 0 then raise Cryptominisat_zero_literal 
      else L.Vec.push_back v (i-1) sgn)
    l

let add_vars s c = 
  let max_var = List.fold_left 
    (fun m l -> 
      if l = 0 then raise Cryptominisat_zero_literal
      else max m (abs l)) 
    s.num_vars c 
  in
  if max_var > s.num_vars then begin
    for i=s.num_vars to max_var-1 do
      L.new_var s.solver
    done;
    s.num_vars <- max_var;
  end

let add_clause s c = 
  (* add new variables if needed *)
  add_vars s c;
  vec_of_lits s.vec c;
  L.add_clause s.solver s.vec

let solve ?(assumptions=[]) s = 
  match assumptions with
  | [] -> L.solve s.solver
  | _ ->
    vec_of_lits s.vec assumptions;
    L.solve_with_assumptions s.solver s.vec
  
let get_model s i = 
  if i=0 then raise Cryptominisat_zero_literal
  else L.get_model s.solver (i-1)

let get_all_models s = 
  Array.init (s.num_vars+1) 
    (fun i -> if i=0 then U else get_model s i)

let print_stats s = L.print_stats s.solver

