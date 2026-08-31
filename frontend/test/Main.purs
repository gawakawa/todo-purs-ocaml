module Test.Main where

import Prelude

import Api (decodeTodo)
import Data.Argonaut (parseJson)
import Data.Either (Either(..))
import Effect (Effect)
import Test.Unit (suite, test)
import Test.Unit.Assert as Assert
import Test.Unit.Main (runTest)

main :: Effect Unit
main = runTest do
  suite "Api.decodeTodo" do
    test "decodes a todo from JSON" do
      let
        body = """{"id":1,"title":"first todo","done":false}"""
        expected = Right { id: 1, title: "first todo", done: false }
        actual = parseJson body >>= decodeTodo
      Assert.equal expected actual
