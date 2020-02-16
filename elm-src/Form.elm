module Form exposing (..)

-- imports

import Array exposing (..)
import Json.Decode as Decode exposing (..)
import Json.Encode as Encode exposing (list, encode, Value)
import Http exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

import SingleSlider as SS exposing (..)
import DoubleSlider as DS exposing (..)
-- import Dropdown as Dropd exposing (..)
import MultiInput as MultInput exposing (..)

import Regex exposing (Regex)


-- types

type alias Form a =
  { url : String
  , fields : Array Field
  , implicitFields : List (String, String)
  , decoder : Decoder a
  , submition : Submition
  }

type Field
  = Text TextFieldModel
  | Password TextFieldModel
  | DoubleSlider DoubleSliderFieldModel
  | SingleSlider SingleSliderFieldModel
  -- | Dropdown DropdownFieldModel
  | Checkbox CheckboxFieldModel
  | Number NumberFieldModel
  | MultiInput MultiInputFieldModel

type alias MultiInputFieldModel =
  { label : String
  , items : List String
  , state : MultInput.State
  , placeholder : String
  }

type alias NumberFieldModel =
  { label : String
  , value : Int
  }

type alias CheckboxFieldModel =
  { label : String
  , value : Bool
  , text : String
  }

-- type alias DropdownFieldModel =
--   { label : String
--   , value : Maybe String
--   , options : Dropd.Options InputMsg
--   }

-- defaultDropdownFieldModel : String -> List String -> DropdownFieldModel
-- defaultDropdownFieldModel label options =
--   let
--     defaultOptions =
--       Dropd.defaultOptions DropdownMsg
--   in
--     { label = label
--     , value = List.head options
--     , options =
--         { items = options |> List.map
--             (\str ->
--                 { value = str
--                 , text = str
--                 , enabled = True
--                 }
--             )
--         , emptyItem = Nothing
--         , onChange = DropdownMsg
--         }
--     }

type alias SingleSliderFieldModel =
  { label : String
  , value : SS.SingleSlider InputMsg
  }

defaultSingleSliderFieldModel : String -> (Float, Float) -> SingleSliderFieldModel
defaultSingleSliderFieldModel label (min, max) =
  { label = label
  , value = SS.init { min = min
                    , max = max
                    , step = 1
                    , value = min
                    , onChange = SingleSliderMsg
                    }
  }

type alias DoubleSliderFieldModel =
  { label : String
  , value : DS.DoubleSlider InputMsg
  }

defaultDoubleSliderFieldModel : String -> (Float, Float) -> DoubleSliderFieldModel
defaultDoubleSliderFieldModel label (min, max) =
  { label = label
  , value = DS.init { min = min
                    , max = max
                    , lowValue = min
                    , highValue = max
                    , step = 1
                    , onLowChange = DoubleSliderLowMsg
                    , onHighChange = DoubleSliderHighMsg
                    }
  }

type alias TextFieldModel =
  { label : String
  , value : String
  , validation : List ((String -> Bool), String)
  -- , htmlAttributes : List (Attribute msg)
  }

defaultTextFieldModel : String -> TextFieldModel
defaultTextFieldModel label =
  { label = label
  , value = ""
  , validation = []
  -- , htmlAttributes = []
  }


-- type alias Condition =
--   { label : Label
--   , validation : Value -> Bool
--   }

type Submition
 = OnSubmit String
 | LiveUpdate

form : Decoder a -> Submition -> String -> List (String, String) -> Form a
form decoder submitionType url implicitFields =
  { url = url
  , fields = Array.empty
  , implicitFields = implicitFields
  , decoder = decoder
  , submition = submitionType
  }

add : Field -> Form a -> Form a
add field myForm =
  { myForm | fields = Array.push field myForm.fields }

textField : String -> Form a -> Form a
textField label myForm =
  add (defaultTextFieldModel label |> Text) myForm

passwordField : String -> Form a -> Form a
passwordField label myForm =
  add (defaultTextFieldModel label |> Password) myForm

