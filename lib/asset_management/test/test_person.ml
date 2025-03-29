open! Core
open Asset_management

let%expect_test "usage hint = ok" =
  print_endline Person.usage_hint;
  [%expect {| STRING person name |}]
;;
