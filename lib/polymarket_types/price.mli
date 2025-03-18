open! Core
open! Async

type t [@@deriving sexp]

val of_dollars : float -> t

(** Returns a string representing the number of cents, rounded to [decimals]
    places. *)
val to_cents_hum : t -> decimals:int -> string

(** Interprets a float as the type [t]. *)
val of_json : Yojson.Basic.t -> t
