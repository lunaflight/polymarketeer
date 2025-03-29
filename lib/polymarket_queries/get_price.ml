open! Core
open! Async
open Polymarket_types

(* TODO-soon: Add robustness for an invalid request. *)
let query ~token_id ~side_of_dealer =
  let%map json =
    Endpoint.send_request (Endpoint.price ~token_id ~side:side_of_dealer)
  in
  Yojson.Basic.Util.member "price" json |> Dollar.of_json_string
;;
