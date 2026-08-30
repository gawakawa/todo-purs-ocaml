let test_greeting () = Alcotest.(check string) "greeting" "Hello, World!" "Hello, World!"

let prop_rev_involutive =
  let open QCheck in
  Test.make ~count:100 ~name:"rev_involutive" (list int) (fun l ->
    List.equal Int.equal l (List.rev (List.rev l)))
;;

let () =
  Alcotest.run
    "hello"
    [ "unit", [ Alcotest.test_case "greeting" `Quick test_greeting ]
    ; "property", List.map QCheck_alcotest.to_alcotest [ prop_rev_involutive ]
    ]
;;
