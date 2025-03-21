open! Core
open! Async

type t =
  { closed : bool
  ; condition_id : string
  ; description : string
  ; end_date : Time_float_unix.t option
  ; icon : Uri_sexp.t
  ; question : string
  ; tokens : Token.t list
  }
[@@deriving fields ~getters, sexp]

let of_json
  json
  ~closed_key
  ~condition_id_key
  ~description_key
  ~end_date:(end_date_key, json_to_time_float_unix)
  ~icon:(icon_key, json_to_uri)
  ~question_key
  ~tokens:(tokens_key, json_to_tokens)
  =
  let open Yojson.Basic.Util in
  { closed = json |> member closed_key |> to_bool
  ; condition_id = json |> member condition_id_key |> to_string
  ; description = json |> member description_key |> to_string
  ; end_date = json |> member end_date_key |> to_option json_to_time_float_unix
  ; icon = json |> member icon_key |> json_to_uri
  ; question = json |> member question_key |> to_string
  ; tokens = json |> member tokens_key |> json_to_tokens
  }
;;
