module Main exposing (..)


-- imports

import Browser exposing (application, UrlRequest)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

import Url exposing (..)
import Url.Parser as Parser exposing (..)
import Url.Parser.Query as PQuery exposing (..)
import Browser.Navigation as Nav exposing (..)

import Json.Decode as Decode exposing (..)
import Json.Decode.Field as Field exposing (..)

import Http exposing (..)

import Array exposing (..)
import Time exposing (..)


-- modules

import Alert exposing (..)
import Form exposing (..)
import Feed exposing (..)
import BasicValues exposing (..)


-- model

type alias Model =
  { route : Route
  , key : Nav.Key
  , alert : Maybe Alert
  , access : Access
  }

type Access
  = Logged LModel
  | Anonymous AModel

type alias LModel =
  { pseudo : String
  , picture : String
  -- feed
  , filtersForm : Maybe FiltersForm
  , feedContent : List Profile
  , feedPageNumber : Int
  , feedPageAmount : Int
  , feedElemAmount : Int
  -- user
  , userDetails : Maybe UserDetails
  -- header
  , unreadNotifsAmount : Int
  -- notifs
  , notifs : List Notif
  -- signout
  , signoutForm : Form (Result String String)
  -- chat
  , chats : List Chat
  , discution : Maybe Discution
  -- settings
  , updatePasswordForm : Form (Result String String)
  }

type alias AModel =
  { signinForm : Form (DataAlert { pseudo: String, picture: String })
  , signupForm : Form (Result String String)
  -- retreive
  , accountRetrievalForm : Maybe (Form (Result String String))
  -- confirm
  , accountConfirmationForm : Maybe (Form (Result String String))
  }


-- init

init : Maybe { pseudo : String, picture : String } -> Url -> Nav.Key -> (Model, Cmd Msg)
init flags url key =
  let route = urlToRoute (url |> Debug.log "url") |> Debug.log "route" in
  ( { route = route
    , key = key
    , alert = Nothing
    , access =
        case flags of
          Nothing ->
            anonymousAccessInit route
          Just { pseudo, picture } ->
            loggedAccessInit pseudo picture
    }
  , Cmd.none
  )

anonymousAccessInit : Route -> Access
anonymousAccessInit route =
  case route of
    Retreive a b -> Anonymous
      { signinForm = signinFormInit
      , signupForm = signupFormInit
      , accountRetrievalForm = Just (requestAccountRetrievalForm a b)
      , accountConfirmationForm = Nothing
      }
    Confirm a b -> Anonymous
      { signinForm = signinFormInit
      , signupForm = signupFormInit
      , accountRetrievalForm = Nothing
      , accountConfirmationForm = Just (requestAccountConfirmationForm a b)
      }
    _ -> Anonymous
      { signinForm = signinFormInit
      , signupForm = signupFormInit
      , accountRetrievalForm = Nothing
      , accountConfirmationForm = Nothing
      }

loggedAccessInit : String -> String -> Access
loggedAccessInit pseudo picture = Logged
  { pseudo = pseudo
  , picture = picture
  , filtersForm = Nothing
  , feedContent = []
  , feedPageNumber = 0
  , feedPageAmount = 0
  , feedElemAmount = 0
  , userDetails = Nothing
  , unreadNotifsAmount = 0
  , notifs = []
  , signoutForm = signoutFormInit
  , chats = []
  , discution = Nothing
  , updatePasswordForm = requestUpdatePasswordForm
  }


-- decoders

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
  = Home
  | Signin
  | Signup
  | User Int
  | Notifs
  | Chats
  | Retreive Int Int
  | Confirm Int Int
  | Settings
  | Unknown

routeParser : Parser.Parser (Route -> a) a
routeParser =
  Parser.oneOf
    [ Parser.map Home     (Parser.top)
    , Parser.map Signin   (Parser.s "signin")
    , Parser.map Signup   (Parser.s "signup")
    , Parser.map User     (Parser.s "user" </> Parser.int)
    , Parser.map Notifs   (Parser.s "notifs")
    , Parser.map Chats    (Parser.s "chat")
    , Parser.map Retreive (Parser.s "retreive" </> Parser.int </> Parser.int)
    , Parser.map Confirm  (Parser.s "confirm" </> Parser.int </> Parser.int)
    , Parser.map Settings (Parser.s "settings")
    ]

urlToRoute : Url -> Route
urlToRoute url =
  Parser.parse routeParser url
  |> Maybe.withDefault Unknown


-- update

