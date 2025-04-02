open! Core
open! Async

let api_cmd =
  Command.group
    ~summary:"Request APIs of Polymarket"
    [ "clob", Clob.cmd
    ; "web", Web.cmd (* TODO-soon: Add the stitched endpoints. *)
    ]
;;

let entrypoint =
  Command.group
    ~summary:"Main entrypoint of Polymarketeer"
    [ "api", api_cmd; "trade", Trade.cmd ]
;;
