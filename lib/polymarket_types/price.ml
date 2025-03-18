open! Core
open! Async

(* Represents an amount of $0.0001 per unit of t.
   More accurately, 10 ** (magnitude_factor) t = 1 dollar. *)
type t = int [@@deriving sexp]

let magnitude_factor = 4

let of_dollars dollars =
  dollars *. Float.int_pow 10. magnitude_factor
  |> Float.round_nearest
  |> Float.to_int
;;

let to_cents_hum t ~decimals =
  (* Dividing by 1e[magnitude_factor] gives you back dollars.
     Multiplying by 1e2 gives you cents. Hence, the following. *)
  Float.of_int t /. Float.int_pow 10. (magnitude_factor - 2)
  |> Float.to_string_hum ~decimals
;;

let of_json json = json |> Yojson.Basic.Util.to_float |> of_dollars
