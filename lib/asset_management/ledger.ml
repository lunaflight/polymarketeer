open! Core
open! Async

type t = Portfolio.t Person.Map.t [@@deriving sexp]

let to_string t ~info_of_token_id =
  if Map.is_empty t
  then Deferred.return "No people in ledger"
  else (
    let%map portfolio_strings =
      Map.to_alist t
      |> Deferred.List.map
           ~how:(`Max_concurrent_jobs 16)
           ~f:(fun (person, portfolio) ->
             let%map portfolio =
               Portfolio.to_string portfolio ~info_of_token_id
             in
             [%string "%{person#Person}'s Portfolio:\n%{portfolio}"])
    in
    String.concat portfolio_strings ~sep:"\n\n")
;;

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

let remove_exn t ~person ~money =
  remove t ~person ~money |> Transaction_failure.result_ok_exn
;;

let update_portfolio t ~person ~f ~token_id ~count ~price =
  let%bind.Result portfolio = portfolio t ~person in
  let%map.Result new_portfolio = f portfolio ~token_id ~count ~price in
  Map.set t ~key:person ~data:new_portfolio
;;

let buy t ~person ~token_id ~count ~price =
  update_portfolio t ~person ~f:Portfolio.buy ~token_id ~count ~price
;;

let buy_exn t ~person ~token_id ~count ~price =
  buy t ~person ~token_id ~count ~price |> Transaction_failure.result_ok_exn
;;

let sell t ~person ~token_id ~count ~price =
  update_portfolio t ~person ~f:Portfolio.sell ~token_id ~count ~price
;;

let sell_exn t ~person ~token_id ~count ~price =
  sell t ~person ~token_id ~count ~price |> Transaction_failure.result_ok_exn
;;

let to_file t ~filename =
  Writer.with_file filename ~f:(fun writer ->
    sexp_of_t t |> Writer.write_sexp writer |> Deferred.return)
;;

let from_file ~filename =
  Monitor.try_with_or_error (fun () ->
    match%map
      Reader.with_file filename ~f:(fun reader -> Reader.read_sexp reader)
    with
    | `Ok sexp -> t_of_sexp sexp
    | `Eof -> empty)
;;

let modify_file ~filename ~f =
  let%bind ledger =
    match%map from_file ~filename with
    | Ok t -> t
    | Error _ -> empty
  in
  let%bind new_ledger = f ledger in
  to_file new_ledger ~filename
;;
