open! Core
open Ledger
open Polymarket_types

let _0_tokens_and_1_dollar = Portfolio.init ~money_owned:(Dollar.of_float 1.)

let%expect_test "initialisation = no tokens and money stored" =
  let portfolio = _0_tokens_and_1_dollar in
  print_s [%message (portfolio : Portfolio.t)];
  [%expect {| (portfolio ((token_ids_owned ()) (money_owned 10000))) |}]
;;

let _1_token_and_0_dollars =
  Portfolio.buy
    _0_tokens_and_1_dollar
    ~token_id:"token_1"
    ~count:1
    ~price:(Dollar.of_float 1.)
  |> Result.ok
  |> Option.value_exn
;;

let%expect_test "buy with sufficient money = tokens stored and money deducted" =
  let portfolio = _1_token_and_0_dollars in
  print_s [%message (portfolio : Portfolio.t)];
  [%expect {| (portfolio ((token_ids_owned ((token_1 1))) (money_owned 0))) |}]
;;

let%expect_test "too many tokens = error" =
  let portfolio =
    _0_tokens_and_1_dollar
    |> Portfolio.buy ~token_id:"token_1" ~count:5 ~price:(Dollar.of_float 1.)
  in
  print_s
    [%message
      (portfolio : (Portfolio.t, Portfolio.Transaction_failure.t) Result.t)];
  [%expect
    {| (portfolio (Error (Not_enough_money ((cost 50000) (money_owned 10000))))) |}]
;;

let%expect_test "tokens too expensive = error" =
  let portfolio =
    _0_tokens_and_1_dollar
    |> Portfolio.buy ~token_id:"token_1" ~count:1 ~price:(Dollar.of_float 2.)
  in
  print_s
    [%message
      (portfolio : (Portfolio.t, Portfolio.Transaction_failure.t) Result.t)];
  [%expect
    {| (portfolio (Error (Not_enough_money ((cost 20000) (money_owned 10000))))) |}]
;;

let%expect_test "buy zero tokens = ok" =
  let portfolio =
    _0_tokens_and_1_dollar
    |> Portfolio.buy ~token_id:"token_1" ~count:0 ~price:(Dollar.of_float 1.)
  in
  print_s
    [%message
      (portfolio : (Portfolio.t, Portfolio.Transaction_failure.t) Result.t)];
  [%expect
    {| (portfolio (Ok ((token_ids_owned ((token_1 0))) (money_owned 10000)))) |}]
;;

let%expect_test "sell tokens = ok" =
  let portfolio =
    _1_token_and_0_dollars
    |> Portfolio.sell ~token_id:"token_1" ~count:1 ~price:(Dollar.of_float 0.5)
  in
  print_s
    [%message
      (portfolio : (Portfolio.t, Portfolio.Transaction_failure.t) Result.t)];
  [%expect
    {| (portfolio (Ok ((token_ids_owned ((token_1 0))) (money_owned 5000)))) |}]
;;

let%expect_test "sell unowned token = error" =
  let portfolio =
    _1_token_and_0_dollars
    |> Portfolio.sell ~token_id:"token_2" ~count:1 ~price:(Dollar.of_float 0.5)
  in
  print_s
    [%message
      (portfolio : (Portfolio.t, Portfolio.Transaction_failure.t) Result.t)];
  [%expect {| (portfolio (Error (Token_not_owned token_2))) |}]
;;

let%expect_test "sell too many tokens = error" =
  let portfolio =
    _1_token_and_0_dollars
    |> Portfolio.sell ~token_id:"token_1" ~count:2 ~price:(Dollar.of_float 0.5)
  in
  print_s
    [%message
      (portfolio : (Portfolio.t, Portfolio.Transaction_failure.t) Result.t)];
  [%expect {| (portfolio (Error (Not_enough_tokens token_1))) |}]
;;

let%expect_test "sell no tokens = ok" =
  let portfolio =
    _1_token_and_0_dollars
    |> Portfolio.sell ~token_id:"token_1" ~count:0 ~price:(Dollar.of_float 0.5)
  in
  print_s
    [%message
      (portfolio : (Portfolio.t, Portfolio.Transaction_failure.t) Result.t)];
  [%expect
    {| (portfolio (Ok ((token_ids_owned ((token_1 1))) (money_owned 0)))) |}]
;;
