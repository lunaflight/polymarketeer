open! Core
open Polymarket_types

let%expect_test "usage hint = ok" =
  print_endline Side.usage_hint;
  [%expect {| buy|sell |}]
;;
