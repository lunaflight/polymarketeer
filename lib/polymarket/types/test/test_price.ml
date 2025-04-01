open! Core
open Polymarket_types

let of_float_and_print dollars =
  let dollar = Dollar.of_float dollars in
  print_s [%message "Underlying representation" (dollar : Dollar.t)];
  List.range 0 3
  |> List.iter ~f:(fun decimals ->
    let cents_hum = Dollar.to_cents_hum dollar ~decimals in
    print_endline
      [%string
        "Cents representation to %{decimals#Int} places: %{cents_hum#String}"])
;;

let%expect_test "price with 4dp = represented correctly" =
  of_float_and_print 1.2345;
  [%expect
    {|
    ("Underlying representation" (dollar 12345))
    Cents representation to 0 places: 123
    Cents representation to 1 places: 123.5
    Cents representation to 2 places: 123.45
    |}]
;;

let%expect_test "price with 5dp, last place > 5 = rounded up" =
  of_float_and_print 1.23456;
  [%expect
    {|
    ("Underlying representation" (dollar 12346))
    Cents representation to 0 places: 123
    Cents representation to 1 places: 123.5
    Cents representation to 2 places: 123.46
    |}]
;;

let%expect_test "price with 5dp, last place = 5 = rounded up" =
  of_float_and_print 1.23455;
  [%expect
    {|
    ("Underlying representation" (dollar 12346))
    Cents representation to 0 places: 123
    Cents representation to 1 places: 123.5
    Cents representation to 2 places: 123.46
    |}]
;;

let%expect_test "price with 5dp, last place < 5 = rounded down" =
  of_float_and_print 1.23454;
  [%expect
    {|
    ("Underlying representation" (dollar 12345))
    Cents representation to 0 places: 123
    Cents representation to 1 places: 123.5
    Cents representation to 2 places: 123.45
    |}]
;;

let%expect_test "price with many dps = rounded correctly" =
  of_float_and_print 1.2345678901234567890;
  [%expect
    {|
    ("Underlying representation" (dollar 12346))
    Cents representation to 0 places: 123
    Cents representation to 1 places: 123.5
    Cents representation to 2 places: 123.46
    |}]
;;

let%expect_test "price with <4 dps = represented correctly" =
  of_float_and_print 0.234;
  [%expect
    {|
    ("Underlying representation" (dollar 2340))
    Cents representation to 0 places: 23
    Cents representation to 1 places: 23.4
    Cents representation to 2 places: 23.40
    |}]
;;

let%expect_test "price = 0 = represented correctly" =
  of_float_and_print 0.0;
  [%expect
    {|
    ("Underlying representation" (dollar 0))
    Cents representation to 0 places: 0
    Cents representation to 1 places: 0.0
    Cents representation to 2 places: 0.00
    |}]
;;

let%expect_test "price has no decimal point = represented correctly" =
  of_float_and_print 12.;
  [%expect
    {|
    ("Underlying representation" (dollar 120000))
    Cents representation to 0 places: 1_200
    Cents representation to 1 places: 1_200.0
    Cents representation to 2 places: 1_200.00
    |}]
;;
