open! Core
open! Async
open Polymarket_types

(** Queries Polymarket for the price of a Token ID.
    If [side_of_dealer] is [Buy], it returns the highest price someone is
    bidding for it.
    If [side_of_dealer] is [Sell], it returns the lowest price someone is
    asking for it.

    See: https://docs.polymarket.com/#get-price. *)
val query : token_id:Token.Id.t -> side_of_dealer:Side.t -> Dollar.t Deferred.t
