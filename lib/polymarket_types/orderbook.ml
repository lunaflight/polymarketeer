open! Core
open! Async

module Order_summary = struct
  type t =
    { price : Dollar.t
    ; size : float
    }
  [@@deriving sexp]

  let of_json json ~price:(price_key, json_to_dollar) ~size_key =
    let open Yojson.Basic.Util in
    { price = json |> member price_key |> json_to_dollar
    ; size = json |> member size_key |> to_string |> Float.of_string
    }
  ;;
end

type t =
  { market : Market.Id.t
  ; asset_id : Token.Id.t
  ; hash : string
  ; timestamp : Time_float_unix.t
  ; bids : Order_summary.t list
  ; asks : Order_summary.t list
  }
[@@deriving sexp]

let of_json
  json
  ~market_key
  ~asset_id_key
  ~hash_key
  ~timestamp:(timestamp_key, json_to_timestamp)
  ~bids_key
  ~asks_key
  ~json_to_order_summary
  =
  let open Yojson.Basic.Util in
  { market = json |> member market_key |> to_string
  ; asset_id = json |> member asset_id_key |> to_string
  ; hash = json |> member hash_key |> to_string
  ; timestamp = json |> member timestamp_key |> json_to_timestamp
  ; bids = json |> member bids_key |> convert_each json_to_order_summary
  ; asks = json |> member asks_key |> convert_each json_to_order_summary
  }
;;
