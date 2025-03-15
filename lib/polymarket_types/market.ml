open! Core
open! Async

type t = { question : string } [@@deriving fields ~getters, sexp]

let of_json json ~question_key =
  { question =
      json |> Yojson.Basic.Util.member question_key |> Yojson.Basic.to_string
  }
;;
