open! Core
open! Async

type t = Portfolio.t Person.Map.t [@@deriving sexp]

let portfolio t ~person =
  Map.find t person
  |> Result.of_option ~error:(Transaction_failure.Person_does_not_exist person)
;;

let empty = Person.Map.empty

let add t ~person ~money =
  Map.update t person ~f:(function
    | None -> Portfolio.init ~money_owned:money
    | Some portfolio -> Portfolio.add portfolio ~money)
;;

let remove t ~person ~money =
  let%map.Result portfolio = portfolio t ~person in
  Map.set t ~key:person ~data:(Portfolio.remove portfolio ~money)
;;

let update_portfolio t ~person ~f ~token_id ~count ~price =
  let%bind.Result portfolio = portfolio t ~person in
  let%map.Result new_portfolio = f portfolio ~token_id ~count ~price in
  Map.set t ~key:person ~data:new_portfolio
;;

let buy t ~person ~token_id ~count ~price =
  update_portfolio t ~person ~f:Portfolio.buy ~token_id ~count ~price
;;

let sell t ~person ~token_id ~count ~price =
  update_portfolio t ~person ~f:Portfolio.sell ~token_id ~count ~price
;;
