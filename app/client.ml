open! Core
open! Async

let command =
  Command.async
    ~summary:"A simple hello world command"
    (let%map_open.Command () = Command.Param.return () in
     fun () ->
       print_endline "Hello world!";
       Deferred.unit)
;;
