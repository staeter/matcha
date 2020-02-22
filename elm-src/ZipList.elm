-- https://package.elm-lang.org/packages/guid75/zipList/latest/ZipList

module ZipList exposing
    ( ZipList
    , fromList, singleton
    , current, toList, length
    , forward, backward
    , currentIndex
    , jumpForward, jumpBackward
    , goToIndex, goToFirst, isCurrent
    , goToNext, goToLast
    , goToPrevious, zipListDecoder
    , map, indexedMap
    , selectedMap, indexedSelectedMap
    , remove, replace, insert
    , insertAfter, insertBefore
    )

{-| A `ZipList` is a collection which can be moved forward/backward and that exposes a single current element


# ZipLists

@docs ZipList


# Creation

@docs fromList, singleton


# Consultation

@docs current, toList, length


# Moving

@docs forward, backward

-}

import Maybe
import Json.Decode as Decode exposing (Decoder, list, decodeString, map)
import MyList exposing (indexedAny)

{-| A collection data type that can be moved forward/backward and that exposes a current element (see the `current` function)
-}
type ZipList a
    = Empty
    | Zipper (List a) a (List a)


{-| Craft a new ZipList out of a List
-}
fromList : List a -> ZipList a
fromList list =
    case list of
        [] ->
            Empty

        head :: queue ->
            Zipper [] head queue


{-| Create a new ZipList with a single element in it
-}
singleton : a -> ZipList a
singleton item =
    Zipper [] item []


{-| Return the current element of a ZipList. `Nothing` will be returned if the zipList is empty
-}
current : ZipList a -> Maybe a
current zipList =
    case zipList of
        Empty ->
            Nothing

        Zipper _ elem _ ->
            Just elem

remove : ZipList a -> ZipList a
remove zipList =
  case zipList of
    Empty -> Empty
    Zipper [] _ [] -> Empty
    Zipper before _ (head :: queue) ->
        Zipper before head queue
    Zipper (head :: queue) _ [] ->
        Zipper queue head []

replace : a -> ZipList a -> ZipList a
replace newElem zipList =
  case zipList of
    Empty -> Empty
    Zipper before _ after ->
      Zipper before newElem after

insert : a -> ZipList a -> ZipList a
insert newElem zipList =
  case zipList of
    Empty -> Zipper [] newElem []
    Zipper before elem after ->
      Zipper (elem :: before) newElem after

insertAfter : a -> ZipList a -> ZipList a
insertAfter newElem zipList =
  case zipList of
    Empty -> Zipper [] newElem []
    Zipper before elem after ->
      Zipper before elem (newElem :: after)

insertBefore : a -> ZipList a -> ZipList a
insertBefore newElem zipList =
  case zipList of
    Empty -> Zipper [] newElem []
    Zipper before elem after ->
      Zipper (newElem :: before) elem after


{-| Move forward a `ZipList`
-}
forward : ZipList a -> ZipList a
forward zipList =
    case zipList of
        Empty ->
            zipList

        Zipper before elem after ->
            case after of
                [] ->
                    zipList

                head :: queue ->
                    Zipper (elem :: before) head queue


{-| Move backward a `ZipList`
-}
backward : ZipList a -> ZipList a
backward zipList =
    case zipList of
        Empty ->
            zipList

        Zipper before elem after ->
            case before of
                [] ->
                    zipList

                head :: queue ->
                    Zipper queue head (elem :: after)


{-| Convert a `ZipList` into a `List`
-}
toList : ZipList a -> List a
toList zipList =
    case zipList of
        Empty ->
            []

        Zipper before elem after ->
            List.concat
                [ List.reverse before
                , List.singleton elem
                , after
                ]


{-| Return a `ZipList` length
-}
length : ZipList a -> Int
length zipList =
    case zipList of
        Empty ->
            0

        Zipper before _ after ->
            1 + List.length before + List.length after


currentIndex : ZipList a -> Maybe Int
currentIndex zipList =
  case zipList of
    Empty -> Nothing
    Zipper before _ _ ->
      List.length before |> Just

