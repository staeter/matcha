module Main exposing (..)


-- imports

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Browser exposing (..)

import Debug exposing (..)


-- model

type alias Model =
  { account : Account
  }

type Account
  = SignIn SignInData
  | SignOut
  | SignUp SignUpData

type alias SignInData =
  { pseudo : String
  , password : String
  }

type alias SignUpData =
  { pseudo : String
  , email : String
  , password : String
  , confirm : String
  }

init : () -> (Model, Cmd Msg)
init _ =
  ( { account = new_signindata
    }
  , Cmd.none
  )

-- update

type Msg
  = NoOp
  | Input_SignIn_pseudo String
  | Input_SignIn_password String
  | Input_SignUp_pseudo String
  | Input_SignUp_email String
  | Input_SignUp_password String
  | Input_SignUp_confirm String
  | To_SignIn
  | To_SignOut
  | To_SignUp
  | Submit_Sign

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Input_SignIn_pseudo pseudo ->
      ( model |> set_signindata_pseudo pseudo, Cmd.none )

    Input_SignIn_password password ->
      ( model |> set_signindata_password password, Cmd.none )

    Input_SignUp_pseudo pseudo ->
      ( model |> set_signupdata_pseudo pseudo, Cmd.none )

    Input_SignUp_email email ->
      ( model |> set_signupdata_email email, Cmd.none )

    Input_SignUp_password password ->
      ( model |> set_signupdata_password password, Cmd.none )

    Input_SignUp_confirm confirm ->
      ( model |> set_signupdata_confirm confirm, Cmd.none )

    To_SignIn ->
      ( { model | account = new_signindata }, Cmd.none )

    To_SignOut ->
      ( { model | account = SignOut }, Cmd.none )

    To_SignUp ->
      ( { model | account = new_signupdata }, Cmd.none )

    _ ->
       (model, Cmd.none)

set_signindata_pseudo : String -> Model -> Model
set_signindata_pseudo pseudo model =
  case model.account of
    SignIn signindata ->
      { model | account = SignIn { signindata | pseudo = pseudo } }
    _ ->
      model

set_signindata_password : String -> Model -> Model
set_signindata_password password model =
  case model.account of
    SignIn signindata ->
      { model | account = SignIn { signindata | password = password } }
    _ ->
      model

set_signupdata_pseudo : String -> Model -> Model
set_signupdata_pseudo pseudo model =
  case model.account of
    SignUp signupdata ->
      { model | account = SignUp { signupdata | pseudo = pseudo } }
    _ ->
      model

set_signupdata_email : String -> Model -> Model
set_signupdata_email email model =
  case model.account of
    SignUp signupdata ->
      { model | account = SignUp { signupdata | email = email } }
    _ ->
      model

set_signupdata_password : String -> Model -> Model
set_signupdata_password password model =
  case model.account of
    SignUp signupdata ->
      { model | account = SignUp { signupdata | password = password } }
    _ ->
      model

set_signupdata_confirm : String -> Model -> Model
set_signupdata_confirm confirm model =
  case model.account of
    SignUp signupdata ->
      { model | account = SignUp { signupdata | confirm = confirm } }
    _ ->
      model

new_signindata : Account
new_signindata =
  SignIn { pseudo = "", password = "" }

new_signupdata : Account
new_signupdata =
  SignUp { pseudo = "", email = "", password = "", confirm = "" }

-- view

view : Model -> Document Msg
view model =
  { title = "matcha"
  , body =
    [ view_account model.account
    , p [] [ text (Debug.toString model) ]
    ]
  }

view_account : Account -> Html Msg
view_account account =
  case account of
    SignIn signindata ->
      view_signin signindata

    SignOut ->
      view_signout

    SignUp signupdata ->
      view_signup signupdata

view_signin : SignInData -> Html Msg
view_signin signindata =
  Html.form []
    [ input [ type_ "text"
            , placeholder "pseudo"
            , onInput Input_SignIn_pseudo
            , value signindata.pseudo
            ] []
    , input [ type_ "password"
            , placeholder "password"
            , onInput Input_SignIn_password
            , value signindata.password
            ] []
    , button [ type_ "submit" ]
             [ text "Sign In" ]
    , a [ onClick To_SignUp ]
        [ text "You don't have any account?" ]
    ]

view_signout : Html Msg
view_signout =
  Html.form []
    [ button [ type_ "submit" ]
             [ text "Sign Out" ]
    ]

view_signup : SignUpData -> Html Msg
view_signup signupdata =
  Html.form []
    [ input [ type_ "text"
            , placeholder "pseudo"
            , onInput Input_SignUp_pseudo
            , value signupdata.pseudo
            ] []
    , input [ type_ "text"
            , placeholder "email"
            , onInput Input_SignUp_email
            , value signupdata.email
            ] []
    , input [ type_ "password"
            , placeholder "password"
            , onInput Input_SignUp_password
            , value signupdata.password
            ] []
    , input [ type_ "password"
            , placeholder "confirm your password"
            , onInput Input_SignUp_confirm
            , value signupdata.confirm
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
