-- Signin
{- authentify user -} -- signin.php

-- Signup
{- create  an user and send an email -} -- signup.php

-- Browse
{- get users list and default filters -} -- default_filters.php
{- send filters and get users list back -} -- fileter.php
{- get next page of users -} -- next_page.php
{- get last page of users -} -- last_page.php
{- like a user -} -- like.php

-- User
{- get all infos of an user -} -- user.php

-- Account
{- get current settings -}  -- current_settings.php
{- update settings -} -- update_settings.php
{- update password -} -- update_password.php

-- Chat
{- get list of chats and the amout of unread messages -} -- chats.php
{- get list of messages exchanged with a user -} -- discution.php
{- send a new message -} -- message.php

-- Retreive
{- update password -} -- retreive_password.php

-- Confirm
{- confirm new account -} -- confirm_account.php

-- Header
{- get amount of unread messages -} -- unread_messages.php
{- get amount of unread notifications -} -- unread_notifications.php

-- Notif
{- get notif list -} -- notifs.php

-- Other
{- sign out -} -- signout.php

module Main exposing (..)


-- imports

import Browser exposing (application, UrlRequest)
import Html exposing (..)
import Html.Attributes exposing (..)

import Url exposing (..)
import Url.Parser as Parser exposing (..)
import Browser.Navigation as Nav exposing (..)

import Json.Decode as Decode exposing (..)
import Json.Decode.Field as Field exposing (..)

import Http exposing (..)

import Array exposing (..)
import Time exposing (..)


-- modules

import Alert exposing (..)
import Form exposing (..)


-- model

type alias Model =
  { url : Url
  , key : Nav.Key
  , alert : Maybe Alert
  , signin : Form (Result String String)
  , signup : Form (Result String String)
  , filters : Form (DataAlert { pageAmount : Int, elemAmount : Int, users : List User})
  , userInfo : Maybe
    { unreadNotifsAmount : Int
    }
  , test :
    { chat : Form (DataAlert Chat) -- chats.php
    , receivedChat : Maybe Chat
    , discution : Form (DataAlert Discution) -- discution.php
    , receivedDiscution : Maybe Discution
    , confirmAccount : Form (Result String String) -- confirm_account.php
    , receivedAccountConfirmation : Result String String
    , receivedFilters : Maybe { pageAmount : Int, elemAmount : Int, users : List User} -- feed_filter.php
    , feedPage : Form (DataAlert (List User)) -- feed_page.php
    , receivedFeedPage : Maybe (List User)
    }
  }

init : () -> Url -> Nav.Key -> (Model, Cmd Msg)
init flags url key =
  ( { url = url
    , key = key
    , alert = Nothing
    , signin = signinForm
    , signup = signupForm
    , filters = filtersForm
    , userInfo = Nothing
    , test =
      { chat = requestChatsForm
      , receivedChat = Nothing
      , discution = requestDiscutionForm
      , receivedDiscution = Nothing
      , confirmAccount = requestAccountConfirmationForm
      , receivedAccountConfirmation = Err "Nothing received yet!"
      , receivedFilters = Nothing
      , feedPage = requestPageForm
      , receivedFeedPage = Nothing
      }
    }
  , Cmd.none
  )

signinForm : Form (Result String String)
signinForm =
  Form.form resultMessageDecoder (OnSubmit "Signin") "http://localhost/control/signin.php"
  |> Form.textField "pseudo"
  |> Form.passwordField "password"

signupForm : Form (Result String String)
signupForm =
  Form.form resultMessageDecoder (OnSubmit "Signup") "http://localhost/control/signup.php"
  |> Form.textField "pseudo"
  |> Form.textField "lastname"
  |> Form.textField "firstname"
  |> Form.textField "email"
  |> Form.passwordField "password"
  |> Form.passwordField "confirm"

-- url

onUrlRequest : UrlRequest -> Msg
onUrlRequest request =
  case request of
    Browser.Internal url ->
      InternalLinkClicked url

    Browser.External href ->
      ExternalLinkClicked href

