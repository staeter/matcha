module Main exposing (..)


-- imports

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

import Browser exposing (..)

import Http exposing (..)

import Json.Decode as Decode exposing (..)
import Json.Decode.Field as Field exposing (..)

import Debug exposing (..)


-- my own modules

import Model exposing (..)
import Account exposing (..)
import Query exposing (..)


-- model

type alias Model =
  { account : Account
  -- , filters : Filters
  -- , browse : List User
  , alert : Maybe Alert
  , log : Maybe String
  }

init : () -> (Model, Cmd Msg)
init _ =
  ( { account = empty_signindata
    , alert = Nothing
    , log = Nothing
    }
  , Cmd.none
  )

-- update

type Msg
  = NoOp
  -- Sign In, Up and Out
  | Input_SignIn_pseudo String
  | Input_SignIn_password String
  | Input_SignUp_pseudo String
  | Input_SignUp_email String
  | Input_SignUp_password String
  | Input_SignUp_confirm String
  | To_SignIn
  | To_SignUp
  | Query_Submit_Account
  | Result_Submit_SignIn (Result Http.Error SD)
  | Result_Submit_SignOut (Result Http.Error SD)
  | Result_Submit_SignUp (Result Http.Error SD)
  -- Settings
  | Query_Current_Settings
  | Result_Current_Settings (Result Http.Error SD)
  | Input_Settings_pseudo String
  | Input_Settings_name String
  | Input_Settings_firstname String
  | Input_Settings_email String
  | Input_Settings_gender Gender
  | Input_Settings_orientation Orientation
  | Input_Settings_description String
  | Query_Submit_Settings
  | Result_Submit_Settings (Result Http.Error SD)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Input_SignIn_pseudo pseudo ->
      ( case model.account of
          SignIn signindata -> { model | account = SignIn { signindata | pseudo = pseudo } }
          _ -> model
      , Cmd.none
      )

    Input_SignIn_password password ->
      ( case model.account of
          SignIn signindata -> { model | account = SignIn { signindata | password = password } }
          _ -> model
      , Cmd.none
      )

    Input_SignUp_pseudo pseudo ->
      ( case model.account of
          SignUp signupdata -> { model | account = SignUp { signupdata | pseudo = pseudo } }
          _ -> model
      , Cmd.none
      )

    Input_SignUp_email email ->
      ( case model.account of
          SignUp signupdata -> { model | account = SignUp { signupdata | email = email } }
          _ -> model
      , Cmd.none
      )

    Input_SignUp_password password ->
      ( case model.account of
          SignUp signupdata -> { model | account = SignUp { signupdata | password = password } }
          _ -> model
      , Cmd.none
      )

    Input_SignUp_confirm confirm ->
      ( case model.account of
          SignUp signupdata -> { model | account = SignUp { signupdata | confirm = confirm } }
          _ -> model
      , Cmd.none
      )

    Input_Settings_pseudo pseudo ->
      ( case model.account of
          SignOut (Just settings) -> { model | account = SignOut (Just { settings | pseudo = pseudo }) }
          _ -> model
      , Cmd.none
      )

    Input_Settings_name name ->
      ( case model.account of
          SignOut (Just settings) -> { model | account = SignOut (Just { settings | name = name }) }
          _ -> model
      , Cmd.none
      )

    Input_Settings_firstname firstname ->
      ( case model.account of
          SignOut (Just settings) -> { model | account = SignOut (Just { settings | firstname = firstname }) }
          _ -> model
      , Cmd.none
      )

    Input_Settings_email email ->
      ( case model.account of
          SignOut (Just settings) -> { model | account = SignOut (Just { settings | email = email }) }
          _ -> model
      , Cmd.none
      )

    Input_Settings_gender gender ->
      ( case model.account of
          SignOut (Just settings) -> { model | account = SignOut (Just { settings | gender = gender }) }
          _ -> model
      , Cmd.none
      )

    Input_Settings_orientation orientation ->
      ( case model.account of
          SignOut (Just settings) -> { model | account = SignOut (Just { settings | orientation = orientation }) }
          _ -> model
      , Cmd.none
      )

    Input_Settings_description description ->
      ( case model.account of
          SignOut (Just settings) -> { model | account = SignOut (Just { settings | description = description }) }
          _ -> model
      , Cmd.none
      )

    To_SignIn ->
      ( { model | account = empty_signindata }, Cmd.none )

    To_SignUp ->
      ( { model | account = empty_signupdata }, Cmd.none )

    Query_Submit_Account ->
      ( { model | alert = Just load }, query_submit_account model.account )

    Result_Submit_SignIn result ->
      case result of
        Ok sd -> ({ model | alert = replace_alert model.alert sd.data.alert |> remove_alert 0, account = SignOut Nothing }, Cmd.none)
        Err _ -> ({ model | alert = remove_alert 0 model.alert, log = Just "Result Err in Result_Submit_SignIn" }, Cmd.none)

    Result_Submit_SignOut result ->
      case result of
        Ok sd -> ({ model | alert = replace_alert model.alert sd.data.alert |> remove_alert 0, account = empty_signindata }, Cmd.none)
        Err _ -> ({ model | alert = remove_alert 0 model.alert, log = Just "Result Err in Result_Submit_SignOut" }, Cmd.none)

    Result_Submit_SignUp result ->
      case result of
        Ok sd -> ({ model | alert = replace_alert model.alert sd.data.alert |> remove_alert 0, account = empty_signindata }, Cmd.none)
        Err _ -> ({ model | alert = remove_alert 0 model.alert, log = Just "Result Err in Result_Submit_SignUp" }, Cmd.none)

    _ ->
       (model, Cmd.none)

