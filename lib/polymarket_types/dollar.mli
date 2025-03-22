open! Core
open! Async

type t [@@deriving sexp]

val of_float : float -> t

(** Returns a string representing the number of cents, rounded to [decimals]
    places. *)
val to_cents_hum : t -> decimals:int -> string

(** Interprets a float as the type [t]. *)
val of_json : Yojson.Basic.t -> t

val ( + ) : t -> t -> t
val ( - ) : t -> t -> t
val ( * ) : t -> int -> t

include Comparable.S with type t := t
