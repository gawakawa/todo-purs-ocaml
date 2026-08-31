module Main where

import Prelude

import Api (Todo, create, delete, list, update)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..), maybe)
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (liftEffect)
import Effect.Exception (throw)
import React.Basic (JSX, keyed)
import React.Basic.DOM as R
import React.Basic.DOM.Client (createRoot, renderRoot)
import React.Basic.DOM.Events (preventDefault, stopPropagation, targetValue)
import React.Basic.Events (handler, handler_)
import React.Basic.Hooks (Component, component, useState', (/\))
import React.Basic.Hooks as React
import React.Basic.Hooks.Aff (useSteppingAff)
import React.Basic.Hooks.ResetToken (useResetToken)
import Web.DOM.NonElementParentNode (getElementById)
import Web.HTML (window)
import Web.HTML.HTMLDocument (toNonElementParentNode)
import Web.HTML.Window (document)

type TodoRowProps =
  { todo :: Todo
  , onToggle :: Effect Unit
  , onDelete :: Effect Unit
  }

todoRow :: TodoRowProps -> JSX
todoRow { todo, onToggle, onDelete } =
  R.li_
    [ R.input
        { type: "checkbox"
        , checked: todo.done
        , onChange: handler_ onToggle
        }
    , R.text todo.title
    , R.button
        { onClick: handler_ onDelete
        , children: [ R.text "delete" ]
        }
    ]

type TodoListProps =
  { todos :: Array Todo
  , onToggle :: Todo -> Effect Unit
  , onDelete :: Todo -> Effect Unit
  }

todoList :: TodoListProps -> JSX
todoList { todos, onToggle, onDelete } =
  R.ul_
    ( map
        ( \todo ->
            keyed (show todo.id) $ todoRow
              { todo
              , onToggle: onToggle todo
              , onDelete: onDelete todo
              }
        )
        todos
    )

mkApp :: Component Unit
mkApp = component "App" \_ ->
  React.do
    resetToken /\ reset <- useResetToken
    result <- useSteppingAff resetToken list
    newTitle /\ setNewTitle <- useState' ""
    let
      handleToggle :: Todo -> Effect Unit
      handleToggle todo = launchAff_ do
        res <- update todo { done = not todo.done }
        case res of
          Left _ -> pure unit
          Right _ -> liftEffect reset

      handleDelete :: Todo -> Effect Unit
      handleDelete todo = launchAff_ do
        res <- delete todo.id
        case res of
          Left _ -> pure unit
          Right _ -> liftEffect reset

      handleSubmit :: Effect Unit
      handleSubmit = launchAff_ do
        res <- create newTitle
        case res of
          Left _ -> pure unit
          Right _ -> liftEffect do
            reset
            setNewTitle ""

      content = case result of
        Nothing -> R.text "Loading..."
        Just (Left err) -> R.text $ "Error: " <> show err
        Just (Right todos) ->
          todoList { todos, onToggle: handleToggle, onDelete: handleDelete }
    pure $ R.div_
      [ R.h1_ [ R.text "Todo" ]
      , R.form
          { onSubmit: handler (preventDefault >>> stopPropagation) \_ -> handleSubmit
          , children:
              [ R.input
                  { value: newTitle
                  , onChange: handler targetValue (maybe (pure unit) setNewTitle)
                  }
              , R.button { type: "submit", children: [ R.text "Add" ] }
              ]
          }
      , content
      ]

main :: Effect Unit
main = do
  app <- mkApp
  doc <- document =<< window
  root <- getElementById "root" $ toNonElementParentNode doc
  case root of
    Nothing -> throw "Could not find container element"
    Just container -> do
      reactRoot <- createRoot container
      renderRoot reactRoot $ app unit
