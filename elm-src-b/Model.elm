module Model exposing (..)


-- includes

import Json.Decode as Decode exposing (..)
import Json.Decode.Field as Field exposing (..)


-- model

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

type Status
  = Success
  | Failure

type Gender
  = Man
  | Woman

type Orientation
  = Homosexual
  | Bisexual
  | Heterosexual

type alias Alert =
  { id : Int
  , content : String
  }


-- special functions

load : Alert
load =
  { id = 0
  , content = "Loading..."
  }


-- decoders

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
