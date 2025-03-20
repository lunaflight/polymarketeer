open! Core
open! Async

type t =
  | Buy
  | Sell
[@@deriving string ~capitalize:"lower sentence case" ~case_insensitive]
