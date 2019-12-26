module Header exposing (..)


-- imports

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

import Url exposing (..)
import Url.Parser as Parser exposing (..)
import Browser.Navigation as Nav exposing (..)

import Json.Decode as Decode exposing (..)
import Json.Decode.Field as Field exposing (..)


-- modules


-- model

type alias Model =
  { url : Url
  , key : Nav.Key
  , alert : Maybe Alert
  }

type alias Alert =
  { color : String
  , message : String
  }

init : Url -> Nav.Key -> Model
init url key =
  { url = url
  , key = key
  , alert = Nothing
  }


-- functions

customAlert : { color : String, message : String } -> Model -> Model
customAlert newMessage model =
  let
    newAlert =
      { color = newMessage.color
      , message = newMessage.message
      }
  in
    { model | alert = Just newAlert }

serverNotReachedAlert : Model -> Model
serverNotReachedAlert model =
  customAlert
    { color = "DarkOrange"
    , message = "Sory we got truble connecting to our server. Please make sure your internet connection is working."
    }
    model

invalidImputAlert : String -> Model -> Model
invalidImputAlert serverMessage model =
  customAlert
    { color = "DarkRed"
    , message = serverMessage
    }
    model

successAlert : String -> Model -> Model
successAlert serverMessage model =
  customAlert
    { color = "DarkGreen"
    , message = serverMessage
    }
    model


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
  case model.alert of
    Just myAlert ->
      div [ style "background-color" myAlert.color
          , style "color" "White"
          ]
          [ text myAlert.message ]
    Nothing ->
      div [ style "background-color" "DarkBlue"
          , style "color" "White"
          ]
          [ text "header" ]
