open! Core
open Polymarket_types

let of_dollars_and_print dollars =
  let price = Price.of_dollars dollars in
  print_s [%message "Underlying representation" (price : Price.t)];
  List.range 0 3
  |> List.iter ~f:(fun decimals ->
    let cents_hum = Price.to_cents_hum price ~decimals in
    print_endline
      [%string
        "Cents representation to %{decimals#Int} places: %{cents_hum#String}"])
;;

let%expect_test "price with 4dp = represented correctly" =
  of_dollars_and_print 1.2345;
  [%expect
    {|
    ("Underlying representation" (price 12345))
    Cents representation to 0 places: 123
    Cents representation to 1 places: 123.5
    Cents representation to 2 places: 123.45
    |}]
;;

let%expect_test "price with 5dp, last place > 5 = rounded up" =
  of_dollars_and_print 1.23456;
  [%expect
    {|
    ("Underlying representation" (price 12346))
    Cents representation to 0 places: 123
    Cents representation to 1 places: 123.5
    Cents representation to 2 places: 123.46
    |}]
;;

let%expect_test "price with 5dp, last place = 5 = rounded up" =
  of_dollars_and_print 1.23455;
  [%expect
    {|
    ("Underlying representation" (price 12346))
    Cents representation to 0 places: 123
    Cents representation to 1 places: 123.5
    Cents representation to 2 places: 123.46
    |}]
;;

let%expect_test "price with 5dp, last place < 5 = rounded down" =
  of_dollars_and_print 1.23454;
  [%expect
    {|
    ("Underlying representation" (price 12345))
    Cents representation to 0 places: 123
    Cents representation to 1 places: 123.5
    Cents representation to 2 places: 123.45
    |}]
;;

let%expect_test "price with many dps = rounded correctly" =
  of_dollars_and_print 1.2345678901234567890;
  [%expect
    {|
    ("Underlying representation" (price 12346))
    Cents representation to 0 places: 123
    Cents representation to 1 places: 123.5
    Cents representation to 2 places: 123.46
    |}]
;;

let%expect_test "price with <4 dps = represented correctly" =
  of_dollars_and_print 0.234;
  [%expect
    {|
    ("Underlying representation" (price 2340))
    Cents representation to 0 places: 23
    Cents representation to 1 places: 23.4
    Cents representation to 2 places: 23.40
    |}]
;;

let%expect_test "price = 0 = represented correctly" =
  of_dollars_and_print 0.0;
  [%expect
    {|
    ("Underlying representation" (price 0))
    Cents representation to 0 places: 0
    Cents representation to 1 places: 0.0
    Cents representation to 2 places: 0.00
    |}]
;;

let%expect_test "price has no decimal point = represented correctly" =
  of_dollars_and_print 12.;
  [%expect
    {|
    ("Underlying representation" (price 120000))
    Cents representation to 0 places: 1_200
    Cents representation to 1 places: 1_200.0
    Cents representation to 2 places: 1_200.00
    |}]
;;
