open! Core
open! Async

module Id = struct
  module T = struct
    type t = string [@@deriving compare, of_string, sexp]
  end

  include T
  include Comparable.Make (T)

  let arg_type = Command.Arg_type.create of_string
  let usage_hint = "STRING token id"
end

type t =
  { token_id : Id.t
  ; outcome : string
  }
[@@deriving fields ~getters, sexp]

let of_json json ~token_id_key ~outcome_key =
  let open Yojson.Basic.Util in
  { token_id = json |> member token_id_key |> to_string
  ; outcome = json |> member outcome_key |> to_string
  }
;;
