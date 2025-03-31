open! Core
open! Async
open Polymarket_types

type t = Uri.t

let to_string t = Uri.to_string t
let clob_endpoint = Uri.of_string "https://clob.polymarket.com"

let book ~token_id =
  Uri.add_query_param'
    (Uri.with_path clob_endpoint "book")
    ("token_id", token_id)
;;

let markets ~condition_id =
  String.concat ~sep:"/" [ "markets"; condition_id ]
  |> Uri.with_path clob_endpoint
;;

let price ~token_id ~side =
  Uri.add_query_params'
    (Uri.with_path clob_endpoint "price")
    [ "token_id", token_id; "side", Side.to_string side ]
;;

let sampling_markets ~next_cursor =
  Uri.add_query_param'
    (Uri.with_path clob_endpoint "sampling-markets")
    ("next_cursor", Next_cursor.to_string next_cursor)
;;

let send_request t =
  let%bind _response, body = Cohttp_async.Client.get t in
  let%map json_str = Cohttp_async.Body.to_string body in
  Yojson.Basic.from_string json_str
;;
