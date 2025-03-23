open! Core
open! Async
open Polymarket_types

let query ~token_id ~side =
  let%map json = Endpoint.send_request (Endpoint.price ~token_id ~side) in
  Yojson.Basic.Util.member "price" json |> Dollar.of_json_string
;;