onUrlChange : Url -> Msg
onUrlChange url =
  UrlChange url

type Route
  = Signin
  | Signup
  | Browse
  | Test
  -- | User
  -- | Account
  -- | Chat
  -- | Retreive
  -- | Confirm

routeParser : Parser (Route -> a) a
routeParser =
  Parser.oneOf
    [ Parser.map Signin (Parser.s "signin")
    , Parser.map Signup (Parser.s "signup")
    , Parser.map Browse (Parser.s "browse")
    , Parser.map Test (Parser.s "test")
    ]


-- update

type Msg
  = NoOp
  | InternalLinkClicked Url
  | ExternalLinkClicked String
  | UrlChange Url
  | Tick Time.Posix
  | SigninForm (Form.Msg (Result String String))
  | SignupForm (Form.Msg (Result String String))
  | FiltersForm (Form.Msg (DataAlert { pageAmount : Int, elemAmount : Int, users : List User}))
  | ChatForm (Form.Msg (DataAlert Chat))
  | DiscutionForm (Form.Msg (DataAlert Discution))
  | ConfirmAccountForm (Form.Msg (Result String String))
  | FeedPageForm (Form.Msg (DataAlert (List User)))
  | Receive_UnreadNotifsAmount (Result Http.Error Int)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Tick _ ->
      (model, requestUnreadNotifsAmount)

    ChatForm formMsg ->
      let
        (newForm, formCmd, response) = Form.update formMsg model.test.chat
      in
        let mt = model.test in
        case response of
          Just result ->
            chatResultHandler result { model | test = { mt | chat = newForm } } formCmd
          Nothing ->
            ( { model | test = { mt | chat = newForm  }}
            , formCmd |> Cmd.map ChatForm
            )

    DiscutionForm formMsg ->
      let
        (newForm, formCmd, response) = Form.update formMsg model.test.discution
      in
        let mt = model.test in
        case response of
          Just result ->
            discutionResultHandler result { model | test = { mt | discution = newForm } } formCmd
          Nothing ->
            ( { model | test = { mt | discution = newForm  }}
            , formCmd |> Cmd.map DiscutionForm
            )

    ConfirmAccountForm formMsg ->
      let
        (newForm, formCmd, response) = Form.update formMsg model.test.confirmAccount
      in
        let mt = model.test in
        case response of
          Just result ->
            simpleResultHandler result { model | test = { mt | confirmAccount = newForm } } formCmd
          Nothing ->
            ( { model | test = { mt | confirmAccount = newForm } }
            , formCmd |> Cmd.map ConfirmAccountForm
            )

    FeedPageForm formMsg ->
      let
        (newForm, formCmd, response) = Form.update formMsg model.test.feedPage
      in
        let mt = model.test in
        case response of
          Just result ->
            feedPageResultHandler result { model | test = { mt | feedPage = newForm } } formCmd
          Nothing ->
            ( { model | test = { mt | feedPage = newForm  }}
            , formCmd |> Cmd.map FeedPageForm
            )

    SigninForm formMsg ->
      let
        (newForm, formCmd, response) = Form.update formMsg model.signin
      in
        case response of
          Just result ->
            signinResultHandler result { model | signin = newForm } formCmd
          Nothing ->
            ( { model | signin = newForm }
            , formCmd |> Cmd.map SigninForm
            )

    SignupForm formMsg ->
      let
        (newForm, formCmd, response) = Form.update formMsg model.signup
      in
        case response of
          Just result ->
            signupResultHandler result { model | signup = newForm } formCmd
          Nothing ->
            ( { model | signup = newForm }
            , formCmd |> Cmd.map SignupForm
            )

    FiltersForm formMsg ->
      let
        (newForm, formCmd, response) = Form.update formMsg model.filters
      in
        case response of
          Just result ->
            filtersResultHandler result { model | filters = newForm } formCmd
          Nothing ->
            ( { model | filters = newForm }
            , formCmd |> Cmd.map FiltersForm
            )

    InternalLinkClicked url ->
      (model, Nav.pushUrl model.key (Url.toString url) )

    ExternalLinkClicked href ->
      (model, Nav.load href)

    UrlChange url ->
      ({ model | url = url }, Cmd.none)

    Receive_UnreadNotifsAmount resultAmount ->
      ( case resultAmount of
          Ok amount ->
            { model
              | userInfo = Maybe.map
                  (\userInfo -> { userInfo | unreadNotifsAmount = amount})
                  model.userInfo
            }
          Err _ ->
            model
      , Cmd.none
      )

    _ ->
      (model, Cmd.none)

