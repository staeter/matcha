module Main exposing (..)


-- imports

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Browser exposing (..)

import Debug exposing (..)


-- model

type alias Model =
  { sign : Sign
  }

type Sign
  = In Form_SignIn
  | Out
  | Up Form_SignUp

new_signin : Sign
new_signin =
  In { pseudo = "", password = "" }

new_signup : Sign
new_signup =
  Up { pseudo = "", email = "", password = "", confirm = "" }

type alias Form_SignIn =
  { pseudo : String
  , password : String
  }

type alias Form_SignUp =
  { pseudo : String
  , email : String
  , password : String
  , confirm : String
  }

init : () -> (Model, Cmd Msg)
init _ =
  ( { sign = new_signin
    }
  , Cmd.none
  )

-- update

type Msg
  = NoOp
  | Input_Form_SignIn_pseudo String
  | Input_Form_SignIn_password String
  | Input_Form_SignUp_pseudo String
  | Input_Form_SignUp_email String
  | Input_Form_SignUp_password String
  | Input_Form_SignUp_confirm String
  | To_SignIn
  | To_SignOut
  | To_SignUp
  | Submit_Sign

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Input_Form_SignIn_pseudo pseudo ->
      ( model |> set_form_signin_pseudo pseudo, Cmd.none )

    Input_Form_SignIn_password password ->
      ( model |> set_form_signin_password password, Cmd.none )

    Input_Form_SignUp_pseudo pseudo ->
      ( model |> set_form_signup_pseudo pseudo, Cmd.none )

    Input_Form_SignUp_email email ->
      ( model |> set_form_signup_email email, Cmd.none )

    Input_Form_SignUp_password password ->
      ( model |> set_form_signup_password password, Cmd.none )

    Input_Form_SignUp_confirm confirm ->
      ( model |> set_form_signup_confirm confirm, Cmd.none )

    To_SignIn ->
      ( { model | sign = new_signin }, Cmd.none )

    To_SignOut ->
      ( { model | sign = Out }, Cmd.none )

    To_SignUp ->
      ( { model | sign = new_signup }, Cmd.none )

    _ ->
       (model, Cmd.none)

set_form_signin_pseudo : String -> Model -> Model
set_form_signin_pseudo pseudo model =
  case model.sign of
    In form_signin ->
      { model | sign = In { form_signin | pseudo = pseudo } }
    _ ->
      model

set_form_signin_password : String -> Model -> Model
set_form_signin_password password model =
  case model.sign of
    In form_signin ->
      { model | sign = In { form_signin | password = password } }
    _ ->
      model

set_form_signup_pseudo : String -> Model -> Model
set_form_signup_pseudo pseudo model =
  case model.sign of
    Up form_signup ->
      { model | sign = Up { form_signup | pseudo = pseudo } }
    _ ->
      model

set_form_signup_email : String -> Model -> Model
set_form_signup_email email model =
  case model.sign of
    Up form_signup ->
      { model | sign = Up { form_signup | email = email } }
    _ ->
      model

set_form_signup_password : String -> Model -> Model
set_form_signup_password password model =
  case model.sign of
    Up form_signup ->
      { model | sign = Up { form_signup | password = password } }
    _ ->
      model

set_form_signup_confirm : String -> Model -> Model
set_form_signup_confirm confirm model =
  case model.sign of
    Up form_signup ->
      { model | sign = Up { form_signup | confirm = confirm } }
    _ ->
      model


-- view

view : Model -> Document Msg
view model =
  { title = "matcha"
  , body =
    [ form_sign model.sign
    , p [] [ text (Debug.toString model) ]
    ]
  }

form_sign : Sign -> Html Msg
form_sign sign =
  case sign of
    In form_signin ->
      Html.form []
        [ input [ type_ "text"
                , placeholder "pseudo"
                , onInput Input_Form_SignIn_pseudo
                , value form_signin.pseudo
                ] []
        , input [ type_ "password"
                , placeholder "password"
                , onInput Input_Form_SignIn_password
                , value form_signin.password
                ] []
        , button [ type_ "submit" ]
                 [ text "Sign In" ]
        , a [ onClick To_SignUp ]
            [ text "You don't have any account?" ]
        ]

    Out ->
      Html.form []
        [ button [ type_ "submit" ]
                 [ text "Sign Out" ]
        ]

    Up form_signup ->
      Html.form []
        [ input [ type_ "text"
                , placeholder "pseudo"
                , onInput Input_Form_SignUp_pseudo
                , value form_signup.pseudo
                ] []
        , input [ type_ "text"
                , placeholder "email"
                , onInput Input_Form_SignUp_email
                , value form_signup.email
                ] []
        , input [ type_ "password"
                , placeholder "password"
                , onInput Input_Form_SignUp_password
                , value form_signup.password
                ] []
        , input [ type_ "password"
                , placeholder "confirm your password"
                , onInput Input_Form_SignUp_confirm
                , value form_signup.confirm
                ] []
        , button [ type_ "submit" ]
                 [ text "Sign Up" ]
        , a [ onClick To_SignIn ]
            [ text "You alredy have an account?" ]
        ]


-- subscriptions

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none


-- main

main =
  Browser.document
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }
