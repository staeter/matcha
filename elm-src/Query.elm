module Query exposing (..)


-- includes

import Json.Decode as Decode exposing (..)
import Json.Decode.Field as Field exposing (..)


-- my own modules

import Model exposing (..)
import Account exposing (..)


-- model

type alias SD =
  { status : Status
  , data : Data
  }

type alias Data =
  { alert : Maybe Alert
  , log : Maybe String
  , settings : Maybe Settings
  }


-- special functions

replace_alert : Maybe Alert -> Maybe Alert -> Maybe Alert
replace_alert alert newalert =
  case (alert, newalert) of
    (Just msg, Just nm) -> Just { nm | id = msg.id + 1 }
    (Nothing, Just nm) -> Just nm
    (Just msg, Nothing) -> alert
    (Nothing, Nothing) -> Nothing

remove_alert : Int -> Maybe Alert -> Maybe Alert
remove_alert idtoremove alert =
  case alert of
    Just a ->
      if a.id == idtoremove
      then Nothing
      else Just a
    Nothing -> Nothing


-- decoders

sdDecoder : Decoder SD
sdDecoder =
  Field.require "status" statusDecoder <| \status ->
  Field.require "data" dataDecoder <| \data ->

  Decode.succeed
    { status = status
    , data = data
    }

dataDecoder : Decoder Data
dataDecoder =
  Field.attempt "alert" alertDecoder <| \alert ->
  Field.attempt "log" Decode.string <| \log ->
  Field.attempt "settings" settingsDecoder <| \settings ->

  Decode.succeed
    { alert = alert
    , log = log
    , settings = settings
    }

alertDecoder : Decoder Alert
alertDecoder =
  Field.require "content" Decode.string <| \content ->

  Decode.succeed
    { id = 1
    , content = content
    }
