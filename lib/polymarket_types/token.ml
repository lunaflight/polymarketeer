open! Core
open! Async

module Id = struct
  module T = struct
    type t = string [@@deriving compare, of_string, sexp]

    let arg_type = Command.Arg_type.create of_string
    let usage_hint = "STRING token id"
  end

  include T
  include Comparable.Make (T)
end

(* TODO-someday: The existence of [price] and [winner] in a [Token] is not
   guaranteed by the CLOB API as shown here:
   https://docs.polymarket.com/#get-sampling-markets.
   It could be more robust to query the price(s) explicitly with the [token_id]
   here: https://docs.polymarket.com/#get-price.
   It could also be more robust to find the winner by checking for the [closed]
   or [end_date_iso] field in a [Market] and then inspecting the prices to see
   who won. *)
type t =
  { token_id : Id.t
  ; outcome : string
  ; price : Dollar.t
  ; winner : bool
  }
[@@deriving fields ~getters, sexp]

let of_json
  json
  ~token_id_key
  ~outcome_key
  ~price:(price_key, json_to_price)
  ~winner_key
  =
  let open Yojson.Basic.Util in
  { token_id = json |> member token_id_key |> to_string
  ; outcome = json |> member outcome_key |> to_string
  ; price = json |> member price_key |> json_to_price
  ; winner = json |> member winner_key |> to_bool
  }
;;
