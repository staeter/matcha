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

import Header exposing (..)
import Signin exposing (..)
import Signup exposing (..)
import Browse exposing (..)


-- model

type alias Model =
  { url : Url
  , key : Nav.Key
  , header : Header.Model
  , signin : Signin.Model
  , signup : Signup.Model
  , browse : Browse.Model
  }

init : () -> Url -> Nav.Key -> (Model, Cmd Msg)
init flags url key =
  ( { url = url
    , key = key
    , header = Header.init url key
    , signin = Signin.init url key
    , signup = Signup.init url key
    , browse = Browse.init
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
  | Browse
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
    , Parser.map Browse (Parser.s "browse")
    ]


-- update

type Msg
  = NoOp
  | InternalLinkClicked Url
  | ExternalLinkClicked String
  | UrlChange Url
  | HeaderMsg Header.Msg
  | SigninMsg Signin.Msg
  | SignupMsg Signup.Msg
  | BrowseMsg Browse.Msg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    HeaderMsg headerMsg ->
      let
        (headerModel, headerCmd) = Header.update headerMsg model.header
      in
        ( { model | header = headerModel }
        , headerCmd |> Cmd.map HeaderMsg
        )

    SigninMsg signinMsg ->
      let
        (signinModel, signinCmd, signinHeaderFun) = Signin.update signinMsg model.signin
      in
        ( { model | signin = signinModel, header = signinHeaderFun model.header }
        , signinCmd |> Cmd.map SigninMsg
        )

    SignupMsg signupMsg ->
      let
        (signupModel, signupCmd) = Signup.update signupMsg model.signup
      in
        ( { model | signup = signupModel }
        , signupCmd |> Cmd.map SignupMsg
        )

    BrowseMsg browseMsg ->
      let
        (browseModel, browseCmd) = Browse.update browseMsg model.browse
      in
        ( { model | browse = browseModel }
        , browseCmd |> Cmd.map BrowseMsg
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
    [ Header.view model.header |> Html.map HeaderMsg
    , Maybe.withDefault (a [ href "/signin" ] [ text "Go to sign in" ]) (page model)
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

        Browse ->
          Browse.view model.browse |> Html.map BrowseMsg
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
