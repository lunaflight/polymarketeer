open! Core
open! Async

module Order_summary : sig
  (** This type encapsulates a [Order_summary].

      See: https://docs.polymarket.com/#get-books. *)
  type t =
    { price : Dollar.t
    ; size : float
    }
  [@@deriving sexp]

  (** Fetches and interprets a [Order_summary] from a [Yojson.Basic.t]
      dictionary.

      Each labelled argument is either
      1) A string, which is the key to locate that data or
      2) A tuple, the first string being the key to locate that data,
      and the second function being how to interpret that data as a custom
      type. *)
  val of_json
    :  Yojson.Basic.t
    -> price:string * (Yojson.Basic.t -> Dollar.t)
    -> size_key:string
    -> t
end

(** This type encapsulates a [Orderbook].

    See: https://docs.polymarket.com/#get-books. *)
type t =
  { market : Market.Id.t
  ; asset_id : Token.Id.t
  ; hash : string
  ; timestamp : Time_float_unix.t
  ; bids : Order_summary.t list
  ; asks : Order_summary.t list
  }
[@@deriving fields ~getters, sexp]

(** Fetches and interprets a [Orderbook] from a [Yojson.Basic.t]
    dictionary. *)
val of_json
  :  Yojson.Basic.t
  -> market_key:string
  -> asset_id_key:string
  -> hash_key:string
  -> timestamp:string * (Yojson.Basic.t -> Time_float_unix.t)
  -> bids_key:string
  -> asks_key:string
  -> json_to_order_summary:(Yojson.Basic.t -> Order_summary.t)
  -> t
