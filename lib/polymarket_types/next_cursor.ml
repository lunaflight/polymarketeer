open! Core
open! Async

type t =
  | Start
  | Next of string
  | End
[@@deriving sexp, variants]

(* The ppx adds [_] to the end of [End] to pre-emptively stop namespace
   clashes. This rebinds it to the unused name [is_end]. *)
let is_end = is_end_

let to_string = function
  | Start -> ""
  | End -> "LTE="
  | Next str -> str
;;

let of_string str =
  let str = String.strip ~drop:(Char.equal '"') str in
  if String.equal str (to_string Start)
  then Start
  else if String.equal str (to_string End)
  then End
  else Next str
;;

let of_json ~key json =
  json |> Yojson.Basic.Util.member key |> Yojson.Basic.to_string |> of_string
;;
