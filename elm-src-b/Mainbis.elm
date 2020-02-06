-- Signin
{- authentify user -} -- account_signin.php

-- Signup
{- create  an user and send an email -} -- account_signup.php

-- Browse
{- get users list and default filters -} -- feed_open.php
{- send filters and get users list back -} -- feed_filter.php
{- get an other page of users -} -- feed_page.php
{- like a user -} -- user_like.php

-- User
{- get all infos of an user -} -- user_info.php

-- Account
{- get current settings -}  -- settings_current.php
{- update settings -} -- settings_update.php
{- update password -} -- password_update.php

-- Chat
{- get list of chats and the amout of unread messages -} -- chat_list.php
{- get list of messages exchanged with a user -} -- chat_discution.php
{- send a new message -} -- chat_message.php

-- Retreive
{- update password -} -- password_retrieval.php

-- Confirm
{- confirm new account -} -- account_confirmation.php

-- Header
{- get amount of unread notifications -} -- account_notifs_amount.php

-- Notif
{- get notif list -} -- account_notifs.php

-- Other
{- sign out -} -- account_signout.php

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
  , userInfo : Maybe
    { unreadNotifsAmount : Int }
  , confirmAccountForm : Form (Result String String) -- account_confirmation.php
  , notifsForm : Form (DataAlert (List Notif)) -- account_notifs.php
  , receivedNotifs : Maybe (List Notif)
  , discutionForm : Form (DataAlert Discution) -- chat_discution.php
  , receivedDiscution : Maybe Discution
  , chatForm : Form (DataAlert (List Chat)) -- chat_list.php
  , receivedChat : Maybe (List Chat)
  , sendMessageForm : Form ConfirmAlert -- chat_message.php
  , receivedMessageSent : Maybe Bool
  , openFeedForm : -- feed_open.php
      Form
        ( DataAlert
          ( Form (DataAlert PageContent)
          , PageContent
          )
        )
  , receivedFilters : Maybe (Form (DataAlert PageContent)) -- feed_filter.php
  , feedPageForm : Form (DataAlert (List User)) -- feed_page.php
  , receivedPageContent : Maybe PageContent
  , retreivedAccountForm : Form (Result String String) -- password_retreive.php
  , updatePasswordForm : Form (Result String String) -- password_update.php
  , userDetailsForm : Form (DataAlert UserDetails) -- user_info.php
  , receivedUserDetails : Maybe UserDetails
  , newLikeStatusForm : Form (DataAlert Bool) -- user_like.php
  , receivedNewLikeStatus : Maybe Bool
  }

init : () -> Url -> Nav.Key -> (Model, Cmd Msg)
init flags url key =
  ( { url = url
    , key = key
    , alert = Nothing
    , signin = signinForm
    , signup = signupForm
    , userInfo = Just
      { unreadNotifsAmount = 0 }
    , confirmAccountForm = requestAccountConfirmationForm
    , notifsForm = requestNotifsForm
    , receivedNotifs = Nothing
    , discutionForm = requestDiscutionForm
    , receivedDiscution = Nothing
    , chatForm = requestChatsForm
    , receivedChat = Nothing
    , sendMessageForm = requestSendMessageForm
    , receivedMessageSent = Nothing
    , openFeedForm = requestOpenFeedForm
    , receivedFilters = Nothing
    , feedPageForm = requestPageForm
    , receivedPageContent = Nothing
    , retreivedAccountForm = requestAccountRetrievalForm
    , updatePasswordForm = requestUpdatePasswordForm
    , userDetailsForm = requestUserDetails
    , receivedUserDetails = Nothing
    , newLikeStatusForm = requestLikeForm
    , receivedNewLikeStatus = Nothing
    }
  , Cmd.none
  )

signinForm : Form (Result String String)
signinForm =
  Form.form resultMessageDecoder (OnSubmit "Signin") "http://localhost/control/account_signin.php"
  |> Form.textField "pseudo"
  |> Form.passwordField "password"

