(** This module encapsulates all "unofficial" API calls.
    This usually means stitching together official API calls with
    our own logic to create a useful wrapper for something that does not
    exist. *)

open! Core
open! Async
open Polymarket_types

(** Returns the following in a tuple given a Token ID:
    1) The price of the token
    2) The question associated with the token
    3) The outcome associated with the token (usually yes or no) *)
val info_of_token_id : Token.Id.t -> (Dollar.t * string * string) Deferred.t
