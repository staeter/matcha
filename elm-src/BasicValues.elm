module BasicValues exposing (..)

import Json.Decode as Decode exposing (..)


type LastLog
  = Now
  | AWhileAgo String

type Gender
  = Man
  | Woman

type Orientation
  = Homosexual
  | Bisexual
  | Heterosexual

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
