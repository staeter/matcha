module Mainb exposing (..)


-- imports

import Browser exposing (application, UrlRequest)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

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
import Feed exposing (..)


-- model

type alias Model =
  { url : Url
  , key : Nav.Key
  , alert : Maybe Alert
  , access : Access
  }

type Access
  = Logged LModel
  | Anonymous AModel

type alias LModel =
  { -- feed
    filtersForm : Maybe FiltersForm
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
  }

type alias AModel =
  { signinForm : Form (Result String String)
  , signupForm : Form (Result String String)
  }


-- init

init : () -> Url -> Nav.Key -> (Model, Cmd Msg)
init flags url key =
  ( { url = url
    , key = key
    , alert = Nothing
    , access = anonymousAccessInit
    }
  , Cmd.none
  )

anonymousAccessInit : Access
anonymousAccessInit = Anonymous
  { signinForm = signinFormInit
  , signupForm = signupFormInit
  }

loggedAccessInit : Access
loggedAccessInit = Logged
  { filtersForm = Nothing
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
  | Unknown

routeParser : Parser (Route -> a) a
routeParser =
  Parser.oneOf
    [ Parser.map Home   (Parser.top)
    , Parser.map Signin (Parser.s "signin")
    , Parser.map Signup (Parser.s "signup")
    , Parser.map User   (Parser.s "user" </> Parser.int)
    , Parser.map Notifs (Parser.s "notifs")
    , Parser.map Chats   (Parser.s "chat")
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
  | SigninForm (Form.Msg (Result String String))
  | SignupForm (Form.Msg (Result String String))
  | SignoutForm  (Form.Msg (Result String String))
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

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  let route = urlToRoute model.url in
  case (model.access, route, msg) of
    (Anonymous _, _, InternalLinkClicked url) ->
      ( model
      , Nav.pushUrl model.key (Url.toString url)
      )

    (Logged _, _, InternalLinkClicked url) ->
      let newRoute = urlToRoute url in
      case newRoute of
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

    (_, _, ExternalLinkClicked href) ->
      (model, Nav.load href)

    (_, _, UrlChange url) ->
      ({ model | url = url }, Cmd.none)

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
            |> Maybe.map (\lmd-> requestDiscution lmd.id ReceiveDiscution)
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
          Just result ->
            signinFormResultHandler result model formCmd
          Nothing ->
            ( { model | access = Anonymous { amodel | signinForm = newForm } }
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
      case result of
        Ok { data, alert } ->
          case data of
            Just (id, newLikeStatus) ->
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
            Nothing ->
              ( model |> (Alert.put << Just) (Alert.invalidImputAlert "Sory we can't let you like/unlike this persone. It could be because your account isn't complete.")
              , Cmd.none
              )
        Err error ->
          ( model |> (Alert.put << Just) (Alert.serverNotReachedAlert error)
          , Cmd.none
          )

    (Logged lmodel, _, ReceiveUserDetails result) ->
      case result of
        Ok { data, alert } ->
          case data of
            Just userDetails ->
              ( { model | alert = alert , access = Logged
                  { lmodel | userDetails = Just userDetails }
                }
              , Cmd.none
              )
            Nothing ->
              ( { model | access = Logged { lmodel | userDetails = Nothing } }
                |> (Alert.put << Just) (Alert.invalidImputAlert "Sory we can't let you access this user's infos. It could be because your account isn't complete.")
              , Cmd.none
              )
        Err error ->
          ( model |> (Alert.put << Just) (Alert.serverNotReachedAlert error)
          , Cmd.none
          )

    (Logged lmodel, _, ReceiveUnreadNotifsAmount result) ->
      (unreadNotifsAmountResultHandler result lmodel model, Cmd.none)

    (Logged lmodel, _, ReceiveNotifS result) ->
      case result of
        Ok { data, alert } ->
          case data of
            Just newNotifList ->
              ( { model | alert = alert , access = Logged
                  { lmodel | notifs = newNotifList }
                }
              , Cmd.none
              )
            Nothing ->
              ( model |> (Alert.put << Just) (Alert.invalidImputAlert "Sory we can't let you access this user's infos. It could be because your account isn't complete.")
              , Cmd.none
              )
        Err error ->
          ( model |> (Alert.put << Just) (Alert.serverNotReachedAlert error)
          , Cmd.none
          )

    (Logged lmodel, _, ReceiveChats result) ->
      case result of
        Ok { data, alert } ->
          case data of
            Just chatList ->
              ( { model | access = Logged { lmodel | chats = chatList } }
                  |> Alert.put alert
              , Cmd.none
              )
            Nothing ->
              ( model |> Alert.put alert
              , Cmd.none
              )
        Err error ->
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

    _ -> ( model, Cmd.none )

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

signinFormResultHandler result model cmd =
  case result of
    Ok (Ok message) ->
      ( { model | access = loggedAccessInit } |> (Alert.put << Just) (Alert.successAlert message)
      , Cmd.batch
        [ Nav.pushUrl model.key "/"
        , cmd |> Cmd.map SigninForm
        , requestFeedInit ReceiveFeedInit
        ]
      )
    Ok (Err message) ->
      ( model |> (Alert.put << Just) (Alert.invalidImputAlert message)
      , cmd |> Cmd.map SigninForm
      )
    Err error ->
      ( model |> (Alert.put << Just) (Alert.serverNotReachedAlert error)
      , cmd |> Cmd.map SigninForm
      )

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

signoutFormResultHandler result model cmd =
  case result of
    Ok (Ok message) ->
      ( { model | access = anonymousAccessInit }  |> (Alert.put << Just) (Alert.successAlert message)
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


-- account

signinFormInit : Form (Result String String)
signinFormInit =
  Form.form resultMessageDecoder (OnSubmit "Signin") "http://localhost/control/account_signin.php"
  |> Form.textField "pseudo"
  |> Form.passwordField "password"

signupFormInit : Form (Result String String)
signupFormInit =
  Form.form resultMessageDecoder (OnSubmit "Signup") "http://localhost/control/account_signup.php"
  |> Form.textField "pseudo"
  |> Form.textField "lastname"
  |> Form.textField "firstname"
  |> Form.textField "email"
  |> Form.passwordField "password"
  |> Form.passwordField "confirm"

signoutFormInit : Form (Result String String)
signoutFormInit =
    Form.form resultMessageDecoder (OnSubmit "signout") "http://localhost/control/account_signout.php"


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

type LastLog
  = Now
  | AWhileAgo String

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


-- view

view : Model -> Browser.Document Msg
view model =
  let route = urlToRoute model.url in
  case (model.access, route) of
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
        div [] (List.map viewMessage discution.messages)
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
      [ a [ href "/chat" ] [ text "chat" ]
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
      Time.every 250 Tick

anonymousAccess_sub : AModel -> Sub Msg
anonymousAccess_sub amodel =
  [ Form.subscriptions amodel.signinForm |> Sub.map SigninForm
  , Form.subscriptions amodel.signupForm |> Sub.map SignupForm
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
