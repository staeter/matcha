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

import Alert exposing (..)


-- model

type alias Model a =
  { a
    | url : Url
    , key : Nav.Key
    , signup : Data
    , alert : Maybe Alert
  }

type alias Data =
  { pseudo : String
  , lastname : String
  , firstname : String
  , email : String
  , password : String
  , confirm : String
  }

data : Data
data =
  { pseudo = ""
  , lastname = ""
  , firstname = ""
  , email = ""
  , password = ""
  , confirm = ""
  }


-- update

type Msg
  = NoOp
  | Imput Field
  | Submit
  | Answer (Result Http.Error (Result String String))

type Field
  = Pseudo String
  | Firstname String
  | Lastname String
  | Email String
  | Password String
  | Confirm String

update : Msg -> Model a -> (Model a, Cmd Msg)
update msg model =
  case msg of
    Imput field ->
      case field of
        Pseudo pseudo ->
          let signupData = model.signup in
            ( { model | signup = { signupData | pseudo = pseudo } }
            , Cmd.none
            )

        Lastname lastname ->
          let signupData = model.signup in
            ( { model | signup = { signupData | lastname = lastname } }
            , Cmd.none
            )

        Firstname firstname ->
          let signupData = model.signup in
            ( { model | signup = { signupData | firstname = firstname } }
            , Cmd.none
            )

        Email email ->
          let signupData = model.signup in
            ( { model | signup = { signupData | email = email } }
            , Cmd.none
            )

        Password password ->
          let signupData = model.signup in
            ( { model | signup = { signupData | password = password } }
            , Cmd.none
            )

        Confirm confirm ->
          let signupData = model.signup in
            ( { model | signup = { signupData | confirm = confirm } }
            , Cmd.none
            )


    Submit ->
      ( model
      , Http.post
          { url = "http://localhost/control/signup.php"
          , body =
              multipartBody
                [ stringPart "pseudo" model.signup.pseudo
                , stringPart "lastname" model.signup.lastname
                , stringPart "firstname" model.signup.firstname
                , stringPart "email" model.signup.email
                , stringPart "password" model.signup.password
                , stringPart "confirm" model.signup.confirm
                ]
          , expect = Http.expectJson Answer answerDecoder
          }
      )

    Answer result ->
      case result of
        Ok (Ok message) ->
          ( { model | signup = data } |> Alert.successAlert message
          , Nav.pushUrl model.key "/signin"
          )
        Ok (Err message) ->
          (model |> Alert.invalidImputAlert message, Cmd.none)
        Err _ ->
          (model |> Alert.serverNotReachedAlert, Cmd.none)


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
  Html.form [ onSubmit Submit ]
            [ input [ type_ "text"
                    , placeholder "pseudo"
                    , onInput (Imput << Pseudo)
                    , Html.Attributes.value model.signup.pseudo
                    ] []
            , input [ type_ "text"
                    , placeholder "first name"
                    , onInput (Imput << Firstname)
                    , Html.Attributes.value model.signup.firstname
                    ] []
            , input [ type_ "text"
                    , placeholder "last name"
                    , onInput (Imput << Lastname)
                    , Html.Attributes.value model.signup.lastname
                    ] []
            , input [ type_ "text"
                    , placeholder "email"
                    , onInput (Imput << Email)
                    , Html.Attributes.value model.signup.email
                    ] []
            , input [ type_ "password"
                    , placeholder "password"
                    , onInput (Imput << Password)
                    , Html.Attributes.value model.signup.password
                    ] []
            , input [ type_ "password"
                    , placeholder "confirm"
                    , onInput (Imput << Confirm)
                    , Html.Attributes.value model.signup.confirm
                    ] []
            , button [ type_ "submit" ]
                     [ text "Sign Up" ]
            , a [ href "/signin" ]
                [ text "You alredy have an account?" ]
            ]
