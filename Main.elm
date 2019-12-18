module Main exposing (..)


-- imports

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Browser exposing (..)
import Http exposing (..)
import Json.Encode as Encode exposing (..)
import Json.Decode as Decode exposing (..)
import Json.Decode.Field as Field exposing (..)

import Debug exposing (..)


-- model

type alias Model =
  { account : Account
  -- , filters : Filters
  -- , browse : List User
  , alert : Maybe Alert
  , log : Maybe String
  }

type alias Filters =
  { ageMin : Int
  , ageMax : Int
  , distanceMax : Int
  , popularityMin : Int
  , popularityMax : Int
  , tags : List String
  , viewed : Bool
  , liked : Bool
  }

type alias UserOverview =
  { id : Int
  , pseudo : String
  , picture : String
  }

type alias User =
  { id : Int
  , pseudo : String
  , gender : Gender
  , orientation : Orientation
  , age : Int
  , picture : String
  , tags : List String
  , distance : Int
  , description : String
  }

type Gender
  = Man
  | Woman

type Orientation
  = Homosexual
  | Bisexual
  | Heterosexual

type Account
  = SignIn SignInData
  | SignUp SignUpData
  | SignOut (Maybe Settings)

type alias Settings =
  { pseudo : String
  , name : String
  , firstname : String
  , email : String
  , gender : Gender
  , orientation : Orientation
  , tags : List String
  , description : String
  -- , localisation : ??? //ni
  , pictures : PicturesData
  , password : PasswordData
  }

type alias PicturesData =
  { main : String
  , other : List String
  }

type alias PasswordData =
  { oldpassword : String
  , newpassword : String
  , confirm : String
  }

empty_passworddata : PasswordData
empty_passworddata =
  { oldpassword = ""
  , newpassword = ""
  , confirm = ""
  }

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

type alias Alert =
  { id : Int
  , content : String
  }

load : Alert
load =
  { id = 0
  , content = "Loading..."
  }

type alias SD =
  { status : Status
  , data : Data
  }

type Status
  = Success
  | Failure

type alias Data =
  { alert : Maybe Alert
  , log : Maybe String
  , settings : Maybe Settings
  }