type Msg
  = NoOp
  | InternalLinkClicked Url
  | ExternalLinkClicked String
  | UrlChange Url
  | Tick Time.Posix
  | SigninForm (Form.Msg (DataAlert { pseudo: String, picture: String }))
  | SignupForm (Form.Msg (Result String String))
  | SignoutForm (Form.Msg (Result String String))
  | UpdatePasswordForm (Form.Msg (Result String String))
  | ReceiveFeedInit (Result Http.Error (DataAlert (FiltersForm, PageContent)))
  | FiltersForm FiltersFormMsg
  | FeedNav Int
  | ReceivePageContentUpdate (Result Http.Error (DataAlert PageContent))
  | Like Int
  | ReceiveLikeUpdate (Result Http.Error (DataAlert (Int, Bool)))
  | ReceiveUserDetails (Result Http.Error (DataAlert UserDetails))
  | ReceiveUnreadNotifsAmount (Result Http.Error (DataAlert Int))
  | ReceiveNotifS (Result Http.Error (DataAlert (List Notif)))
  | ReceiveChats (Result Http.Error (DataAlert (List Chat)))
  | AccessDiscution Int
  | ReceiveDiscution (Result Http.Error (DataAlert Discution))
  | ReceiveDiscutionRefresh (Result Http.Error (DataAlert Discution))
  | SendMessageForm (Form.Msg ConfirmAlert)
  | AccountRetrievalForm (Form.Msg (Result String String))
  | AccountConfirmationForm (Form.Msg (Result String String))

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case (model.access, model.route, msg) of
    (Anonymous amodel, _, InternalLinkClicked url) ->
      ( model
      , Nav.pushUrl model.key (Url.toString url)
      )

    (Logged _, _, InternalLinkClicked url) ->
      let newRoute = urlToRoute url in
      case newRoute of
        Home ->
          ( model
          , requestFeedInit ReceiveFeedInit
          )
        User id ->
          ( model
          , Cmd.batch
              [ requestUserDetails id ReceiveUserDetails
              , Nav.pushUrl model.key (Url.toString url)
              ]
          )
        Notifs ->
          ( model
          , Cmd.batch
              [ requestNotifs ReceiveNotifS
              , Nav.pushUrl model.key (Url.toString url)
              ]
          )
        Chats ->
          ( model
          , Cmd.batch
              [ requestChats ReceiveChats
              , Nav.pushUrl model.key (Url.toString url)
              ]
          )
        _ ->
          ( model
          , Nav.pushUrl model.key (Url.toString url)
          )

    (Logged _, _, ExternalLinkClicked href) ->
      (model, Nav.load href)

    (Anonymous amodel, _, UrlChange url) ->
      let newRoute = urlToRoute url in
      case newRoute of
        Retreive a b ->
          let
            accountRetrievalForm = Just
              (requestAccountRetrievalForm a b)
          in
            ( { model | route = newRoute, access = Anonymous
                { amodel | accountRetrievalForm = accountRetrievalForm }
              }
            , Cmd.none
            )
        Confirm a b ->
          let
            accountConfirmationForm = Just
              (requestAccountConfirmationForm a b)
          in
            ( { model | route = newRoute, access = Anonymous
                { amodel | accountConfirmationForm = accountConfirmationForm }
              }
            , Cmd.none
            )
        _ ->
          ({ model | route = newRoute }, Cmd.none)

    (_, _, UrlChange url) ->
      ({ model | route = urlToRoute url }, Cmd.none)

    (Logged lmodel, Notifs, Tick _) ->
      ( model
      , Cmd.batch
          [ requestNotifs ReceiveNotifS
          , requestUnreadNotifsAmount
          ]
      )

    (Logged lmodel, Chats, Tick _) ->
      ( model
      , Cmd.batch
          [ requestChats ReceiveChats
          , lmodel.discution
            |> Maybe.map (\lmd-> requestDiscution lmd.id ReceiveDiscutionRefresh)
            |> Maybe.withDefault Cmd.none
          , requestUnreadNotifsAmount
          ]
      )

    (Logged lmodel, _, Tick _) ->
      (model, requestUnreadNotifsAmount)

    (Anonymous amodel, Signin, SigninForm formMsg) ->
      let
        (newForm, formCmd, response) = Form.update formMsg amodel.signinForm
      in
      case response of
        Nothing ->
          ( { model | access = Anonymous { amodel | signinForm = newForm } }
          , formCmd |> Cmd.map SigninForm
          )
        Just result ->
          case toWebResultDataAlert result of
            AvData { pseudo, picture } alert ->
              ( { model | access = loggedAccessInit pseudo picture }
                |> Alert.put alert
              , Cmd.batch
                [ Nav.pushUrl model.key "/"
                , formCmd |> Cmd.map SigninForm
                ]
              )
            NoData alert ->
              ( model |> Alert.put alert
              , formCmd |> Cmd.map SigninForm
              )
            Error error ->
              ( model |> (Alert.put << Just) (Alert.serverNotReachedAlert error)
              , formCmd |> Cmd.map SigninForm
              )

    (Anonymous amodel, Signup, SignupForm formMsg) ->
      let
        (newForm, formCmd, response) = Form.update formMsg amodel.signupForm
      in
        case response of
          Just result ->
            signupFormResultHandler result model formCmd
          Nothing ->
            ( { model | access = Anonymous { amodel | signupForm = newForm } }
            , formCmd |> Cmd.map SignupForm
            )

    (Anonymous amodel, _, AccountRetrievalForm formMsg) ->
      case amodel.accountRetrievalForm of
        Nothing -> ( model, Cmd.none )
        Just accountRetrievalForm ->
          let
            (newForm, formCmd, response) = Form.update formMsg accountRetrievalForm
          in
            case response of
              Just result ->
                retreiveAccountResultHandler result { model | access = Anonymous { amodel | accountRetrievalForm = Just newForm } } formCmd
              Nothing ->
                ( { model | access = Anonymous { amodel | accountRetrievalForm = Just newForm } }
                , formCmd |> Cmd.map AccountRetrievalForm
                )

    (Logged lmodel, _, SignoutForm formMsg) ->
      let
        (newForm, formCmd, response) = Form.update formMsg lmodel.signoutForm
      in
        case response of
          Just result ->
            signoutFormResultHandler result model formCmd
          Nothing ->
            ( { model | access = Logged { lmodel | signoutForm = newForm } }
            , formCmd |> Cmd.map SignoutForm
            )

    (Logged lmodel, _, ReceiveFeedInit result) ->
      case result of
        Ok { data, alert } ->
          ( { model | alert = alert, access = Logged (receiveFeedInit data lmodel) }
          , Cmd.none
          )
        Err error ->
          ( model |> (Alert.put << Just) (Alert.serverNotReachedAlert error)
          , Cmd.none
          )

    (Logged lmodel, _, FiltersForm formMsg) ->
      case lmodel.filtersForm of
        Nothing -> ( model, Cmd.none )
        Just currentFiltersForm ->
          let
            (newForm, formCmd, response) = Form.update formMsg currentFiltersForm
          in
            case response of
              Just (Ok { data, alert }) ->
                ( { model | alert = alert, access = Logged (receivePageContentUpdate True data lmodel) }
                , formCmd |> Cmd.map FiltersForm
                )
              Just (Err error) ->
                ( { model | access = Logged { lmodel | filtersForm = Just newForm } }
                    |> (Alert.put << Just) (Alert.serverNotReachedAlert error)
                , formCmd |> Cmd.map FiltersForm
                )
              Nothing ->
                ( { model | access = Logged { lmodel | filtersForm = Just newForm } }
                , formCmd |> Cmd.map FiltersForm
                )

    (Logged lmodel, Home, FeedNav page) ->
      let maybeNewLModelCmdTuple = requestFeedPage page ReceivePageContentUpdate lmodel in
      case maybeNewLModelCmdTuple of
        Just (newLModel, pageRequestCmd) ->
          ( { model | access = Logged newLModel }, pageRequestCmd )
        Nothing ->
          ( model, Cmd.none )

    (Logged lmodel, _, ReceivePageContentUpdate result) ->
      case result of
        Ok { data, alert } ->
          ( { model | alert = alert, access = Logged (receivePageContentUpdate False data lmodel) }
          , Cmd.none
          )
        Err error ->
          ( model |> (Alert.put << Just) (Alert.serverNotReachedAlert error)
          , Cmd.none
          )

    (Logged lmodel, Home, Like id) ->
      let likeRequest = requestLike id ReceiveLikeUpdate in
      ( model, likeRequest )
    (Logged lmodel, User urlId, Like id) ->
      if urlId == id
      then
        let likeRequest = requestLike id ReceiveLikeUpdate in
        ( model, likeRequest )
      else
        ( model, Cmd.none )

    (Logged lmodel, _, ReceiveLikeUpdate result) ->
      case toWebResultDataAlert result of
        AvData (id, newLikeStatus) alert ->
          ( { model | alert = alert , access = Logged
              { lmodel
                  | feedContent = lmodel.feedContent |> List.map
                      (\profile ->
                        if profile.id == id
                        then { profile | liked = newLikeStatus }
                        else profile
                      )
                  , userDetails = lmodel.userDetails |> Maybe.map
                      (\usrd->
                        if usrd.id == id
                        then { usrd | liked = newLikeStatus }
                        else usrd
                      )
              }
            }
          , Cmd.none
          )
        NoData alert ->
          ( model |> (Alert.put << Just) (Alert.invalidImputAlert "Sory we can't let you like/unlike this persone. It could be because your account isn't complete.")
          , Cmd.none
          )
        Error error ->
          ( model |> (Alert.put << Just) (Alert.serverNotReachedAlert error)
          , Cmd.none
          )

    (Logged lmodel, _, ReceiveUserDetails result) ->
      case toWebResultDataAlert result of
        AvData userDetails alert ->
          ( { model | alert = alert , access = Logged
              { lmodel | userDetails = Just userDetails }
            }
          , Cmd.none
          )
        NoData alert ->
          ( { model | access = Logged { lmodel | userDetails = Nothing } }
            |> (Alert.put << Just) (Alert.invalidImputAlert "Sory we can't let you access this user's infos. It could be because your account isn't complete.")
          , Cmd.none
          )
        Error error ->
          ( model |> (Alert.put << Just) (Alert.serverNotReachedAlert error)
          , Cmd.none
          )

    (Logged lmodel, _, ReceiveUnreadNotifsAmount result) ->
      (unreadNotifsAmountResultHandler result lmodel model, Cmd.none)

    (Logged lmodel, _, ReceiveNotifS result) ->
      case toWebResultDataAlert result of
        AvData newNotifList alert ->
          ( { model | alert = alert , access = Logged
              { lmodel | notifs = newNotifList }
            }
          , Cmd.none
          )
        NoData alert ->
          ( model |> (Alert.put << Just) (Alert.invalidImputAlert "Sory we can't let you access this user's infos. It could be because your account isn't complete.")
          , Cmd.none
          )
        Error error ->
          ( model |> (Alert.put << Just) (Alert.serverNotReachedAlert error)
          , Cmd.none
          )

    (Logged lmodel, _, ReceiveChats result) ->
      case toWebResultDataAlert result of
        AvData chatList alert ->
          ( { model | access = Logged { lmodel | chats = chatList } }
              |> Alert.put alert
          , Cmd.none
          )
        NoData alert ->
          ( model |> Alert.put alert
          , Cmd.none
          )
        Error error ->
          ( model |> Alert.put (Just (Alert.serverNotReachedAlert error))
          , Cmd.none
          )

    (Logged lmodel, Chats, AccessDiscution id) ->
      ( model, requestDiscution id ReceiveDiscution )

    (Logged lmodel, _, ReceiveDiscution result) ->
      case result of
        Ok { data, alert } ->
          ( { model | alert = alert , access = Logged
              { lmodel | discution = data }
            }
          , Cmd.none
          )
        Err error ->
          ( model |> (Alert.put << Just) (Alert.serverNotReachedAlert error)
          , Cmd.none
          )

    (Logged lmodel, _, ReceiveDiscutionRefresh result) ->
      case toWebResultDataAlert result of
        AvData newDiscution alert ->
          ( { model | access = Logged
              { lmodel | discution =
                  Maybe.map
                    (\ oldDiscution -> { newDiscution | sendMessageForm = oldDiscution.sendMessageForm } )
                    lmodel.discution
              }
            } |> Alert.put alert
          , Cmd.none
          )
        NoData alert ->
          ( model |> Alert.put alert
          , Cmd.none
          )
        Error error ->
          ( model |> (Alert.put << Just) (Alert.serverNotReachedAlert error)
          , Cmd.none
          )

    (Logged lmodel, _, SendMessageForm formMsg) ->
      Maybe.withDefault ( model, Cmd.none ) <| Maybe.map
        (\discution ->
          let
            (newForm, formCmd, response) = Form.update formMsg discution.sendMessageForm
          in
            case response of
              Nothing ->
                ( model |> setSendMessageForm newForm discution lmodel
                , formCmd |> Cmd.map SendMessageForm
                )
              Just result ->
                ( sendMessageFormResultHandler result discution lmodel model
                  |> setSendMessageForm newForm discution lmodel
                , formCmd |> Cmd.map SendMessageForm
                )
        ) lmodel.discution

    (Logged lmodel, _, UpdatePasswordForm formMsg) ->
      let
        (newForm, formCmd, response) = Form.update formMsg lmodel.updatePasswordForm
      in
        case response of
          Just result ->
            updatePasswordResultHandler result { lmodel | updatePasswordForm = newForm } model formCmd
          Nothing ->
            ( { model | access = Logged
                  { lmodel | updatePasswordForm = newForm }
              }
            , formCmd |> Cmd.map UpdatePasswordForm
            )

    _ -> ( model, Cmd.none )


