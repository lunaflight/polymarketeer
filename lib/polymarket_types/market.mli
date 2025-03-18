open! Core
open! Async

(** This type encapsulates a [Market].

    See: https://docs.polymarket.com/#get-markets. *)
type t =
  { question : string
  ; tokens : Token.t list
  }
[@@deriving fields ~getters, sexp]

(** Fetches and interprets a [Market] from a [Yojson.Basic.t]
    dictionary.

    Each labelled argument is either
    1) A string, which is the key to locate that data or
    2) A tuple, the first string being the key to locate that data,
    and the second function being how to interpret that data as a custom
    type. *)
val of_json
  :  Yojson.Basic.t
  -> question_key:string
  -> tokens:string * (Yojson.Basic.t -> Token.t list)
  -> t
