open! Core
open! Async

module Id : sig
  (** This is represents a unique ID for a market. It is often called a
      condition ID in the Polymarket documentation. *)
  type t = string [@@deriving sexp]
end

(** This type encapsulates a [Market].

    See: https://docs.polymarket.com/#get-markets. *)
type t =
  { closed : bool
  ; condition_id : Id.t
  ; description : string
  ; (* This is an [option] as it could be [null] in responses. *)
    end_date : Time_float_unix.t option
  ; icon : Uri_sexp.t
  ; question : string
  ; tokens : Token.t list
  }
[@@deriving fields ~getters, sexp]

(** Fetches and interprets a [Market] from a [Yojson.Basic.t]
    dictionary.

    Each labelled argument is either
    1) A string, which is the key to locate that data or
    2) A tuple, the first string being the key to locate that data,
    and the second function being how to interpret that data as a custom
    type. *)
val of_json
  :  Yojson.Basic.t
  -> closed_key:string
  -> condition_id_key:string
  -> description_key:string
  -> end_date:string * (Yojson.Basic.t -> Time_float.t)
  -> icon:string * (Yojson.Basic.t -> Uri.t)
  -> question_key:string
  -> tokens:string * (Yojson.Basic.t -> Token.t list)
  -> t
