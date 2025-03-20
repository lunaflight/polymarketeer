open! Core
open! Async
open Polymarket_types

(** Queries Polymarket for markets that have rewards enabled.
    See: https://docs.polymarket.com/#get-sampling-markets. *)
val query : unit -> Market.t list Deferred.t
