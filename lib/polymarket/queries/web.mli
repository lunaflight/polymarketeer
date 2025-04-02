open! Core
open! Async
open Polymarket_types

(* TODO-someday: Allow searches for ended markets too. *)

(** Returns matching markets given a search term.
    This works exactly the same as typing a search term in the Polymarket
    website by default. That means that only active markets are returned.
    See: https://polymarket.com/. *)
val search_active_markets : search_term:string -> Market.t list Deferred.t