signupForm : Form (Result String String)
signupForm =
  Form.form resultMessageDecoder (OnSubmit "Signup") "http://localhost/control/account_signup.php"
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
  | FiltersForm (Form.Msg (DataAlert PageContent))
  | ChatForm (Form.Msg (DataAlert (List Chat)))
  | DiscutionForm (Form.Msg (DataAlert Discution))
  | ConfirmAccountForm (Form.Msg (Result String String))
  | RetreiveAccountForm (Form.Msg (Result String String))
  | UpdatePasswordForm (Form.Msg (Result String String))
  | FeedPageForm (Form.Msg (DataAlert (List User)))
  | OpenFeedForm (Form.Msg (DataAlert (Form (DataAlert PageContent), PageContent)))
  | ReceiveUnreadNotifsAmount (Result Http.Error (DataAlert Int))
  | LikeForm (Form.Msg (DataAlert Bool))
  | NotifsForm (Form.Msg (DataAlert (List Notif)))
  | SendMessageForm (Form.Msg ConfirmAlert)
  | UserDetailsForm (Form.Msg (DataAlert UserDetails))

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Tick _ ->
      (model, requestUnreadNotifsAmount)

    NotifsForm formMsg ->
      let
        (newForm, formCmd, response) = Form.update formMsg model.notifsForm
      in
        case response of
          Just result ->
            notifsFormResultHandler result { model | notifsForm = newForm } formCmd
          Nothing ->
            ( { model | notifsForm = newForm }
            , formCmd |> Cmd.map NotifsForm
            )

    LikeForm formMsg ->
      let
        (newForm, formCmd, response) = Form.update formMsg model.newLikeStatusForm
      in
        case response of
          Just result ->
            newLikeStatusResultHandler result { model | newLikeStatusForm = newForm } formCmd
          Nothing ->
            ( { model | newLikeStatusForm = newForm }
            , formCmd |> Cmd.map LikeForm
            )

    UserDetailsForm formMsg ->
      let
        (newForm, formCmd, response) = Form.update formMsg model.userDetailsForm
      in
        case response of
          Just result ->
            userDetailsResultHandler result { model | userDetailsForm = newForm } formCmd
          Nothing ->
            ( { model | userDetailsForm = newForm }
            , formCmd |> Cmd.map UserDetailsForm
            )

    SendMessageForm formMsg ->
      let
        (newForm, formCmd, response) = Form.update formMsg model.sendMessageForm
      in
        case response of
          Just result ->
            sendMessageResultHandler result { model | sendMessageForm = newForm } formCmd
          Nothing ->
            ( { model | sendMessageForm = newForm }
            , formCmd |> Cmd.map SendMessageForm
            )

    ChatForm formMsg ->
      let
        (newForm, formCmd, response) = Form.update formMsg model.chatForm
      in
        case response of
          Just result ->
            chatResultHandler result { model | chatForm = newForm } formCmd
          Nothing ->
            ( { model | chatForm = newForm }
            , formCmd |> Cmd.map ChatForm
            )

    DiscutionForm formMsg ->
      let
        (newForm, formCmd, response) = Form.update formMsg model.discutionForm
      in
        case response of
          Just result ->
            discutionResultHandler result { model | discutionForm = newForm } formCmd
          Nothing ->
            ( { model | discutionForm = newForm }
            , formCmd |> Cmd.map DiscutionForm
            )

    ConfirmAccountForm formMsg ->
      let
        (newForm, formCmd, response) = Form.update formMsg model.confirmAccountForm
      in
        case response of
          Just result ->
            confirmAccountResultHandler result { model | confirmAccountForm = newForm } formCmd
          Nothing ->
            ( { model | confirmAccountForm = newForm }
            , formCmd |> Cmd.map ConfirmAccountForm
            )

    RetreiveAccountForm formMsg ->
      let
        (newForm, formCmd, response) = Form.update formMsg model.retreivedAccountForm
      in
        case response of
          Just result ->
            retreiveAccountResultHandler result { model | retreivedAccountForm = newForm } formCmd
          Nothing ->
            ( { model | retreivedAccountForm = newForm }
            , formCmd |> Cmd.map RetreiveAccountForm
            )

    UpdatePasswordForm formMsg ->
      let
        (newForm, formCmd, response) = Form.update formMsg model.updatePasswordForm
      in
        case response of
          Just result ->
            updatePasswordResultHandler result { model | updatePasswordForm = newForm } formCmd
          Nothing ->
            ( { model | updatePasswordForm = newForm }
            , formCmd |> Cmd.map UpdatePasswordForm
            )

    FeedPageForm formMsg ->
      let
        (newForm, formCmd, response) = Form.update formMsg model.feedPageForm
      in
        case response of
          Just result ->
            feedPageResultHandler result { model | feedPageForm = newForm } formCmd
          Nothing ->
            ( { model | feedPageForm = newForm }
            , formCmd |> Cmd.map FeedPageForm
            )

    OpenFeedForm formMsg ->
      let
        (newForm, formCmd, response) = Form.update formMsg model.openFeedForm
      in
        case response of
          Just result ->
            openFeedResultHandler result { model | openFeedForm = newForm } formCmd
          Nothing ->
            ( { model | openFeedForm = newForm }
            , formCmd |> Cmd.map OpenFeedForm
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
      case model.receivedFilters of
        Just receivedFF ->
          let
            (newForm, formCmd, response) = Form.update formMsg receivedFF
          in
            case response of
              Just result ->
                filtersResultHandler result { model | receivedFilters = Just newForm } formCmd
              Nothing ->
                ( { model | receivedFilters = Just newForm }
                , formCmd |> Cmd.map FiltersForm
                )
        Nothing ->
          ( model |> Alert.customAlert "DarkPurple" "Impossible call to inexistant filtersForm"
          , Cmd.none
          )

    InternalLinkClicked url ->
      (model, Nav.pushUrl model.key (Url.toString url) )

    ExternalLinkClicked href ->
      (model, Nav.load href)

    UrlChange url ->
      ({ model | url = url }, Cmd.none)

    ReceiveUnreadNotifsAmount result ->
      (unreadNotifsAmountResultHandler result model, Cmd.none)

    _ ->
      (model, Cmd.none)

unreadNotifsAmountResultHandler : Result Http.Error (DataAlert Int) -> Model -> Model
unreadNotifsAmountResultHandler result model =
  case result of
    Ok { alert, data } ->
      let newAlert = if alert == Nothing then model.alert else alert in
        Maybe.withDefault
          (model |> Alert.serverNotReachedAlert (Http.BadBody "Data not received for notifs amount"))
          (Maybe.map
            (\amount ->
              { model
                | alert = newAlert
                , userInfo = Maybe.map
                  (\ui -> { ui | unreadNotifsAmount = amount })
                  model.userInfo
              }
            )
            data
          )
    Err error ->
      model |> Alert.serverNotReachedAlert error

notifsFormResultHandler result model cmd =
  case result of
    Ok { alert, data } ->
      ( { model | alert = alert, receivedNotifs = data }
      , cmd |> Cmd.map NotifsForm
      )
    Err error ->
      ( model |> Alert.serverNotReachedAlert error
      , cmd |> Cmd.map NotifsForm
      )

sendMessageResultHandler : Result Http.Error ConfirmAlert -> Model -> Cmd (Form.Msg ConfirmAlert) -> (Model, Cmd Msg)
sendMessageResultHandler result model cmd =
  case result of
    Ok { confirm, alert } ->
      ( { model | alert = alert, receivedMessageSent = Just confirm }
      , cmd |> Cmd.map SendMessageForm
      )
    Err error ->
      ( model |> Alert.serverNotReachedAlert error
      , cmd |> Cmd.map SendMessageForm
      )

userDetailsResultHandler : Result Http.Error (DataAlert UserDetails) -> Model -> Cmd (Form.Msg (DataAlert UserDetails)) -> (Model, Cmd Msg)
userDetailsResultHandler result model cmd =
  case result of
    Ok { alert, data } ->
      ( { model | alert = alert, receivedUserDetails = data }
      , cmd |> Cmd.map UserDetailsForm
      )
    Err error ->
      ( model |> Alert.serverNotReachedAlert error
      , cmd |> Cmd.map UserDetailsForm
      )

newLikeStatusResultHandler result model cmd =
  case result of
    Ok { alert, data } ->
      ( { model | alert = alert, receivedNewLikeStatus = data }
      , cmd |> Cmd.map LikeForm
      )
    Err error ->
      ( model |> Alert.serverNotReachedAlert error
      , cmd |> Cmd.map LikeForm
      )

openFeedResultHandler result model cmd =
  case result of
    Ok { alert, data } ->
      case data of
        Just (pageContent, myFiltersForm) ->
          ( { model | alert = alert, receivedFilters = Just pageContent, receivedPageContent = Just myFiltersForm }
          , cmd |> Cmd.map OpenFeedForm
          )
        Nothing ->
          ( { model | alert = alert }
          , cmd |> Cmd.map OpenFeedForm
          )
    Err error ->
      ( model |> Alert.serverNotReachedAlert error
      , cmd |> Cmd.map OpenFeedForm
      )

feedPageResultHandler : Result Http.Error (DataAlert (List User)) -> Model -> Cmd (Form.Msg (DataAlert (List User))) -> (Model, Cmd Msg)
feedPageResultHandler result model cmd =
  case result of
    Ok { alert, data } ->
      ( { model
          | alert = alert
          , receivedPageContent =
              Maybe.map
                (\pc -> { pc | users = Maybe.withDefault pc.users data })
                model.receivedPageContent
        }
      , cmd |> Cmd.map FeedPageForm
      )
    Err error ->
      ( model |> Alert.serverNotReachedAlert error
      , cmd |> Cmd.map FeedPageForm
      )

discutionResultHandler : Result Http.Error (DataAlert Discution) -> Model -> Cmd (Form.Msg (DataAlert Discution)) -> (Model, Cmd Msg)
discutionResultHandler result model cmd =
  case result of
    Ok { alert, data } ->
      ( { model | alert = alert, receivedDiscution = data }
      , cmd |> Cmd.map DiscutionForm
      )
    Err error ->
      ( model |> Alert.serverNotReachedAlert error
      , cmd |> Cmd.map DiscutionForm
      )

chatResultHandler result model cmd =
  case result of
    Ok { alert, data } ->
      ( { model | alert = alert, receivedChat = data }
      , cmd |> Cmd.map ChatForm
      )
    Err error ->
      ( model |> Alert.serverNotReachedAlert error
      , cmd |> Cmd.map ChatForm
      )

filtersResultHandler result model cmd =
  case result of
    Ok { alert, data } ->
      ( { model | alert = alert, receivedPageContent = data }
      , cmd |> Cmd.map FiltersForm
      )
    Err error ->
      ( model |> Alert.serverNotReachedAlert error
      , cmd |> Cmd.map FiltersForm
      )

confirmAccountResultHandler result model cmd =
  case result of
    Ok (Ok message) ->
      ( model |> Alert.successAlert message
      , cmd |> Cmd.map ConfirmAccountForm
      )
    Ok (Err message) ->
      ( model |> Alert.invalidImputAlert message
      , cmd |> Cmd.map ConfirmAccountForm
      )
    Err error ->
      ( model |> Alert.serverNotReachedAlert error
      , cmd |> Cmd.map ConfirmAccountForm
      )

retreiveAccountResultHandler result model cmd =
  case result of
    Ok (Ok message) ->
      ( model |> Alert.successAlert message
      , cmd |> Cmd.map RetreiveAccountForm
      )
    Ok (Err message) ->
      ( model |> Alert.invalidImputAlert message
      , cmd |> Cmd.map RetreiveAccountForm
      )
    Err error ->
      ( model |> Alert.serverNotReachedAlert error
      , cmd |> Cmd.map RetreiveAccountForm
      )

updatePasswordResultHandler result model cmd =
  case result of
    Ok (Ok message) ->
      ( model |> Alert.successAlert message
      , cmd |> Cmd.map UpdatePasswordForm
      )
    Ok (Err message) ->
      ( model |> Alert.invalidImputAlert message
      , cmd |> Cmd.map UpdatePasswordForm
      )
    Err error ->
      ( model |> Alert.serverNotReachedAlert error
      , cmd |> Cmd.map UpdatePasswordForm
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
    Err error ->
      ( model |> Alert.serverNotReachedAlert error
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
    Err error ->
      ( model |> Alert.serverNotReachedAlert error
      , cmd |> Cmd.map SignupForm
      )


-- user details

type alias UserDetails =
  { id : Int
  , pseudo : String
  , first_name : String
  , last_name : String
  , gender : Gender
  , orientation : Orientation
  , biography : String
  , birth : String
  , last_log : LastLog
  , pictures : List String
  , popularity_score : Int
  , tags : List String
  , liked : Bool
  }

type Gender
  = Man
  | Woman

type Orientation
  = Homosexual
  | Bisexual
  | Heterosexual

userDetailsDecoder : Decoder UserDetails
userDetailsDecoder =
  Field.require "id" Decode.int <| \id ->
  Field.require "pseudo" Decode.string <| \pseudo ->
  Field.require "first_name" Decode.string <| \first_name ->
  Field.require "last_name" Decode.string <| \last_name ->
  Field.require "gender" genderDecoder <| \gender ->
  Field.require "orientation" orientationDecoder <| \orientation ->
  Field.require "biography" Decode.string <| \biography ->
  Field.require "birth" Decode.string <| \birth ->
  Field.require "last_log" lastLogDecoder <| \last_log ->
  Field.require "pictures" (Decode.list Decode.string) <| \pictures ->
  Field.require "popularity_score" Decode.int <| \popularity_score ->
  Field.require "tags" (Decode.list Decode.string) <| \tags ->
  Field.require "liked" Decode.bool <| \liked ->

  Decode.succeed
    { id = id
    , pseudo = pseudo
    , first_name = first_name
    , last_name = last_name
    , gender = gender
    , orientation = orientation
    , biography = biography
    , birth = birth
    , last_log = last_log
    , pictures = pictures
    , popularity_score = popularity_score
    , tags = tags
    , liked = liked
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

requestUserDetails : Form (DataAlert UserDetails)
requestUserDetails =
  Form.form (dataAlertDecoder userDetailsDecoder) (OnSubmit "Request user details") "http://localhost/control/user_info.php"
  |> Form.numberField "id" 0

-- feed

type alias User =
  { id : Int
  , pseudo : String
  , picture : String
  , tags : List String
  , liked : Bool
  }

type alias FiltersEdgeValues =
  { ageMin : Float
  , ageMax : Float
  , distanceMax : Float
  , popularityMin : Float
  , popularityMax : Float
  }

type alias PageContent =
  { pageAmount : Int
  , elemAmount : Int
  , users : List User
  }

defaultFiltersEdgeValues : FiltersEdgeValues
defaultFiltersEdgeValues =
  { ageMin = 13
  , ageMax = 90
  , distanceMax = 8
  , popularityMin = 0
  , popularityMax = 200
  }

filtersForm : FiltersEdgeValues -> Form (DataAlert PageContent)
filtersForm {ageMin, ageMax, distanceMax, popularityMin, popularityMax} =
  Form.form (dataAlertDecoder filterDecoder) LiveUpdate "http://localhost/control/feed_filter.php"
  |> Form.doubleSliderField "age" (ageMin, ageMax, 1)
  |> Form.doubleSliderField "popularity" (popularityMin, popularityMax, 1)
  |> Form.singleSliderField "distanceMax" (3, distanceMax, 1)
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

filterDecoder : Decoder PageContent
filterDecoder =
  Field.require "pageAmount" Decode.int <| \pageAmount ->
  Field.require "elemAmount" Decode.int <| \elemAmount ->
  Field.require "users" (Decode.list userDecoder) <| \users ->

  Decode.succeed
    { pageAmount = pageAmount
    , elemAmount = elemAmount
    , users = users
    }

requestOpenFeedForm :
  Form
    ( DataAlert
      ( Form (DataAlert PageContent)
      , PageContent
      )
    )
requestOpenFeedForm =
  Form.form (dataAlertDecoder openFeedDecoder) (OnSubmit "Open feed") "http://localhost/control/feed_open.php"

openFeedDecoder :
  Decoder
    ( Form (DataAlert PageContent)
    , PageContent
    )
openFeedDecoder =
  Field.require "filtersEdgeValues" filtersEdgeValuesDecoder <| \filtersEdgeValues ->
  Field.require "pageContent" filterDecoder <| \pageContent ->

  Decode.succeed
    ( filtersForm filtersEdgeValues
    , pageContent
    )

filtersEdgeValuesDecoder : Decoder FiltersEdgeValues
filtersEdgeValuesDecoder =
  Field.require "ageMin" Decode.float <| \ageMin ->
  Field.require "ageMax" Decode.float <| \ageMax ->
  Field.require "distanceMax" Decode.float <| \distanceMax ->
  Field.require "popularityMin" Decode.float <| \popularityMin ->
  Field.require "popularityMax" Decode.float <| \popularityMax ->

  Decode.succeed
    { ageMin = ageMin
    , ageMax = ageMax
    , distanceMax = distanceMax
    , popularityMin = popularityMin
    , popularityMax = popularityMax
    }


-- confirm account

requestAccountConfirmationForm : Form (Result String String)
requestAccountConfirmationForm =
  Form.form resultMessageDecoder (OnSubmit "confirm account") "http://localhost/control/account_confirmation.php"
  |> Form.textField "a"
  |> Form.textField "b"


-- retreive password

requestAccountRetrievalForm : Form (Result String String)
requestAccountRetrievalForm =
  Form.form resultMessageDecoder (OnSubmit "Retrieve password") "http://localhost/control/password_retrieval.php"
  |> Form.textField "a"
  |> Form.textField "b"
  |> Form.passwordField "newpw"
  |> Form.passwordField "confirm"


-- update password

requestUpdatePasswordForm : Form (Result String String)
requestUpdatePasswordForm =
  Form.form resultMessageDecoder (OnSubmit "update password") "http://localhost/control/password_update.php"
  |> Form.passwordField "oldpw"
  |> Form.passwordField "newpw"
  |> Form.passwordField "confirm"


-- like

requestLikeForm : Form (DataAlert Bool)
requestLikeForm =
  Form.form (dataAlertDecoder likeStatusDecoder) (OnSubmit "Request like") "http://localhost/control/user_like.php"
  |> Form.numberField "id" 0

likeStatusDecoder : Decoder Bool
likeStatusDecoder =
  Field.require "newLikeStatus" Decode.bool <| \newLikeStatus ->
  Decode.succeed newLikeStatus


-- send message

requestSendMessageForm : Form ConfirmAlert
requestSendMessageForm =
  Form.form confirmAlertDecoder (OnSubmit "Send message to that id") "http://localhost/control/chat_message.php"
  |> Form.numberField "id" 0
  |> Form.textField "content"

confirmAlertDecoder : Decoder { confirm: Bool, alert: Maybe Alert }
confirmAlertDecoder =
  Field.require "confirm" Decode.bool <| \confirm ->
  Field.attempt "alert" alertDecoder <| \alert ->

  Decode.succeed ({ confirm = confirm, alert = alert })


-- notifications

requestUnreadNotifsAmount : Cmd Msg
requestUnreadNotifsAmount =
  Http.post
      { url = "http://localhost/control/account_notifs_amount.php"
      , body = emptyBody
      , expect = Http.expectJson ReceiveUnreadNotifsAmount (dataAlertDecoder unreadNotifsAmountDecoder)
      }

unreadNotifsAmountDecoder : Decoder Int
unreadNotifsAmountDecoder =
  Field.require "amount" Decode.int <| \amount ->
  Decode.succeed amount

type alias Notif =
  { id : Int
  , content : String
  , date : String
  , unread : Bool
  }

requestNotifsForm : Form (DataAlert (List Notif))
requestNotifsForm =
  Form.form (Decode.list notifDecoder |> dataAlertDecoder) (OnSubmit "Request notifs") "http://localhost/control/account_notifs.php"

notifDecoder : Decoder Notif
notifDecoder =
  Field.require "id" Decode.int <| \id ->
  Field.require "content" Decode.string <| \content ->
  Field.require "date" Decode.string <| \date ->
  Field.require "unread" Decode.bool <| \unread ->

  Decode.succeed
    { id = id
    , content = content
    , date = date
    , unread = unread
    }


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

type alias ConfirmAlert =
  { alert : Maybe Alert, confirm : Bool }

requestChatsForm : Form (DataAlert (List Chat))
requestChatsForm =
  Form.form (dataAlertDecoder (Decode.list chatDecoder)) (OnSubmit "Request chats") "http://localhost/control/chat_list.php"

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
  Form.form (dataAlertDecoder discutionDecoder) (OnSubmit "Request discution") "http://localhost/control/chat_discution.php"
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
  Field.require "data" dataDecoder <| \data ->
  Field.attempt "alert" alertDecoder <| \alert ->

  Decode.succeed ({ data = Just data, alert = alert })


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
            [ a [ href "/signin" ]
                [ text "signout" ]
            ]

testView : Model -> Html Msg
testView model =
  Html.div []
            [ br [] [], text "account_confirmation.php"
            , Form.view model.confirmAccountForm |> Html.map ConfirmAccountForm
            , br [] [], text "account_notifs.php"
            , Form.view model.notifsForm |> Html.map NotifsForm
            , br [] [], text "chat_discution.php"
            , Form.view model.discutionForm |> Html.map DiscutionForm
            , br [] [], text "chat_list.php"
            , Form.view model.chatForm |> Html.map ChatForm
            , br [] [], text "chat_message.php"
            , Form.view model.sendMessageForm |> Html.map SendMessageForm
            , br [] [], text "feed_open.php"
            , Form.view model.openFeedForm |> Html.map OpenFeedForm
            , Maybe.withDefault (text "...")
                ( Maybe.map
                    (\opf -> Form.view opf |> Html.map FiltersForm)
                    model.receivedFilters
                )
            , br [] [], br [] [], text "feed_page.php"
            , Form.view model.feedPageForm |> Html.map FeedPageForm
            , br [] [], text "password_retrieval.php"
            , Form.view model.retreivedAccountForm |> Html.map RetreiveAccountForm
            , br [] [], text "password_update.php"
            , Form.view model.updatePasswordForm |> Html.map UpdatePasswordForm
            , br [] [], text "user_info.php"
            , Form.view model.userDetailsForm |> Html.map UserDetailsForm
            , br [] [], text "user_like.php"
            , Form.view model.newLikeStatusForm |> Html.map LikeForm
            , br [] [], br [] [], br [] []
            , text (Debug.toString model)
            ]


-- subscriptions

subscriptions : Model -> Sub Msg
subscriptions model =
  [ Form.subscriptions model.signin |> Sub.map SigninForm
  , Form.subscriptions model.signup |> Sub.map SignupForm
  , model.receivedFilters
    |> Maybe.map (\rFF -> Form.subscriptions rFF |> Sub.map FiltersForm)
    |> Maybe.withDefault Sub.none
  -- , Time.every 1000 Tick
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
