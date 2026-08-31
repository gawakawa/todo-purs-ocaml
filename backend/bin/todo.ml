module T = Caqti_type

type t =
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

let to_yojson { id; title; completed } =
  `Assoc [ "id", `Int id; "title", `String title; "completed", `Bool completed ]
;;

(* Field access via Yojson.Safe.Util raises on a missing/mistyped field,
   which with_body in handlers.ml turns into a 400. *)
let create_of_yojson json =
  { title = Yojson.Safe.Util.(json |> member "title" |> to_string) }
;;

let update_of_yojson json =
  let open Yojson.Safe.Util in
  { title = json |> member "title" |> to_string
  ; completed = json |> member "completed" |> to_bool
  }
;;
