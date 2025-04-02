open! Core
open! Async
open Polymarket_types

let search_active_markets ~search_term =
  let open Yojson.Basic.Util in
  let of_json market =
    Market.of_json
      market
      ~closed_key:"closed"
      ~condition_id_key:"conditionId"
      ~description_key:"description"
      ~end_date:
        ( "endDateIso"
        , fun json ->
            (* Convert "YYYY-MM-DD" assuming UTC. *)
            Time_float_unix.of_date_ofday
              ~zone:Timezone.utc
              (to_string json |> Date.of_string)
              (Time_float.Ofday.create ()) )
      ~icon:("icon", fun json -> to_string json |> Uri.of_string)
      ~question_key:"question"
        (* The [Token.t]s are spread across the [clobTokenIds] field and the
           [outcomes] field. *)
      ~tokens:
        ( "clobTokenIds"
        , fun json ->
            let token_ids =
              to_string json
              |> Yojson.Basic.from_string
              |> convert_each to_string
            in
            let outcomes =
              member "outcomes" market
              |> to_string
              |> Yojson.Basic.from_string
              |> convert_each to_string
            in
            (* This should be the case, and we have no specification or
               documentation about it. If it is not the case, I am not
               sure how else to interpret the data and assume it is
               ill-formed. *)
            List.zip_exn token_ids outcomes
            |> List.map ~f:(fun (token_id, outcome) : Token.t ->
              { token_id; outcome }) )
  in
  let is_bogus market = member "active" market |> to_bool in
  let%map json = Endpoint.search ~search_term |> Endpoint.send_request in
  let markets =
    Or_error.try_with (fun () ->
      member "events" json
      |> convert_each (fun event ->
        member "markets" event
        |> convert_each (fun market ->
          (* Short-circuiting is required; if it is inactive, the JSON can be
             ill-formed with an invalid question. This is a bogus market. *)
          if not (is_bogus market) then None else Some (of_json market))
        |> List.filter_opt)
      |> List.concat)
  in
  match markets with
  (* When fetching the markets is invalid such as on empty input "",
     we silently fallback to returning no search results. *)
  | Error _ -> []
  | Ok markets -> markets
;;
