module Alert exposing (..)


-- imports

import Html exposing (..)
import Html.Attributes exposing (..)

import Json.Decode as Decode exposing (..)
import Json.Decode.Field as Field exposing (..)


-- modules


-- model

type alias Model a =
  { a
    | alert : Maybe Alert
  }

type alias Alert =
  { color : String
  , message : String
  }


-- functions

alert : String -> String -> Alert
alert color message =
  { color = color
  , message = message
  }

customAlert : String -> String -> Model a -> Model a
customAlert color message model =
  { model | alert = Just (alert color message) }

serverNotReachedAlert : Model a -> Model a
serverNotReachedAlert model =
  customAlert
    "DarkOrange"
    "Sory we got truble connecting to our server. Please make sure your internet connection is working."
    model

invalidImputAlert : String -> Model a -> Model a
invalidImputAlert serverMessage model =
  customAlert
    "DarkRed"
    serverMessage
    model

successAlert : String -> Model a -> Model a
successAlert serverMessage model =
  customAlert
    "DarkGreen"
    serverMessage
    model


-- decoder

alertDecoder : Decoder Alert
alertDecoder =
  Field.require "color" Decode.string <| \color ->
  Field.require "message" Decode.string <| \message ->

  Decode.succeed
    (alert color message)


-- view

view : Model a -> Html msg
view model =
  case model.alert of
    Just myAlert ->
      div [ style "background-color" myAlert.color
          , style "color" "White"
          ]
          [ text myAlert.message ]
    Nothing ->
      div [] []