type WebResultDataAlert data
  = AvData data (Maybe Alert)
  | NoData (Maybe Alert)
  | Error Http.Error

toWebResultDataAlert : Result Http.Error (DataAlert a) -> WebResultDataAlert a
toWebResultDataAlert result =
  case result of
    Ok { data, alert } ->
      case data of
        Just val -> AvData val alert
        Nothing -> NoData alert
    Err error -> Error error

sendMessageFormResultHandler result discution lmodel model =
  case result of
    Ok { confirm, alert } ->
      model
      |> Alert.withDefault
          ( if confirm
            then Alert.successAlert "Message sent!"
            else Alert.invalidImputAlert "We can't send that message to this user. It may be because your or his/her account isn't complete or because there is no match between you two."
          ) alert

    Err error ->
      model
      |> (Alert.put << Just << Alert.serverNotReachedAlert) error

setSendMessageForm : Form ConfirmAlert -> Discution -> LModel -> Model -> Model
setSendMessageForm newForm discution lmodel model =
  { model | access = Logged
      { lmodel | discution = Just
          { discution | sendMessageForm = newForm }
      }
  }

unreadNotifsAmountResultHandler : Result Http.Error (DataAlert Int) -> LModel -> Model -> Model
unreadNotifsAmountResultHandler result lmodel model =
  case result of
    Ok { alert, data } ->
      let newAlert = if alert == Nothing then model.alert else alert in -- //ni: alert smarter update
        data
        |> Maybe.map
            (\amount ->
              { model
                | alert = newAlert
                , access = Logged { lmodel | unreadNotifsAmount = amount }
              }
            )
        |> Maybe.withDefault
            (model |> (Alert.put << Just) (Alert.serverNotReachedAlert (Http.BadBody "Data not received for notifs amount")))
    Err error ->
      model |> (Alert.put << Just) (Alert.serverNotReachedAlert error)

