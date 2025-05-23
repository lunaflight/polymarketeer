open! Core
open! Async
open Asset_management
open Polymarket_types

let _0_tokens_and_1_dollar = Portfolio.init ~money_owned:(Dollar.of_float 1.)

let%expect_test "initialisation = no tokens and money stored" =
  let portfolio = _0_tokens_and_1_dollar in
  print_s [%message (portfolio : Portfolio.t)];
  [%expect {| (portfolio ((token_ids_owned ()) (money_owned 10000))) |}];
  Deferred.return ()
;;

let%expect_test "adding money = ok" =
  let portfolio =
    Portfolio.add _0_tokens_and_1_dollar ~money:(Dollar.of_float 0.5)
  in
  print_s [%message (portfolio : Portfolio.t)];
  [%expect {| (portfolio ((token_ids_owned ()) (money_owned 15000))) |}];
  Deferred.return ()
;;

let%expect_test "removing money less than owned = ok" =
  let portfolio =
    Portfolio.remove _0_tokens_and_1_dollar ~money:(Dollar.of_float 0.5)
  in
  print_s [%message (portfolio : Portfolio.t)];
  [%expect {| (portfolio ((token_ids_owned ()) (money_owned 5000))) |}];
  Deferred.return ()
;;

let%expect_test "removing money equal to owned = ok" =
  let portfolio =
    Portfolio.remove _0_tokens_and_1_dollar ~money:(Dollar.of_float 1.)
  in
  print_s [%message (portfolio : Portfolio.t)];
  [%expect {| (portfolio ((token_ids_owned ()) (money_owned 0))) |}];
  Deferred.return ()
;;

let%expect_test "removing money more than owned = capped at zero" =
  let portfolio =
    Portfolio.remove _0_tokens_and_1_dollar ~money:(Dollar.of_float 5.)
  in
  print_s [%message (portfolio : Portfolio.t)];
  [%expect {| (portfolio ((token_ids_owned ()) (money_owned 0))) |}];
  Deferred.return ()
;;

let _2_tokens_and_0_dollars =
  Portfolio.buy
    _0_tokens_and_1_dollar
    ~token_id:"token_1"
    ~count:2
    ~price:(Dollar.of_float 0.5)
  |> Transaction_failure.result_ok_exn
;;

let%expect_test "buy with sufficient money = tokens stored and money deducted" =
  let portfolio = _2_tokens_and_0_dollars in
  print_s [%message (portfolio : Portfolio.t)];
  [%expect {| (portfolio ((token_ids_owned ((token_1 2))) (money_owned 0))) |}];
  Deferred.return ()
;;

let%expect_test "too many tokens = error" =
  let portfolio =
    _0_tokens_and_1_dollar
    |> Portfolio.buy ~token_id:"token_1" ~count:5 ~price:(Dollar.of_float 1.)
  in
  print_s [%message (portfolio : (Portfolio.t, Transaction_failure.t) Result.t)];
  [%expect
    {| (portfolio (Error (Not_enough_money ((cost 50000) (money_owned 10000))))) |}];
  Deferred.return ()
;;

let%expect_test "tokens too expensive = error" =
  let portfolio =
    _0_tokens_and_1_dollar
    |> Portfolio.buy ~token_id:"token_1" ~count:1 ~price:(Dollar.of_float 2.)
  in
  print_s [%message (portfolio : (Portfolio.t, Transaction_failure.t) Result.t)];
  [%expect
    {| (portfolio (Error (Not_enough_money ((cost 20000) (money_owned 10000))))) |}];
  Deferred.return ()
;;

let%expect_test "buy zero tokens = ok" =
  let portfolio =
    _0_tokens_and_1_dollar
    |> Portfolio.buy ~token_id:"token_1" ~count:0 ~price:(Dollar.of_float 1.)
  in
  print_s [%message (portfolio : (Portfolio.t, Transaction_failure.t) Result.t)];
  [%expect
    {| (portfolio (Ok ((token_ids_owned ((token_1 0))) (money_owned 10000)))) |}];
  Deferred.return ()
;;

let%expect_test "sell tokens to non-zero amount = ok" =
  let portfolio =
    _2_tokens_and_0_dollars
    |> Portfolio.sell ~token_id:"token_1" ~count:1 ~price:(Dollar.of_float 0.5)
  in
  print_s [%message (portfolio : (Portfolio.t, Transaction_failure.t) Result.t)];
  [%expect
    {| (portfolio (Ok ((token_ids_owned ((token_1 1))) (money_owned 5000)))) |}];
  Deferred.return ()
