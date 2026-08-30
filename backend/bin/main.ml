let () =
  Dream.run ~port:8080
  @@ Dream.router [ Dream.get "/api/hello" (fun _ -> Dream.respond "Hello from backend") ]
;;