feedPageResultHandler : Result Http.Error (DataAlert (List User)) -> Model -> Cmd (Form.Msg (DataAlert (List User))) -> (Model, Cmd Msg)
feedPageResultHandler result model cmd =
  case result of
    Ok { alert, data } ->
      let mt = model.test in
      ( { model | alert = alert, test = { mt | receivedFeedPage = data }}
      , cmd |> Cmd.map FeedPageForm
      )
    Err _ ->
      ( model |> Alert.serverNotReachedAlert
      , cmd |> Cmd.map FeedPageForm
      )

discutionResultHandler : Result Http.Error (DataAlert Discution) -> Model -> Cmd (Form.Msg (DataAlert Discution)) -> (Model, Cmd Msg)
discutionResultHandler result model cmd =
  case result of
    Ok { alert, data } ->
      let mt = model.test in
      ( { model | alert = alert, test = { mt | receivedDiscution = data }}
      , cmd |> Cmd.map DiscutionForm
      )
    Err _ ->
      ( model |> Alert.serverNotReachedAlert
      , cmd |> Cmd.map DiscutionForm
      )

chatResultHandler result model cmd =
  case result of
    Ok { alert, data } ->
      let mt = model.test in
      ( { model | alert = alert, test = { mt | receivedChat = data }}
      , cmd |> Cmd.map ChatForm
      )
    Err _ ->
      ( model |> Alert.serverNotReachedAlert
      , cmd |> Cmd.map ChatForm
      )

filtersResultHandler result model cmd =
  case result of
    Ok { alert, data } ->
      let mt = model.test in
      ( { model | alert = alert, test = { mt | receivedFilters = data }}
      , cmd |> Cmd.map FiltersForm
      )
    Err _ ->
      ( model |> Alert.serverNotReachedAlert
      , cmd |> Cmd.map FiltersForm
      )

simpleResultHandler result model cmd =
  case result of
    Ok (Ok message) ->
      ( model |> Alert.successAlert message
      , cmd |> Cmd.map ConfirmAccountForm
      )
    Ok (Err message) ->
      ( model |> Alert.invalidImputAlert message
      , cmd |> Cmd.map ConfirmAccountForm
      )
    Err _ ->
      ( model |> Alert.serverNotReachedAlert
      , cmd |> Cmd.map ConfirmAccountForm
      )

signinResultHandler result model cmd =
  case result of
    Ok (Ok message) ->
      ( model |> Alert.successAlert message
      , Cmd.batch
        [ Nav.pushUrl model.key "/browse"
        , cmd |> Cmd.map SigninForm
        ]
      )
    Ok (Err message) ->
      ( model |> Alert.invalidImputAlert message
      , cmd |> Cmd.map SigninForm
      )
    Err _ ->
      ( model |> Alert.serverNotReachedAlert
      , cmd |> Cmd.map SigninForm
      )

signupResultHandler result model cmd =
  case result of
    Ok (Ok message) ->
      ( model |> Alert.successAlert message
      , Cmd.batch
        [ Nav.pushUrl model.key "/signin"
        , cmd |> Cmd.map SignupForm
        ]
      )
    Ok (Err message) ->
      ( model |> Alert.invalidImputAlert message
      , cmd |> Cmd.map SignupForm
      )
    Err _ ->
      ( model |> Alert.serverNotReachedAlert
      , cmd |> Cmd.map SignupForm
      )


