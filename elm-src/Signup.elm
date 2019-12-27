module Signup exposing (..)


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
  , pseudo : String
  , lastname : String
  , firstname : String
  , email : String
  , password : String
  , confirm : String
  }

init : Url -> Nav.Key -> Model
init url key =
  { url = url
  , key = key
  , pseudo = ""
  , lastname = ""
  , firstname = ""
  , email = ""
  , password = ""
  , confirm = ""
  }


-- update

type Msg
  = NoOp
  | Input_pseudo String
  | Input_firstname String
  | Input_lastname String
  | Input_email String
  | Input_password String
  | Input_confirm String
  | Submit
  | Answer (Result Http.Error (Result String String))

update : Msg -> Model -> (Model, Cmd Msg, (Header.Model -> Header.Model))
update msg model =
  case msg of
    Input_pseudo pseudo ->
      ( { model | pseudo = pseudo }
      , Cmd.none
      , (\hm -> hm)
      )

    Input_lastname lastname ->
      ( { model | lastname = lastname }
      , Cmd.none
      , (\hm -> hm)
      )

    Input_firstname firstname ->
      ( { model | firstname = firstname }
      , Cmd.none
      , (\hm -> hm)
      )

    Input_email email ->
      ( { model | email = email }
      , Cmd.none
      , (\hm -> hm)
      )

    Input_password password ->
      ( { model | password = password }
      , Cmd.none
      , (\hm -> hm)
      )

    Input_confirm confirm ->
      ( { model | confirm = confirm }
      , Cmd.none
      , (\hm -> hm)
      )

    Submit ->
      ( model
      , Http.post
          { url = "http://localhost/control/signup.php"
          , body =
              multipartBody
                [ stringPart "pseudo" model.pseudo
                , stringPart "lastname" model.lastname
                , stringPart "firstname" model.firstname
                , stringPart "email" model.email
                , stringPart "password" model.password
                , stringPart "confirm" model.confirm
                ]
          , expect = Http.expectJson Answer answerDecoder
          }
      , (\hm -> hm)
      )

    Answer result ->
      case result of
        Ok (Ok message) ->
          ( init model.url model.key
          , Nav.pushUrl model.key "/signin"
          , (\hm -> hm |> Header.successAlert message)
          )
        Ok (Err message) ->
          (model, Cmd.none, (\hm -> hm |> Header.invalidImputAlert message))
        Err _ ->
          (model, Cmd.none, (\hm -> hm |> Header.serverNotReachedAlert))


    _ ->
       (model, Cmd.none, (\hm -> hm))


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
  Html.form [ onSubmit Submit ]
            [ input [ type_ "text"
                    , placeholder "pseudo"
                    , onInput Input_pseudo
                    , Html.Attributes.value model.pseudo
                    ] []
            , input [ type_ "text"
                    , placeholder "first name"
                    , onInput Input_firstname
                    , Html.Attributes.value model.firstname
                    ] []
            , input [ type_ "text"
                    , placeholder "last name"
                    , onInput Input_lastname
                    , Html.Attributes.value model.lastname
                    ] []
            , input [ type_ "text"
                    , placeholder "email"
                    , onInput Input_email
                    , Html.Attributes.value model.email
                    ] []
            , input [ type_ "password"
                    , placeholder "password"
                    , onInput Input_password
                    , Html.Attributes.value model.password
                    ] []
            , input [ type_ "password"
                    , placeholder "confirm"
                    , onInput Input_confirm
                    , Html.Attributes.value model.confirm
                    ] []
            , button [ type_ "submit" ]
                     [ text "Sign Up" ]
            , a [ href "/signin" ]
                [ text "You alredy have an account?" ]
            ]
