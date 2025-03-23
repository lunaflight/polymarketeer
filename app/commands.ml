open! Core
open! Async
open Polymarket_queries
open Polymarket_types

let get_price =
  Command.async
    ~summary:"Get the price of a Token ID"
    (let%map_open.Command token_id = anon ("token_id" %: Token.Id.arg_type)
     and side =
       flag
         "-s"
         (required Side.arg_type)
         ~doc:[%string "SIDE %{Side.usage_hint}"]
     in
     fun () ->
       let%map price = Get_price.query ~token_id ~side in
       print_s [%sexp (price : Dollar.t)])
;;

(* TODO-soon: This command should take filter options to make it more
   browseable. *)
let sampling_markets =
  Command.async
    ~summary:"Get markets that have rewards enabled"
    (let%map_open.Command () = Command.Param.return () in
     fun () ->
       let%map market_list = Sampling_markets.query () in
       List.iter market_list ~f:(fun market ->
         print_s [%sexp (market : Market.t)]))
;;

let api =
  Command.group
    ~summary:"Request APIs of Polymarket"
    [ "get-price", get_price; "sampling-markets", sampling_markets ]
;;

let main =
  Command.group ~summary:"Main entrypoint of Polymarketeer" [ "api", api ]
;;
