open! Core
open! Async
open Asset_management
open Polymarket_types

let filename = Filename.of_parts [ "data"; "ledger.sexp" ]

let change_money_cmd ~summary ~f =
  Command.async
    ~summary
    (let%map_open.Command person =
       flag "-p" (required Person.arg_type) ~doc:Person.usage_hint
     and money = flag "-m" (required Dollar.arg_type) ~doc:Dollar.usage_hint in
     fun () ->
       Ledger.modify_file ~filename ~f:(fun ledger ->
         f ledger ~person ~money |> Deferred.return))
;;

let add = change_money_cmd ~summary:"Add money to a person" ~f:Ledger.add

let remove =
  change_money_cmd ~summary:"Remove money from a person" ~f:Ledger.remove_exn
;;

let admin_cmd =
  Command.group
    ~summary:"Admin commands to manage the persistent ledger"
    [ "add", add; "remove", remove ]
;;

let change_token_cmd ~summary ~f ~side_of_dealer =
  Command.async
    ~summary
    (let%map_open.Command person =
       flag "-p" (required Person.arg_type) ~doc:Person.usage_hint
     and token_id =
       flag "-t" (required Token.Id.arg_type) ~doc:Token.Id.usage_hint
     and count = flag "-c" (required int) ~doc:"INT number of tokens" in
     fun () ->
       Ledger.modify_file ~filename ~f:(fun ledger ->
         let%map price =
           Polymarket_queries.Get_price.query ~token_id ~side_of_dealer
         in
         f ledger ~person ~token_id ~count ~price))
;;

let buy =
  change_token_cmd
    ~summary:"Buy tokens for a person"
    ~f:Ledger.buy_exn
    ~side_of_dealer:Side.Sell
;;

let sell =
  change_token_cmd
    ~summary:"Sell tokens for a person"
    ~f:Ledger.sell_exn
    ~side_of_dealer:Side.Buy
;;

let view =
  Command.async
    ~summary:"View state of ledger"
    (let%map_open.Command () = Command.Param.return () in
     fun () ->
       let%map ledger =
         Ledger.from_file ~filename |> Deferred.Or_error.ok_exn
       in
       Ledger.to_string ledger |> print_endline)
;;

let cmd =
  Command.group
    ~summary:"Commands to interact with the persistent ledger"
    [ "admin", admin_cmd; "buy", buy; "sell", sell; "view", view ]
;;
