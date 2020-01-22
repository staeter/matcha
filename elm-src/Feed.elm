module Feed exposing (..)


import Http exposing (..)

import Json.Decode as Decode exposing (..)
import Json.Decode.Field as Field exposing (..)

import Form exposing (..)
import Alert exposing (..)

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

requestFeedInit : (Result Http.Error (DataAlert (FiltersForm, PageContent)) -> msg) -> Cmd msg
requestFeedInit toMsg =
  Http.post
      { url = "http://localhost/control/feed_open.php"
      , body = emptyBody
      , expect = Http.expectJson toMsg (dataAlertDecoder feedOpenDecoder)
      }

requestFeedPage : Int -> (Result Http.Error (DataAlert PageContent) -> msg) -> Feed a -> Maybe (Feed a, Cmd msg)
requestFeedPage requestedPageNumber toMsg umodel =
  if requestedPageNumber /= umodel.feedPageNumber
  && requestedPageNumber < umodel.feedPageAmount
  && requestedPageNumber >= 0
  then Just
    ( { umodel | feedPageNumber = requestedPageNumber, feedContent = [] }
    , Http.post
        { url = "http://localhost/control/feed_page.php"
        , body = multipartBody [stringPart "page" (String.fromInt requestedPageNumber)]
        , expect = Http.expectJson toMsg (dataAlertDecoder pageContentDecoder)
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
