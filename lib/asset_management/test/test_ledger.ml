open! Core
open Asset_management
open Polymarket_types

let initial_ledger =
  Ledger.add
    Ledger.empty
    ~person:(Person.of_string "person_1")
    ~money:(Dollar.of_float 1.)
;;

let%expect_test "initial ledger = ok" =
  print_s [%message (initial_ledger : Ledger.t)];
  [%expect
    {| (initial_ledger ((person_1 ((token_ids_owned ()) (money_owned 10000))))) |}]
;;

let%expect_test "getting portfolio = ok" =
  let portfolio =
    Ledger.portfolio initial_ledger ~person:(Person.of_string "person_1")
  in
  print_s [%message (portfolio : (Portfolio.t, Transaction_failure.t) Result.t)];
  [%expect {| (portfolio (Ok ((token_ids_owned ()) (money_owned 10000)))) |}]
;;

let%expect_test "getting portfolio of unknown person = error" =
  let portfolio =
    Ledger.portfolio initial_ledger ~person:(Person.of_string "person_2")
  in
  print_s [%message (portfolio : (Portfolio.t, Transaction_failure.t) Result.t)];
  [%expect {| (portfolio (Error (Person_does_not_exist person_2))) |}]
;;

let%expect_test "adding money = ok" =
  let ledger =
    Ledger.add
      initial_ledger
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
      initial_ledger
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
      initial_ledger
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
      initial_ledger
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
      initial_ledger
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
      initial_ledger
      ~person:(Person.of_string "person_2")
      ~money:(Dollar.of_float 1.)
  in
  print_s [%message (ledger : (Ledger.t, Transaction_failure.t) Result.t)];
  [%expect {| (ledger (Error (Person_does_not_exist person_2))) |}]
;;

let ledger_with_tokens =
  Ledger.buy
    initial_ledger
    ~person:(Person.of_string "person_1")
    ~token_id:"token_1"
    ~price:(Dollar.of_float 1.)
    ~count:1
  |> Result.ok
  |> Option.value_exn
;;

(* No further testing is done, as [test_portfolio.ml] handles the underlying
   operations. *)
let%expect_test "buying tokens = ok" =
  print_s [%message (ledger_with_tokens : Ledger.t)];
  [%expect
    {|
    (ledger_with_tokens
     ((person_1 ((token_ids_owned ((token_1 1))) (money_owned 0)))))
    |}]
;;

let%expect_test "buying tokens for unknown person = error" =
  let ledger =
    Ledger.buy
      initial_ledger
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
      ledger_with_tokens
      ~person:(Person.of_string "person_1")
      ~token_id:"token_1"
      ~price:(Dollar.of_float 0.5)
      ~count:1
  in
  print_s [%message (ledger : (Ledger.t, Transaction_failure.t) Result.t)];
  [%expect
    {|
    (ledger
     (Ok ((person_1 ((token_ids_owned ((token_1 0))) (money_owned 5000))))))
    |}]
;;

let%expect_test "selling tokens for unknown person = error" =
  let ledger =
    Ledger.sell
      initial_ledger
      ~person:(Person.of_string "person_2")
      ~token_id:"token_1"
      ~price:(Dollar.of_float 1.)
      ~count:1
  in
  print_s [%message (ledger : (Ledger.t, Transaction_failure.t) Result.t)];
  [%expect {| (ledger (Error (Person_does_not_exist person_2))) |}]
;;
