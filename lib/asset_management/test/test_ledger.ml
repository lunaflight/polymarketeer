open! Core
open Asset_management
open Polymarket_types

let _1_person_no_tokens =
  Ledger.add
    Ledger.empty
    ~person:(Person.of_string "person_1")
    ~money:(Dollar.of_float 1.)
;;

let%expect_test "initial ledger = ok" =
  print_s [%message (_1_person_no_tokens : Ledger.t)];
  [%expect
    {| (_1_person_no_tokens ((person_1 ((token_ids_owned ()) (money_owned 10000))))) |}]
;;

let%expect_test "getting portfolio = ok" =
  let portfolio =
    Ledger.portfolio _1_person_no_tokens ~person:(Person.of_string "person_1")
  in
  print_s [%message (portfolio : (Portfolio.t, Transaction_failure.t) Result.t)];
  [%expect {| (portfolio (Ok ((token_ids_owned ()) (money_owned 10000)))) |}]
;;

let%expect_test "getting portfolio of unknown person = error" =
  let portfolio =
    Ledger.portfolio _1_person_no_tokens ~person:(Person.of_string "person_2")
  in
  print_s [%message (portfolio : (Portfolio.t, Transaction_failure.t) Result.t)];
  [%expect {| (portfolio (Error (Person_does_not_exist person_2))) |}]
;;

let%expect_test "adding money = ok" =
  let ledger =
    Ledger.add
      _1_person_no_tokens
      ~person:(Person.of_string "person_1")
      ~money:(Dollar.of_float 1.)
  in
  print_s [%message (ledger : Ledger.t)];
  [%expect
    {| (ledger ((person_1 ((token_ids_owned ()) (money_owned 20000))))) |}]
;;

let%expect_test "adding money to new person = ok" =
  let ledger =
    Ledger.add
      _1_person_no_tokens
      ~person:(Person.of_string "person_2")
      ~money:(Dollar.of_float 1.)
  in
  print_s [%message (ledger : Ledger.t)];
  [%expect
    {|
    (ledger
     ((person_1 ((token_ids_owned ()) (money_owned 10000)))
      (person_2 ((token_ids_owned ()) (money_owned 10000)))))
    |}]
;;

let%expect_test "removing owned money = ok" =
  let ledger =
    Ledger.remove
      _1_person_no_tokens
      ~person:(Person.of_string "person_1")
      ~money:(Dollar.of_float 0.5)
  in
  print_s [%message (ledger : (Ledger.t, Transaction_failure.t) Result.t)];
  [%expect
    {| (ledger (Ok ((person_1 ((token_ids_owned ()) (money_owned 5000)))))) |}]
;;

let%expect_test "removing money to zero = ok" =
  let ledger =
    Ledger.remove
      _1_person_no_tokens
      ~person:(Person.of_string "person_1")
      ~money:(Dollar.of_float 1.)
  in
  print_s [%message (ledger : (Ledger.t, Transaction_failure.t) Result.t)];
  [%expect
    {| (ledger (Ok ((person_1 ((token_ids_owned ()) (money_owned 0)))))) |}]
;;

let%expect_test "removing more money than owned = ok" =
  let ledger =
    Ledger.remove
      _1_person_no_tokens
      ~person:(Person.of_string "person_1")
      ~money:(Dollar.of_float 5.)
  in
  print_s [%message (ledger : (Ledger.t, Transaction_failure.t) Result.t)];
  [%expect
    {| (ledger (Ok ((person_1 ((token_ids_owned ()) (money_owned 0)))))) |}]
;;

let%expect_test "removing money to unknown person = error" =
  let ledger =
    Ledger.remove
      _1_person_no_tokens
      ~person:(Person.of_string "person_2")
      ~money:(Dollar.of_float 1.)
  in
  print_s [%message (ledger : (Ledger.t, Transaction_failure.t) Result.t)];
  [%expect {| (ledger (Error (Person_does_not_exist person_2))) |}]
;;

let _1_person_with_tokens =
  Ledger.buy
    _1_person_no_tokens
    ~person:(Person.of_string "person_1")
    ~token_id:"token_1"
    ~price:(Dollar.of_float 1.)
    ~count:1
  |> Transaction_failure.result_ok_exn
;;

(* No further testing is done, as [test_portfolio.ml] handles the underlying
   operations. *)
let%expect_test "buying tokens = ok" =
  print_s [%message (_1_person_with_tokens : Ledger.t)];
  [%expect
    {|
    (_1_person_with_tokens
     ((person_1 ((token_ids_owned ((token_1 1))) (money_owned 0)))))
    |}]
;;

let%expect_test "buying tokens for unknown person = error" =
  let ledger =
    Ledger.buy
      _1_person_no_tokens
      ~person:(Person.of_string "person_2")
      ~token_id:"token_1"
      ~price:(Dollar.of_float 1.)
      ~count:1
  in
  print_s [%message (ledger : (Ledger.t, Transaction_failure.t) Result.t)];
  [%expect {| (ledger (Error (Person_does_not_exist person_2))) |}]
;;

(* No further testing is done, as [test_portfolio.ml] handles the underlying
   operations. *)
let%expect_test "selling tokens = ok" =
  let ledger =
    Ledger.sell
      _1_person_with_tokens
      ~person:(Person.of_string "person_1")
      ~token_id:"token_1"
      ~price:(Dollar.of_float 0.5)
      ~count:1
  in
  print_s [%message (ledger : (Ledger.t, Transaction_failure.t) Result.t)];
  [%expect
    {| (ledger (Ok ((person_1 ((token_ids_owned ()) (money_owned 5000)))))) |}]
;;

let%expect_test "selling tokens for unknown person = error" =
  let ledger =
    Ledger.sell
      _1_person_no_tokens
      ~person:(Person.of_string "person_2")
      ~token_id:"token_1"
      ~price:(Dollar.of_float 1.)
      ~count:1
  in
  print_s [%message (ledger : (Ledger.t, Transaction_failure.t) Result.t)];
  [%expect {| (ledger (Error (Person_does_not_exist person_2))) |}]
;;

let%expect_test "empty ledger = string representation ok" =
  Ledger.empty |> Ledger.to_string |> print_endline;
  [%expect {| No people in ledger |}]
;;

let%expect_test "ledger with 1 person = string representation ok" =
  _1_person_with_tokens |> Ledger.to_string |> print_endline;
  [%expect
    {|
    person_1's Portfolio:
    0.00 cents
    1x Token: token_1
    |}]
;;

let _2_people_with_tokens =
  Ledger.add
    _1_person_with_tokens
    ~person:(Person.of_string "person_2")
    ~money:(Dollar.of_float 2.5)
;;

let%expect_test "ledger with 2 people = string representation ok" =
  _2_people_with_tokens |> Ledger.to_string |> print_endline;
  [%expect
    {|
    person_1's Portfolio:
    0.00 cents
    1x Token: token_1

    person_2's Portfolio:
    250.00 cents
    No tokens owned
    |}]
;;
