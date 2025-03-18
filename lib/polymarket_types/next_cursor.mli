open! Core
open! Async

(** This type encapsulates the logic of [next_cursor] during paginated
    requests.

    See: https://docs.polymarket.com/#get-markets. *)
type t [@@deriving sexp]

val start : t
val is_end : t -> bool

(** Constructs a cursor from a string.

    The empty string [""] corresponds to the first cursor.
    The string ["LTE="] corresponds to the last cursor.
    All other strings are valid IDs for a cursor.

    This function strips any leading and ending ["\""] characters as a form of
    normalisation. It is invalid to use quotes during the requests and hence is
    a safeguard. *)
val of_string : string -> t

(** Converts the cursor to a string that is passable as a request parameter. *)
val to_string : t -> string

(** Interprets a string as the type [t]. *)
val of_json : Yojson.Basic.t -> t
