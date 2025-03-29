open! Core
open! Async
open Polymarket_types

(** Queries Polymarket for a orderbook summary from a Token ID.
    See: https://docs.polymarket.com/#get-book. *)
val query : token_id:Token.Id.t -> Orderbook.t Deferred.t
