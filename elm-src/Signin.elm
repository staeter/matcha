module Signin exposing (..)


-- imports

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

import Http exposing (..)

import Json.Decode as Decode exposing (..)
import Json.Decode.Field as Field exposing (..)


-- modules


-- model

type alias Model =
  { pseudo : String
  , password : String
  }

init : Model
init =
  { pseudo = ""
  , password = ""
  }


-- update

type Msg
  = NoOp
  | Input_pseudo String
  | Input_password String
  | Submit
  | Answer (Result Http.Error (Result String String))

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
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

    _ ->
       (model, Cmd.none)


-- decoder

answerDecoder : Decoder (Result String String)
answerDecoder =
  Field.require "status" resultDecoder <| \status ->
  Field.require "message" Decode.string <| \message ->

  Decode.succeed (status message)

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
