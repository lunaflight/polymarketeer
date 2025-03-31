open! Core
open! Async
open Polymarket_types

type t =
  { token_ids_owned : int Token.Id.Map.t
  ; money_owned : Dollar.t
  }
[@@deriving fields ~getters, sexp]

let to_string { token_ids_owned; money_owned } ~info_of_token_id =
  let%map token_ids =
    if Map.is_empty token_ids_owned
    then Deferred.return "No tokens owned"
    else (
      let%map token_strings =
        Map.to_alist token_ids_owned
        |> Deferred.List.map
             ~how:(`Max_concurrent_jobs 16)
             ~f:(fun (token_id, count) ->
               match info_of_token_id with
               | None ->
                 Deferred.return [%string "%{count#Int}x Token: %{token_id}"]
               | Some info_of_token_id ->
                 let%map price, question, outcome = info_of_token_id token_id in
                 let cents = Dollar.to_cents_hum price ~decimals:2 in
                 [%string
                   "%{count#Int}x Token: %{question} (%{outcome}) Current \
                    Price: %{cents} cents"])
      in
      String.concat token_strings ~sep:"\n")
  in
  let cents = Dollar.to_cents_hum money_owned ~decimals:2 in
  [%string "%{cents} cents\n%{token_ids}"]
;;

let empty =
  { token_ids_owned = Token.Id.Map.empty; money_owned = Dollar.of_float 0. }
;;

let add { token_ids_owned; money_owned } ~money =
  { token_ids_owned; money_owned = Dollar.(money_owned + money) }
;;

let remove { token_ids_owned; money_owned } ~money =
  (* Attempts to remove the money, capping it at zero. *)
  { token_ids_owned; money_owned = Dollar.(max zero (money_owned - money)) }
;;

let init ~money_owned = add empty ~money:money_owned

let buy { token_ids_owned; money_owned } ~token_id ~count ~price =
  let cost = Dollar.( * ) price count in
  if Dollar.(cost > money_owned)
  then Error (Transaction_failure.Not_enough_money { cost; money_owned })
  else
    Ok
      { token_ids_owned =
          Map.update token_ids_owned token_id ~f:(function
            | None -> count
            | Some existing_count -> count + existing_count)
      ; money_owned = Dollar.(money_owned - cost)
      }
;;

let sell { token_ids_owned; money_owned } ~token_id ~count ~price =
  match Map.find token_ids_owned token_id with
  | None -> Error (Transaction_failure.Token_not_owned token_id)
  | Some existing_count ->
    if existing_count < count
    then Error (Transaction_failure.Not_enough_tokens token_id)
    else (
      let token_ids_owned =
        if existing_count = count
        then Map.remove token_ids_owned token_id
        else Map.set token_ids_owned ~key:token_id ~data:(existing_count - count)
      in
      Ok
        { token_ids_owned
        ; money_owned = Dollar.(money_owned + (price * count))
        })
;;