;;

let%expect_test "sell tokens to zero = removed from portfolio" =
  let portfolio =
    _2_tokens_and_0_dollars
    |> Portfolio.sell ~token_id:"token_1" ~count:2 ~price:(Dollar.of_float 0.5)
  in
  print_s [%message (portfolio : (Portfolio.t, Transaction_failure.t) Result.t)];
  [%expect {| (portfolio (Ok ((token_ids_owned ()) (money_owned 10000)))) |}];
  Deferred.return ()
;;

let%expect_test "sell unowned token = error" =
  let portfolio =
    _2_tokens_and_0_dollars
    |> Portfolio.sell ~token_id:"token_2" ~count:1 ~price:(Dollar.of_float 0.5)
  in
  print_s [%message (portfolio : (Portfolio.t, Transaction_failure.t) Result.t)];
  [%expect {| (portfolio (Error (Token_not_owned token_2))) |}];
  Deferred.return ()
;;

let%expect_test "sell too many tokens = error" =
  let portfolio =
    _2_tokens_and_0_dollars
    |> Portfolio.sell ~token_id:"token_1" ~count:2 ~price:(Dollar.of_float 0.5)
  in
  print_s [%message (portfolio : (Portfolio.t, Transaction_failure.t) Result.t)];
  [%expect {| (portfolio (Ok ((token_ids_owned ()) (money_owned 10000)))) |}];
  Deferred.return ()
;;

let%expect_test "sell no tokens = ok" =
  let portfolio =
    _2_tokens_and_0_dollars
    |> Portfolio.sell ~token_id:"token_1" ~count:0 ~price:(Dollar.of_float 0.5)
  in
  print_s [%message (portfolio : (Portfolio.t, Transaction_failure.t) Result.t)];
  [%expect
    {| (portfolio (Ok ((token_ids_owned ((token_1 2))) (money_owned 0)))) |}];
  Deferred.return ()
;;

let print_portfolio portfolio =
  portfolio |> Portfolio.to_string ~info_of_token_id:None >>| print_endline
;;

let print_portfolio_with_mock_api_call portfolio ~price =
  portfolio
  |> Portfolio.to_string
       ~info_of_token_id:
         (Some
            (fun token_id ->
              Deferred.return
                (price, [%string "%{token_id}'s question"], "outcome")))
  >>| print_endline
;;

let%expect_test "0 tokens without mock = string representation ok" =
  let%map () = print_portfolio _0_tokens_and_1_dollar in
  [%expect {|
    100.00 cents
    No tokens owned
    |}]
;;

let%expect_test "0 tokens with mock = string representation ok" =
  let%map () =
    print_portfolio_with_mock_api_call
      _0_tokens_and_1_dollar
      ~price:(Dollar.of_float 0.5)
  in
  [%expect {|
    100.00 cents
    No tokens owned
    |}]
;;

let%expect_test "1 token without mock = string representation ok" =
  let%map () = print_portfolio _2_tokens_and_0_dollars in
  [%expect {|
    0.00 cents
    2x Token: token_1
    |}]
;;

let%expect_test "1 token with mock = string representation ok" =
  let%map () =
    print_portfolio_with_mock_api_call
      _2_tokens_and_0_dollars
      ~price:(Dollar.of_float 0.5)
  in
  [%expect
    {|
    0.00 cents
    2x Token: token_1's question (outcome) Current Price: 50.00 cents
    |}]
;;

let _2_tokens_and_some_dollars =
  _2_tokens_and_0_dollars
  |> Portfolio.add ~money:(Dollar.of_float 1.5)
  |> Portfolio.buy ~token_id:"token_2" ~count:1 ~price:(Dollar.of_float 0.2)
  |> Transaction_failure.result_ok_exn
;;

let%expect_test "2 tokens without mock = string representation ok" =
  let%map () = print_portfolio _2_tokens_and_some_dollars in
  [%expect
    {|
    130.00 cents
    2x Token: token_1
    1x Token: token_2
    |}]
;;

let%expect_test "2 tokens with mock = string representation ok" =
  let%map () =
    print_portfolio_with_mock_api_call
      _2_tokens_and_some_dollars
      ~price:(Dollar.of_float 0.5)
  in
  [%expect
    {|
    130.00 cents
    2x Token: token_1's question (outcome) Current Price: 50.00 cents
    1x Token: token_2's question (outcome) Current Price: 50.00 cents
    |}]
;;