signupFormResultHandler result model cmd =
  case result of
    Ok (Ok message) ->
      ( model |> (Alert.put << Just) (Alert.successAlert message)
      , Cmd.batch
        [ Nav.pushUrl model.key "/signin"
        , cmd |> Cmd.map SignupForm
        ]
      )
    Ok (Err message) ->
      ( model |> (Alert.put << Just) (Alert.invalidImputAlert message)
      , cmd |> Cmd.map SignupForm
      )
    Err error ->
      ( model |> (Alert.put << Just) (Alert.serverNotReachedAlert error)
      , cmd |> Cmd.map SignupForm
      )

signoutFormResultHandler : Result Http.Error (Result String String) -> Model -> Cmd (Form.Msg (Result String String)) -> (Model, Cmd Msg)
signoutFormResultHandler result model cmd =
  case result of
    Ok (Ok message) ->
      ( { model | access = anonymousAccessInit model.route }  |> (Alert.put << Just) (Alert.successAlert message)
      , Cmd.batch
        [ Nav.pushUrl model.key "/"
        , cmd |> Cmd.map SignoutForm
        ]
      )
    Ok (Err message) ->
      ( model |> (Alert.put << Just) (Alert.invalidImputAlert message)
      , cmd |> Cmd.map SignoutForm
      )
    Err error ->
      ( model |> (Alert.put << Just) (Alert.serverNotReachedAlert error)
      , cmd |> Cmd.map SignoutForm
      )

