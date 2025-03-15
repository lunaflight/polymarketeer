open! Core
open Polymarket_queries
open Polymarket_types

let sampling_markets_uri_and_print ~next_cursor =
  Sampling_markets.For_testing.uri ~next_cursor |> Uri.to_string |> print_string
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
