module Form exposing (..)

-- imports

import Array exposing (..)
import Json.Decode as Decode exposing (..)
import Json.Encode as Encode exposing (list, encode, Value)
import Http exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

import SingleSlider as SSlider exposing (..)
import DoubleSlider as DSlider exposing (..)
import Dropdown as Dropd exposing (..)
import MultiInput as MultInput exposing (..)

import Regex exposing (Regex)


-- types

type alias Form a =
  { url : String
  , fields : Array Field
  , decoder : Decoder a
  , submition : Submition
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
  | SingleSlider SSlider.Model
  | Dropdown (Dropd.Options InputMsg) (Maybe String)
  | Checkbox Bool
  | Number Int
  | MultiInput { items : List String, state : MultInput.State }

-- type alias Condition =
--   { label : Label
--   , validation : Value -> Bool
--   }

type Submition
 = OnSubmit String
 | LiveUpdate

form : Decoder a -> Submition -> String -> Form a
form decoder submitionType url =
  { url = url
  , fields = Array.empty
  , decoder = decoder
  , submition = submitionType
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

singleSliderField : Label -> (Float, Float, Float) -> Form a -> Form a
singleSliderField label (min, max, step) myForm =
  field
    label
    ( SingleSlider
        ( let
            mySingleSlider = SSlider.defaultModel
          in
            { mySingleSlider
                | min = min
                , max = max
                , step = step
                , value = min
            }
        )
    )
    myForm

dropdownField : Label -> List String -> Form a -> Form a
dropdownField label options myForm =
    let
      myDropdownTmp =
        Dropd.defaultOptions DropdownMsg

      myDropdown =
        { myDropdownTmp
          | items = options |> List.map
              (\str ->
                  { value = str
                  , text = str
                  , enabled = True
                  }
              )
        }

      selectedVal =
        List.head options
    in
      field label (Dropdown myDropdown selectedVal) myForm

checkboxField : Label -> Bool -> Form a -> Form a
checkboxField label checked myForm =
  field label (Checkbox checked) myForm

numberField : Label -> Int -> Form a -> Form a
numberField label defaultVal myForm =
  field label (Number defaultVal) myForm

multiInputField : Label -> List String -> Form a -> Form a
multiInputField label initialItems myForm =
  field
    label
    ( MultiInput
        { items = initialItems
        , state = MultInput.init label
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
  | DoubleSliderMsg DSlider.Msg
  | SingleSliderMsg SSlider.Msg
  | DropdownMsg (Maybe String)
  | CheckboxMsg Bool
  | NumberMsg Int
  | MultiInputMsg MultInput.Msg

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
  case (myField.value, msg) of
    (Text _, TextMsg val) ->
      ({ myField | value = Text val }, Cmd.none)

    (Password _, PasswordMsg val) ->
      ({ myField | value = Password val }, Cmd.none)

    (DoubleSlider myDoubleSlider, DoubleSliderMsg doubleSliderMsg) ->
      let
        (newDoubleSlider, _, _) =
          DSlider.update doubleSliderMsg myDoubleSlider
      in
        ({ myField | value = DoubleSlider newDoubleSlider }, Cmd.none)

    (SingleSlider mySingleSlider, SingleSliderMsg singleSliderMsg) ->
      let
        (newSingleSlider, _, _) =
          SSlider.update singleSliderMsg mySingleSlider
      in
        ({ myField | value = SingleSlider newSingleSlider }, Cmd.none)

    (Dropdown myDropdown _, DropdownMsg selectedVal) ->
      ({ myField | value = Dropdown myDropdown selectedVal }, Cmd.none)

    (Checkbox _, CheckboxMsg val) ->
      ({ myField | value = Checkbox val }, Cmd.none)

    (Number _, NumberMsg val) ->
      ({ myField | value = Number val }, Cmd.none)

    (MultiInput { items, state }, MultiInputMsg mimsg) ->
      let
        ( nextState, nextItems, nextCmd ) =
            MultInput.update { separators = [ "\n", "\t", " ", "," ] } mimsg state items
      in
        ( { myField | value = MultiInput{ items = nextItems, state = nextState } }
        , nextCmd |> Cmd.map MultiInputMsg
        )

    _ -> (myField, Cmd.none)



submit : Form a -> Cmd (Msg a)
submit myForm =
  Http.post
      { url = myForm.url
      , body =
        multipartBody
          (List.concat (List.map
            httpPostFieldBodyPart
            (Array.toList myForm.fields)
          ))
      , expect = Http.expectJson Response myForm.decoder
      }

httpPostFieldBodyPart : Field -> List Http.Part
httpPostFieldBodyPart myField =
  case myField.value of
    Text str -> stringPart myField.label str |> List.singleton
    Password str -> stringPart myField.label str |> List.singleton
    DoubleSlider doubleSlider ->
      stringPart (myField.label ++ "Min") (String.fromFloat doubleSlider.lowValue)
      :: stringPart (myField.label ++ "Max") (String.fromFloat doubleSlider.highValue)
      :: []
    SingleSlider singleSlider ->
      stringPart myField.label (String.fromFloat singleSlider.value)
      |> List.singleton
    Dropdown _ maybeVal ->
      maybeVal
      |> Maybe.map
        (\val -> stringPart myField.label val |> List.singleton)
      |> Maybe.withDefault
        (stringPart myField.label "Invalid" |> List.singleton)
    Checkbox checked ->
      if checked
      then stringPart myField.label "True" |> List.singleton
      else stringPart myField.label "False" |> List.singleton
    Number val -> stringPart myField.label (String.fromInt val) |> List.singleton
    MultiInput { items, state } ->
      Encode.list Encode.string items
      |> Encode.encode 0
      |> stringPart myField.label
      |> List.singleton


-- subscriptions

subscriptions_field : Int -> Field -> Sub (Msg a)
subscriptions_field id myField =
  case myField.value of
    DoubleSlider val ->
      DSlider.subscriptions val |> Sub.map (Input id << DoubleSliderMsg)
    MultiInput { items, state } ->
      MultInput.subscriptions state |> Sub.map (Input id << MultiInputMsg)
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
              (List.singleton (submitButton myForm.submition))
            )

submitButton : Submition -> Html (Msg a)
submitButton submitionType =
  case submitionType of
    LiveUpdate -> div [] []
    OnSubmit buttonText -> button [ type_ "submit" ] [ text buttonText ]

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

    SingleSlider val ->
      SSlider.view val |> Html.map (Input id << SingleSliderMsg)

    Dropdown myDropdown selectedVal ->
      Dropd.dropdown myDropdown [] selectedVal
      |> Html.map (Input id)

    Checkbox checked ->
      div []
          [ input [ type_ "checkbox"
                  , Html.Attributes.id myField.label
                  , onCheck (Input id << CheckboxMsg)
                  , Html.Attributes.checked checked
                  ] []
          , label [ for myField.label ]
                  [ text myField.label ]
          ]

    Number val ->
      input [ type_ "number"
            , placeholder myField.label
            , onInput (Input id << NumberMsg << Maybe.withDefault 0 << String.toInt)
            , Html.Attributes.value (String.fromInt val)
            ] []

    MultiInput { items, state } ->
      MultInput.view
        { placeholder = myField.label
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
