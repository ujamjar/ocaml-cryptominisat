(** {1 OCaml bindings for [cryptominisat4]} *)

external bind : unit -> unit = "bind"

(** {2 solver results} *)

type lbool = T | F | U
  (** True, False or Undefined *)

exception Cryptominisat_bad_result_value
  (** Internal error - cryptominisat returned something we didnt understand. *)

val string_of_lbool : lbool -> string
  (** convert result to string *)

(** {2 low level interface} 
 
 Matches the low level C++ interface of [Cryptominisat].  Literals
 are specified with an integer (>=0) and sign flag. *)
module L : sig

  open Ctypes

  (** C++ [vector] of [Lit]s *)
  module Vec : sig
    type t
    val create : unit -> t
    val destroy : t -> unit
    val clear : t -> unit
    val push_back : t -> int -> bool -> unit
  end

  type t
    (** solver type *)

  val create : ?verbose:int ->
               ?conflict_limit:Signed.Long.t ->
               ?threads:int ->
               unit -> t
    (** create solver *)

  val destroy : t -> unit
    (** destroy solver *)

  val new_vars : t -> int -> unit
    (** [new_vars solver n] adds n new variables to solver *)

  val new_var : t -> unit
    (** [new_vars solver] adds 1 new variable to solver *)

  val add_clause : t -> Vec.t -> unit
    (** add a clause to solver *)

  val solve : t -> lbool
    (** run solver *)

  val solve_with_assumptions : t -> Vec.t -> lbool
    (** run solver with assumptions on given variables *)

  val get_model : t -> int -> lbool
    (** [get_model solver i] get result for variable [i] *) 

  val print_stats : t -> unit
    (** print statistics *)
end

(** {2 high level interface} 

  Matches the python interface of [cryptominisat] and DIMACS file format.

  Literals are specified as a signed integer (<> 0).  Negative integers mean the
  literal in inverted.

  New variables are added automatically to the solver as they are requested.  *)

type t 
  (** solver type *)

exception Cryptominisat_zero_literal
  (** A zero valued literal was encountered *)

val create : ?verbose:int ->
             ?conflict_limit:Signed.Long.t ->
             ?threads:int ->
             unit -> t
  (** create solver *)

val destroy : t -> unit
  (** destroy solver *)

val add_clause : t -> int list -> unit
  (** add a clause to solver *)

val solve : ?assumptions:int list -> t -> lbool
  (** run solver with optional assumptions on given variables *)

val get_model : t -> int -> lbool
  (** [get_model solver i] get result for variable [i] *) 

val get_all_models : t -> lbool array
  (** return results for all variables.  The 0th index will be set to Undefined *)

val print_stats : t -> unit
  (** print statistics *)


