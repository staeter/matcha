module Account exposing (..)


-- import

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

import Json.Decode as Decode exposing (..)
import Json.Decode.Field as Field exposing (..)


-- my own modules

import Model exposing (..)


-- model

type Account
  = SignIn SignInData
  | SignUp SignUpData
  | SignOut (Maybe Settings)

type alias SignInData =
  { pseudo : String
  , password : String
  }

type alias SignUpData =
  { pseudo : String
  , email : String
  , password : String
  , confirm : String
  }

type alias Settings =
  { pseudo : String
  , name : String
  , firstname : String
  , email : String
  , gender : Gender
  , orientation : Orientation
  , tags : List String
  , description : String
  -- , localisation : ??? //ni
  , pictures : PicturesData
  , password : PasswordData
  }

type alias PicturesData =
  { main : String
  , other : List String
  }

type alias PasswordData =
  { oldpassword : String
  , newpassword : String
  , confirm : String
  }



-- empty

empty_signindata : Account
empty_signindata =
  SignIn { pseudo = "", password = "" }

empty_signupdata : Account
empty_signupdata =
  SignUp { pseudo = "", email = "", password = "", confirm = "" }

empty_passworddata : PasswordData
empty_passworddata =
  { oldpassword = ""
  , newpassword = ""
  , confirm = ""
  }


-- decoders

settingsDecoder : Decoder Settings
settingsDecoder =
  Field.require "pseudo" Decode.string <| \pseudo ->
  Field.require "name" Decode.string <| \name ->
  Field.require "firstname" Decode.string <| \firstname ->
  Field.require "email" Decode.string <| \email ->
  Field.require "gender" genderDecoder <| \gender ->
  Field.require "orientation" orientationDecoder <| \orientation ->
  Field.require "tags" (Decode.list Decode.string) <| \tags ->
  Field.require "description" Decode.string <| \description ->
  Field.require "pictures" picturesDataDecoder <| \pictures ->

  Decode.succeed
    { pseudo = pseudo
    , name = name
    , firstname = firstname
    , email = email
    , gender = gender
    , orientation = orientation
    , tags = tags
    , description = description
    , pictures = pictures
    , password = empty_passworddata
    }

picturesDataDecoder : Decoder PicturesData
picturesDataDecoder =
  Field.require "main" Decode.string <| \main_ ->
  Field.require "other" (Decode.list Decode.string) <| \other ->

  Decode.succeed
    { main = main_
    , other = other
    }
