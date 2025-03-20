open! Core
open! Async
open Polymarket_types

let query ~token ~side =
  let%map json =
    Endpoint.send_request
      (Endpoint.price ~token_id:(Token.token_id token) ~side)
  in
  Price.of_json json
;;
