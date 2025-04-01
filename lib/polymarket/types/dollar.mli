open! Core
open! Async

type t [@@deriving sexp]

val arg_type : t Command.Arg_type.t
val usage_hint : string
val of_float : float -> t

(** Returns a string representing the number of cents, rounded to [decimals]
    places. *)
val to_cents_hum : t -> decimals:int -> string

val of_json_float : Yojson.Basic.t -> t
val of_json_string : Yojson.Basic.t -> t
val zero : t
val ( + ) : t -> t -> t
val ( - ) : t -> t -> t
val ( * ) : t -> int -> t

include Comparable.S with type t := t
