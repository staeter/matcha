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
  | FeedNav Int
  | ReceivePageContentUpdate (Result Http.Error (DataAlert PageContent))
  | Like Int
  | ReceiveLikeUpdate (Result Http.Error (DataAlert (Int, Bool)))

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
      let maybeNewUModelCmdTuple = requestFeedPage page ReceivePageContentUpdate umodel in
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

    (User umodel, Home, Like id) ->
      let likeRequest = requestLike id ReceiveLikeUpdate in
      ( model, likeRequest )

    (User umodel, _, ReceiveLikeUpdate result) ->
      case result of
        Ok { data, alert } ->
          case data of
            Just (id, newLikeStatus) ->
              ( { model | alert = alert , access = User
                  { umodel | feedContent = List.map
                      (\profile ->
                        if profile.id == id
                        then { profile | liked = newLikeStatus }
                        else profile
                      )
                      umodel.feedContent
                  }
                }
              , Cmd.none
              )
            Nothing ->
              ( model |> Alert.invalidImputAlert "Sory we can't let you like/unlike this persone. It could be because your account isn't complete."
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
        , requestFeedInit ReceiveFeedInit
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
