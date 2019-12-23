module Signin exposing (..)


-- imports

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

-- modules


-- model

type alias Model =
  { pseudo : String
  , password : String
  }

init : Model
init =
  { pseudo = ""
  , password = ""
  }


-- url

-- onUrlRequest : UrlRequest -> Msg
-- onUrlRequest request =
--   NoOp
--
-- onUrlChange : Url -> Msg
-- onUrlChange url =
--   NoOp


-- update

type Msg
  = NoOp
  | Input_pseudo String
  | Input_password String
  | Submit

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Input_pseudo pseudo ->
      ( { model | pseudo = pseudo }
      , Cmd.none
      )

    Input_password password ->
      ( { model | password = password }
      , Cmd.none
      )

    _ ->
       (model, Cmd.none)


-- view

view : Model -> Html Msg
view model =
  Html.form [ onSubmit Submit ]
    [ input [ type_ "text"
            , placeholder "pseudo"
            , onInput Input_pseudo
            , Html.Attributes.value model.pseudo
            ] []
    , input [ type_ "password"
            , placeholder "password"
            , onInput Input_password
            , Html.Attributes.value model.password
            ] []
    , button [ type_ "submit" ]
             [ text "Sign In" ]
    ]
