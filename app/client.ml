open! Core
open! Async

let command =
  Command.async
    ~summary:"A simple entrypoint to the app"
    (let%map_open.Command () = Command.Param.return () in
     fun () ->
       let%map.Deferred market_list =
         Polymarket_queries.Sampling_markets.query ()
       in
       List.iter market_list ~f:(fun market ->
         print_s [%sexp (market : Polymarket_types.Market.t)]))
;;
