module Main where

import Prelude

import Affjax.ResponseFormat as ResponseFormat
import Affjax.Web (get, printError)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Exception (throw)
import React.Basic.DOM as R
import React.Basic.DOM.Client (createRoot, renderRoot)
import React.Basic.Hooks (Component, component)
import React.Basic.Hooks as React
import React.Basic.Hooks.Aff (useAff)
import Web.DOM.NonElementParentNode (getElementById)
import Web.HTML (window)
import Web.HTML.HTMLDocument (toNonElementParentNode)
import Web.HTML.Window (document)

mkApp :: Component Unit
mkApp = component "App" \_ ->
  React.do
    result <- useAff unit (get ResponseFormat.string "/api/hello")
    let
      message = case result of
        Nothing -> "Loading..."
        Just (Left err) -> "Error: " <> printError err
        Just (Right res) -> res.body
    pure $ R.h1_ [ R.text message ]

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