-- feed

type alias User =
  { id : Int
  , pseudo : String
  , picture : String
  , tags : List String
  , liked : Bool
  }

filtersForm : Form (DataAlert { pageAmount : Int, elemAmount : Int, users : List User})
filtersForm =
  Form.form (dataAlertDecoder filterDecoder) LiveUpdate "http://localhost/control/feed_filter.php"
  |> Form.doubleSliderField "age" (18, 90, 1)
  |> Form.doubleSliderField "popularity" (0, 100, 1)
  |> Form.singleSliderField "distanceMax" (0, 100, 1)
  |> Form.checkboxField "viewed" False
  |> Form.checkboxField "liked" False

requestPageForm : Form (DataAlert (List User))
requestPageForm =
  Form.form (Decode.list userDecoder |> dataAlertDecoder) (OnSubmit "Request page") "http://localhost/control/feed_page.php"
  |> Form.numberField "page" 0

userDecoder : Decoder User
userDecoder =
  Field.require "id" Decode.int <| \id ->
  Field.require "pseudo" Decode.string <| \pseudo ->
  Field.require "picture" Decode.string <| \picture ->
  Field.require "tags" (Decode.list Decode.string) <| \tags ->
  Field.require "liked" Decode.bool <| \liked ->

  Decode.succeed
    { id = id
    , pseudo = pseudo
    , picture = picture
    , tags = tags
    , liked = liked
    }

filterDecoder : Decoder { pageAmount : Int, elemAmount : Int, users : List User}
filterDecoder =
  Field.require "pageAmount" Decode.int <| \pageAmount ->
  Field.require "elemAmount" Decode.int <| \elemAmount ->
  Field.require "users" (Decode.list userDecoder) <| \users ->

  Decode.succeed
    { pageAmount = pageAmount
    , elemAmount = elemAmount
    , users = users
    }


-- confirm account

requestAccountConfirmationForm : Form (Result String String)
requestAccountConfirmationForm =
  Form.form resultMessageDecoder (OnSubmit "confirm account") "http://localhost/control/confirm_account.php"
  |> Form.textField "a"
  |> Form.textField "b"


-- notifications

requestUnreadNotifsAmount : Cmd Msg
requestUnreadNotifsAmount =
  Http.post
      { url = "http://localhost/control/unread_notifications.php"
      , body = emptyBody
      , expect = Http.expectJson Receive_UnreadNotifsAmount unreadNotifsAmountDecoder
      }

unreadNotifsAmountDecoder : Decoder Int
unreadNotifsAmountDecoder =
  Field.require "amount" Decode.int <| \amount ->
  Decode.succeed amount


-- chat

type alias Chat =
  { id : Int
  , pseudo : String
  , picture : String
  , last_log : LastLog
  , discution : Discution
  , unread : Bool
  }

type alias Message =
  { sent : Bool
  , date : String
  , content : String
  }

type Discution
  = Discution (List Message)
  | OnlyLastMessage String

type LastLog
  = Now
  | AWhileAgo String

type alias DataAlert a =
  { alert : Maybe Alert, data : Maybe a }

requestChatsForm : Form (DataAlert Chat)
requestChatsForm =
  Form.form (dataAlertDecoder chatDecoder) (OnSubmit "Request chats") "http://localhost/control/chats.php"

chatListDecoder : Decoder (List Chat)
chatListDecoder =
  Field.require "chats" (Decode.list chatDecoder) <| \chats ->
  Decode.succeed chats

chatDecoder : Decoder Chat
chatDecoder =
  Field.require "id" Decode.int <| \id ->
  Field.require "pseudo" Decode.string <| \pseudo ->
  Field.require "picture" Decode.string <| \picture ->
  Field.require "last_log" lastLogDecoder <| \last_log ->
  Field.require "last_message" Decode.string <| \last_message ->
  Field.require "unread" Decode.bool <| \unread ->

  Decode.succeed
    { id = id
    , pseudo = pseudo
    , picture = picture
    , last_log = last_log
    , discution = OnlyLastMessage last_message
    , unread = unread
    }

