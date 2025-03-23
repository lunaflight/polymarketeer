open! Core
open! Async

module T = struct
  type t = string [@@deriving compare, of_string, sexp]
end

include T
include Comparable.Make (T)
