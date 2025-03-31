open! Core
open! Async
open Polymarket_types

(** Queries Polymarket for a market from a condition ID.
    See: https://docs.polymarket.com/#get-market. *)
val query : condition_id:Market.Id.t -> Market.t Deferred.t