doubleSliderField : String -> (Float, Float) -> Form a -> Form a
doubleSliderField label (min, max) myForm =
  add (defaultDoubleSliderFieldModel label (min, max) |> DoubleSlider) myForm

singleSliderField : String -> (Float, Float) -> Form a -> Form a
singleSliderField label (min, max) myForm =
  add (defaultSingleSliderFieldModel label (min, max) |> SingleSlider) myForm

-- dropdownField : String -> List String -> Form a -> Form a
-- dropdownField label options myForm =
--   add (defaultDropdownFieldModel label options |> Dropdown) myForm

checkboxField : String -> Bool -> String -> Form a -> Form a
checkboxField label checked text myForm =
  add
    ( Checkbox
        { label = label
        , value = checked
        , text = text
        }
    )
    myForm

numberField : String -> Int -> Form a -> Form a
numberField label defaultVal myForm =
  add (Number { label = label, value = defaultVal }) myForm

multiInputField : String -> List String -> Form a -> Form a
multiInputField label initialItems myForm =
  add
    ( MultiInput
        { label = label
        , items = initialItems
        , state = MultInput.init label
        , placeholder = label
        }
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
  | DoubleSliderLowMsg Float
  | DoubleSliderHighMsg Float
  | SingleSliderMsg Float
  -- | DropdownMsg (Maybe String)
  | CheckboxMsg Bool
  | NumberMsg Int
  | MultiInputMsg MultInput.Msg

type DoubleSliderMsg
  = DoubleSliderLowChange Float
  | DoubleSliderHighChange Float

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
              (myNewField, fieldCmd) = updateField inputMsg myField
              myNewForm = { myForm | fields = myForm.fields |> Array.set id myNewField }
              submitionCmd =
                case myForm.submition of
                  LiveUpdate -> submit myForm
                  OnSubmit _ -> Cmd.none

              cmd = Cmd.batch [Cmd.map (Input id) fieldCmd, submitionCmd]
            in
              ( myNewForm, cmd, Nothing)

          Nothing -> (myForm, Cmd.none, Nothing)

    Submit ->
      ( myForm
      , submit myForm
      , Nothing
      )

    Response result ->
      (myForm, Cmd.none, Just result)

updateField : InputMsg -> Field -> (Field, Cmd InputMsg)
updateField msg myField =
  case (myField, msg) of
    (Text model, TextMsg newVal) ->
      (Text { model | value = newVal }, Cmd.none)

    (Password model, PasswordMsg newVal) ->
      (Password { model | value = newVal }, Cmd.none)

    (DoubleSlider model, DoubleSliderLowMsg newLowVal) ->
      ( DoubleSlider { model | value = DS.updateLowValue newLowVal model.value }
      , Cmd.none )

    (DoubleSlider model, DoubleSliderHighMsg newHighVal) ->
      ( DoubleSlider { model | value = DS.updateHighValue newHighVal model.value }
      , Cmd.none )

    (SingleSlider model, SingleSliderMsg newVal) ->
      ( SingleSlider { model | value = SS.update newVal model.value }
      , Cmd.none )

    -- (Dropdown model, DropdownMsg newVal) ->
    --   ( Dropdown { model | value = newVal }
    --   , Cmd.none )

    (Checkbox model, CheckboxMsg newVal) ->
      (Checkbox { model | value = newVal }, Cmd.none)

    (Number model, NumberMsg newVal) ->
      (Number { model | value = newVal }, Cmd.none)

    (MultiInput model, MultiInputMsg mimsg) ->
      let
        ( nextState, nextItems, nextCmd ) =
            MultInput.update { separators = [ "\n", "\t", " ", "," ] } mimsg model.state model.items
      in
        ( MultiInput { model | items = nextItems, state = nextState }
        , nextCmd |> Cmd.map MultiInputMsg
        )

    _ -> (myField, Cmd.none)



submit : Form a -> Cmd (Msg a)
submit myForm =
  Http.post
      { url = myForm.url
      , body =
        List.append
          ( List.map httpPostFieldBodyPart (Array.toList myForm.fields) )
          ( List.map (\(key, val)-> stringPart key val |> List.singleton) myForm.implicitFields )
        |> List.concat |> multipartBody
      , expect = Http.expectJson Response myForm.decoder
      }

httpPostFieldBodyPart : Field -> List Http.Part
httpPostFieldBodyPart myField =
  case myField of
    Text model -> stringPart model.label model.value |> List.singleton
    Password model -> stringPart model.label model.value |> List.singleton
    DoubleSlider model ->
      ( DS.fetchLowValue model.value
        |> String.fromFloat
        |> Http.stringPart (model.label ++ "Min")
      ) ::
      ( DS.fetchHighValue model.value
        |> String.fromFloat
        |> Http.stringPart (model.label ++ "Max")
        |> List.singleton
      )
    SingleSlider model ->
      SS.fetchValue model.value
      |> String.fromFloat
      |> Http.stringPart model.label
      |> List.singleton
    -- Dropdown model ->
    --   model.value
    --   |> Maybe.map
    --     (\val -> stringPart model.label val |> List.singleton)
    --   |> Maybe.withDefault []
    Checkbox model ->
      if model.value
      then Http.stringPart model.label "True" |> List.singleton
      else Http.stringPart model.label "False" |> List.singleton
    Number model -> stringPart model.label (String.fromInt model.value) |> List.singleton
    MultiInput { label, items, state, placeholder } ->
      Encode.list Encode.string items
      |> Encode.encode 0
      |> Http.stringPart label
      |> List.singleton


-- subscriptions

subscriptions_field : Int -> Field -> Sub (Msg a)
subscriptions_field id myField =
  case myField of
    _ -> Sub.none

subscriptions : Form a -> Sub (Msg a)
subscriptions myForm =
  myForm.fields
  |> Array.indexedMap subscriptions_field
  |> Array.toList
  |> Sub.batch


-- view

view : Form a -> Html (Msg a)
view myForm =
  Html.form [ onSubmit Submit ]
            ( List.append
                ( myForm.fields
                  |> Array.indexedMap view_field
                  |> Array.toList
                )
                ( submitButton myForm.submition
                  |> List.singleton
                )
            )

submitButton : Submition -> Html (Msg a)
submitButton submitionType =
  case submitionType of
    LiveUpdate -> div [] []
    OnSubmit buttonText -> button [ type_ "submit" ] [ text buttonText ]

view_field : Int -> Field -> Html (Msg a)
view_field id myField =
  case myField of
    Text model ->
      input ( [ type_ "text"
              , onInput (Input id << TextMsg)
              , Html.Attributes.value model.value
              ]
              -- |> List.append htmlAttributes
            ) []

    Password model ->
      input ( [ type_ "password"
              , onInput (Input id << PasswordMsg)
              , Html.Attributes.value model.value
              ]
              -- |> List.append htmlAttributes
            ) []

    DoubleSlider model ->
      DS.view model.value
      |> Html.map (Input id)

    SingleSlider model ->
      SS.view model.value
      |> Html.map (Input id)

    -- Dropdown model ->
    --   Dropd.dropdown model.options [] model.value
    --   |> Html.map (Input id)

    Checkbox model ->
      div []
          [ input [ type_ "checkbox"
                  , Html.Attributes.id model.label
                  , onCheck (Input id << CheckboxMsg)
                  , Html.Attributes.checked model.value
                  ] []
          , label [ for model.label ]
                  [ text model.text ]
          ]

    Number model ->
      input [ type_ "number"
            , onInput (Input id << NumberMsg << Maybe.withDefault 0 << String.toInt)
            , Html.Attributes.value (String.fromInt model.value)
            ] []

    MultiInput { label, items, state, placeholder } ->
      MultInput.view
        { placeholder = placeholder
        , toOuterMsg = Input id << MultiInputMsg
        , isValid = matches "^[a-z0-9]+(?:-[a-z0-9]+)*$"
        }
        [] items state

matches : String -> String -> Bool
matches regex =
    let
      validRegex =
        Regex.fromString regex
        |> Maybe.withDefault Regex.never
    in
      Regex.findAtMost 1 validRegex >> List.isEmpty >> not
