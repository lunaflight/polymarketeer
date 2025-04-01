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
    dictionary. *)
val of_json : Yojson.Basic.t -> token_id_key:string -> outcome_key:string -> t