retreiveAccountResultHandler result model cmd =
  case result of
    Ok (Ok message) ->
      ( model |> (Alert.put << Just) (Alert.successAlert message)
      , cmd |> Cmd.map AccountRetrievalForm
      )
    Ok (Err message) ->
      ( model |> (Alert.put << Just) (Alert.invalidImputAlert message)
      , cmd |> Cmd.map AccountRetrievalForm
      )
    Err error ->
      ( model |> (Alert.put << Just) (Alert.serverNotReachedAlert error)
      , cmd |> Cmd.map AccountRetrievalForm
      )

updatePasswordResultHandler result lmodel model cmd =
  case result of
    Ok (Ok message) ->
      ( { model | access = Logged lmodel }
        |> (Alert.put << Just << Alert.successAlert) message
      , cmd |> Cmd.map UpdatePasswordForm
      )
    Ok (Err message) ->
      ( { model | access = Logged lmodel }
        |> (Alert.put << Just << Alert.invalidImputAlert) message
      , cmd |> Cmd.map UpdatePasswordForm
      )
    Err error ->
      ( { model | access = Logged lmodel }
        |> (Alert.put << Just << Alert.serverNotReachedAlert) error
      , cmd |> Cmd.map UpdatePasswordForm
      )


-- update password

requestUpdatePasswordForm : Form (Result String String)
requestUpdatePasswordForm =
  Form.form resultMessageDecoder (OnSubmit "update password") "http://localhost/control/password_update.php" []
  |> Form.passwordField "oldpw"
  |> Form.passwordField "newpw"
  |> Form.passwordField "confirm"


-- chat

