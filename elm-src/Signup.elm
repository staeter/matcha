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
  , header : Header.Model
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
  , header = Header.init url key
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
  -- other modules msgs
  | HeaderMsg Header.Msg
  -- local msgs
  | Input_pseudo String
  | Input_firstname String
  | Input_lastname String
  | Input_email String
  | Input_password String
  | Input_confirm String
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

    Input_lastname lastname ->
      ( { model | lastname = lastname }
      , Cmd.none
      )

    Input_firstname firstname ->
      ( { model | firstname = firstname }
      , Cmd.none
      )

    Input_email email ->
      ( { model | email = email }
      , Cmd.none
      )

    Input_password password ->
      ( { model | password = password }
      , Cmd.none
      )

    Input_confirm confirm ->
      ( { model | confirm = confirm }
      , Cmd.none
      )

    _ ->
       (model, Cmd.none)


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
      ]
