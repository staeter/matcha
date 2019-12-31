module Signin exposing (..)


-- imports

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

import Http exposing (..)

import Url exposing (..)
import Url.Parser as Parser exposing (..)
import Browser.Navigation as Nav exposing (..)

import Json.Decode as Decode exposing (..)
import Json.Decode.Field as Field exposing (..)

import Array exposing (..)


-- modules

import Alert exposing (..)
import Form exposing (..)


-- model

type alias Model a =
  { a
    | url : Url
    , key : Nav.Key
    , alert : Maybe Alert
    , signin : Form (Result String String)
  }

signinForm : Form (Result String String)
signinForm =
  Form.form answerDecoder "http://localhost/control/signin.php"
  |> Form.field "pseudo" (Text "") Array.empty
  |> Form.field "password" (Password "") Array.empty


-- update

type Msg
  = NoOp
  | SigninForm (Form.Msg (Result String String))
  -- | Submit
  -- | Answer (Result Http.Error (Result String String))

update : Msg -> Model a -> (Model a, Cmd Msg)
update msg model =
  case msg of
    SigninForm formMsg ->
      let
        (newForm, formCmd, response) = Form.update formMsg model.signin
      in
        case response of
          Just result ->
            case result of
              Ok (Ok message) ->
                ( { model | signin = newForm } |> Alert.successAlert message
                , Cmd.batch
                  [ Nav.pushUrl model.key "/browse"
                  , formCmd |> Cmd.map SigninForm
                  ]
                )
              Ok (Err message) ->
                ( { model | signin = newForm } |> Alert.invalidImputAlert message
                , formCmd |> Cmd.map SigninForm
                )
              Err _ ->
                ( { model | signin = newForm } |> Alert.serverNotReachedAlert
                , formCmd |> Cmd.map SigninForm
                )
          Nothing ->
            ( { model | signin = newForm }
            , formCmd |> Cmd.map SigninForm
            )

    -- Submit ->
    --   ( model
    --   , Http.post
    --       { url = "http://localhost/control/signin.php"
    --       , body =
    --           multipartBody
    --             [ stringPart "pseudo" model.signin.pseudo
    --             , stringPart "password" model.signin.password
    --             ]
    --       , expect = Http.expectJson Answer answerDecoder
    --       }
    --   )
    --
    -- Answer result ->
    --   case result of
    --     Ok (Ok message) ->
    --       ( { model | signin = data } |> Alert.successAlert message
    --       , Nav.pushUrl model.key "/browse"
    --       )
    --     Ok (Err message) ->
    --       (model |> Alert.invalidImputAlert message, Cmd.none)
    --     Err _ ->
    --       (model |> Alert.serverNotReachedAlert, Cmd.none)

    _ ->
       (model, Cmd.none)


-- decoder

answerDecoder : Decoder (Result String String)
answerDecoder =
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


-- view

view : Model a -> Html Msg
view model =
  Html.div []
            [ Form.view model.signin |> Html.map SigninForm
            , a [ href "/signup" ]
                [ text "You don't have any account?" ]
            ]
