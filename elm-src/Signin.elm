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


-- modules

import Header exposing (..)


-- model

type alias Model =
  { url : Url
  , key : Nav.Key
  , header : Header.Model
  , pseudo : String
  , password : String
  }

init : Url -> Nav.Key -> Model
init url key =
  { url = url
  , key = key
  , header = Header.init url key
  , pseudo = ""
  , password = ""
  }


-- update

type Msg
  = NoOp
  -- other modules msgs
  | HeaderMsg Header.Msg
  -- local msgs
  | Input_pseudo String
  | Input_password String
  | Submit
  | Answer (Result Http.Error (Result String String))

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

    Input_pseudo pseudo ->
      ( { model | pseudo = pseudo }
      , Cmd.none
      )

    Input_password password ->
      ( { model | password = password }
      , Cmd.none
      )

    Submit ->
      ( model
      , Http.post
          { url = "/control/signin.php"
          , body =
              multipartBody
                [ stringPart "pseudo" model.pseudo
                , stringPart "password" model.password
                ]
          , expect = Http.expectJson Answer answerDecoder
          }
      )

    Answer result ->
      case result of
        Ok (Ok message) ->
          ( { model
            | pseudo = ""
            , password = ""
            , header = Header.successAlert message model.header
            }
          , Nav.pushUrl model.key "/browse"
          )
        Ok (Err message) ->
          ({ model | header = Header.invalidImputAlert message model.header }, Cmd.none)
        Err _ ->
          ({ model | header = Header.serverNotReachedAlert model.header }, Cmd.none)

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

view : Model -> Html Msg
view model =
  div []
      [ Header.view model.header |> Html.map HeaderMsg
      , Html.form [ onSubmit Submit ]
                  [ input [ type_ "text"
                          , placeholder "pseudo"
                          , onInput Input_pseudo
                          , Html.Attributes.value model.pseudo
                          ] []
                  , input [ type_ "password"
                          , placeholder "password"
                          , onInput Input_password
                          , Html.Attributes.value model.password
                          ] []
                  , button [ type_ "submit" ]
                           [ text "Sign In" ]
                  , a [ href "/signup" ]
                      [ text "You don't have any account?" ]
        ]
      ]
