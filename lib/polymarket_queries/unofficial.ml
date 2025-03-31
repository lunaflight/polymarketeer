open! Core
open! Async
open Polymarket_types

let info_of_token_id token_id =
  let%map price, market =
    Deferred.both
      (Get_price.query ~token_id ~side_of_dealer:Side.Buy)
      (let%bind orderbook = Get_book.query ~token_id in
       let condition_id = Orderbook.market orderbook in
       Get_market.query ~condition_id)
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
