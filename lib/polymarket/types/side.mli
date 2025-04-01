open! Core
open! Async

type t =
  | Buy
  | Sell

val usage_hint : string
val arg_type : t Command.Arg_type.t

(** Converts it to a string that is passable as a request parameter. *)
val to_string : t -> string

(** Converts it from a string, case insensitively. *)
val of_string : string -> t
