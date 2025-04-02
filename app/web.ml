open! Core
open! Async
open Polymarket_queries
open Polymarket_types

let search_active_markets =
  Command.async
    ~summary:"Return markets satisfying a search term"
    (let%map_open.Command search_term = anon ("search_term" %: string) in
     fun () ->
       let%map market_list = Web.search_active_markets ~search_term in
       List.iter market_list ~f:(fun market ->
         print_s [%sexp (market : Market.t)]))
;;

let cmd =
  Command.group
    ~summary:"Request web APIs of Polymarket"
    [ "search-active-markets", search_active_markets ]
;;
