open! Core
open! Async
open Polymarket_types

(** This type encapsulates a persons owned money and their "assets" in the form
    of token ids. *)
type t [@@deriving sexp]

val money_owned : t -> Dollar.t
val token_ids_owned : t -> int Token.Id.Map.t

(** Initialises a portfolio with no token ids and [money_owned] dollars to begin
    with. *)
val init : money_owned:Dollar.t -> t

val add : t -> money:Dollar.t -> t

(** Removes [money], capped from going negative. *)
val remove : t -> money:Dollar.t -> t

val buy
  :  t
  -> token_id:Token.Id.t
  -> count:int
  -> price:Dollar.t
  -> (t, Transaction_failure.t) Result.t

val sell
  :  t
  -> token_id:Token.Id.t
  -> count:int
  -> price:Dollar.t
  -> (t, Transaction_failure.t) Result.t