query_submit_account : Account -> Cmd Msg
query_submit_account account =
  case account of
    SignIn signindata ->
      Http.post { url = "http://localhost/control/signin.php"
                , body = multipartBody
                            [ stringPart "pseudo" signindata.pseudo
                            , stringPart "password" signindata.password
                            ]
                , expect = Http.expectJson Result_Submit_SignIn sdDecoder
                }
    SignOut _ ->
      Http.post { url = "http://localhost/control/signout.php"
                , body = Http.emptyBody
                , expect = Http.expectJson Result_Submit_SignOut sdDecoder
                }
    SignUp signupdata ->
      Http.post { url = "http://localhost/control/signup.php"
                , body = multipartBody
                            [ stringPart "pseudo" signupdata.pseudo
                            , stringPart "email" signupdata.email
                            , stringPart "password" signupdata.password
                            , stringPart "confirm" signupdata.confirm
                            ]
                , expect = Http.expectJson Result_Submit_SignUp sdDecoder
                }


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

    SignOut _ ->
      view_signout

    SignUp signupdata ->
      view_signup signupdata

view_signin : SignInData -> Html Msg
view_signin signindata =
  Html.form [ onSubmit Query_Submit_Account ]
    [ input [ type_ "text"
            , placeholder "pseudo"
            , onInput Input_SignIn_pseudo
            , Html.Attributes.value signindata.pseudo
            ] []
    , input [ type_ "password"
            , placeholder "password"
            , onInput Input_SignIn_password
            , Html.Attributes.value signindata.password
            ] []
    , button [ type_ "submit" ]
             [ text "Sign In" ]
    , a [ onClick To_SignUp ]
        [ text "You don't have any account?" ]
    ]

view_signout : Html Msg
view_signout =
  Html.form [ onSubmit Query_Submit_Account  ]
    [ button [ type_ "submit" ]
             [ text "Sign Out" ]
    ]

view_signup : SignUpData -> Html Msg
view_signup signupdata =
  Html.form [ onSubmit Query_Submit_Account ]
    [ input [ type_ "text"
            , placeholder "pseudo"
            , onInput Input_SignUp_pseudo
            , Html.Attributes.value signupdata.pseudo
            ] []
    , input [ type_ "text"
            , placeholder "email"
            , onInput Input_SignUp_email
            , Html.Attributes.value signupdata.email
            ] []
    , input [ type_ "password"
            , placeholder "password"
            , onInput Input_SignUp_password
            , Html.Attributes.value signupdata.password
            ] []
    , input [ type_ "password"
            , placeholder "confirm your password"
            , onInput Input_SignUp_confirm
            , Html.Attributes.value signupdata.confirm
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
