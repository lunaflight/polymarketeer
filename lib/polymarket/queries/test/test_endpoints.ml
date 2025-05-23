open! Core
open Polymarket_queries
open Polymarket_types

let book_uri_and_print ~token_id =
  Endpoint.book ~token_id |> Endpoint.to_string |> print_string
;;

let%expect_test "url ok" =
  book_uri_and_print ~token_id:"id";
  [%expect {| https://clob.polymarket.com/book?token_id=id |}]
;;

let markets_uri_and_print ~condition_id =
  Endpoint.markets ~condition_id |> Endpoint.to_string |> print_string
;;

let%expect_test "url ok" =
  markets_uri_and_print ~condition_id:"id";
  [%expect {| https://clob.polymarket.com/markets/id |}]
;;

let price_uri_and_print ~token_id ~side =
  Endpoint.price ~token_id ~side |> Endpoint.to_string |> print_string
;;

let%expect_test "buy = url ok" =
  price_uri_and_print ~token_id:"id" ~side:Side.Buy;
  [%expect {| https://clob.polymarket.com/price?token_id=id&side=buy |}]
;;

let%expect_test "sell = url ok" =
  price_uri_and_print ~token_id:"id" ~side:Side.Sell;
  [%expect {| https://clob.polymarket.com/price?token_id=id&side=sell |}]
;;

let sampling_markets_uri_and_print ~next_cursor =
  Endpoint.sampling_markets ~next_cursor |> Endpoint.to_string |> print_string
;;

let%expect_test "normal next cursor = url ok" =
  sampling_markets_uri_and_print ~next_cursor:(Next_cursor.of_string "NTAw");
  [%expect {| https://clob.polymarket.com/sampling-markets?next_cursor=NTAw |}]
;;

let%expect_test "next cursor ending with == = url ok" =
  sampling_markets_uri_and_print ~next_cursor:(Next_cursor.of_string "Abc==");
  [%expect {| https://clob.polymarket.com/sampling-markets?next_cursor=Abc== |}]
;;

let%expect_test "starting next cursor = url either has empty next_cursor or no \
                 parameter"
  =
  sampling_markets_uri_and_print ~next_cursor:Next_cursor.start;
  [%expect {| https://clob.polymarket.com/sampling-markets?next_cursor= |}]
;;

let search_uri_and_print ~search_term =
  Endpoint.search ~search_term |> Endpoint.to_string |> print_string
;;

let%expect_test "url ok" =
  search_uri_and_print ~search_term:"search term";
  [%expect
    {| https://polymarket.com/api/events/global?q=search%20term&events_status=active |}]
;;
