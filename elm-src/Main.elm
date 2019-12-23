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

import Browser exposing (application, UrlRequest)
import Html exposing (..)
import Url exposing (..)
import Browser.Navigation as Nav exposing (..)


-- modules

import Signin exposing (..)


-- model

type alias Model =
  { signin : Signin.Model
  }

init : () -> Url -> Nav.Key -> (Model, Cmd Msg)
init _ _ _ =
  ( { signin = Signin.init
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
  | Signin Signin.Msg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Signin signinMsg ->
      let
        (signinModel, signinCmd) = Signin.update signinMsg model.signin
      in
        ( { model | signin = signinModel }
        , signinCmd |> Cmd.map Signin
        )

    _ ->
       (model, Cmd.none)


-- view

view : Model -> Browser.Document Msg
view model =
  { title = "matcha"
  , body =
    [ Signin.view model.signin |> Html.map Signin
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
