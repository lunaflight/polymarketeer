open! Core
open! Async
open Polymarket_queries
open Polymarket_types

let get_book =
  Command.async
    ~summary:"Get the order book summary with a Token ID"
    (let%map_open.Command token_id = anon ("token_id" %: Token.Id.arg_type) in
     fun () ->
       let%map orderbook = Get_book.query ~token_id in
       print_s [%sexp (orderbook : Orderbook.t)])
;;

let get_market =
  Command.async
    ~summary:"Get the market with a Condition ID"
    (let%map_open.Command condition_id =
       anon ("condition_id" %: Market.Id.arg_type)
     in
     fun () ->
       let%map market = Get_market.query ~condition_id in
       print_s [%sexp (market : Market.t)])
;;

let get_price =
  Command.async
    ~summary:"Get the price of a Token ID"
    (let%map_open.Command token_id = anon ("token_id" %: Token.Id.arg_type)
     and side_of_dealer =
       flag
         "-s"
         (required Side.arg_type)
         ~doc:
           (String.concat
              ~sep:" "
              [ Side.usage_hint
              ; "Refers to the side of the dealer to pair with"
              ])
     in
     fun () ->
       let%map price = Get_price.query ~token_id ~side_of_dealer in
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

let cmd =
  Command.group
    ~summary:"Request APIs of Polymarket"
    [ "get-book", get_book
    ; "get-market", get_market
    ; "get-price", get_price
    ; "sampling-markets", sampling_markets
    ]
;;
