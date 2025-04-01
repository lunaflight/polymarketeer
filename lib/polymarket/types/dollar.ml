open! Core
open! Async

module T = struct
  (* Represents an amount of $0.0001 per unit of t.
     More accurately, 10 ** (magnitude_factor) t = 1 dollar. *)
  type t = int [@@deriving compare, sexp]

  let magnitude_factor = 4

  let of_float dollars =
    dollars *. Float.int_pow 10. magnitude_factor
    |> Float.round_nearest
    |> Float.to_int
  ;;

  let arg_type =
    Command.Arg_type.create (fun string -> Float.of_string string |> of_float)
  ;;

  let usage_hint = "FLOAT amount in dollars"

  let to_cents_hum t ~decimals =
    (* Dividing by 1e[magnitude_factor] gives you back dollars.
       Multiplying by 1e2 gives you cents. Hence, the following. *)
    Float.of_int t /. Float.int_pow 10. (magnitude_factor - 2)
    |> Float.to_string_hum ~decimals
  ;;

  let of_json_float json = json |> Yojson.Basic.Util.to_float |> of_float

  let of_json_string json =
    json |> Yojson.Basic.Util.to_string |> Float.of_string |> of_float
  ;;

  let zero = of_float 0.
  let ( + ) = Int.( + )
  let ( - ) = Int.( - )
  let ( * ) = Int.( * )
end

include T
include Comparable.Make (T)
