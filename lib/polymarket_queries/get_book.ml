open! Core
open! Async
open Polymarket_types

(* TODO-soon: Add robustness for an invalid request. *)
let query ~token_id =
  let%map json = Endpoint.send_request (Endpoint.book ~token_id) in
  Orderbook.of_json
    json
    ~market_key:"market"
    ~asset_id_key:"asset_id"
    ~hash_key:"hash"
    ~timestamp:
      ( "timestamp"
      , fun json ->
          (* The json is expressed as milliseconds after epoch in a string. *)
          Yojson.Basic.Util.to_string json
          |> Float.of_string
          |> Time_float_unix.Span.of_ms
          |> Time_float.of_span_since_epoch )
    ~bids_key:"bids"
    ~asks_key:"asks"
    ~json_to_order_summary:
      (Orderbook.Order_summary.of_json
         ~price:("price", Dollar.of_json_string)
         ~size_key:"size")
;;
