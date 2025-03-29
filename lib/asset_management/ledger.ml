open! Core
open! Async

type t = Portfolio.t Person.Map.t [@@deriving sexp]

(** TODO-soon: Add a string representation for this so "view" can be made into
    a command. *)

let of_transaction_failure_exn result =
  result |> Result.map_error ~f:Transaction_failure.to_error |> Or_error.ok_exn
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
  remove t ~person ~money |> of_transaction_failure_exn
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
  buy t ~person ~token_id ~count ~price |> of_transaction_failure_exn
;;

let sell t ~person ~token_id ~count ~price =
  update_portfolio t ~person ~f:Portfolio.sell ~token_id ~count ~price
;;

let sell_exn t ~person ~token_id ~count ~price =
  sell t ~person ~token_id ~count ~price |> of_transaction_failure_exn
;;

let to_file t ~filename =
  Writer.with_file filename ~f:(fun writer ->
    sexp_of_t t |> Writer.write_sexp writer |> Deferred.return)
;;

let from_file_or_empty ~filename =
  match%map
    Monitor.try_with_or_error (fun () ->
      match%map
        Reader.with_file filename ~f:(fun reader -> Reader.read_sexp reader)
      with
      | `Ok sexp -> t_of_sexp sexp
      | `Eof -> empty)
  with
  | Ok t -> t
  | Error _ -> empty
;;

let modify_file ~filename ~f =
  let%bind ledger = from_file_or_empty ~filename in
  let%bind new_ledger = f ledger in
  to_file new_ledger ~filename
;;
