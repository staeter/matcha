-- Signin
-- Signup
-- Browse
-- User
-- Account
-- Chat
-- Retreive
-- Confirm
-- Notif

module Main exposing (..)


-- imports

import Browser exposing (..)
import Html exposing (..)
import Url exposing (..)
import Browser.Navigation as Nav exposing (..)


-- modules


-- model

type alias Model =
  {
  }

init : () -> Url -> Nav.Key -> (Model, Cmd Msg)
init _ _ _ =
  ( {
    }
  , Cmd.none
  )


-- url

onUrlRequest : UrlRequest -> Msg
onUrlRequest request =
  NoOp

onUrlChange : Url -> Msg
onUrlChange url =
  NoOp


-- update

type Msg
  = NoOp

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    _ ->
       (model, Cmd.none)


-- view

view : Model -> Browser.Document Msg
view model =
  { title = "matcha"
  , body =
    [ p [] [ text "Hello World!" ]
    ]
  }


-- subscriptions

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none


-- main

main =
  Browser.application
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    , onUrlRequest = onUrlRequest
    , onUrlChange = onUrlChange
    }
