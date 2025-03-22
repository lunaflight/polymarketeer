open! Core
open! Async
open Polymarket_types

let query () =
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
                         ~price:("price", Dollar.of_json)
                         ~winner_key:"winner") ))
      in
      let%map tl = get_all_markets ~next_cursor in
      List.append markets tl)
  in
  get_all_markets ~next_cursor:Next_cursor.start
;;
