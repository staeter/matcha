module Main exposing (..)


-- imports

import Browser exposing (application, UrlRequest)
import Html  exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

import Url  exposing (..)
import Url.Parser as Parser  exposing (..)
import Url.Parser.Query as PQuery  exposing (..)
import Browser.Navigation as Nav  exposing (..)

import Json.Decode as Decode  exposing (..)
import Json.Decode.Field as Field  exposing (..)

import Http  exposing (..)

import Array  exposing (..)
import Time  exposing (..)

import File exposing (File)
import File.Select as Select  exposing (..)

import Element as El exposing (..)
import Element.Input as Inp exposing (..)
import Element.Background as Background exposing (..)
import Element.Events as Ev exposing (..)
import Element.Font as Font exposing (..)
import Element.Border as Border exposing (..)

import MultiInput exposing (..)

import RemoteData exposing (RemoteData(..))

import Bootstrap.CDN as CDN exposing (stylesheet)
import Bootstrap.Card as Card exposing (..)
import Bootstrap.Carousel as Carousel exposing (..)
import Bootstrap.Carousel.Slide as Slide exposing (..)


-- modules

import Alert exposing (..)
import Form exposing (..)
import Feed exposing (..)
import BasicValues exposing (..)
import ZipList exposing (..)
import Dropdown exposing (..)


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
  , userDetails : RemoteData String UserDetails
  -- header
  , unreadNotifsAmount : Int
  -- notifs
  , notifs : List Notif
  -- chat
  , chats : List Chat
  , discution : Maybe Discution
  -- pwUpdate
  , pwUpdateOld : String
  , pwUpdateNew : String
  , pwUpdateConfirm : String
  -- settings
  , settingsPseudo : String
  , settingsFirstname : String
  , settingsLastname : String
  , settingsEmail : String
  , settingsGender : ZipList (Gender, String)
  , settingsOrientation : ZipList (BasicValues.Orientation, String)
  , settingsBiography : String
  , settingsTagsState : MultiInput.State
  , settingsTagsItems : List String
  -- pictures settings
  , pictures : Maybe (ZipList (Int, String))
  }

type alias AModel =
  { -- signin
    signinPseudo : String
  , signinPassword : String
  -- signup
  , signupPseudo : String
  , signupLastname : String
  , signupFirstname : String
  , signupEmail : String
  , signupPassword : String
  , signupConfirm : String
  -- retreive
  , retreivalRequestEmail : String
  , accountRetrievalForm : Maybe (Form (Result String String))
  -- confirm
  , accountConfirmationForm : Maybe (Form (Result String String))
  }


-- init

init : Maybe { pseudo : String, picture : String } -> Url -> Nav.Key -> (Model, Cmd Msg)
init flags url key =
  let
    route = urlToRoute url
    accessCmd =
      case flags of
        Nothing ->
          anonymousAccessInit route
        Just { pseudo, picture } ->
          loggedAccessInit route pseudo picture
  in
    accessCmd
    |> Tuple.mapFirst
        (\ access ->
          { route = route
            , key = key
            , alert = Nothing
            , access = access
            }
        )

anonymousAccessInit : Route -> (Access, Cmd Msg)
anonymousAccessInit route =
  ( case route of
      RetreiveLink a b -> Anonymous
        { signinPseudo = ""
        , signinPassword = ""
        , signupPseudo = ""
        , signupLastname = ""
        , signupFirstname = ""
        , signupEmail = ""
        , signupPassword = ""
        , signupConfirm = ""
        , retreivalRequestEmail = ""
        , accountRetrievalForm = Just (requestAccountRetrievalForm a b)
        , accountConfirmationForm = Nothing
        }
      Confirm a b -> Anonymous
        { signinPseudo = ""
        , signinPassword = ""
        , signupPseudo = ""
        , signupLastname = ""
        , signupFirstname = ""
        , signupEmail = ""
        , signupPassword = ""
        , signupConfirm = ""
        , retreivalRequestEmail = ""
        , accountRetrievalForm = Nothing
        , accountConfirmationForm = Just (requestAccountConfirmationForm a b)
        }
      _ -> Anonymous
        { signinPseudo = ""
        , signinPassword = ""
        , signupPseudo = ""
        , signupLastname = ""
        , signupFirstname = ""
        , signupEmail = ""
        , signupPassword = ""
        , signupConfirm = ""
        , retreivalRequestEmail = ""
        , accountRetrievalForm = Nothing
        , accountConfirmationForm = Nothing
        }
  , Cmd.none )

loggedAccessInit : Route -> String -> String -> (Access, Cmd Msg)
loggedAccessInit route pseudo picture =
  ( Logged
      { pseudo = pseudo
      , picture = picture
      , filtersForm = Nothing
      , feedContent = []
      , feedPageNumber = 0
      , feedPageAmount = 0
      , feedElemAmount = 0
      , userDetails = NotAsked
      , unreadNotifsAmount = 0
      , notifs = []
      , chats = []
      , discution = Nothing
      , pwUpdateOld = ""
      , pwUpdateNew = ""
      , pwUpdateConfirm = ""
      , settingsPseudo = ""
      , settingsFirstname = ""
      , settingsLastname = ""
      , settingsEmail = ""
      , settingsGender = ZipList.fromList genderList
      , settingsOrientation = ZipList.fromList orientationList
      , settingsBiography = ""
      , settingsTagsState = MultiInput.init "settings-tags"
      , settingsTagsItems = []
      , pictures = Nothing
      }
  , case route of
      Home ->
        requestFeedInit ReceiveFeedInit |> Debug.log "send request FeedInit"
      User id ->
        requestUserDetails id ReceiveUserDetails
      Notifs ->
        requestNotifs ReceiveNotifS
      Chats ->
        requestChats ReceiveChats
      Settings ->
        requestCurrentSettings ReceiveCurrentSettings |> Debug.log "send request CurrentSettings"
      _ ->
        Cmd.none
  )


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
  | Retreive
  | RetreiveLink Int Int
  | Confirm Int Int
  | Settings
  | Test
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
    , Parser.map Retreive (Parser.s "retreive")
    , Parser.map RetreiveLink (Parser.s "retreive" </> Parser.int </> Parser.int)
    , Parser.map Confirm  (Parser.s "confirm" </> Parser.int </> Parser.int)
    , Parser.map Settings (Parser.s "settings")
    , Parser.map Test (Parser.s "test")
    ]

