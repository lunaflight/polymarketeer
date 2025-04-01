open! Core
open! Async
open Polymarket_types

(** Queries Polymarket for a orderbook summary from a Token ID.
    See: https://docs.polymarket.com/#get-book. *)
val get_book : token_id:Token.Id.t -> Orderbook.t Deferred.t

(** Queries Polymarket for a market from a condition ID.
    See: https://docs.polymarket.com/#get-market. *)
val get_market : condition_id:Market.Id.t -> Market.t Deferred.t

(** Queries Polymarket for the price of a Token ID.
    If [side_of_dealer] is [Buy], it returns the highest price someone is
    bidding for it.
    If [side_of_dealer] is [Sell], it returns the lowest price someone is
    asking for it.

    See: https://docs.polymarket.com/#get-price. *)
val get_price
  :  token_id:Token.Id.t
  -> side_of_dealer:Side.t
  -> Dollar.t Deferred.t

(** Queries Polymarket for markets that have rewards enabled.
    See: https://docs.polymarket.com/#get-sampling-markets. *)
val sampling_markets : unit -> Market.t list Deferred.t
