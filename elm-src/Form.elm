module Form exposing (..)

-- imports

import Array exposing (..)
import Json.Decode as Decode exposing (..)
import Http exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


-- types

type alias Form a =
  { url : String
  , fields : Array Field
  , decoder : Decoder a
  }

type alias Field =
  { label : Label
  , value : Value
  , conditions : Array Condition
  }

type alias Label = String

type Value
  = Text String
  | Password String

type alias Condition =
  { label : Label
  , validation : Value -> Bool
  }

-- type Submit -- //ni
--  = OnSubmit String
--  | LiveUpdate

form : Decoder a -> String -> Form a
form decoder url =
  { url = url
  , fields = Array.empty
  , decoder = decoder
  }

field : Label -> Value -> Array Condition -> Form a -> Form a
field label value conditions myForm =
  { myForm | fields
    = Array.push (Field label value conditions) myForm.fields
  }

condition : Label -> (Value -> Bool) -> Condition
condition label validation =
  Condition label validation


type Msg a
  = Input Int String
  | Submit
  | Response (Result Http.Error a)

update :  Msg a -> Form a -> (Form a, Cmd (Msg a), Maybe (Result Http.Error a))
update msg myForm =
  case msg of
    Input id updatedValue -> -- //ni
      let
        myField = Array.get id myForm.fields
        myNewField = Maybe.map
          (\mf ->
            { mf | value =
              case mf.value of
                Text val -> Text updatedValue
                Password val -> Password updatedValue
            }
          )
          myField
        myNewForm = Maybe.map
          (\mnf -> { myForm | fields = Array.set id mnf myForm.fields })
          myNewField
      in
        (Maybe.withDefault myForm myNewForm, Cmd.none, Nothing)

    Submit -> -- //ni
      ( myForm
      , Http.post
          { url = myForm.url
          , body =
              multipartBody
                (List.map
                  (\myField ->
                    case myField.value of
                      Text str -> stringPart myField.label str
                      Password str -> stringPart myField.label str
                  )
                  (Array.toList myForm.fields)
                )
          , expect = Http.expectJson Response myForm.decoder
          }
      , Nothing
      )

    Response result ->
      (myForm, Cmd.none, Just result)

view : Form a -> Html (Msg a)
view myForm =
  Html.form [ onSubmit Submit ]
            (List.append
              (Array.toList (Array.indexedMap view_field myForm.fields))
              (List.singleton (button [ type_ "submit" ] [ text "Submit" ])) -- //ni
            )

view_field : Int -> Field -> Html (Msg a)
view_field id myField =
  case myField.value of
    Text val ->
      input [ type_ "text"
            , placeholder "pseudo"
            , onInput (Input id)
            , Html.Attributes.value val
            ] []

    Password val ->
      input [ type_ "password"
            , placeholder "pseudo"
            , onInput (Input id)
            , Html.Attributes.value val
            ] []
