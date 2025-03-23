open! Core
open! Async

(** This type is a simple abstraction for a [Person]. *)
type t [@@deriving compare, of_string, sexp]

include Comparable.S with type t := t
