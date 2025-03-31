open! Core
open! Async
open Polymarket_types

(** This type encapsulates a persons owned money and their "assets" in the form
    of Token IDs. *)
type t [@@deriving sexp]

(** Returns a string representation of a portfolio.

    The [info_of_token_id] parameter describes a function that given a Token ID, returns the following in a tuple:
    1) The price of a token
    2) The question associated with the token
    3) The outcome associated with the token (usually yes or no)
    If omitted, just the Token ID will be used in stringification. *)
val to_string
  :  t
  -> info_of_token_id:
       (Token.Id.t -> (Dollar.t * string * string) Deferred.t) option
  -> string Deferred.t

val money_owned : t -> Dollar.t
val token_ids_owned : t -> int Token.Id.Map.t

(** Initialises a portfolio with no Token IDs and [money_owned] dollars to begin
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
