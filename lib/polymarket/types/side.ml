open! Core
open! Async

type t =
  | Buy
  | Sell
[@@deriving
  enumerate, string ~capitalize:"lower sentence case" ~case_insensitive]

let usage_hint =
  let possible_strings =
    all |> List.map ~f:to_string |> String.concat ~sep:"|"
  in
  [%string "SIDE [%{possible_strings}]"]
;;

let arg_type = Command.Arg_type.create of_string
