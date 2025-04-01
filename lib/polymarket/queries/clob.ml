open! Core
open! Async
open Polymarket_types

(* TODO-soon: Add robustness for invalid requests. *)

let get_book ~token_id =
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

let get_market ~condition_id =
  let%map json = Endpoint.markets ~condition_id |> Endpoint.send_request in
  Market.of_json
    json
    ~closed_key:"closed"
    ~condition_id_key:"condition_id"
    ~description_key:"description"
    ~end_date:
      ( "end_date_iso"
      , fun json ->
          Yojson.Basic.Util.to_string json |> Time_float_unix.of_string )
    ~icon:("icon", fun json -> Yojson.Basic.Util.to_string json |> Uri.of_string)
    ~question_key:"question"
    ~tokens:
      ( "tokens"
      , Yojson.Basic.Util.convert_each
          (Token.of_json
             ~token_id_key:"token_id"
             ~outcome_key:"outcome"
             ~price:("price", Dollar.of_json_float)
             ~winner_key:"winner") )
;;

let get_price ~token_id ~side_of_dealer =
  let%map json =
    Endpoint.send_request (Endpoint.price ~token_id ~side:side_of_dealer)
  in
  Yojson.Basic.Util.member "price" json |> Dollar.of_json_string
;;

let sampling_markets () =
  (* Each query to Polymarket returns a maximum of 500 markets, paginating
     them with a [Next_cursor.t]. Hence, recursion is required.
     Refer to https://docs.polymarket.com/#get-sampling-markets. *)
  let rec get_all_markets ~next_cursor =
    if Next_cursor.is_end next_cursor
    then Deferred.return []
    else (
      let%bind json =
        Endpoint.send_request (Endpoint.sampling_markets ~next_cursor)
      in
      let next_cursor =
        Yojson.Basic.Util.member "next_cursor" json |> Next_cursor.of_json
      in
      let markets =
        json
        |> Yojson.Basic.Util.member "data"
        |> Yojson.Basic.Util.convert_each
             (Market.of_json
                ~closed_key:"closed"
                ~condition_id_key:"condition_id"
                ~description_key:"description"
                ~end_date:
                  ( "end_date_iso"
                  , fun json ->
                      Yojson.Basic.Util.to_string json
                      |> Time_float_unix.of_string )
                ~icon:
                  ( "icon"
                  , fun json ->
                      Yojson.Basic.Util.to_string json |> Uri.of_string )
                ~question_key:"question"
                ~tokens:
                  ( "tokens"
                  , Yojson.Basic.Util.convert_each
                      (Token.of_json
                         ~token_id_key:"token_id"
                         ~outcome_key:"outcome"
                         ~price:("price", Dollar.of_json_float)
                         ~winner_key:"winner") ))
      in
      let%map tl = get_all_markets ~next_cursor in
      List.append markets tl)
  in
  get_all_markets ~next_cursor:Next_cursor.start
;;
