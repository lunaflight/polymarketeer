open! Core
open! Async

(** This type is a simple abstraction for a [Person]. *)
type t [@@deriving compare, of_string, sexp]

include Comparable.S with type t := t

val arg_type : t Command.Arg_type.t
val usage_hint : string
