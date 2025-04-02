open! Core
open! Async
open Polymarket_types

type t = Uri.t

let to_string t = Uri.to_string t

(* TODO-someday: There is possibly room for injection attacks.
   Consider cleansing the input by stripping "/"s or non alphanumeric
   characters. *)
(* Calling this is equivalent to
   [base/path_0/.../path_n?query_0=param_0&...&query_n=param_n]. *)
let create ~base ~path ~query_params =
  let endpoint_with_path =
    Uri.path base :: path |> String.concat ~sep:"/" |> Uri.with_path base
  in
  Uri.add_query_params' endpoint_with_path query_params
;;

let clob = Uri.of_string "https://clob.polymarket.com"

let book ~token_id =
  create ~base:clob ~path:[ "book" ] ~query_params:[ "token_id", token_id ]
;;

let markets ~condition_id =
  create ~base:clob ~path:[ "markets"; condition_id ] ~query_params:[]
;;

let price ~token_id ~side =
  create
    ~base:clob
    ~path:[ "price" ]
    ~query_params:[ "token_id", token_id; "side", Side.to_string side ]
;;

let sampling_markets ~next_cursor =
  create
    ~base:clob
    ~path:[ "sampling-markets" ]
    ~query_params:[ "next_cursor", Next_cursor.to_string next_cursor ]
;;

let web = Uri.of_string "https://polymarket.com/api"

let search ~search_term =
  create
    ~base:web
    ~path:[ "events"; "global" ]
    ~query_params:[ "q", search_term; "events_status", "active" ]
;;

let send_request t =
  let%bind _response, body = Cohttp_async.Client.get t in
  let%map json_str = Cohttp_async.Body.to_string body in
  Yojson.Basic.from_string json_str
;;
