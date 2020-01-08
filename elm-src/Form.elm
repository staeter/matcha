module Form exposing (..)

-- imports

import Array exposing (..)
import Json.Decode as Decode exposing (..)
import Http exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import DoubleSlider as DSlider exposing (..)


-- types

type alias Form a =
  { url : String
  , fields : Array Field
  , decoder : Decoder a
  }

type alias Field =
  { label : Label
  , value : Value
  }

type alias Label = String

type Value
  = Text String
  | Password String
  | DoubleSlider DSlider.Model

-- type alias Condition =
--   { label : Label
--   , validation : Value -> Bool
--   }

-- type Submit -- //ni
--  = OnSubmit String
--  | LiveUpdate

form : Decoder a -> String -> Form a
form decoder url =
  { url = url
  , fields = Array.empty
  , decoder = decoder
  }

field : Label -> Value -> Form a -> Form a
field label value myForm =
  { myForm | fields
    = Array.push (Field label value) myForm.fields
  }

textField : Label -> Form a -> Form a
textField label myForm =
  field label (Text "") myForm

passwordField : Label -> Form a -> Form a
passwordField label myForm =
  field label (Password "") myForm

doubleSliderField : Label -> (Float, Float, Int) -> Form a -> Form a
doubleSliderField label (min, max, step) myForm =
  field
    label
    ( DoubleSlider
        ( let
            myDoubleSlider = DSlider.defaultModel
          in
            { myDoubleSlider
                | min = min
                , max = max
                , step = step
                , lowValue = min
                , highValue = max
            }
        )
    )
    myForm

-- condition : Label -> (Value -> Bool) -> Condition
-- condition label validation =
--   Condition label validation


type Msg a
  = Input Int InputMsg
  | Submit
  | Response (Result Http.Error a)

type InputMsg
  = TextMsg String
  | PasswordMsg String
  | DoubleSliderMsg DSlider.Msg

update :  Msg a -> Form a -> (Form a, Cmd (Msg a), Maybe (Result Http.Error a))
update msg myForm =
  case msg of
    Input id inputMsg ->
      let
        maybeMyField = Array.get id myForm.fields
      in
        case maybeMyField of

          Just myField ->
            let
              myNewField = updateField inputMsg myField
              myNewForm = { myForm | fields = myForm.fields |> Array.set id myNewField }
            in
              ( myNewForm, Cmd.none, Nothing)

          Nothing -> (myForm, Cmd.none, Nothing)

    Submit ->
      ( myForm
      , Http.post
          { url = myForm.url
          , body =
            multipartBody
              (List.concat (List.map
                httpPostFieldBodyPart
                (Array.toList myForm.fields)
              ))
          , expect = Http.expectJson Response myForm.decoder
          }
      , Nothing
      )

    Response result ->
      (myForm, Cmd.none, Just result)

updateField : InputMsg -> Field -> Field
updateField msg myField =
  case myField.value of
    Text _ ->
      case msg of
        TextMsg val -> { myField | value = Text val }
        _ -> myField
    Password _ ->
      case msg of
        PasswordMsg val -> { myField | value = Password val }
        _ -> myField
    DoubleSlider myDoubleSlider ->
      case msg of
        DoubleSliderMsg doubleSliderMsg ->
          let
            (newDoubleSlider, _, _) =
              DSlider.update doubleSliderMsg myDoubleSlider
          in
            { myField | value = DoubleSlider newDoubleSlider }
        _ -> myField

httpPostFieldBodyPart : Field -> List Http.Part
httpPostFieldBodyPart myField =
  case myField.value of
    Text str -> stringPart myField.label str |> List.singleton
    Password str -> stringPart myField.label str |> List.singleton
    DoubleSlider doubleSlider ->
      stringPart (myField.label ++ "Min") (String.fromFloat doubleSlider.lowValue)
      :: stringPart (myField.label ++ "Max") (String.fromFloat doubleSlider.highValue)
      :: []

-- inputHandler : Int -> InputMsg -> Form a -> (Form a, Cmd (Msg a), Maybe (Result Http.Error a))
-- inputHandler id inputMsg =
--
--       case updatedValue of
--         TextMsg newValue ->
--           case myField.value of
--             Text val ->
--               let
--                 myNewField = { myField | value = Text updatedValue }
--                 myNewForm = { myForm | fields = myForm.fields |> Array.set id myNewField }
--               in
--                 (myNewForm, Cmd.none, Nothing)
--
--             _ -> (myForm, Cmd.none, Nothing)
--
--         PasswordMsg newValue ->
--           case myField.value of
--             Password val ->
--               let
--                 myNewField = { myField | value = Password updatedValue }
--                 myNewForm = { myForm | fields = myForm.fields |> Array.set id myNewField }
--               in
--                 (myNewForm, Cmd.none, Nothing)
--
--             _ -> (myForm, Cmd.none, Nothing)
--
--         DoubleSliderMsg doubleSliderMsg ->
--           case myField.value of
--             DoubleSlider myDoubleSlider ->
--               let
--                 {-
--                 I took a look at DSlider package implementation and it seems
--                 that the cmd returned by DSlider.update is always = Cmd.none
--                 which makes the use of the if else they propose in the doc
--                 completely useless.
--                 https://package.elm-lang.org/packages/carwow/elm-slider/10.0.0/
--                 -- //ni: They are building a new vertion! Update on release
--                 -}
--                 (newDoubleSlider, doubleSliderCmd, updateResults) =
--                   DSlider.update doubleSliderMsg myDoubleSlider
--
--                 myNewField = { myField | value = DoubleSlider newDoubleSlider }
--                 myNewForm = { myForm | fields = Array.set id myNewField myForm.fields }
--                 cmd = Cmd.none
--                   -- if updateResults
--                   -- then doubleSliderCmd |> Cmd.map (Input id << DoubleSliderMsg)
--                   -- else Cmd.none
--               in
--                 ( myNewForm, cmd, Nothing )
--
--             _ ->
--               (myForm, Cmd.none, Nothing)


-- subscriptions

subscriptions_field : Int -> Field -> Sub (Msg a)
subscriptions_field id myField =
  case myField.value of
    DoubleSlider val ->
      DSlider.subscriptions val |> Sub.map (Input id << DoubleSliderMsg)
    _ -> Sub.none

subscriptions : Form a -> Sub (Msg a)
subscriptions myForm =
  Sub.batch (Array.toList (Array.indexedMap subscriptions_field myForm.fields))


-- view

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
            , placeholder myField.label
            , onInput (Input id << TextMsg)
            , Html.Attributes.value val
            ] []

    Password val ->
      input [ type_ "password"
            , placeholder myField.label
            , onInput (Input id << PasswordMsg)
            , Html.Attributes.value val
            ] []

    DoubleSlider val ->
      DSlider.view val |> Html.map (Input id << DoubleSliderMsg)
