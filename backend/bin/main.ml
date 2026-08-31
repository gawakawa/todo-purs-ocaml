module type DB = Caqti_lwt.CONNECTION

module T = Caqti_type

type todo =
  { id : int
  ; title : string
  ; completed : bool
  }

type create = { title : string }

type update =
  { title : string
  ; completed : bool
  }

let row = T.(t3 int string bool)
let of_row (id, title, completed) = { id; title; completed }

let yojson_of_todo { id; title; completed } =
  `Assoc [ "id", `Int id; "title", `String title; "completed", `Bool completed ]
;;

(* Field access via Yojson.Safe.Util raises on a missing/mistyped field,
   which with_body below turns into a 400. *)
let create_of_yojson json =
  { title = Yojson.Safe.Util.(json |> member "title" |> to_string) }
;;

let update_of_yojson json =
  let open Yojson.Safe.Util in
  { title = json |> member "title" |> to_string
  ; completed = json |> member "completed" |> to_bool
  }
;;

let list_todos =
  let query =
    let open Caqti_request.Infix in
    (T.unit ->* row) "SELECT id, title, completed FROM todo ORDER BY id"
  in
  fun (module Db : DB) ->
    let%lwt todos_or_error = Db.collect_list query () in
    let%lwt todos = Caqti_lwt.or_fail todos_or_error in
    Lwt.return (List.map of_row todos)
;;

let get_todo id =
  let query =
    let open Caqti_request.Infix in
    (T.int ->? row) "SELECT id, title, completed FROM todo WHERE id = ?"
  in
  fun (module Db : DB) ->
    let%lwt todo_or_error = Db.find_opt query id in
    let%lwt todo = Caqti_lwt.or_fail todo_or_error in
    Lwt.return (Option.map of_row todo)
;;

let create_todo title =
  let query =
    let open Caqti_request.Infix in
    (T.string ->! row) "INSERT INTO todo (title) VALUES (?) RETURNING id, title, completed"
  in
  fun (module Db : DB) ->
    let%lwt todo_or_error = Db.find query title in
    let%lwt todo = Caqti_lwt.or_fail todo_or_error in
    Lwt.return (of_row todo)
;;

let update_todo id title completed =
  let query =
    let open Caqti_request.Infix in
    (T.(t3 string bool int) ->? row)
      "UPDATE todo SET title = ?, completed = ? WHERE id = ? RETURNING id, title, completed"
  in
  fun (module Db : DB) ->
    let%lwt todo_or_error = Db.find_opt query (title, completed, id) in
    let%lwt todo = Caqti_lwt.or_fail todo_or_error in
    Lwt.return (Option.map of_row todo)
;;

let delete_todo id =
  let query =
    let open Caqti_request.Infix in
    (T.int ->? T.int) "DELETE FROM todo WHERE id = ? RETURNING id"
  in
  fun (module Db : DB) ->
    let%lwt deleted_or_error = Db.find_opt query id in
    let%lwt deleted = Caqti_lwt.or_fail deleted_or_error in
    Lwt.return (Option.is_some deleted)
;;

let json_todo ?status t = Dream.json ?status (Yojson.Safe.to_string (yojson_of_todo t))

let with_id request f =
  match int_of_string_opt (Dream.param request "id") with
  | None -> Dream.empty `Bad_Request
  | Some id -> f id
;;

let with_body request of_yojson f =
  let%lwt body = Dream.body request in
  match of_yojson (Yojson.Safe.from_string body) with
  | exception _ -> Dream.empty `Bad_Request
  | parsed -> f parsed
;;

let index request =
  let%lwt todos = Dream.sql request list_todos in
  Dream.json (Yojson.Safe.to_string (`List (List.map yojson_of_todo todos)))
;;

let show request =
  with_id request (fun id ->
    match%lwt Dream.sql request (get_todo id) with
    | None -> Dream.empty `Not_Found
    | Some todo -> json_todo todo)
;;

let create request =
  with_body request create_of_yojson (fun { title } ->
    let%lwt todo = Dream.sql request (create_todo title) in
    json_todo ~status:`Created todo)
;;

let update request =
  with_id request (fun id ->
    with_body request update_of_yojson (fun { title; completed } ->
      match%lwt Dream.sql request (update_todo id title completed) with
      | None -> Dream.empty `Not_Found
      | Some todo -> json_todo todo))
;;

let destroy request =
  with_id request (fun id ->
    match%lwt Dream.sql request (delete_todo id) with
    | false -> Dream.empty `Not_Found
    | true -> Dream.empty `No_Content)
;;

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
       [ Dream.get "/api/todos" index
       ; Dream.get "/api/todos/:id" show
       ; Dream.post "/api/todos" create
       ; Dream.put "/api/todos/:id" update
       ; Dream.delete "/api/todos/:id" destroy
       ]
;;
