open! Core
open! Async

type t =
  | Buy
  | Sell
[@@deriving
  enumerate, string ~capitalize:"lower sentence case" ~case_insensitive]

let usage_hint = all |> List.map ~f:to_string |> String.concat ~sep:"|"
let arg_type = Command.Arg_type.create of_string
