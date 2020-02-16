module Dropdown exposing
    ( Item
    , dropdown
    )

{-|
This module is a rework of https://package.elm-lang.org/packages/abadi199/elm-input-extra/5.2.2/Dropdown

@docs Item, Options, defaultOptions


# View

@docs dropdown

-}

import Html exposing (Html, option, select)
import Html.Attributes as At exposing (value, selected)
import Html.Events as Ev exposing (on, targetValue)
import Json.Decode as Decode exposing (map)
import ZipList exposing (ZipList, indexedSelectedMap, toList)


{-| Item is the individual content of the dropdown.

  - `value` is the item value or `id`
  - `text` is the display text of the dropdown item.
  - `enabled` is a flag to indicate whether the item is enabled or disabled.

-}
type alias Item a =
  ( a, String )



{-| Html element.

Put this in your view's Html content.
Example:

    type Msg = DropdownChanged String

    Html.div []
        [ Dropdown.dropdown
            (Dropdown.defaultOptions DropdownChanged)
            [ class "my-dropdown" ]
            model.selectedDropdownValue
        ]

-}
dropdown : List (Html.Attribute msg) -> ZipList (Item a) -> (ZipList (Item a) -> msg) -> Html msg
dropdown attributes itemList toMsg =
    let
        toOption index isSelected (_, text) =
            Html.option
                [ At.value (String.fromInt index)
                , At.selected isSelected
                ]
                [ Html.text text ]
    in
    Html.select
        ( onChange itemList toMsg
          :: attributes
        )
        ( ZipList.indexedSelectedMap toOption itemList
          |> ZipList.toList
        )


onChange : ZipList (Item a) -> (ZipList (Item a) -> msg) -> Html.Attribute msg
onChange itemList toMsg =
    let
        goToNewIndexZipList optionValueStr =
          String.toInt optionValueStr
          |> Maybe.map (\ newIndex -> ZipList.goTo newIndex itemList )
          |> Maybe.withDefault itemList
    in
    Ev.on "change" (Decode.map (toMsg << goToNewIndexZipList) Ev.targetValue)
