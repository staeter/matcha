module Signup exposing (..)


-- imports

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

import Url exposing (..)
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
    , signup : Form (Result String String)
  }

signupForm : Form (Result String String)
signupForm =
  Form.form answerDecoder "http://localhost/control/signup.php"
  |> Form.textField "pseudo" Array.empty
  |> Form.textField "lastname" Array.empty
  |> Form.textField "firstname" Array.empty
  |> Form.textField "email" Array.empty
  |> Form.passwordField "password" Array.empty
  |> Form.passwordField "confirm" Array.empty


-- update

type Msg
  = NoOp
  | SignupForm (Form.Msg (Result String String))

update : Msg -> Model a -> (Model a, Cmd Msg)
update msg model =
  case msg of
    SignupForm formMsg ->
      let
        (newForm, formCmd, response) = Form.update formMsg model.signup
      in
        case response of
          Just result ->
            case result of
              Ok (Ok message) ->
                ( { model | signup = newForm } |> Alert.successAlert message
                , Nav.pushUrl model.key "/signin"
                )
              Ok (Err message) ->
                ( { model | signup = newForm } |> Alert.invalidImputAlert message, Cmd.none)
              Err _ ->
                ( { model | signup = newForm } |> Alert.serverNotReachedAlert, Cmd.none)
          Nothing ->
            ( { model | signup = newForm }
            , formCmd |> Cmd.map SignupForm
            )
            
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
            [ Form.view model.signup |> Html.map SignupForm
            , a [ href "/signin" ]
                [ text "You alredy have an account?" ]
            ]
