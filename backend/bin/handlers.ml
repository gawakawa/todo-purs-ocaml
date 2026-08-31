let json_todo ?status t = Dream.json ?status (Yojson.Safe.to_string (Todo.to_yojson t))

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
  let%lwt todos = Dream.sql request Queries.list_todos in
  Dream.json (Yojson.Safe.to_string (`List (List.map Todo.to_yojson todos)))
;;

let show request =
  with_id request (fun id ->
    match%lwt Dream.sql request (Queries.get_todo id) with
    | None -> Dream.empty `Not_Found
    | Some todo -> json_todo todo)
;;

let create request =
  with_body request Todo.create_of_yojson (fun { title } ->
    let%lwt todo = Dream.sql request (Queries.create_todo title) in
    json_todo ~status:`Created todo)
;;

let update request =
  with_id request (fun id ->
    with_body request Todo.update_of_yojson (fun { title; completed } ->
      match%lwt Dream.sql request (Queries.update_todo id title completed) with
      | None -> Dream.empty `Not_Found
      | Some todo -> json_todo todo))
;;

let destroy request =
  with_id request (fun id ->
    match%lwt Dream.sql request (Queries.delete_todo id) with
    | false -> Dream.empty `Not_Found
    | true -> Dream.empty `No_Content)
;;
