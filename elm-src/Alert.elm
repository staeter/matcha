module Alert exposing (..)


-- imports

import Html exposing (..)
import Html.Attributes exposing (..)


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

alert : { color : String, message : String } -> Model a -> Model a
alert newMessage model =
  let
    newAlert =
      { color = newMessage.color
      , message = newMessage.message
      }
  in
    { model | alert = Just newAlert }

serverNotReachedAlert : Model a -> Model a
serverNotReachedAlert model =
  alert
    { color = "DarkOrange"
    , message = "Sory we got truble connecting to our server. Please make sure your internet connection is working."
    }
    model

invalidImputAlert : String -> Model a -> Model a
invalidImputAlert serverMessage model =
  alert
    { color = "DarkRed"
    , message = serverMessage
    }
    model

successAlert : String -> Model a -> Model a
successAlert serverMessage model =
  alert
    { color = "DarkGreen"
    , message = serverMessage
    }
    model


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
      div [ style "background-color" "DarkBlue"
          , style "color" "White"
          ]
          [ text "header" ]