init : () -> (Model, Cmd Msg)
init _ =
  ( { account = new_signindata
    , alert = Nothing
    , log = Nothing
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
  | Query_Submit_Account
  | Result_Submit_SignIn (Result Http.Error SD)
  | Result_Submit_SignOut (Result Http.Error SD)
  | Result_Submit_SignUp (Result Http.Error SD)
  | Query_Current_Settings
  | Result_Current_Settings (Result Http.Error SD)
  | Query_Submit_Settings
  | Result_Submit_Settings (Result Http.Error SD)

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

    To_SignUp ->
      ( { model | account = new_signupdata }, Cmd.none )

    Query_Submit_Account ->
      ( { model | alert = Just load }, query_submit_account model.account )

    Result_Submit_SignIn result ->
      case result of
        Ok sd -> ({ model | alert = new_alert model.alert sd.data.alert |> remove_alert 0, account = SignOut Nothing }, Cmd.none)
        Err _ -> ({ model | alert = remove_alert 0 model.alert, log = Just "Result Err in Result_Submit_SignIn" }, Cmd.none)

    Result_Submit_SignOut result ->
      case result of
        Ok sd -> ({ model | alert = new_alert model.alert sd.data.alert |> remove_alert 0, account = new_signindata }, Cmd.none)
        Err _ -> ({ model | alert = remove_alert 0 model.alert, log = Just "Result Err in Result_Submit_SignOut" }, Cmd.none)

    Result_Submit_SignUp result ->
      case result of
        Ok sd -> ({ model | alert = new_alert model.alert sd.data.alert |> remove_alert 0, account = new_signindata }, Cmd.none)
        Err _ -> ({ model | alert = remove_alert 0 model.alert, log = Just "Result Err in Result_Submit_SignUp" }, Cmd.none)

    _ ->
       (model, Cmd.none)

new_alert : Maybe Alert -> Maybe Alert -> Maybe Alert
new_alert alert newalert =
  case (alert, newalert) of
    (Just msg, Just nm) -> Just { nm | id = msg.id + 1 }
    (Nothing, Just nm) -> Just nm
    (Just msg, Nothing) -> alert
    (Nothing, Nothing) -> Nothing

remove_alert : Int -> Maybe Alert -> Maybe Alert
remove_alert idtoremove alert =
  case alert of
    Just a ->
      if a.id == idtoremove
      then Nothing
      else Just a
    Nothing -> Nothing

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

sdDecoder : Decoder SD
sdDecoder =
  Field.require "status" statusDecoder <| \status ->
  Field.require "data" dataDecoder <| \data ->

  Decode.succeed
    { status = status
    , data = data
    }

statusDecoder : Decoder Status
statusDecoder =
  Decode.string |> andThen
    (\ str ->
      case str of
        "Success" ->
          Decode.succeed Success

        "Failure" ->
          Decode.succeed Failure

        _ ->
          Decode.fail "statusDecoder failed : not valid status"
    )

dataDecoder : Decoder Data
dataDecoder =
  Field.attempt "alert" alertDecoder <| \alert ->
  Field.attempt "log" Decode.string <| \log ->
  Field.attempt "settings" settingsDecoder <| \settings ->

  Decode.succeed
    { alert = alert
    , log = log
    , settings = settings
    }

alertDecoder : Decoder Alert
alertDecoder =
  Field.require "content" Decode.string <| \content ->

  Decode.succeed
    { id = 1
    , content = content
    }

andMap = Decode.map2 (|>)

settingsDecoder : Decoder Settings
settingsDecoder =
  Field.require "pseudo" Decode.string <| \pseudo ->
  Field.require "name" Decode.string <| \name ->
  Field.require "firstname" Decode.string <| \firstname ->
  Field.require "email" Decode.string <| \email ->
  Field.require "gender" genderDecoder <| \gender ->
  Field.require "orientation" orientationDecoder <| \orientation ->
  Field.require "tags" (Decode.list Decode.string) <| \tags ->
  Field.require "description" Decode.string <| \description ->
  Field.require "pictures" picturesDataDecoder <| \pictures ->

  Decode.succeed
    { pseudo = pseudo
    , name = name
    , firstname = firstname
    , email = email
    , gender = gender
    , orientation = orientation
    , tags = tags
    , description = description
    , pictures = pictures
    , password = empty_passworddata
    }

picturesDataDecoder : Decoder PicturesData
picturesDataDecoder =
  Field.require "main" Decode.string <| \main_ ->
  Field.require "other" (Decode.list Decode.string) <| \other ->

  Decode.succeed
    { main = main_
    , other = other
    }

genderDecoder : Decoder Gender
genderDecoder =
  Decode.string |> andThen
    (\ str ->
      case str of
        "Man" ->
          Decode.succeed Man

        "Woman" ->
          Decode.succeed Woman

        _ ->
          Decode.fail "genderDecoder failed : not valid gender"
    )

orientationDecoder : Decoder Orientation
orientationDecoder =
  Decode.string |> andThen
    (\ str ->
      case str of
        "Homosexual" ->
          Decode.succeed Homosexual

        "Bisexual" ->
          Decode.succeed Bisexual

        "Heterosexual" ->
          Decode.succeed Heterosexual

        _ ->
          Decode.fail "orientationDecoder failed : not valid orientation"
    )

result_submit_account_Ok : Model -> SD -> (Model, Cmd Msg)
result_submit_account_Ok model sd =
  ( model
  , Cmd.none
  )

result_submit_account_Err : Model -> (Model, Cmd Msg)
result_submit_account_Err model =
  ( model
  , Cmd.none
  )

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
