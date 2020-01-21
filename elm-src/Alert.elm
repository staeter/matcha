module Alert exposing (..)


-- imports

import Html exposing (..)
import Html.Attributes exposing (..)

import Http exposing (Error(..))

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

type alias DataAlert a =
  { alert : Maybe Alert, data : Maybe a }


-- functions

alert : String -> String -> Alert
alert color message =
  { color = color
  , message = message
  }

customAlert : String -> String -> Model a -> Model a
customAlert color message model =
  { model | alert = Just (alert color message) }

serverNotReachedAlert : Http.Error -> Model a -> Model a
serverNotReachedAlert error model =
  customAlert
    "DarkOrange"
    (httpErrorMessage error)
    model

--"Sory we got truble connecting to our server. Please make sure your internet connection is working."
httpErrorMessage : Http.Error -> String
httpErrorMessage error =
  case error of
    BadUrl message -> "Sory we got truble connecting to our server. The URL seems to be incorect: " ++ message
    Timeout -> "Sory we got truble connecting to our server. The server do not respond."
    NetworkError -> "Sory we got truble connecting to our server. Please make sure your internet connection is working."
    BadStatus status -> "Sory we got truble connecting to our server. Something happened to our server: Status code " ++ String.fromInt status
    BadBody message -> "Sory we got truble connecting to our server. The body of the request is invalid: " ++ message

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

dataAlertDecoder : Decoder a -> Decoder (DataAlert a)
dataAlertDecoder dataDecoder =
  Field.attempt "data" dataDecoder <| \data ->
  Field.attempt "alert" alertDecoder <| \dAlert ->

  Decode.succeed ({ data = data, alert = dAlert })


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