jumpForward : Int -> ZipList a -> ZipList a
jumpForward jumpSize zipList =
  if jumpSize <= 0
  then zipList
  else case zipList of
    Zipper before elem (head :: queue) ->
        Zipper (elem :: before) head queue
        |> jumpForward (jumpSize - 1)
    _ -> zipList

jumpBackward : Int -> ZipList a -> ZipList a
jumpBackward jumpSize zipList =
  if jumpSize <= 0
  then zipList
  else case zipList of
    Zipper (head :: queue) elem after ->
        Zipper queue head (elem :: after)
        |> jumpBackward (jumpSize - 1)
    _ -> zipList

type Sign
  = Zero
  | Positif
  | Negatif

sign : Int -> Sign
sign val =
  if val == 0
  then Zero
  else
    if val > 0
    then Positif
    else Negatif

goToIndex : Int -> ZipList a -> ZipList a
goToIndex newIndex zipList =
  let
    maybeIndex = currentIndex zipList
    delta =
      maybeIndex
      |> Maybe.map (\index -> newIndex - index)
      |> Maybe.withDefault 0
  in
  case sign delta of
    Zero -> zipList
    Positif ->
      jumpForward delta zipList
    Negatif ->
      jumpBackward (abs delta) zipList

isCurrent : (a -> Bool) -> ZipList a -> Bool
isCurrent condition zipList =
  current zipList
  |> Maybe.map condition
  |> Maybe.withDefault False

goToFirst : (a -> Bool) -> ZipList a -> ZipList a
goToFirst condition zipList =
  let newZipList = goToIndex 0 zipList in
  if isCurrent condition newZipList
  then newZipList
  else goToNext condition newZipList

goToNext : (a -> Bool) -> ZipList a -> ZipList a
goToNext condition zipList =
  case zipList of
    Empty -> Empty
    Zipper _ _ after ->
      if List.any condition after
      then goToNext condition (forward zipList)
      else zipList

goToLast : (a -> Bool) -> ZipList a -> ZipList a
goToLast condition zipList =
  let newZipList = goToIndex ((length zipList) - 1) zipList in
  if isCurrent condition newZipList
  then newZipList
  else goToPrevious condition newZipList

goToPrevious : (a -> Bool) -> ZipList a -> ZipList a
goToPrevious condition zipList =
  case zipList of
    Empty -> Empty
    Zipper before _ _ ->
      if List.any condition before
      then goToPrevious condition (backward zipList)
      else zipList

map : (a -> b) -> ZipList a -> ZipList b
map func zipList =
  case zipList of
    Empty -> Empty
    Zipper before elem after ->
      Zipper
        (List.map func before)
        (func elem)
        (List.map func after)

indexedMap : (Int -> a -> b) -> ZipList a -> ZipList b
indexedMap func zipList =
  case zipList of
    Empty -> Empty
    Zipper before elem after ->
      let index = List.length before in
      Zipper
        (List.indexedMap
          (\ indexBe elemBe -> func (index - 1 - indexBe) elemBe )
            before
        )
        (func index elem)
        (List.indexedMap
          (\ indexAf elemAf -> func (index + 1 + indexAf) elemAf )
          after
        )

selectedMap : (Bool -> a -> b) -> ZipList a -> ZipList b
selectedMap func zipList =
  case zipList of
    Empty -> Empty
    Zipper before elem after ->
      Zipper
        (List.map (func False) before)
        (func True elem)
        (List.map (func False) after)

indexedSelectedMap : (Int -> Bool -> a -> b) -> ZipList a -> ZipList b
indexedSelectedMap func zipList =
  case zipList of
    Empty -> Empty
    Zipper before elem after ->
      let index = List.length before in
      Zipper
        (List.indexedMap
          (\ indexBe elemBe -> func (index - 1 - indexBe) False elemBe )
            before
        )
        (func index True elem)
        (List.indexedMap
          (\ indexAf elemAf -> func (index + 1 + indexAf) False elemAf )
          after
        )

zipListDecoder : Decoder a -> Decoder (ZipList a)
zipListDecoder decoderA =
  Decode.list decoderA
  |> Decode.map fromList
