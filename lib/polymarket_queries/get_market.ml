open! Core
open! Async
open Polymarket_types

(* TODO-soon: Add robustness for an invalid request. *)
let query ~condition_id =
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
