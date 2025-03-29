open! Core
open! Async
open Polymarket_types

module Not_enough_money : sig
  type t =
    { cost : Dollar.t
    ; money_owned : Dollar.t
    }
end

type t =
  | Not_enough_money of Not_enough_money.t
  | Not_enough_tokens of Token.Id.t
  | Person_does_not_exist of Person.t
  | Token_not_owned of Token.Id.t
[@@deriving sexp]

val result_ok_exn : ('a, t) Result.t -> 'a
