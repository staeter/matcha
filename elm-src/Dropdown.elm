module Dropdown exposing (Item, dropdown)

import Html exposing (Html, option, select, text)
import Html.Attributes as At exposing (value, selected)
import Html.Events as Ev exposing (on, targetValue)
import Json.Decode as Decode exposing (map)
import ZipList exposing (ZipList, goToIndex, indexedSelectedMap, toList)


type alias Item a =
  ( a, String )

dropdown : List (Html.Attribute msg) -> ZipList (Item a) -> (ZipList (Item a) -> msg) -> Html msg
dropdown attributes itemList toMsg =
  Html.select
    ( onChange itemList toMsg
      :: attributes
    )
    ( ZipList.indexedSelectedMap toHtmlOption itemList
      |> ZipList.toList
    )


-- not exposed functions

toHtmlOption : Int -> Bool -> Item a -> Html msg
toHtmlOption index isSelected (_, text) =
  Html.option
    [ At.value (String.fromInt index)
    , At.selected isSelected
    ]
    [ Html.text text ]

onChange : ZipList (Item a) -> (ZipList (Item a) -> msg) -> Html.Attribute msg
onChange itemList toMsg =
  let
    goToNewIndexZipList optionValueStr =
      String.toInt optionValueStr
      |> Maybe.map (\ newIndex -> ZipList.goToIndex newIndex itemList )
      |> Maybe.withDefault itemList
  in
  Ev.on "change" (Decode.map (toMsg << goToNewIndexZipList) Ev.targetValue)
