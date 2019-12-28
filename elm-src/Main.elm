-- Signin
{- authentify user -} -- signin.php

-- Signup
{- create  an user and send an email -} -- signup.php

-- Browse
{- get users list and default filters -} -- default_filters.php
{- send filters and get users list back -} -- fileter.php
{- get next page of users -} -- next_page.php
{- get last page of users -} -- last_page.php
{- like a user -} -- like.php

-- User
{- get all infos of an user -} -- user.php

-- Account
{- get current settings -}  -- current_settings.php
{- update settings -} -- update_settings.php
{- update password -} -- update_password.php

-- Chat
{- get list of chats and the amout of unread messages -} -- chats.php
{- get list of messages exchanged with a user -} -- chat.php
{- send a new message -} -- message.php

-- Retreive
{- update password -} -- retreive_password.php

-- Confirm
{- confirm new account -} -- confirm_account.php

-- Header
{- get amount of unread messages -} -- unread_messages.php
{- get amount of unread notifications -} -- unread_notifications.php

-- Notif
{- get notif list -} -- notifs.php

-- Other
{- sign out -} -- signout.php

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
  , signin : Signin.Data
  , signup : Signup.Model
  , browse : Browse.Model
  }

init : () -> Url -> Nav.Key -> (Model, Cmd Msg)
init flags url key =
  ( { url = url
    , key = key
    , header = Header.init url key
    , signin = Signin.data
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
        (signinModel, signinCmd, signinHeaderFun) = Signin.update signinMsg model
      in
        ( { signinModel | header = signinHeaderFun model.header }
        , signinCmd |> Cmd.map SigninMsg
        )

    SignupMsg signupMsg ->
      let
        (signupModel, signupCmd, signupHeaderFun) = Signup.update signupMsg model.signup
      in
        ( { model | signup = signupModel, header = signupHeaderFun model.header }
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
          Signin.view model |> Html.map SigninMsg

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
