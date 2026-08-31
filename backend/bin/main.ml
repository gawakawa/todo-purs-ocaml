let database_url =
  match Sys.getenv_opt "DATABASE_URL" with
  | Some url -> url
  | None -> failwith "DATABASE_URL environment variable is not set"
;;

let () =
  Dream.run ~port:8080 ~interface:"0.0.0.0"
  @@ Dream.logger
  @@ Dream.sql_pool database_url
  @@ Dream.router
       [ Dream.get "/api/todos" Handlers.index
       ; Dream.get "/api/todos/:id" Handlers.show
       ; Dream.post "/api/todos" Handlers.create
       ; Dream.put "/api/todos/:id" Handlers.update
       ; Dream.delete "/api/todos/:id" Handlers.destroy
       ]
;;