requestDiscutionForm : Form (DataAlert Discution)
requestDiscutionForm =
  Form.form (dataAlertDecoder discutionDecoder) (OnSubmit "Request discution") "http://localhost/control/discution.php"
  |> Form.numberField "id" 0

discutionDecoder : Decoder Discution
discutionDecoder =
  Field.require "messages" (Decode.list messageDecoder) <| \messages ->
  Decode.succeed (Discution messages)

messageDecoder : Decoder Message
messageDecoder =
  Field.require "sent" Decode.bool <| \sent ->
  Field.require "date" Decode.string <| \date ->
  Field.require "content" Decode.string <| \content ->

  Decode.succeed
    { sent = sent
    , date = date
    , content = content
    }

lastLogDecoder : Decoder LastLog
lastLogDecoder =
  Decode.string |> andThen
    (\ str ->
      case str of
        "Now" ->
          Decode.succeed Now

        date ->
          Decode.succeed (AWhileAgo date)
    )


-- general decoders

resultMessageDecoder : Decoder (Result String String)
resultMessageDecoder =
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

dataAlertDecoder : Decoder a -> Decoder { data: Maybe a, alert: Maybe Alert }
dataAlertDecoder dataDecoder =
  Field.attempt "data" dataDecoder <| \data ->
  Field.attempt "alert" alertDecoder <| \alert ->

  Decode.succeed ({ data = data, alert = alert })


-- view

view : Model -> Browser.Document Msg
view model =
  { title = "matcha"
  , body =
    [ Alert.view model
    , Maybe.withDefault (a [ href "/test" ] [ text "Go to testing" ]) (page model)
    ]
  }

page : Model -> Maybe (Html Msg)
page model =
  Maybe.map
    (\route ->
      case route of
        Signin ->
          signinView model

        Signup ->
          signupView model

        Browse ->
          browseView model

        Test ->
          testView model
    )
    (Parser.parse routeParser model.url)

signinView : Model -> Html Msg
signinView model =
  Html.div []
            [ Form.view model.signin |> Html.map SigninForm
            , a [ href "/signup" ]
                [ text "You don't have any account?" ]
            ]

signupView : Model -> Html Msg
signupView model =
  Html.div []
            [ Form.view model.signup |> Html.map SignupForm
            , a [ href "/signin" ]
                [ text "You alredy have an account?" ]
            ]

browseView : Model -> Html Msg
browseView model =
  Html.div []
            [ Form.view model.filters |> Html.map FiltersForm
            , a [ href "/signin" ]
                [ text "signout" ]
            ]

testView : Model -> Html Msg
testView model =
  Html.div []
            [ text "chats.php"
            , Form.view model.test.chat |> Html.map ChatForm
            , br [] [], text "discution.php"
            , Form.view model.test.discution |> Html.map DiscutionForm
            , br [] [], text "confirm_account.php"
            , Form.view model.test.confirmAccount |> Html.map ConfirmAccountForm
            , br [] [], text "feed_filter.php"
            , Form.view model.filters |> Html.map FiltersForm
            , br [] [], text "feed_page.php"
            , Form.view model.test.feedPage |> Html.map FeedPageForm
            , br [] [], text (Debug.toString model)
            ]


-- subscriptions

subscriptions : Model -> Sub Msg
subscriptions model =
  [ Form.subscriptions model.signin |> Sub.map SigninForm
  , Form.subscriptions model.signup |> Sub.map SignupForm
  , Form.subscriptions model.filters |> Sub.map FiltersForm
  , Time.every 1000 Tick
  ] |> Sub.batch


-- main

main : Program () Model Msg
main =
  Browser.application
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    , onUrlRequest = onUrlRequest
    , onUrlChange = onUrlChange
    }
