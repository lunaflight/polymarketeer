open! Core
open! Async

(** This type encapsulates a [Market].

    See: https://docs.polymarket.com/#get-markets. *)
type t = { question : string } [@@deriving fields ~getters, sexp]

(** Fetches and interprets a [Market] from a [Yojson.Basic.t]
    dictionary, populating the fields with the keys given in the labelled
    arguments *)
val of_json : Yojson.Basic.t -> question_key:string -> t
