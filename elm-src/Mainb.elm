module Mainb exposing (..)


-- imports

import Browser exposing (application, UrlRequest)
import Html exposing (..)
import Html.Attributes exposing (..)

import Url exposing (..)
import Url.Parser as Parser exposing (..)
import Browser.Navigation as Nav exposing (..)

import Json.Decode as Decode exposing (..)
import Json.Decode.Field as Field exposing (..)

import Http exposing (..)

import Array exposing (..)
import Time exposing (..)


-- modules

import Alert exposing (..)
import Form exposing (..)


-- model

type alias Model =
  { url : Url
  , key : Nav.Key
  , alert : Maybe Alert
  , access : Access
  }

type Access
  = User UModel
  | Anonymous AModel

type alias UModel =
  { -- unreadNotifsAmount : Int
  }

type alias AModel =
  { signinForm : Form (Result String String)
  , signupForm : Form (Result String String)
  }


-- initialisations

init : () -> Url -> Nav.Key -> (Model, Cmd Msg)
init flags url key =
  ( { url = url
    , key = key
    , alert = Nothing
    , access = anonymousAccess_init
    }
  , Cmd.none
  )

anonymousAccess_init : Access
anonymousAccess_init = Anonymous
  { signinForm = signinForm_init
  , signupForm = signupForm_init
  }

userAccess_init : Access
userAccess_init = User
  {
  }

signinForm_init : Form (Result String String)
signinForm_init =
  Form.form resultMessageDecoder (OnSubmit "Signin") "http://localhost/control/account_signin.php"
  |> Form.textField "pseudo"
  |> Form.passwordField "password"

signupForm_init : Form (Result String String)
signupForm_init =
  Form.form resultMessageDecoder (OnSubmit "Signup") "http://localhost/control/account_signup.php"
  |> Form.textField "pseudo"
  |> Form.textField "lastname"
  |> Form.textField "firstname"
  |> Form.textField "email"
  |> Form.passwordField "password"
  |> Form.passwordField "confirm"


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
  | Home

routeParser : Parser (Route -> a) a
routeParser =
  Parser.oneOf
    [ Parser.map Home (Parser.top)
    , Parser.map Signin (Parser.s "signin")
    , Parser.map Signup (Parser.s "signup")
    ]


-- update

type Msg
  = NoOp
  | InternalLinkClicked Url
  | ExternalLinkClicked String
  | UrlChange Url
  | SigninForm (Form.Msg (Result String String))
  | SignupForm (Form.Msg (Result String String))

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  let maybeRoute = Parser.parse routeParser model.url in
  case (model.access, maybeRoute, msg) of
    (_, _, InternalLinkClicked url) ->
      (model, Nav.pushUrl model.key (Url.toString url) )

    (_, _, ExternalLinkClicked href) ->
      (model, Nav.load href)

    (_, _, UrlChange url) ->
      ({ model | url = url }, Cmd.none)

    (Anonymous amodel, Just Signin, SigninForm formMsg) ->
      let
        (newForm, formCmd, response) = Form.update formMsg amodel.signinForm
      in
        case response of
          Just result ->
            signinFormResultHandler result model formCmd
          Nothing ->
            ( { model | access = Anonymous { amodel | signinForm = newForm } }
            , formCmd |> Cmd.map SigninForm
            )

    (Anonymous amodel, Just Signup, SignupForm formMsg) ->
      let
        (newForm, formCmd, response) = Form.update formMsg amodel.signupForm
      in
        case response of
          Just result ->
            signupFormResultHandler result model formCmd
          Nothing ->
            ( { model | access = Anonymous { amodel | signupForm = newForm } }
            , formCmd |> Cmd.map SignupForm
            )

    _ -> ( model, Cmd.none )


signinFormResultHandler result model cmd =
  case result of
    Ok (Ok message) ->
      ( { model | access = userAccess_init } |> Alert.successAlert message
      , Cmd.batch
        [ Nav.pushUrl model.key "/"
        , cmd |> Cmd.map SigninForm
        ]
      )
    Ok (Err message) ->
      ( model |> Alert.invalidImputAlert message
      , cmd |> Cmd.map SigninForm
      )
    Err error ->
      ( model |> Alert.serverNotReachedAlert error
      , cmd |> Cmd.map SigninForm
      )

signupFormResultHandler result model cmd =
  case result of
    Ok (Ok message) ->
      ( model |> Alert.successAlert message
      , Cmd.batch
        [ Nav.pushUrl model.key "/signin"
        , cmd |> Cmd.map SignupForm
        ]
      )
    Ok (Err message) ->
      ( model |> Alert.invalidImputAlert message
      , cmd |> Cmd.map SignupForm
      )
    Err error ->
      ( model |> Alert.serverNotReachedAlert error
      , cmd |> Cmd.map SignupForm
      )


-- general decoders

resultMessageDecoder : Decoder (Result String String)
resultMessageDecoder =
  Field.require "result" resultDecoder <| \result ->
  Field.require "message" Decode.string <| \message ->

  Decode.succeed (result message)

resultDecoder : Decoder (String -> Result String String)
resultDecoder =
  Decode.string |> andThen
    (\ str ->
      case str of
        "Success" ->
          Decode.succeed Ok

        "Failure" ->
          Decode.succeed Err

        _ ->
          Decode.fail "statusDecoder failed : not a valid status"
    )

dataAlertDecoder : Decoder a -> Decoder { data: Maybe a, alert: Maybe Alert }
dataAlertDecoder dataDecoder =
  Field.attempt "data" dataDecoder <| \data ->
  Field.attempt "alert" alertDecoder <| \alert ->

  Decode.succeed ({ data = data, alert = alert })


-- view

view : Model -> Browser.Document Msg
view model =
  let maybeRoute = Parser.parse routeParser model.url in
  case (model.access, maybeRoute) of
    (Anonymous amodel, Just Signin) ->
      { title = "matcha - signin"
      , body =
        [ Alert.view model
        , signinView amodel
        ]
      }

    (Anonymous amodel, Just Signup) ->
      { title = "matcha - signup"
      , body =
        [ Alert.view model
        , signupView amodel
        ]
      }

    (Anonymous _, _) ->
      { title = "matcha - 404 page not found"
      , body =
        [ text "You seem lost: "
        , a [ href "/signin" ] [ text "go to signin" ]
        ]
      }

    (User _, Just Home) ->
      { title = "matcha - home"
      , body =
        [ Alert.view model
        , text "this is home"
        ]
      }

    (User _, _) ->
      { title = "matcha - 404 page not found"
      , body =
        [ text "You seem lost: "
        , a [ href "/" ] [ text "go back home" ]
        ]
      }

signinView : AModel -> Html Msg
signinView amodel =
  Html.div []
            [ Form.view amodel.signinForm |> Html.map SigninForm
            , a [ href "/signup" ]
                [ text "You don't have any account?" ]
            ]

signupView : AModel -> Html Msg
signupView amodel =
  Html.div []
            [ Form.view amodel.signupForm |> Html.map SignupForm
            , a [ href "/signin" ]
                [ text "You alredy have an account?" ]
            ]


-- subscriptions

subscriptions : Model -> Sub Msg
subscriptions model =
  case model.access of
    Anonymous amodel ->
      anonymousAccess_sub amodel
    User umodel ->
      Sub.none

anonymousAccess_sub : AModel -> Sub Msg
anonymousAccess_sub amodel =
  [ Form.subscriptions amodel.signinForm |> Sub.map SigninForm
  , Form.subscriptions amodel.signupForm |> Sub.map SignupForm
  ] |> Sub.batch


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
