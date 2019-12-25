module Confirm exposing (..)


-- imports

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


-- modules


-- model

type alias Model =
  {
  }

init : Model
init =
  {
  }


-- update

type Msg
  = NoOp

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    _ ->
       (model, Cmd.none)


-- view

view : Model -> Html Msg
view model =
  text "hello!"
