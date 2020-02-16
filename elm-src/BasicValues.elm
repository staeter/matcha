module BasicValues exposing (..)

import Json.Decode as Decode exposing (..)


type LastLog
  = Now
  | AWhileAgo String

type Gender
  = Man
  | Woman

genderToString : Gender -> String
genderToString gender =
  case gender of
    Man -> "Man"
    Woman -> "Woman"

genderList : List (Gender, String)
genderList =
  [ (Man, "man")
  , (Woman, "woman")
  ]

type Orientation
  = Homosexual
  | Bisexual
  | Heterosexual

orientationToString : Orientation -> String
orientationToString orientaion =
  case orientaion of
    Homosexual -> "Homosexual"
    Bisexual -> "Bisexual"
    Heterosexual -> "Heterosexual"

orientationList : List (Orientation, String)
orientationList =
  [ (Homosexual, "homosexual")
  , (Bisexual, "bisexual")
  , (Heterosexual, "heterosexual")
  ]

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
