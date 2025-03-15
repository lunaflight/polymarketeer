open! Core
open Polymarket_types

let of_string_and_print str =
  let next_cursor = Next_cursor.of_string str in
  print_s [%sexp (next_cursor : Next_cursor.t)]
;;

let%expect_test "empty string = beginning" =
  of_string_and_print "";
  [%expect {| Start |}]
;;

let%expect_test "normal string = next cursor stored" =
  of_string_and_print "NTAw";
  [%expect {| (Next NTAw) |}]
;;

let%expect_test "quoted string = stripped and stored" =
  of_string_and_print "\"NTAw\"";
  [%expect {| (Next NTAw) |}]
;;

let%expect_test "string LTE= = no next cursor" =
  of_string_and_print "LTE=";
  [%expect {| End |}]
;;
