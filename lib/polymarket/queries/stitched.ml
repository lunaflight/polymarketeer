open! Core
open! Async
open Polymarket_types

let info_of_token_id token_id =
  let%map price, market =
    Deferred.both
      (Clob.get_price ~token_id ~side_of_dealer:Side.Buy)
      (let%bind orderbook = Clob.get_book ~token_id in
       let condition_id = Orderbook.market orderbook in
       Clob.get_market ~condition_id)
  in
  let question = Market.question market in
  let outcome =
    (* [List.find_exn] is safe as we expect all API calls to Polymarket to
       return sane results.
       Token ID -> Orderbook -> Market ID -> Market
       The market must contain the token ID as it is derived from the token ID.
    *)
    Market.tokens market
    |> List.find_exn ~f:(fun token ->
      Token.token_id token |> Token.Id.equal token_id)
    |> Token.outcome
  in
  price, question, outcome
;;
