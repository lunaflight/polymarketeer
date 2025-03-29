open! Core
open! Async

let entrypoint =
  Command.group
    ~summary:"Main entrypoint of Polymarketeer"
    [ "api", Api.cmd; "trade", Trade.cmd ]
;;
