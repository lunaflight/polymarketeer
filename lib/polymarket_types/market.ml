open! Core
open! Async

type t =
  { question : string
  ; tokens : Token.t list
  }
[@@deriving fields ~getters, sexp]

let of_json json ~question_key ~tokens:(tokens_key, json_to_tokens) =
  let open Yojson.Basic.Util in
  { question = json |> member question_key |> to_string
  ; tokens = json |> member tokens_key |> json_to_tokens
  }
;;
