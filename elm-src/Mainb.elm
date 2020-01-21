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

loggedAccessInit : Access
loggedAccessInit = Logged
  { filtersForm = Nothing
  , feedContent = []
  , feedPageNumber = 0
  , feedPageAmount = 0
  , feedElemAmount = 0
  , userDetails = Nothing
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
  | User Int
  | Unknown

routeParser : Parser (Route -> a) a
routeParser =
  Parser.oneOf
    [ Parser.map Home   (Parser.top)
    , Parser.map Signin (Parser.s "signin")
    , Parser.map Signup (Parser.s "signup")
    , Parser.map User   (Parser.s "user" </> Parser.int)
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
  | ReceiveUserDetails (Result Http.Error (DataAlert UserDetails))

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
      let
        newRoute =
          Maybe.withDefault
            Unknown
            (Parser.parse routeParser url)
      in
      case newRoute of
        User id ->
          ( model
          , Cmd.batch
              [ requestUserDetails id ReceiveUserDetails
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
      let
        newRoute =
          Maybe.withDefault
            Unknown
            (Parser.parse routeParser url)
      in
      case newRoute of
        User id ->
          ( { model | url = url }
          , requestUserDetails id ReceiveUserDetails
          )
        _ -> ({ model | url = url }, Cmd.none)

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

    (Logged lmodel, _, ReceiveFeedInit result) ->
      case result of
        Ok { data, alert } ->
          ( { model | alert = alert, access = Logged (receiveFeedInit data lmodel) }
          , Cmd.none
          )
        Err error ->
          ( model |> Alert.serverNotReachedAlert error
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
                    |> Alert.serverNotReachedAlert error
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
          ( model |> Alert.serverNotReachedAlert error
          , Cmd.none
          )

    (Logged lmodel, Home, Like id) ->
      let likeRequest = requestLike id ReceiveLikeUpdate in
      ( model, likeRequest )

    (Logged lmodel, _, ReceiveLikeUpdate result) ->
      case result of
        Ok { data, alert } ->
          case data of
            Just (id, newLikeStatus) ->
              ( { model | alert = alert , access = Logged
                  { lmodel | feedContent = List.map
                      (\profile ->
                        if profile.id == id
                        then { profile | liked = newLikeStatus }
                        else profile
                      )
                      lmodel.feedContent
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
                |> Alert.invalidImputAlert "Sory we can't let you access this user's infos. It could be because your account isn't complete."
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
      ( { model | access = loggedAccessInit } |> Alert.successAlert message
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

    (Logged lmodel, Home) ->
      { title = "matcha - home"
      , body =
        [ Alert.view model
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
          lmodel.userDetails
          |> Maybe.map viewUserDetails
          |> Maybe.withDefault ( text "Loading..." )
          |> List.singleton
      }

    (Logged _, _) ->
      { title = "matcha - 404 page not found"
      , body =
        [ text "You seem lost", br [] []
        , a [ href "/" ] [ text "go back home" ]
        ]
      }

viewUserDetails : UserDetails -> Html Msg
viewUserDetails userDetails =
  div []
      [ div []
          ( List.map
              (\p-> img [ src p ] [])
              userDetails.pictures
          )
      , h2 [] [ text userDetails.pseudo ]
      , br [] []
      , h3 [] [ text (userDetails.first_name ++ " " ++ userDetails.last_name) ]
      , br [] []
      , text (orientationToString userDetails.orientation ++ " " ++ genderToString userDetails.gender )
      , br [] []
      , text userDetails.birth
      , br [] [], br [] []
      , text userDetails.biography
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