type alias Chat =
  { id : Int
  , pseudo : String
  , picture : String
  , last_log : LastLog
  , last_message : String
  , unread : Bool
  }

type alias Discution =
  { id : Int
  , sendMessageForm : Form ConfirmAlert
  , pseudo : String
  , picture : String
  , last_log : LastLog
  , messages : List Message
  }

type alias Message =
  { sent : Bool
  , date : String
  , content : String
  }

requestChats : (Result Http.Error (DataAlert (List Chat)) -> msg) -> Cmd msg
requestChats toMsg =
  Http.post
      { url = "http://localhost/control/chat_list.php"
      , body = emptyBody
      , expect = Http.expectJson toMsg (Decode.list chatDecoder |> dataAlertDecoder)
      }

requestDiscution : Int -> (Result Http.Error (DataAlert Discution) -> msg) -> Cmd msg
requestDiscution id toMsg =
  Http.post
      { url = "http://localhost/control/chat_discution.php"
      , body = multipartBody [stringPart "id" (String.fromInt id)]
      , expect = Http.expectJson toMsg (dataAlertDecoder discutionDecoder)
      }

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
    , last_message = last_message
    , unread = unread
    }

discutionDecoder : Decoder Discution
discutionDecoder =
  Field.require "id" Decode.int <| \id ->
  Field.require "pseudo" Decode.string <| \pseudo ->
  Field.require "picture" Decode.string <| \picture ->
  Field.require "last_log" lastLogDecoder <| \last_log ->
  Field.require "messages" (Decode.list messageDecoder) <| \messages ->

  Decode.succeed
    { id = id
    , sendMessageForm = requestSendMessageForm id
    , pseudo = pseudo
    , picture = picture
    , last_log = last_log
    , messages = messages
    }

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


-- send message

requestSendMessageForm : Int -> Form ConfirmAlert
requestSendMessageForm id =
  Form.form confirmAlertDecoder (OnSubmit "Send message to that id") "http://localhost/control/chat_message.php" [("id", String.fromInt id)]
  |> Form.textField "content"

confirmAlertDecoder : Decoder { confirm: Bool, alert: Maybe Alert }
confirmAlertDecoder =
  Field.require "confirm" Decode.bool <| \confirm ->
  Field.attempt "alert" alertDecoder <| \alert ->

  Decode.succeed ({ confirm = confirm, alert = alert })


-- account

signinFormInit : Form (DataAlert { pseudo: String, picture: String })
signinFormInit =
  Form.form (dataAlertDecoder signinDecoder) (OnSubmit "Signin") "http://localhost/control/account_signin.php" []
  |> Form.textField "pseudo"
  |> Form.passwordField "password"

signinDecoder : Decoder { pseudo: String, picture: String }
signinDecoder =
  Field.require "pseudo" Decode.string <| \pseudo ->
  Field.require "picture" Decode.string <| \picture ->
  Decode.succeed ({ pseudo = pseudo, picture = picture })

signupFormInit : Form (Result String String)
signupFormInit =
  Form.form resultMessageDecoder (OnSubmit "Signup") "http://localhost/control/account_signup.php" []
  |> Form.textField "pseudo"
  |> Form.textField "lastname"
  |> Form.textField "firstname"
  |> Form.textField "email"
  |> Form.passwordField "password"
  |> Form.passwordField "confirm"

signoutFormInit : Form (Result String String)
signoutFormInit =
    Form.form resultMessageDecoder (OnSubmit "signout") "http://localhost/control/account_signout.php" []


-- notifs amount

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


-- notifs

type alias Notif =
  { id : Int
  , content : String
  , date : String
  , unread : Bool
  }

requestNotifs : ((Result Http.Error (DataAlert (List Notif))) -> msg) -> Cmd msg
requestNotifs myMsg =
  Http.post
      { url = "http://localhost/control/account_notifs.php"
      , body = emptyBody
      , expect = Http.expectJson myMsg (Decode.list notifDecoder |> dataAlertDecoder)
      }

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


-- like

requestLike : Int -> (Result Http.Error (DataAlert (Int, Bool)) -> msg) -> Cmd msg
requestLike id toMsg =
  Http.post
      { url = "http://localhost/control/user_like.php"
      , body = multipartBody [stringPart "id" (String.fromInt id)]
      , expect = Http.expectJson toMsg (dataAlertDecoder likeStatusDecoder)
      }

likeStatusDecoder : Decoder (Int, Bool)
likeStatusDecoder =
  Field.require "id" Decode.int <| \id ->
  Field.require "newLikeStatus" Decode.bool <| \newLikeStatus ->
  Decode.succeed (id, newLikeStatus)


-- retreive

