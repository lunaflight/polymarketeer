open! Core
open! Async
open Polymarket_types

(** Queries Polymarket for the price of a token.
    See: https://docs.polymarket.com/#get-price. *)
val query : token:Token.t -> side:Side.t -> Price.t Deferred.t
