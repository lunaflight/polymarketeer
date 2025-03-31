open! Core
open! Async

module Id : sig
  type t = string [@@deriving compare, sexp]

  val arg_type : t Command.Arg_type.t
  val usage_hint : string

  include Comparable.S with type t := t
end

type t [@@deriving sexp]

val token_id : t -> Id.t
val outcome : t -> string

(** Fetches and interprets a [Token] from a [Yojson.Basic.t]
    dictionary.

    Each labelled argument is either
    1) A string, which is the key to locate that data or
    2) A tuple, the first string being the key to locate that data,
    and the second function being how to interpret that data as a custom
    type. *)
val of_json
  :  Yojson.Basic.t
  -> token_id_key:string
  -> outcome_key:string
  -> price:string * (Yojson.Basic.t -> Dollar.t)
  -> winner_key:string
  -> t
