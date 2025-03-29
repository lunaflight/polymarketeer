open! Core
open! Async

module T = struct
  type t = string [@@deriving compare, string, sexp]

  let arg_type = Command.Arg_type.create of_string
  let usage_hint = "STRING person name"
end

include T
include Comparable.Make (T)
