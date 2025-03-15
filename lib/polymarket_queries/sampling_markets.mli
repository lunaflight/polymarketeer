open! Core
open! Async
open Polymarket_types

(** Queries Polymarket for all open (sampling) markets. *)
val query : unit -> Market.t list Deferred.t

module For_testing : sig
  val uri : next_cursor:Next_cursor.t -> Uri.t
end
