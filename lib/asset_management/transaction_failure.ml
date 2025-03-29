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

let to_error t = Error.create_s [%message "Transaction failure" (t : t)]

let result_ok_exn result =
  Result.map_error result ~f:to_error |> Or_error.ok_exn
;;
