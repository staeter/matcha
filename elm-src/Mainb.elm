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


-- model

type alias Model =
  { url : Url
  , key : Nav.Key
  , alert : Maybe Alert
  , access : Access
  }

type Access
  = User UModel
  | Anonymous AModel

type alias UModel =
  { -- feed
    filtersForm : Maybe FiltersForm
  , feedContent : List Profile
  , feedPageNumber : Int
  , feedPageAmount : Int
  , feedElemAmount : Int
  -- , unreadNotifsAmount : Int
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

userAccessInit : Access
userAccessInit = User
  { filtersForm = Nothing
  , feedContent = []
  , feedPageNumber = 0
  , feedPageAmount = 0
  , feedElemAmount = 0
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

type alias DataAlert a =
  { alert : Maybe Alert, data : Maybe a }

dataAlertDecoder : Decoder a -> Decoder (DataAlert a)
dataAlertDecoder dataDecoder =
  Field.attempt "data" dataDecoder <| \data ->
  Field.attempt "alert" alertDecoder <| \alert ->

  Decode.succeed ({ data = data, alert = alert })


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
  | Unknown

routeParser : Parser (Route -> a) a
routeParser =
  Parser.oneOf
    [ Parser.map Home (Parser.top)
    , Parser.map Signin (Parser.s "signin")
    , Parser.map Signup (Parser.s "signup")
    ]


-- update

type Msg
  = NoOp
  | InternalLinkClicked Url
  | ExternalLinkClicked String
  | UrlChange Url
  | SigninForm (Form.Msg (Result String String))
  | SignupForm (Form.Msg (Result String String))
  | ReceiveFeedInit (Result Http.Error (DataAlert (FiltersForm, PageContent)))
  | FiltersForm FiltersFormMsg
  | ReceivePageContentUpdate (Result Http.Error (DataAlert PageContent))
  | FeedNav Int

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  let
    route =
      Maybe.withDefault
        Unknown
        (Parser.parse routeParser model.url)
  in
  case (model.access, route, msg) of
    (_, _, InternalLinkClicked url) ->
      (model, Nav.pushUrl model.key (Url.toString url) )

    (_, _, ExternalLinkClicked href) ->
      (model, Nav.load href)

    (_, _, UrlChange url) ->
      ({ model | url = url }, Cmd.none)

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

    (User umodel, _, ReceiveFeedInit result) ->
      case result of
        Ok { data, alert } ->
          ( { model | alert = alert, access = User (receiveFeedInit data umodel) }
          , Cmd.none
          )
        Err error ->
          ( model |> Alert.serverNotReachedAlert error
          , Cmd.none
          )

    (User umodel, _, FiltersForm formMsg) ->
      case umodel.filtersForm of
        Nothing -> ( model, Cmd.none )
        Just currentFiltersForm ->
          let
            (newForm, formCmd, response) = Form.update formMsg currentFiltersForm
          in
            case response of
              Just (Ok { data, alert }) ->
                ( { model | alert = alert, access = User (receivePageContentUpdate True data umodel) }
                , formCmd |> Cmd.map FiltersForm
                )
              Just (Err error) ->
                ( { model | access = User { umodel | filtersForm = Just newForm } }
                    |> Alert.serverNotReachedAlert error
                , formCmd |> Cmd.map FiltersForm
                )
              Nothing ->
                ( { model | access = User { umodel | filtersForm = Just newForm } }
                , formCmd |> Cmd.map FiltersForm
                )

    (User umodel, Home, FeedNav page) ->
      let maybeNewUModelCmdTuple = requestFeedPage page umodel in
      case maybeNewUModelCmdTuple of
        Just (newUModel, pageRequestCmd) ->
          ( { model | access = User newUModel }, pageRequestCmd )
        Nothing ->
          ( model, Cmd.none )

    (User umodel, _, ReceivePageContentUpdate result) ->
      case result of
        Ok { data, alert } ->
          ( { model | alert = alert, access = User (receivePageContentUpdate False data umodel) }
          , Cmd.none
          )
        Err error ->
          ( model |> Alert.serverNotReachedAlert error
          , Cmd.none
          )

    _ -> ( model, Cmd.none )


signinFormResultHandler result model cmd =
  case result of
    Ok (Ok message) ->
      ( { model | access = userAccessInit } |> Alert.successAlert message
      , Cmd.batch
        [ Nav.pushUrl model.key "/"
        , cmd |> Cmd.map SigninForm
        , requestFeedInit
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

signupFormResultHandler result model cmd =
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


-- feed

type alias Feed a =
  { a
    | filtersForm : Maybe FiltersForm
    , feedContent : List Profile
    , feedPageNumber : Int
    , feedPageAmount : Int
    , feedElemAmount : Int
  }

type alias FiltersForm = Form (DataAlert PageContent)
type alias FiltersFormMsg = Form.Msg (DataAlert PageContent)

type alias Profile =
  { id : Int
  , pseudo : String
  , picture : String
  , tags : List String
  , liked : Bool
  }

type alias PageContent =
  { pageAmount : Int
  , elemAmount : Int
  , users : List Profile
  }

type alias FiltersEdgeValues =
  { ageMin : Float
  , ageMax : Float
  , distanceMax : Float
  , popularityMin : Float
  , popularityMax : Float
  }

filtersFormInit : FiltersEdgeValues -> FiltersForm
filtersFormInit {ageMin, ageMax, distanceMax, popularityMin, popularityMax} =
  Form.form (dataAlertDecoder pageContentDecoder) LiveUpdate "http://localhost/control/feed_filter.php"
  |> Form.doubleSliderField "age" (ageMin, ageMax, 1)
  |> Form.doubleSliderField "popularity" (popularityMin, popularityMax, 1)
  |> Form.singleSliderField "distanceMax" (3, distanceMax, 1)
  |> Form.checkboxField "viewed" False
  |> Form.checkboxField "liked" False

requestFeedInit : Cmd Msg
requestFeedInit =
  Http.post
      { url = "http://localhost/control/feed_open.php"
      , body = emptyBody
      , expect = Http.expectJson ReceiveFeedInit (dataAlertDecoder feedOpenDecoder)
      }

requestFeedPage : Int -> Feed a -> Maybe (Feed a, Cmd Msg)
requestFeedPage requestedPageNumber umodel =
  if requestedPageNumber /= umodel.feedPageNumber &&
     requestedPageNumber < umodel.feedPageAmount &&
     requestedPageNumber >= 0
  then Just
    ( { umodel | feedPageNumber = requestedPageNumber, feedContent = [] }
    , Http.post
        { url = "http://localhost/control/feed_page.php"
        , body = multipartBody [stringPart "page" (String.fromInt requestedPageNumber)]
        , expect = Http.expectJson ReceivePageContentUpdate (dataAlertDecoder pageContentDecoder)
        }
    )
  else Nothing

receiveFeedInit : Maybe (FiltersForm, PageContent) -> Feed a -> Feed a
receiveFeedInit maybeData umodel =
  case maybeData of
    Just (receivedFiltersForm, receivedPageContent) ->
      { umodel | filtersForm = Just receivedFiltersForm}
      |> receivePageContentUpdate True (Just receivedPageContent)
    Nothing -> umodel

receivePageContentUpdate : Bool -> Maybe PageContent -> Feed a -> Feed a
receivePageContentUpdate resetPage maybeReceivedPageContent umodel =
  case maybeReceivedPageContent of
    Just receivedPageContent ->
      { umodel
        | feedContent = receivedPageContent.users
        , feedPageNumber = if resetPage then 0 else umodel.feedPageNumber
        , feedPageAmount = receivedPageContent.pageAmount
        , feedElemAmount = receivedPageContent.elemAmount
      }
    Nothing -> umodel

feedOpenDecoder : Decoder (FiltersForm, PageContent)
feedOpenDecoder =
  Field.require "filtersEdgeValues" filtersEdgeValuesDecoder <| \filtersEdgeValues ->
  Field.require "pageContent" pageContentDecoder <| \pageContent ->

  Decode.succeed
    ( filtersFormInit filtersEdgeValues
    , pageContent
    )

pageContentDecoder : Decoder PageContent
pageContentDecoder =
  Field.require "pageAmount" Decode.int <| \pageAmount ->
  Field.require "elemAmount" Decode.int <| \elemAmount ->
  Field.require "users" (Decode.list profileDecoder) <| \users ->

  Decode.succeed
    { pageAmount = pageAmount
    , elemAmount = elemAmount
    , users = users
    }

profileDecoder : Decoder Profile
profileDecoder =
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


-- view

view : Model -> Browser.Document Msg
view model =
  let
    route =
      Maybe.withDefault
        Unknown
        (Parser.parse routeParser model.url)
  in
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

    (User umodel, Home) ->
      { title = "matcha - home"
      , body =
        [ Alert.view model
        , Maybe.map Form.view umodel.filtersForm
          |> Maybe.map (Html.map FiltersForm)
          |> Maybe.withDefault (text "Loading...")
        , viewFeed umodel
        ]
      }

    (User _, _) ->
      { title = "matcha - 404 page not found"
      , body =
        [ text "You seem lost", br [] []
        , a [ href "/" ] [ text "go back home" ]
        ]
      }

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
      , br [] [], text profile.pseudo
      , br [] [], div [] (List.map text profile.tags)
      , if profile.liked then text "liked" else text "nope"
      ]

viewFeedPageNav : Feed a -> Html Msg
viewFeedPageNav umodel =
  div []
    ( List.range 1 umodel.feedPageAmount
    |> List.map (\ pageNr ->
                    button [ onClick (FeedNav (pageNr - 1))
                           , if pageNr - 1 == umodel.feedPageNumber
                             then style "background-color" "lightblue"
                             else style "background-color" "white"
                           ]
                           [ text (String.fromInt pageNr) ]
                )
    )

viewFeed : Feed a -> Html Msg
viewFeed umodel =
  if List.isEmpty umodel.feedContent
  then
    text "Loading content..."
  else
    div []
        [ div [] ( List.map viewProfile umodel.feedContent )
        , viewFeedPageNav umodel
        ]


-- subscriptions

subscriptions : Model -> Sub Msg
subscriptions model =
  case model.access of
    Anonymous amodel ->
      anonymousAccess_sub amodel
    User umodel ->
      Sub.none

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
