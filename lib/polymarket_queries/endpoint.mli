(** This module returns [Uri.t]s corrsponding to various endpoints that can
    be queried in the Polymarket API. *)

open! Core
open! Async
open Polymarket_types

type t

val to_string : t -> string
val clob_endpoint : t

(** Returns the endpoint for order book summary for a market.
    See: https://docs.polymarket.com/#get-book. *)
val book : token_id:Token.Id.t -> t

(** Returns the endpoint for the market of a condition ID.
    See: https://docs.polymarket.com/#get-market. *)
val markets : condition_id:Market.Id.t -> t

(** Returns the endpoint for the price of a token.
    See: https://docs.polymarket.com/#get-price. *)
val price : token_id:Token.Id.t -> side:Side.t -> t

(** Returns the endpoint for markets that have rewards enabled.
    See: https://docs.polymarket.com/#get-sampling-markets. *)
val sampling_markets : next_cursor:Next_cursor.t -> t

(** Returns the JSON body after sending a HTTP GET request to the
    endpoint. *)
val send_request : t -> Yojson.Basic.t Deferred.t