requestAccountRetrievalForm : Int -> Int -> Form (Result String String)
requestAccountRetrievalForm a b =
  Form.form resultMessageDecoder (OnSubmit "Retrieve password") "http://localhost/control/password_retrieval.php" [("a", String.fromInt a), ("b", String.fromInt b)]
  |> Form.passwordField "newpw"
  |> Form.passwordField "confirm"


-- confirm account

requestAccountConfirmationForm : Int -> Int -> Form (Result String String)
requestAccountConfirmationForm a b =
  Form.form resultMessageDecoder (OnSubmit "confirm account") "http://localhost/control/account_confirmation.php" [("a", String.fromInt a), ("b", String.fromInt b)]


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

requestUserDetails : Int -> (Result Http.Error (DataAlert UserDetails) -> msg) -> Cmd msg
requestUserDetails id toMsg =
  Http.post
      { url = "http://localhost/control/user_info.php"
      , body = multipartBody [stringPart "id" (String.fromInt id)]
      , expect = Http.expectJson toMsg (dataAlertDecoder userDetailsDecoder)
      }

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


-- view

view : Model -> Browser.Document Msg
view model =
  case (model.access, model.route) of
    (Anonymous amodel, Signin) ->
      { title = "matcha - signin"
      , body =
        [ Alert.view model
        , signinView amodel
        ]
      }

    (Anonymous amodel, Signup) ->
      { title = "matcha - signup"
      , body =
        [ Alert.view model
        , signupView amodel
        ]
      }

    (Anonymous _, Home) ->
      { title = "matcha - home"
      , body =
        [ text "Welcome to Matcha. The best site too meet your future love!"
        , br [] [], a [ href "/signin" ] [ text "Signin" ]
        , text " or ", a [ href "/signup" ] [ text "Signup" ]
        ]
      }

    (Anonymous amodel, Retreive a b) ->
      { title = "matcha - retreive password"
      , body =
        [ Alert.view model
        , amodel.accountRetrievalForm
          |> Maybe.map (Form.view >> Html.map AccountRetrievalForm)
          |> Maybe.withDefault (div [] [])
        ]
      }

    (Anonymous amodel, Confirm a b) ->
      { title = "matcha - retreive password"
      , body =
        [ Alert.view model
        , amodel.accountConfirmationForm
          |> Maybe.map (Form.view >> Html.map AccountConfirmationForm)
          |> Maybe.withDefault (div [] [])
        ]
      }

    (Anonymous _, _) ->
      { title = "matcha - 404 page not found"
      , body =
        [ text "You seem lost", br [] []
        , a [ href "/signin" ] [ text "go to signin" ]
        ]
      }

    (Logged lmodel, Home) ->
      { title = "matcha - home"
      , body =
        [ viewHeader lmodel
        , Alert.view model
        , Maybe.map Form.view lmodel.filtersForm
          |> Maybe.map (Html.map FiltersForm)
          |> Maybe.withDefault (text "Loading...")
        , viewFeed lmodel
        ]
      }

    (Logged lmodel, User id) ->
      { title = "matcha - " ++
          ( lmodel.userDetails
            |> Maybe.map (\ud -> ud.pseudo)
            |> Maybe.withDefault "Loading..."
          )
      , body =
          [ viewHeader lmodel
          , lmodel.userDetails
            |> Maybe.map viewUserDetails
            |> Maybe.withDefault ( text "Loading..." )
          ]
      }

    (Logged lmodel, Notifs) ->
      { title = "matcha - notifications"
      , body =
        [ viewHeader lmodel
        , Alert.view model
        , viewNotifs lmodel.notifs
        ]
      }

    (Logged lmodel, Chats) ->
      { title = "matcha - notifications"
      , body =
        [ viewHeader lmodel
        , Alert.view model
        , viewChats lmodel.chats
        , viewDiscution lmodel.discution
        ]
      }

    (Logged lmodel, Settings) ->
      { title = "matcha - notifications"
      , body =
        [ viewHeader lmodel
        , Alert.view model
        , Form.view lmodel.updatePasswordForm |> Html.map UpdatePasswordForm
        ]
      }

    (Logged _, _) ->
      { title = "matcha - 404 page not found"
      , body =
        [ text "You seem lost", br [] []
        , a [ href "/" ] [ text "go back home" ]
        ]
      }

viewChats : List Chat -> Html Msg
viewChats chatList =
  div [] (List.map viewChat chatList)

viewChat : Chat -> Html Msg
viewChat chat =
  div [ if chat.unread
        then style "background-color" "LightBlue"
        else style "background-color" "White"
      , onClick (AccessDiscution chat.id)
      ]
      [ img [ src chat.picture ] []
      , text chat.pseudo
      ]

