open! Core
open! Async
open Polymarket_types

(** Queries Polymarket for the price of a Token ID.
    See: https://docs.polymarket.com/#get-price. *)
val query : token_id:Token.Id.t -> side:Side.t -> Dollar.t Deferred.t
