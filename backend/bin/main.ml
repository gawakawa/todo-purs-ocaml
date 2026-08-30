module type DB = Caqti_lwt.CONNECTION

let count_todos =
  let open Caqti_request.Infix in
  (Caqti_type.unit ->! Caqti_type.int) "SELECT count(*) FROM todo"
;;

let db_health request =
  Dream.sql request (fun (module Db : DB) ->
    Lwt.bind (Db.find count_todos ()) (fun result ->
      Lwt.bind (Caqti_lwt.or_fail result) (fun count ->
        Dream.json (Printf.sprintf {|{"todos":%d}|} count))))
;;

let () =
  Dream.run ~port:8080 ~interface:"0.0.0.0"
  @@ Dream.sql_pool "sqlite3:db.sqlite"
  @@ Dream.router
       [ Dream.get "/api/hello" (fun _ -> Dream.respond "Hello from backend")
       ; Dream.get "/api/db-health" db_health
       ]
;;
