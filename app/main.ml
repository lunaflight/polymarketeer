open! Core
open! Async

let cmd =
  Command.group ~summary:"Main entrypoint of Polymarketeer" [ "api", Api.cmd ]
;;