urlToRoute : Url -> Route
urlToRoute url =
  Parser.parse routeParser url
  |> Maybe.withDefault Unknown


-- update

type Msg
  = NoOp
  -- url
  | InternalLinkClicked Url
  | ExternalLinkClicked String
  | UrlChange Url
  -- time
  | Tick Time.Posix
  -- signin
  | InputSigninPseudo String
  | InputSigninPassword String
  | SubmitSignin
  | ResultSignin (Result Http.Error (DataAlert { pseudo: String, picture: String }))
  -- signup
  | InputSignupPseudo String
  | InputSignupLastname String
  | InputSignupFirstname String
  | InputSignupEmail String
  | InputSignupPassword String
  | InputSignupConfirm String
  | SubmitSignup
  | ResultSignup (Result Http.Error (Result String String))
  -- signout
  | SubmitSignout
  | ResultSignout (Result Http.Error (Result String String))
  -- password update
  | InputPwUpdateOld String
  | InputPwUpdateNew String
  | InputPwUpdateConfirm String
  | SubmitPwUpdate
  | ResultPwUpdate (Result Http.Error (Result String String))
  -- retreiveal request
  | InputRetreivalRequestEmail String
  | SubmitRetreivalRequest
  | ResultRetreivalRequest (Result Http.Error (Result String String))
  -- settings
  | InputSettingsPseudo String
  | InputSettingsFirstname String
  | InputSettingsLastname String
  | InputSettingsEmail String
  | InputSettingsGender (ZipList (Gender, String))
  | InputSettingsOrientation (ZipList (BasicValues.Orientation, String))
  | InputSettingsBiography String
  | InputSettingsTags MultiInput.Msg
  | SubmitSettings
  | ResultSettings (Result Http.Error (Result String String))
  -- user pictures update
  | SelectImage (ZipList (Int, String))
  | RemovePicture
  | SelectReplacementPicture
  | ReplacePicture File
  | ReceivePicturesUpdate (Result Http.Error (DataAlert (ZipList (Int, String))))
  -- user details
  | InputUserDetailsSelectImage Carousel.Msg
  -- other
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
  | ReceiveCurrentSettings (Result Http.Error (DataAlert CurrentSettings))

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case (model.access, model.route, msg) of

    -- url

    (Anonymous amodel, _, InternalLinkClicked url) ->
      ( model
      , Nav.pushUrl model.key (Url.toString url)
      )

    (Logged _, _, InternalLinkClicked url) ->
      ( model
      , Nav.pushUrl model.key (Url.toString url)
      )

    (Logged _, _, ExternalLinkClicked href) ->
      (model, Nav.load href)

    (Logged lmodel, _, UrlChange url) ->
      let newRoute = urlToRoute url in
      case newRoute |> Debug.log "urlChange" of
        Home ->
          ( { model | route = newRoute }
          , requestFeedInit ReceiveFeedInit |> Debug.log "send request FeedInit"
          )
        User id ->
          ( { model | route = newRoute }
          , requestUserDetails id ReceiveUserDetails
          )
        Notifs ->
          ( { model | route = newRoute }
          , requestNotifs ReceiveNotifS
          )
        Chats ->
          ( { model | route = newRoute }
          , requestChats ReceiveChats
          )
        Settings ->
          ( { model | route = newRoute }
          , requestCurrentSettings ReceiveCurrentSettings |> Debug.log "send request CurrentSettings"
          )
        _ ->
          ({ model | route = newRoute }, Cmd.none)

    (Anonymous amodel, _, UrlChange url) ->
      let newRoute = urlToRoute url in
      case newRoute |> Debug.log "urlChange" of
        RetreiveLink a b ->
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


    -- time

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


    -- signin

    (Anonymous amodel, Signin, InputSigninPseudo pseudo) ->
      ( { model | access = Anonymous { amodel |
          signinPseudo = pseudo
        }}
      , Cmd.none
      )

    (Anonymous amodel, Signin, InputSigninPassword password) ->
      ( { model | access = Anonymous { amodel |
          signinPassword = password
        }}
      , Cmd.none
      )

    (Anonymous amodel, Signin, SubmitSignin) ->
      ( model
      , submitSignin amodel
      )

    (Anonymous amodel, _, ResultSignin result) ->
      case toWebResultDataAlert result of
        AvData { pseudo, picture } alert ->
          ( { model | access =
                loggedAccessInit model.route pseudo picture
                |> Tuple.first
            }
            |> Alert.put alert
          , Nav.pushUrl model.key "/"
          )
        NoData alert ->
          ( model |> Alert.put alert
          , Cmd.none
          )
        Error error ->
          ( model |> (Alert.put << Just) (Alert.serverNotReachedAlert error)
          , Cmd.none
          )


    -- signup

    (Anonymous amodel, Signup, InputSignupPseudo pseudo) ->
      ( { model | access = Anonymous { amodel |
          signupPseudo = pseudo
        }}
      , Cmd.none
      )

    (Anonymous amodel, Signup, InputSignupLastname lastname) ->
      ( { model | access = Anonymous { amodel |
          signupLastname = lastname
        }}
      , Cmd.none
      )

    (Anonymous amodel, Signup, InputSignupFirstname firstname) ->
      ( { model | access = Anonymous { amodel |
          signupFirstname = firstname
        }}
      , Cmd.none
      )

    (Anonymous amodel, Signup, InputSignupEmail email) ->
      ( { model | access = Anonymous { amodel |
          signupEmail = email
        }}
      , Cmd.none
      )

    (Anonymous amodel, Signup, InputSignupPassword password) ->
      ( { model | access = Anonymous { amodel |
          signupPassword = password
        }}
      , Cmd.none
      )

    (Anonymous amodel, Signup, InputSignupConfirm pwConfirmation) ->
      ( { model | access = Anonymous { amodel |
          signupConfirm = pwConfirmation
        }}
      , Cmd.none
      )

    (Anonymous amodel, Signup, SubmitSignup) ->
      ( model
      , submitSignup amodel
      )

    (Anonymous amodel, _, ResultSignup result) ->
      case result of
        Ok (Ok message) ->
          ( model |> (Alert.put << Just) (Alert.successAlert message)
          , Nav.pushUrl model.key "/signin"
          )
        Ok (Err message) ->
          ( model |> (Alert.put << Just) (Alert.invalidImputAlert message)
          , Cmd.none
          )
        Err error ->
          ( model |> (Alert.put << Just) (Alert.serverNotReachedAlert error)
          , Cmd.none
          )


    -- password update

    (Logged lmodel, Settings, InputPwUpdateOld oldpw) ->
      ( { model | access = Logged { lmodel |
          pwUpdateOld = oldpw
        }}
      , Cmd.none
      )

    (Logged lmodel, Settings, InputPwUpdateNew newpw) ->
      ( { model | access = Logged { lmodel |
          pwUpdateNew = newpw
        }}
      , Cmd.none
      )

    (Logged lmodel, Settings, InputPwUpdateConfirm confirmpw) ->
      ( { model | access = Logged { lmodel |
          pwUpdateConfirm = confirmpw
        }}
      , Cmd.none
      )

    (Logged lmodel, Settings, SubmitPwUpdate) ->
      ( model
      , submitPwUpdate lmodel
      )

    (Logged lmodel, _, ResultPwUpdate result) ->
      case result of
        Ok (Ok message) ->
          ( model
            |> (Alert.put << Just << Alert.successAlert) message
          , Cmd.none
          )
        Ok (Err message) ->
          ( model
            |> (Alert.put << Just << Alert.invalidImputAlert) message
          , Cmd.none
          )
        Err error ->
          ( model
            |> (Alert.put << Just << Alert.serverNotReachedAlert) error
          , Cmd.none
          )


    -- request retreival

    (Anonymous amodel, Retreive, InputRetreivalRequestEmail email) ->
      ( { model | access = Anonymous { amodel |
          retreivalRequestEmail = email
        }}
      , Cmd.none
      )

    (Anonymous amodel, Retreive, SubmitRetreivalRequest) ->
      ( model
      , submitRetreivalRequest amodel
      )

    (Anonymous amodel, _, ResultRetreivalRequest result) ->
      case result of
        Ok (Ok message) ->
          ( model
            |> (Alert.put << Just << Alert.successAlert) message
          , Nav.pushUrl model.key "/signin"
          )
        Ok (Err message) ->
          ( model
            |> (Alert.put << Just << Alert.invalidImputAlert) message
          , Cmd.none
          )
        Err error ->
          ( model
            |> (Alert.put << Just << Alert.serverNotReachedAlert) error
          , Cmd.none
          )


    -- general settings

    (Logged lmodel, Settings, InputSettingsPseudo pseudo) ->
      ( { model | access = Logged { lmodel |
          settingsPseudo = pseudo
        }}
      , Cmd.none
      )

    (Logged lmodel, Settings, InputSettingsLastname lastname) ->
      ( { model | access = Logged { lmodel |
          settingsLastname = lastname
        }}
      , Cmd.none
      )

    (Logged lmodel, Settings, InputSettingsFirstname firstname) ->
      ( { model | access = Logged { lmodel |
          settingsFirstname = firstname
        }}
      , Cmd.none
      )

    (Logged lmodel, Settings, InputSettingsEmail email) ->
      ( { model | access = Logged { lmodel |
          settingsEmail = email
        }}
      , Cmd.none
      )

    (Logged lmodel, Settings, InputSettingsGender selection) ->
      ( { model | access = Logged { lmodel |
          settingsGender = selection
        }}
      , Cmd.none
      )

    (Logged lmodel, Settings, InputSettingsOrientation selection) ->
      ( { model | access = Logged { lmodel |
          settingsOrientation = selection
        }}
      , Cmd.none
      )

    (Logged lmodel, Settings, InputSettingsBiography bio) ->
      ( { model | access = Logged { lmodel |
          settingsBiography = bio
        }}
      , Cmd.none
      )

    (Logged lmodel, Settings, InputSettingsTags multInputMsg) ->
      let
        ( nextState, nextItems, nextCmd ) =
            MultiInput.update
              { separators = [ "\n", "\t", " ", "," ] }
              multInputMsg lmodel.settingsTagsState lmodel.settingsTagsItems
      in
        ( { model | access = Logged { lmodel
            | settingsTagsItems = nextItems
            , settingsTagsState = nextState
          } }
        , nextCmd |> Cmd.map InputSettingsTags
        )

    (Logged lmodel, Settings, SubmitSettings) ->
      ( model
      , submitSettings lmodel
      )

    (Logged lmodel, _, ResultSettings result) ->
      case result of
        Ok (Ok message) ->
          ( model |> (Alert.put << Just) (Alert.successAlert message)
          , Cmd.none
          )
        Ok (Err message) ->
          ( model |> (Alert.put << Just) (Alert.invalidImputAlert message)
          , Cmd.none
          )
        Err error ->
          ( model |> (Alert.put << Just) (Alert.serverNotReachedAlert error)
          , Cmd.none
          )


    -- other

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

    (Logged lmodel, _, SubmitSignout) ->
      (model, requestSignout)

    (Logged lmodel, _, ResultSignout response) ->
      case response of
        Ok (Ok message) ->
          ( { model | access =
                anonymousAccessInit model.route
                |> Tuple.first
            } |> (Alert.put << Just) (Alert.successAlert message)
          , Nav.pushUrl model.key "/"
          )
        Ok (Err message) ->
          ( model |> (Alert.put << Just) (Alert.invalidImputAlert message)
          , Cmd.none
          )
        Err error ->
          ( model |> (Alert.put << Just) (Alert.serverNotReachedAlert error)
          , Cmd.none
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
                  , userDetails =
                      case lmodel.userDetails of
                        Success usrd ->
                          if usrd.id == id
                          then Success { usrd | liked = newLikeStatus }
                          else Success usrd
                        smthg -> smthg
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
              { lmodel | userDetails = Success userDetails }
            }
          , Cmd.none
          )
        NoData alert ->
          ( { model | access = Logged { lmodel | userDetails = RemoteData.Failure "Access denied" } }
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

    (Logged lmodel, _, ReceiveCurrentSettings result) ->
      case toWebResultDataAlert result of
        AvData currentSettings alert ->
          ( { model | access = Logged
              { lmodel
                | pictures = Just currentSettings.pictures
                , settingsPseudo = currentSettings.pseudo
                , settingsFirstname = currentSettings.first_name
                , settingsLastname = currentSettings.last_name
                , settingsEmail = currentSettings.email
                , settingsGender =
                    ZipList.fromList genderList
                    |> ZipList.goToFirst (\ elem -> currentSettings.gender == Tuple.first elem )
                , settingsOrientation =
                    ZipList.fromList orientationList
                    |> ZipList.goToFirst (\ elem -> currentSettings.orientation == Tuple.first elem )
                , settingsBiography = currentSettings.biography
                , settingsTagsItems = currentSettings.tags
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

    (Logged lmodel, Settings, SelectImage newZipList) ->
      case lmodel.pictures of
        Nothing -> (model, Cmd.none)
        Just pictures ->
          ( { model | access = Logged { lmodel | pictures = Just
              newZipList
            } }
          , Cmd.none
          )

    (Logged lmodel, Settings, RemovePicture) ->
      lmodel.pictures
      |> Maybe.map (\p-> (model, removePicture p ReceivePicturesUpdate))
      |> Maybe.withDefault (model, Cmd.none)

    (Logged lmodel, Settings, SelectReplacementPicture) ->
      (model, Select.file ["image/png", "image/jpg"] ReplacePicture)

    (Logged lmodel, Settings, ReplacePicture file) ->
      lmodel.pictures
      |> Maybe.map (\p-> (model, replacePicture p file ReceivePicturesUpdate))
      |> Maybe.withDefault (model, Cmd.none)

    (Logged lmodel, _, ReceivePicturesUpdate response) ->
      case toWebResultDataAlert response of
        AvData newPictures alert ->
          ( { model | access = Logged
              { lmodel | pictures = Just newPictures }
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

    (Logged lmodel, User _, InputUserDetailsSelectImage carouselMsg) ->
      case lmodel.userDetails of
        Success userDetails ->
          ( { model | access = Logged { lmodel | userDetails = Success { userDetails |
              carouselState = Carousel.update carouselMsg userDetails.carouselState
            } } }
          , Cmd.none
          )
        _ -> (model, Cmd.none)

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


-- settings

type alias CurrentSettings =
  { pseudo : String
  , first_name : String
  , last_name : String
  , email : String
  , gender : Gender
  , orientation : BasicValues.Orientation
  , biography : String
  , birth : String
  , pictures : ZipList (Int, String)
  , popularity_score : Int
  , tags : List String
  }

requestCurrentSettings : (Result Http.Error (DataAlert CurrentSettings) -> msg) -> Cmd msg
requestCurrentSettings toMsg =
  Http.post
      { url = "http://localhost/control/settings_current.php"
      , body = emptyBody
      , expect = Http.expectJson toMsg (dataAlertDecoder currentSettingsDecoder)
      }

currentSettingsDecoder : Decoder CurrentSettings
currentSettingsDecoder =
  Field.require "pseudo" Decode.string <| \pseudo ->
  Field.require "first_name" Decode.string <| \first_name ->
  Field.require "last_name" Decode.string <| \last_name ->
  Field.require "email" Decode.string <| \email ->
  Field.require "gender" genderDecoder <| \gender ->
  Field.require "orientation" orientationDecoder <| \orientation ->
  Field.require "biography" Decode.string <| \biography ->
  Field.require "birth" Decode.string <| \birth ->
  Field.require "pictures" (Decode.list pictureDecoder) <| \pictures ->
  Field.require "popularity_score" Decode.int <| \popularity_score ->
  Field.require "tags" (Decode.list Decode.string) <| \tags ->

  Decode.succeed
    { pseudo = pseudo
    , first_name = first_name
    , last_name = last_name
    , email = email
    , gender = gender
    , orientation = orientation
    , biography = biography
    , birth = birth
    , pictures = ZipList.fromList pictures
    , popularity_score = popularity_score
    , tags = tags
    }

type alias SettingsModel a =
  { a
  | settingsPseudo : String
  , settingsFirstname : String
  , settingsLastname : String
  , settingsEmail : String
  , settingsGender : ZipList (Gender, String)
  , settingsOrientation : ZipList (BasicValues.Orientation, String)
  , settingsBiography : String
  , settingsTagsState : MultiInput.State
  , settingsTagsItems : List String
  }

submitSettings : SettingsModel a -> Cmd Msg
submitSettings model =
  Http.post
      { url = "http://localhost/control/settings_update.php"
      , body = multipartBody
                [ stringPart "pseudo" model.settingsPseudo
                , stringPart "first_name" model.settingsFirstname
                , stringPart "last_name" model.settingsLastname
                , stringPart "email" model.settingsEmail
                , stringPart
                    "gender"
                    ( ZipList.current model.settingsGender
                      |> Maybe.withDefault (Woman, "")
                      |> Tuple.first
                      |> genderToString
                    )
                , stringPart
                    "orientation"
                    ( ZipList.current model.settingsOrientation
                      |> Maybe.withDefault (Bisexual, "")
                      |> Tuple.first
                      |> orientationToString
                    )
                , stringPart "biography" model.settingsBiography
                ]
      , expect = Http.expectJson ResultPwUpdate resultMessageDecoder
      }

pictureDecoder : Decoder (Int, String)
pictureDecoder =
  Field.require "id" Decode.int <| \id ->
  Field.require "path" Decode.string <| \path ->
  Decode.succeed (id, path)

removePicture :  ZipList (Int, String) -> (Result Http.Error (DataAlert (ZipList (Int, String))) -> Msg) -> Cmd Msg
removePicture pictures toMsg =
  let
    maybeId =  pictures
          |> ZipList.current
          |> Maybe.map Tuple.first
  in
  case maybeId of
    Nothing -> Cmd.none
    Just id ->
      Http.post
        { url = "http://localhost/control/picture_remove.php"
        , body = multipartBody [stringPart "id" (String.fromInt id)]
        , expect = Http.expectJson toMsg (dataAlertDecoder (zipListDecoder pictureDecoder))
        }

replacePicture : ZipList (Int, String) -> File -> (Result Http.Error (DataAlert (ZipList (Int, String))) -> Msg) -> Cmd Msg
replacePicture pictures pictureFile toMsg =
  let
    maybeId =  pictures
          |> ZipList.current
          |> Maybe.map Tuple.first
  in
  case maybeId of
    Nothing -> Cmd.none
    Just id ->
      Http.post
        { url = "http://localhost/control/picture_replace.php"
        , body = multipartBody
                  [ stringPart "id" (String.fromInt id)
                  , filePart "pictureFile" pictureFile
                  ]
        , expect = Http.expectJson toMsg (dataAlertDecoder (zipListDecoder pictureDecoder))
        }

-- update password

type alias PwUpdateModel a =
  { a
  | pwUpdateOld : String
  , pwUpdateNew : String
  , pwUpdateConfirm : String
  }

submitPwUpdate : PwUpdateModel a -> Cmd Msg
submitPwUpdate model =
  Http.post
      { url = "http://localhost/control/password_update.php"
      , body = multipartBody
                [ stringPart "oldpw" model.pwUpdateOld
                , stringPart "newpw" model.pwUpdateNew
                , stringPart "confirm" model.pwUpdateConfirm
                ]
      , expect = Http.expectJson ResultPwUpdate resultMessageDecoder
      }


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

type alias SigninModel a =
  { a
  | signinPseudo : String
  , signinPassword : String
  }

submitSignin : SigninModel a -> Cmd Msg
submitSignin model =
  Http.post
      { url = "http://localhost/control/account_signin.php"
      , body = multipartBody
                [ stringPart "pseudo" model.signinPseudo
                , stringPart "password" model.signinPassword
                ]
      , expect = Http.expectJson ResultSignin (dataAlertDecoder signinDecoder)
      }

signinDecoder : Decoder { pseudo: String, picture: String }
signinDecoder =
  Field.require "pseudo" Decode.string <| \pseudo ->
  Field.require "picture" Decode.string <| \picture ->
  Decode.succeed ({ pseudo = pseudo, picture = picture })

type alias SignupModel a =
  { a
  | signupPseudo : String
  , signupLastname : String
  , signupFirstname : String
  , signupEmail : String
  , signupPassword : String
  , signupConfirm : String
  }

submitSignup : SignupModel a -> Cmd Msg
submitSignup model =
  Http.post
      { url = "http://localhost/control/account_signup.php"
      , body = multipartBody
                [ stringPart "pseudo" model.signupPseudo
                , stringPart "lastname" model.signupLastname
                , stringPart "firstname" model.signupFirstname
                , stringPart "email" model.signupEmail
                , stringPart "password" model.signupPassword
                , stringPart "confirm" model.signupConfirm
                ]
      , expect = Http.expectJson ResultSignup resultMessageDecoder
      }

requestSignout : Cmd Msg
requestSignout =
  Http.post
      { url = "http://localhost/control/account_signout.php"
      , body = emptyBody
      , expect = Http.expectJson ResultSignout resultMessageDecoder
      }


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

type alias RetreivalRequestModel a =
  { a | retreivalRequestEmail : String }

submitRetreivalRequest : RetreivalRequestModel a -> Cmd Msg
submitRetreivalRequest model =
  Http.post
      { url = "http://localhost/control/password_retreival_request.php"
      , body = multipartBody
                [ stringPart "email" model.retreivalRequestEmail ]
      , expect = Http.expectJson ResultRetreivalRequest resultMessageDecoder
      }


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
  , orientation : BasicValues.Orientation
  , biography : String
  , birth : String
  , last_log : LastLog
  , pictures : List String
  , carouselState : Carousel.State
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
    , carouselState = Carousel.initialState
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
          |> El.layout []
        ]
      }

    (Anonymous amodel, Signup) ->
      { title = "matcha - signup"
      , body =
        [ Alert.view model
        , signupView amodel
          |> El.layout []
        ]
      }

    (Anonymous _, Home) ->
      { title = "matcha - home"
      , body =
        [ Html.text "Welcome to Matcha. The best site too meet your future love!"
        , br [] [], a [ href "/signin" ] [ Html.text "Signin" ]
        , Html.text " or ", a [ href "/signup" ] [ Html.text "Signup" ]
        ]
      }

    (Anonymous amodel, Retreive) ->
      { title = "matcha - retreive password"
      , body =
        [ Alert.view model
        , retreivealRequestView amodel
          |> El.layout []
        ]
      }

    (Anonymous amodel, RetreiveLink a b) ->
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

    (Logged lmodel, Home) ->
      { title = "matcha - home"
      , body =
        [ viewHeader model.route lmodel
        , Alert.view model
        , Maybe.map Form.view lmodel.filtersForm
          |> Maybe.map (Html.map FiltersForm)
          |> Maybe.withDefault (Html.text "Loading...")
        , viewFeed lmodel
        ]
      }

    (Logged lmodel, User id) ->
      { title = "matcha - " ++
          ( case lmodel.userDetails of
              Success ud -> ud.pseudo
              RemoteData.Failure err -> "error: " ++ err
              NotAsked -> "Requesting..."
              Loading -> "Loading..."
          )
      , body =
          [ [ CDN.stylesheet
            , viewHeader model.route lmodel
            ]
          , case lmodel.userDetails of
              Success ud ->
                [ Alert.view model
                , viewUserDetails ud
                ]
              RemoteData.Failure err ->
                model
                |> (Alert.put << Just << Alert.invalidImputAlert)
                    ("error: " ++ err)
                |> Alert.view
                |> List.singleton
              NotAsked ->
                model
                |> (Alert.put << Just << Alert.invalidImputAlert)
                    "Requesting our server. Please reload the page if it takes too long."
                |> Alert.view
                |> List.singleton
              Loading ->
                model
                |> (Alert.put << Just << Alert.alert "DarkBlue")
                    "Loading..."
                |> Alert.view
                |> List.singleton
          ] |> List.concat
      }

    (Logged lmodel, Notifs) ->
      { title = "matcha - notifications"
      , body =
        [ viewHeader model.route lmodel
        , Alert.view model
        , viewNotifs lmodel.notifs
        ]
      }

    (Logged lmodel, Chats) ->
      { title = "matcha - notifications"
      , body =
        [ viewHeader model.route lmodel
        , Alert.view model
        , viewChats lmodel.chats
        , viewDiscution lmodel.discution
        ]
      }

    (Logged lmodel, Settings) ->
      { title = "matcha - notifications"
      , body =
        [ viewHeader model.route lmodel
        , Alert.view model
        , wrappedRow
            [ spaceEvenly
            , El.width fill
            , padding 64
            ]
            [ el  [ paddingEach
                      { top = 0
                      , right = 32
                      , bottom = 128
                      , left = 32
                      }
                  , El.width (minimum 512 fill)
                  ]
                  (viewPictUpdate lmodel)
            , el  [ paddingEach
                      { top = 0
                      , right = 32
                      , bottom = 128
                      , left = 32
                      }
                  , El.width (minimum 512 fill)
                  ]
                  (settingsView lmodel)
            , el  [ paddingEach
                      { top = 0
                      , right = 32
                      , bottom = 128
                      , left = 32
                      }
                  , El.width (minimum 512 fill)
                  ]
                  (viewPwUpdate lmodel)
            ]
          |> El.layout []
        ]
      }

    (Anonymous _, _) ->
      { title = "matcha - 404 page not found"
      , body =
          column  [ centerX
                  , centerY
                  ]
                  [ El.el [ padding 5
                          , centerX
                          ]
                          ( El.text "You seem lost" )
                  , El.el [ padding 5
                          , centerX
                          ]
                          ( a [ href "/signin" ]
                              [ Html.text "go to signin" ]
                            |> El.html
                          )
                  ]
          |> El.layout []
          |> List.singleton
      }

    (Logged _, _) ->
      { title = "matcha - 404 page not found"
      , body =
          column  [ centerX
                  , centerY
                  ]
                  [ El.el [ padding 5
                          , centerX
                          ]
                          ( El.text "You seem lost" )
                  , El.el [ padding 5
                          , centerX
                          ]
                          ( a [ href "/" ]
                              [ Html.text "go back home" ]
                            |> El.html
                          )
                  ]
          |> El.layout []
          |> List.singleton
      }

type alias PictUpdateModel a =
  { a
  | pictures : Maybe (ZipList (Int, String))
  }

viewPictUpdate : PictUpdateModel a -> Element Msg
viewPictUpdate model =
  column
      [ spacing 32
      , centerX
      , Border.shadow
          { offset = (0.0, 0.0)
          , size = 0.0
          , blur = 100.0
          , color = rgba 0 0 0 0.2
          }
      , paddingXY 16 64
      ]
      [ el  [ centerX ]
            ( model.pictures
              |> Maybe.map (\p-> div [] [ viewGalery SelectImage p ])
              |> Maybe.withDefault (div [] [])
              |> El.html
            )
      , Inp.button
          [ centerX ]
          { onPress = Just RemovePicture
          , label = El.text "remove selected image"
          }
      , Inp.button
          [ centerX ]
          { onPress = Just SelectReplacementPicture
          , label = El.text "replace selected image"
          }
      ]

viewChats : List Chat -> Html Msg
viewChats chatList =
  div [] (List.map viewChat chatList)

viewChat : Chat -> Html Msg
viewChat chat =
  div [ if chat.unread
        then style "background-color" "LightBlue"
        else style "background-color" "White"
      , Html.Events.onClick (AccessDiscution chat.id)
      ]
      [ img [ src chat.picture ] []
      , Html.text chat.pseudo
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
  |> Maybe.withDefault (div [] [ Html.text "Loading..." ])

viewMessage : Message -> Html Msg
viewMessage message =
  div [ if message.sent
        then style "background-color" "LightBlue"
        else style "background-color" "LightGrey"
      ]
      [ Html.text message.content
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
      [ Html.text notif.content
      , br [] []
      , Html.text notif.date
      ]

viewHeader : Route -> LModel -> Html Msg
viewHeader route lmodel =
  div [ class "header" ]
      [ div [class "header-right" ]
            [ a [ href "/"
                , if route == Home
                  then class "active"
                  else class ""
                ] [ Html.text "home" ]
            , a [ href "/chat"
                , if route == Chats
                  then class "active"
                  else class ""
                ] [ Html.text "chat" ]
            , a [ href "/notifs"
                , if route == Notifs
                  then class "active"
                  else class ""
                ]
                [ Html.text ( "notifs ("
                          ++ (String.fromInt lmodel.unreadNotifsAmount)
                          ++ ")"
                       )
                ]
            , a [ href "/settings"
                , if route == Settings
                  then class "active"
                  else class ""
                ] [ Html.text "settings" ]
            , a [ Html.Events.onClick SubmitSignout
                , style "color" "DarkRed"
                ] [ Html.text "signout" ]
            -- , Form.view lmodel.signoutForm |> Html.map SignoutForm
            ]
      ]

viewUserDetails : UserDetails -> Html Msg
viewUserDetails userDetails =
  div []
      [ viewCarousel
          userDetails.pictures
          userDetails.carouselState
          InputUserDetailsSelectImage
      , h2 [] [ Html.text userDetails.pseudo ]
      , h3 [] [ Html.text (userDetails.first_name ++ " " ++ userDetails.last_name) ]
      , Html.text (orientationToString userDetails.orientation ++ " " ++ genderToString userDetails.gender )
      , Html.text userDetails.birth
      , br [] []
      , Html.text userDetails.biography
      , br [] []
      , viewLikeButton userDetails.id userDetails.liked
      ]

orientationToString : BasicValues.Orientation -> String
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

onEnter : msg -> El.Attribute msg
onEnter msg =
  Decode.field "key" Decode.string
  |> Decode.andThen
      (\key ->
          if key == "Enter" then
            Decode.succeed msg

          else
            Decode.fail "Not the enter key"
      )
  |> Html.Events.on "keyup"
  |> El.htmlAttribute


signinView : SigninModel a -> Element Msg
signinView model =
  column  [ spacing 32
          , centerX
          , centerY
          ]
          [ Inp.username
                [ onEnter SubmitSignin
                , padding 8
                ]
                { onChange = InputSigninPseudo
                , text = model.signinPseudo
                , placeholder = Inp.placeholder [] (El.text"pseudo") |> Just
                , label = labelLeft
                            [ centerY
                            ]
                            (El.text "pseudo : ")
                }
          , Inp.currentPassword
                [ onEnter SubmitSignin
                , padding 8
                ]
                { onChange = InputSigninPassword
                , text = model.signinPassword
                , placeholder = Inp.placeholder [] (El.text "password") |> Just
                , label = labelLeft
                            [ centerY
                            ]
                            (El.text "password : ")
                , show = False
                }
          , Inp.button
                [ padding 0
                , centerX
                ]
                { onPress = Just SubmitSignin
                , label = El.text "Signin"
                }
          , a [ href "/retreive" ]
              [ Html.text "You forgot yout password?" ]
            |> El.html
            |> El.el  [ centerX
                      , centerY
                      , paddingEach
                          { top = 32
                          , right = 32
                          , left = 32
                          , bottom = 2
                          }
                      ]
          , a [ href "/signup" ]
              [ Html.text "You don't have any account?" ]
            |> El.html
            |> El.el  [ centerX
                      , centerY
                      , paddingEach
                          { top = 2
                          , right = 32
                          , left = 32
                          , bottom = 32
                          }
                      ]
          ]

signupView : SignupModel a -> Element Msg
signupView model =
  column  [ spacing 32
          , centerX
          , centerY
          ]
          [ Inp.username
                [ onEnter SubmitSignup
                , padding 8
                ]
                { onChange = InputSignupPseudo
                , text = model.signupPseudo
                , placeholder = Inp.placeholder [] (El.text "pseudo") |> Just
                , label = labelLeft
                            [ centerY ]
                            (El.text "pseudo : ")
                }
          , Inp.text
                [ onEnter SubmitSignup
                , padding 8
                ]
                { onChange = InputSignupLastname
                , text = model.signupLastname
                , placeholder = Inp.placeholder [] (El.text "lastname") |> Just
                , label = labelLeft
                            [ centerY ]
                            (El.text "lastname : ")
                }
          , Inp.text
                [ onEnter SubmitSignup
                , padding 8
                ]
                { onChange = InputSignupFirstname
                , text = model.signupFirstname
                , placeholder = Inp.placeholder [] (El.text "firstname") |> Just
                , label = labelLeft
                            [ centerY ]
                            (El.text "firstname : ")
                }
          , Inp.email
                [ onEnter SubmitSignup
                , padding 8
                ]
                { onChange = InputSignupEmail
                , text = model.signupEmail
                , placeholder = Inp.placeholder [] (El.text "email") |> Just
                , label = labelLeft
                            [ centerY ]
                            (El.text "email : ")
                }
          , Inp.newPassword
                [ onEnter SubmitSignup
                , padding 8
                ]
                { onChange = InputSignupPassword
                , text = model.signupPassword
                , placeholder = Inp.placeholder [] (El.text "password") |> Just
                , label = labelLeft
                            [ centerY ]
                            (El.text "password : ")
                , show = False
                }
          , Inp.newPassword
                [ onEnter SubmitSignup
                , padding 8
                ]
                { onChange = InputSignupConfirm
                , text = model.signupConfirm
                , placeholder = Inp.placeholder [] (El.text "confirm") |> Just
                , label = labelLeft
                            [ centerY ]
                            (El.text "confirm : ")
                , show = False
                }
          , Inp.button
                [ padding 0
                , centerX
                ]
                { onPress = Just SubmitSignup
                , label = El.text "Signup"
                }
          , a [ href "/signin" ]
              [ Html.text "You alredy have an account?" ]
            |> El.html
            |> El.el  [ padding 32
                      , centerX
                      ]
          ]

viewPwUpdate : PwUpdateModel a -> Element Msg
viewPwUpdate model =
  column  [ spacing 16
          , centerX
          , Border.shadow
              { offset = (0.0, 0.0)
              , size = 0.0
              , blur = 100.0
              , color = rgba 0 0 0 0.2
              }
          , padding 64
          ]
          [ Inp.currentPassword
                [ onEnter SubmitPwUpdate
                , padding 8
                ]
                { onChange = InputPwUpdateOld
                , text = model.pwUpdateOld
                , placeholder = Inp.placeholder [] (El.text "current password") |> Just
                , label = labelLeft
                            [ centerY ]
                            (El.text "old : ")
                , show = False
                }
          , Inp.newPassword
                [ onEnter SubmitPwUpdate
                , padding 8
                ]
                { onChange = InputPwUpdateNew
                , text = model.pwUpdateNew
                , placeholder = Inp.placeholder [] (El.text "new password") |> Just
                , label = labelLeft
                            [ centerY ]
                            (El.text "new : ")
                , show = False
                }
          , Inp.newPassword
                [ onEnter SubmitPwUpdate
                , padding 8
                ]
                { onChange = InputPwUpdateConfirm
                , text = model.pwUpdateConfirm
                , placeholder = Inp.placeholder [] (El.text "confirm new password") |> Just
                , label = labelLeft
                            [ centerY ]
                            (El.text "confirm : ")
                , show = False
                }
          , Inp.button
                [ padding 0
                , centerX
                ]
                { onPress = Just SubmitPwUpdate
                , label = El.text "update password"
                }
          ]

retreivealRequestView : RetreivalRequestModel a -> Element Msg
retreivealRequestView model =
  column  [ spacing 32
          , centerX
          , centerY
          ]
          [ Inp.email
                [ onEnter SubmitRetreivalRequest
                , padding 8
                ]
                { onChange = InputRetreivalRequestEmail
                , text = model.retreivalRequestEmail
                , placeholder = Inp.placeholder [] (El.text "email") |> Just
                , label = labelLeft
                            [ centerY ]
                            (El.text "email : ")
                }
          , Inp.button
                [ padding 0
                , centerX
                ]
                { onPress = Just SubmitRetreivalRequest
                , label = El.text "retreive my account"
                }
          , a [ href "/signin" ]
              [ Html.text "You remember your password?" ]
            |> El.html
            |> El.el  [ padding 32
                      , centerX
                      ]
          ]

settingsView : SettingsModel a -> Element Msg
settingsView model =
  column  [ spacing 16
          , centerX
          , Border.shadow
              { offset = (0.0, 0.0)
              , size = 0.0
              , blur = 100.0
              , color = rgba 0 0 0 0.2
              }
          , padding 64
          ]
          [ Inp.username
                [ onEnter SubmitSettings
                , padding 8
                ]
                { onChange = InputSettingsPseudo
                , text = model.settingsPseudo
                , placeholder = Inp.placeholder [] (El.text "Your pseudo") |> Just
                , label = labelLeft
                            [ centerY ]
                            (El.text "pseudo : ")
                }
          , Inp.text
                [ onEnter SubmitSettings
                , padding 8
                ]
                { onChange = InputSettingsLastname
                , text = model.settingsLastname
                , placeholder = Inp.placeholder [] (El.text "Your lastname") |> Just
                , label = labelLeft
                            [ centerY ]
                            (El.text "lastname : ")
                }
          , Inp.text
                [ onEnter SubmitSettings
                , padding 8
                ]
                { onChange = InputSettingsFirstname
                , text = model.settingsFirstname
                , placeholder = Inp.placeholder [] (El.text "Your firstname") |> Just
                , label = labelLeft
                            [ centerY ]
                            (El.text "firstname : ")
                }
          , Inp.email
                [ onEnter SubmitSettings
                , padding 8
                ]
                { onChange = InputSettingsEmail
                , text = model.settingsEmail
                , placeholder = Inp.placeholder [] (El.text "Your email") |> Just
                , label = labelLeft
                            [ centerY ]
                            (El.text "email : ")
                }
          , El.el
                [ onEnter SubmitSettings
                , padding 8
                ]
                ( dropdown [] model.settingsGender InputSettingsGender
                  |> El.html
                )
          , El.el
                [ onEnter SubmitSettings
                , padding 8
                ]
                ( dropdown [] model.settingsOrientation InputSettingsOrientation
                  |> El.html
                )
          , Inp.multiline
                [ onEnter SubmitSettings
                , padding 8
                ]
                { onChange = InputSettingsBiography
                , text = model.settingsBiography
                , placeholder = Inp.placeholder [] (El.text "Your biography") |> Just
                , label = labelAbove
                            [ centerY
                            , El.alignLeft
                            ]
                            (El.text "biography : ")
                , spellcheck = True
                }
          , el  []
                ( MultiInput.view
                    { placeholder = "tags"
                    , toOuterMsg = InputSettingsTags
                    , isValid = matches "^[a-z0-9]+(?:-[a-z0-9]+)*$"
                    }
                    [] model.settingsTagsItems model.settingsTagsState
                  |> El.html
                )
          , Inp.button
                [ padding 0
                , centerX
                ]
                { onPress = Just SubmitSettings
                , label = El.text "update core settings"
                }
          ]

viewProfile : Profile -> Html Msg
viewProfile profile =
  div []
      [ img [ src profile.picture ] []
      , br [] []
      , a [ href ("/user/" ++ (String.fromInt profile.id)) ]
          [ Html.text profile.pseudo ]
      , br [] []
      , div [] (List.map Html.text profile.tags)
      , viewLikeButton profile.id profile.liked
      ]

viewLikeButton : Int -> Bool -> Html Msg
viewLikeButton id isLiked =
  Html.button
          [ Html.Events.onClick (Like id)
          , if isLiked
            then style "background-color" "red"
            else style "background-color" "white"
          ]
          [ Html.text "Like" ]

viewFeedPageNav : Feed a -> Html Msg
viewFeedPageNav lmodel =
  div []
    ( List.range 1 lmodel.feedPageAmount
    |> List.map (\ pageNr ->
                    Html.button [ Html.Events.onClick (FeedNav (pageNr - 1))
                           , if pageNr - 1 == lmodel.feedPageNumber
                             then style "background-color" "lightblue"
                             else style "background-color" "white"
                           ]
                           [ Html.text (String.fromInt pageNr) ]
                )
    )

viewFeed : Feed a -> Html Msg
viewFeed lmodel =
  if List.isEmpty lmodel.feedContent
  then
    Html.text "Loading content..."
  else
    div []
        [ div [] ( List.map viewProfile lmodel.feedContent )
        , viewFeedPageNav lmodel
        ]

viewGalery : (ZipList (a, String) -> Msg) -> ZipList (a, String) -> Html Msg
viewGalery toMsg pictures =
  div [ class "w"]
      [ div [ class "ts" ]
            ( pictures
              |> ZipList.indexedSelectedMap
                    ( viewGaleryElem
                        (\ index ->
                            ZipList.goTo index pictures
                            |> toMsg
                        )
                    )
              |> ZipList.toList
              |> List.concat
            )
      ]

viewGaleryElem : (Int -> Msg) -> Int -> Bool -> (a, String) -> List (Html Msg)
viewGaleryElem toMsg index checked (_, pict) =
  [ input [ Html.Attributes.id ("c" ++ String.fromInt(index + 1))
          , Html.Attributes.class "c"
          , Html.Attributes.type_ "radio"
          , Html.Attributes.name "ts"
          , Html.Attributes.checked checked
          , Html.Events.onClick (toMsg index)
          ] []
  , label [ Html.Attributes.class "t"
          , Html.Attributes.for ("c" ++ String.fromInt(index + 1))
          , Html.Attributes.attribute "style"
              ( if checked
                then "--w: 100%; --l: 0"
                else "--w: 20%; --l: " ++ String.fromInt(20 * index) ++ "%"
              )
          ]
          [ img [ Html.Attributes.src pict ] []
          ]
  ]

viewCarousel : List String -> Carousel.State -> (Carousel.Msg -> Msg) -> Html Msg
viewCarousel imgList state toMsg =
  Carousel.config toMsg
    [ Html.Attributes.style
        "width" "256px"
    , Html.Attributes.style
        "height" "256px"
    ]
  |> Carousel.withControls
  |> Carousel.withIndicators
  |> Carousel.slides
      ( imgList
        |> List.map
            (\ img ->
              Slide.config
                [ Html.Attributes.style
                    "background-image" ("url(\"" ++ img ++ "\")")
                , Html.Attributes.style
                    "background-size" "cover"
                , Html.Attributes.style
                    "background-position" "50% 50%"
                , Html.Attributes.style
                    "background-repeat" "no-repeat"
                , Html.Attributes.style
                    "width" "256px"
                , Html.Attributes.style
                    "height" "256px"
                ]
                (Slide.customContent (div [] [])) )
      )
  |> Carousel.view state

-- subscriptions

subscriptions : Model -> Sub Msg
subscriptions model =
  case model.access of
    Anonymous amodel ->
      Sub.none
    Logged lmodel ->
      [ Time.every 3000 Tick
      , MultiInput.subscriptions lmodel.settingsTagsState
        |> Sub.map InputSettingsTags
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
