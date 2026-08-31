module type DB = Caqti_lwt.CONNECTION

module T = Caqti_type

let list_todos =
  let query =
    let open Caqti_request.Infix in
    (T.unit ->* Todo.row) "SELECT id, title, completed FROM todo ORDER BY id"
  in
  fun (module Db : DB) ->
    let%lwt todos_or_error = Db.collect_list query () in
    let%lwt todos = Caqti_lwt.or_fail todos_or_error in
    Lwt.return (List.map Todo.of_row todos)
;;

let get_todo id =
  let query =
    let open Caqti_request.Infix in
    (T.int ->? Todo.row) "SELECT id, title, completed FROM todo WHERE id = ?"
  in
  fun (module Db : DB) ->
    let%lwt todo_or_error = Db.find_opt query id in
    let%lwt todo = Caqti_lwt.or_fail todo_or_error in
    Lwt.return (Option.map Todo.of_row todo)
;;

let create_todo title =
  let query =
    let open Caqti_request.Infix in
    (T.string ->! Todo.row)
      "INSERT INTO todo (title) VALUES (?) RETURNING id, title, completed"
  in
  fun (module Db : DB) ->
    let%lwt todo_or_error = Db.find query title in
    let%lwt todo = Caqti_lwt.or_fail todo_or_error in
    Lwt.return (Todo.of_row todo)
;;

let update_todo id title completed =
  let query =
    let open Caqti_request.Infix in
    (T.(t3 string bool int) ->? Todo.row)
      "UPDATE todo SET title = ?, completed = ? WHERE id = ? RETURNING id, title, \
       completed"
  in
  fun (module Db : DB) ->
    let%lwt todo_or_error = Db.find_opt query (title, completed, id) in
    let%lwt todo = Caqti_lwt.or_fail todo_or_error in
    Lwt.return (Option.map Todo.of_row todo)
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
