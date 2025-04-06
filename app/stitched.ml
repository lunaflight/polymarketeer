open! Core
open! Async
open Polymarket_queries
open Polymarket_types

let info_of_token_id =
  Command.async
    ~summary:"Get the info associated with a Token ID"
    (let%map_open.Command token_id = anon ("token_id" %: Token.Id.arg_type) in
     fun () ->
       let%map price, question, outcome = Stitched.info_of_token_id token_id in
       print_s
         [%message (price : Dollar.t) (question : string) (outcome : string)])
;;

let cmd =
  Command.group
    ~summary:"Request stitched together unofficial APIs of Polymarket"
    [ "info-of-token-id", info_of_token_id ]
;;
