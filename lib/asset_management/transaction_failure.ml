open! Core
open! Async
open Polymarket_types

module Not_enough_money = struct
  type t =
    { cost : Dollar.t
    ; money_owned : Dollar.t
    }
  [@@deriving sexp]
end

type t =
  | Not_enough_money of Not_enough_money.t
  | Not_enough_tokens of Token.Id.t
  | Person_does_not_exist of Person.t
  | Token_not_owned of Token.Id.t
[@@deriving sexp]
