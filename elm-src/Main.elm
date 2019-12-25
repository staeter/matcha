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
import Html.Attributes exposing (..)
import Url exposing (..)
import Url.Parser as Parser exposing (..)
import Browser.Navigation as Nav exposing (..)


-- modules

import Signin exposing (..)
import Signup exposing (..)


-- model

type alias Model =
  { url : Url
  , key : Nav.Key
  , signin : Signin.Model
  , signup : Signup.Model
  }

init : () -> Url -> Nav.Key -> (Model, Cmd Msg)
init flags url key =
  ( { url = url
    , key = key
    , signin = Signin.init
    , signup = Signup.init
    }
  , Cmd.none
  )


-- url

onUrlRequest : UrlRequest -> Msg
onUrlRequest request =
  case request of
    Browser.Internal url ->
      InternalLinkClicked url

    Browser.External href ->
      ExternalLinkClicked href

onUrlChange : Url -> Msg
onUrlChange url =
  UrlChange url

type Route
  = Signin
  | Signup
  -- | Browse
  -- | User
  -- | Account
  -- | Chat
  -- | Retreive
  -- | Confirm

routeParser : Parser (Route -> a) a
routeParser =
  oneOf
    [ Parser.map Signin (Parser.s "signin")
    , Parser.map Signup (Parser.s "signup")
    ]


-- update

type Msg
  = NoOp
  | InternalLinkClicked Url
  | ExternalLinkClicked String
  | UrlChange Url
  | SigninMsg Signin.Msg
  | SignupMsg Signup.Msg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    SigninMsg signinMsg ->
      let
        (signinModel, signinCmd) = Signin.update signinMsg model.signin
      in
        ( { model | signin = signinModel }
        , signinCmd |> Cmd.map SigninMsg
        )

    SignupMsg signupMsg ->
      let
        (signupModel, signupCmd) = Signup.update signupMsg model.signup
      in
        ( { model | signup = signupModel }
        , signupCmd |> Cmd.map SignupMsg
        )

    InternalLinkClicked url ->
      (model, Nav.pushUrl model.key (Url.toString url) )

    ExternalLinkClicked href ->
      (model, Nav.load href)

    UrlChange url ->
      ({ model | url = url }, Cmd.none)

    _ ->
      (model, Cmd.none)


-- view

view : Model -> Browser.Document Msg
view model =
  { title = "matcha"
  , body =
    [ Maybe.withDefault (a [ href "/signin" ] [ text "Go to sign in" ]) (page model)
    ]
  }

page : Model -> Maybe (Html Msg)
page model =
  Maybe.map
    (\route ->
      case route of
        Signin ->
          Signin.view model.signin |> Html.map SigninMsg

        Signup ->
          Signup.view model.signup |> Html.map SignupMsg
    )
    (Parser.parse routeParser model.url)


-- subscriptions

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none


-- main

main : Program () Model Msg
main =
  Browser.application
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    , onUrlRequest = onUrlRequest
    , onUrlChange = onUrlChange
    }