viewDiscution : Maybe Discution -> Html Msg
viewDiscution maybeDiscution =
  maybeDiscution
  |> Maybe.map
      (\discution ->
        div []
            [ div [] (List.map viewMessage discution.messages)
            , (Form.view discution.sendMessageForm |> Html.map SendMessageForm)
            ]
      )
  |> Maybe.withDefault (div [] [ text "Loading..." ])

viewMessage : Message -> Html Msg
viewMessage message =
  div [ if message.sent
        then style "background-color" "LightBlue"
        else style "background-color" "LightGrey"
      ]
      [ text message.content
      ]

viewNotifs : List Notif -> Html Msg
viewNotifs notifs =
  div [] (List.map viewNotif notifs)

viewNotif : Notif -> Html Msg
viewNotif notif =
  div [ if notif.unread
        then style "background-color" "LightBlue"
        else style "background-color" "White"
      ]
      [ text notif.content
      , br [] []
      , text notif.date
      ]

viewHeader : LModel -> Html Msg
viewHeader lmodel =
  div []
      [ a [ href "/" ] [ text "home" ]
      , a [ href "/chat" ] [ text "chat" ]
      , a [ href "/notifs" ] [ text (String.fromInt lmodel.unreadNotifsAmount)]
      , Form.view lmodel.signoutForm |> Html.map SignoutForm
      ]

viewUserDetails : UserDetails -> Html Msg
viewUserDetails userDetails =
  div []
      [ div []
          ( List.map
              (\p-> img [ src p ] [])
              userDetails.pictures
          )
      , h2 [] [ text userDetails.pseudo ]
      , h3 [] [ text (userDetails.first_name ++ " " ++ userDetails.last_name) ]
      , text (orientationToString userDetails.orientation ++ " " ++ genderToString userDetails.gender )
      , text userDetails.birth
      , br [] []
      , text userDetails.biography
      , br [] []
      , viewLikeButton userDetails.id userDetails.liked
      ]

orientationToString : Orientation -> String
orientationToString orientation =
  case orientation of
    Heterosexual -> "heterosexual"
    Homosexual -> "homosexual"
    Bisexual -> "bisexual"

genderToString : Gender -> String
genderToString gender =
  case gender of
    Man -> "man"
    Woman -> "woman"

signinView : AModel -> Html Msg
signinView amodel =
  Html.div []
            [ Form.view amodel.signinForm |> Html.map SigninForm
            , a [ href "/signup" ]
                [ text "You don't have any account?" ]
            ]

signupView : AModel -> Html Msg
signupView amodel =
  Html.div []
            [ Form.view amodel.signupForm |> Html.map SignupForm
            , a [ href "/signin" ]
                [ text "You alredy have an account?" ]
            ]

viewProfile : Profile -> Html Msg
viewProfile profile =
  div []
      [ img [ src profile.picture ] []
      , br [] []
      , a [ href ("/user/" ++ (String.fromInt profile.id)) ]
          [ text profile.pseudo ]
      , br [] []
      , div [] (List.map text profile.tags)
      , viewLikeButton profile.id profile.liked
      ]

viewLikeButton : Int -> Bool -> Html Msg
viewLikeButton id isLiked =
  button [ onClick (Like id)
         , if isLiked
           then style "background-color" "red"
           else style "background-color" "white"
         ]
         [ text "Like" ]

viewFeedPageNav : Feed a -> Html Msg
viewFeedPageNav lmodel =
  div []
    ( List.range 1 lmodel.feedPageAmount
    |> List.map (\ pageNr ->
                    button [ onClick (FeedNav (pageNr - 1))
                           , if pageNr - 1 == lmodel.feedPageNumber
                             then style "background-color" "lightblue"
                             else style "background-color" "white"
                           ]
                           [ text (String.fromInt pageNr) ]
                )
    )

viewFeed : Feed a -> Html Msg
viewFeed lmodel =
  if List.isEmpty lmodel.feedContent
  then
    text "Loading content..."
  else
    div []
        [ div [] ( List.map viewProfile lmodel.feedContent )
        , viewFeedPageNav lmodel
        ]


-- subscriptions

subscriptions : Model -> Sub Msg
subscriptions model =
  case model.access of
    Anonymous amodel ->
      anonymousAccess_sub amodel
    Logged lmodel ->
      Time.every 3000 Tick

anonymousAccess_sub : AModel -> Sub Msg
anonymousAccess_sub amodel =
  [ Form.subscriptions amodel.signinForm |> Sub.map SigninForm
  , Form.subscriptions amodel.signupForm |> Sub.map SignupForm
  ] |> Sub.batch


-- main

main : Program (Maybe { pseudo : String, picture : String }) Model Msg
main =
  Browser.application
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    , onUrlRequest = onUrlRequest
    , onUrlChange = onUrlChange
    }
