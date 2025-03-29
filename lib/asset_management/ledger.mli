open! Core
open! Async
open Polymarket_types

(** This type is an abstraction over a mapping between people and their
    portfolios. *)
type t [@@deriving sexp]

val empty : t

(** Obtains the [Portfolio.t] of [person].
    Returns a failure if [person] does not exist. *)
val portfolio
  :  t
  -> person:Person.t
  -> (Portfolio.t, Transaction_failure.t) Result.t

(** Adds [money] to [person]. Creates the [person] if they do not exist. *)
val add : t -> person:Person.t -> money:Dollar.t -> t

(** Removes [money] from [person]. Refer to [Portfolio.remove] for details.
    Returns a failure if [person] does not exist. *)
val remove
  :  t
  -> person:Person.t
  -> money:Dollar.t
  -> (t, Transaction_failure.t) Result.t

val remove_exn : t -> person:Person.t -> money:Dollar.t -> t

(** Buys tokens for [person]. Refer to [Portfolio.add] for details.
    Returns a failure if [person] does not exist. *)
val buy
  :  t
  -> person:Person.t
  -> token_id:Token.Id.t
  -> count:int
  -> price:Dollar.t
  -> (t, Transaction_failure.t) Result.t

val buy_exn
  :  t
  -> person:Person.t
  -> token_id:Token.Id.t
  -> count:int
  -> price:Dollar.t
  -> t

(** Sells tokens for [person]. Refer to [Portfolio.sell] for details.
    Returns a failure if [person] does not exist. *)
val sell
  :  t
  -> person:Person.t
  -> token_id:Token.Id.t
  -> count:int
  -> price:Dollar.t
  -> (t, Transaction_failure.t) Result.t

val sell_exn
  :  t
  -> person:Person.t
  -> token_id:Token.Id.t
  -> count:int
  -> price:Dollar.t
  -> t

(** Reads the contents of [filename], and passes it through [f], writing
    the result back to [filename].

    For a malformed [filename], read [from_file_or_empty] for fallback
    details. *)
val modify_file
  :  filename:Filename.t
  -> f:(t -> t Deferred.t)
  -> unit Deferred.t
