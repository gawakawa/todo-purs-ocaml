module Api
  ( ApiError(..)
  , Todo
  , create
  , decodeTodo
  , delete
  , list
  , update
  ) where

import Prelude

import Data.Argonaut
  ( Json
  , JsonDecodeError(..)
  , decodeJson
  , encodeJson
  , parseJson
  , stringify
  , toArray
  )
import Data.Bifunctor (lmap)
import Data.Either (Either(..), note)
import Data.Traversable (traverse)
import Effect.Aff (Aff, attempt)
import Effect.Exception (Error)
import Fetch (Method(..), fetch)

type Todo = { id :: Int, title :: String, completed :: Boolean }

data ApiError
  = NetworkError Error
  | UnexpectedStatus Int
  | DecodeError JsonDecodeError

instance Show ApiError where
  show (NetworkError e) = "(NetworkError " <> show e <> ")"
  show (UnexpectedStatus s) = "(UnexpectedStatus " <> show s <> ")"
  show (DecodeError e) = "(DecodeError " <> show e <> ")"

decodeTodo :: Json -> Either JsonDecodeError Todo
decodeTodo = decodeJson

list :: Aff (Either ApiError (Array Todo))
list = attempt (fetch "/api/todos" {}) >>= case _ of
  Left err -> pure (Left (NetworkError err))
  Right { status, text }
    | status /= 200 -> pure (Left (UnexpectedStatus status))
    | otherwise -> do
        body <- text
        pure $ lmap DecodeError do
          json <- parseJson body
          items <- note (TypeMismatch "Array") (toArray json)
          traverse decodeTodo items

create :: String -> Aff (Either ApiError Todo)
create title =
  attempt
    ( fetch "/api/todos"
        { method: POST
        , headers: { "Content-Type": "application/json" }
        , body: stringify (encodeJson { title })
        }
    )
    >>= case _ of
      Left err -> pure (Left (NetworkError err))
      Right { status, text }
        | status /= 201 -> pure (Left (UnexpectedStatus status))
        | otherwise -> do
            body <- text
            pure $ lmap DecodeError (parseJson body >>= decodeTodo)

update :: Todo -> Aff (Either ApiError Todo)
update todo =
  attempt
    ( fetch ("/api/todos/" <> show todo.id)
        { method: PUT
        , headers: { "Content-Type": "application/json" }
        , body: stringify (encodeJson { title: todo.title, completed: todo.completed })
        }
    )
    >>= case _ of
      Left err -> pure (Left (NetworkError err))
      Right { status, text }
        | status /= 200 -> pure (Left (UnexpectedStatus status))
        | otherwise -> do
            body <- text
            pure $ lmap DecodeError (parseJson body >>= decodeTodo)

delete :: Int -> Aff (Either ApiError Unit)
delete id = attempt (fetch ("/api/todos/" <> show id) { method: DELETE }) <#> case _ of
  Left err -> Left (NetworkError err)
  Right { status }
    | status == 204 -> Right unit
    | otherwise -> Left (UnexpectedStatus status)
