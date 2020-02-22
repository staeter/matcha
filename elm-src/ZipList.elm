module ZipList exposing
    ( ZipList
    , fromList, singleton
    , current, toList, length, currentIndex, isCurrent
    , remove, replace, insert, insertAfter, insertBefore
    , forward, backward, jumpForward, jumpBackward
    , goToIndex, goToFirst, goToNext, goToLast, goToPrevious
    , map, indexedMap, selectedMap, indexedSelectedMap
    , zipListDecoder
    )


{-| A `ZipList` is a list that has a single selected element. We call it current as "the one that is currently selected".

# ZipLists
@docs ZipList

# Create
@docs fromList, singleton

# Consult
@docs current, toList, length, currentIndex, isCurrent

# Edit
@docs remove, replace, insert, insertAfter, insertBefore

# Move
@docs forward, backward, jumpForward, jumpBackward

# Advanced Move
@docs goToIndex, goToFirst, goToNext, goToLast, goToPrevious

# Transform
@docs map, mapCurrent, indexedMap, selectedMap, indexedSelectedMap

# Decode
@docs zipListDecoder

-}

import Maybe exposing (Maybe, map, withDefault)
import Json.Decode as Decode exposing (Decoder, list, decodeString, map)


{-| A collection data type that can be moved forward/backward and that exposes a current element (see the `current` function).
-}
type ZipList a
    = Empty
    | Zipper (List a) a (List a)


{-| Craft a new `ZipList` out of a `List`.
-}
fromList : List a -> ZipList a
fromList list =
    case list of
        [] ->
            Empty

        head :: queue ->
            Zipper [] head queue


{-| Create a new `ZipList` with a single element in it.
-}
singleton : a -> ZipList a
singleton item =
    Zipper [] item []


{-| Return the current element of a `ZipList`. `Nothing` will be returned if a `ZipList` is empty.
-}
current : ZipList a -> Maybe a
current zipList =
    case zipList of
        Empty ->
            Nothing

        Zipper _ elem _ ->
            Just elem


{-| Convert a `ZipList` into a `List`.
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


{-| Return a `ZipList` length.
-}
length : ZipList a -> Int
length zipList =
    case zipList of
        Empty ->
            0

        Zipper before _ after ->
            1 + List.length before + List.length after


{-| Return the index (starting at zero) of the current element. `Nothing` will be returned if a `ZipList` is empty.
-}
currentIndex : ZipList a -> Maybe Int
currentIndex zipList =
  case zipList of
    Empty -> Nothing
    Zipper before _ _ ->
      List.length before |> Just


{-| Test wether current passes a condition.
-}
isCurrent : (a -> Bool) -> ZipList a -> Bool
isCurrent condition zipList =
  current zipList
  |> Maybe.map condition
  |> Maybe.withDefault False


{-| Remove current from a `ZipList`. The new current is in priority the `ZipList`'s next element.
-}
remove : ZipList a -> ZipList a
remove zipList =
  case zipList of
    Empty -> Empty
    Zipper [] _ [] -> Empty
    Zipper before _ (head :: queue) ->
        Zipper before head queue
    Zipper (head :: queue) _ [] ->
        Zipper queue head []


{-| Replace current from a `ZipList` with a new value. If a `ZipList` is empty, the returned one will be too.
-}
replace : a -> ZipList a -> ZipList a
replace newElem zipList =
  case zipList of
    Empty -> Empty
    Zipper before _ after ->
      Zipper before newElem after


{-| Insert a new value in a `ZipList`. The current will be pushed backward to let the new value take its place.
-}
insert : a -> ZipList a -> ZipList a
insert newElem zipList =
  case zipList of
    Empty -> Zipper [] newElem []
    Zipper before elem after ->
      Zipper (elem :: before) newElem after


{-| Insert a new value in a `ZipList` right after current.
-}
insertAfter : a -> ZipList a -> ZipList a
insertAfter newElem zipList =
  case zipList of
    Empty -> Zipper [] newElem []
    Zipper before elem after ->
      Zipper before elem (newElem :: after)


{-| Insert a new value in a `ZipList` right before current.
-}
insertBefore : a -> ZipList a -> ZipList a
insertBefore newElem zipList =
  case zipList of
    Empty -> Zipper [] newElem []
    Zipper before elem after ->
      Zipper (newElem :: before) elem after


{-| Move current forward. Current will not move if it is at the end of the `ZipList`.
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


{-| Move current backward. Current will not move if it is at the begining of the `ZipList`.
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


{-| Move current forward a given amout of times. Current will be the last element of the `ZipList` if the jump size is too big.
-}
jumpForward : Int -> ZipList a -> ZipList a
jumpForward jumpSize zipList =
  if jumpSize <= 0
  then zipList
  else case zipList of
    Zipper before elem (head :: queue) ->
        Zipper (elem :: before) head queue
        |> jumpForward (jumpSize - 1)
    _ -> zipList


{-| Move current backward a given amout of times. Current will be the first element of the `ZipList` if the jump size is too big.
-}
jumpBackward : Int -> ZipList a -> ZipList a
jumpBackward jumpSize zipList =
  if jumpSize <= 0
  then zipList
  else case zipList of
    Zipper (head :: queue) elem after ->
        Zipper queue head (elem :: after)
        |> jumpBackward (jumpSize - 1)
    _ -> zipList


{-| Move current to an index (starting at zero). Current will be the first element of the `ZipList` if the index is too low and it will be the last element if the index is too high.
-}
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


{-| Move current to the first element of a `ZipList` fulfilling a condition. Current will be the first element of the `ZipList` if there is no matching element.
-}
goToFirst : (a -> Bool) -> ZipList a -> ZipList a
goToFirst condition zipList =
  let newZipList = goToIndex 0 zipList in
  if isCurrent condition newZipList
  then newZipList
  else goToNext condition newZipList


{-| Move current to the next element fulfilling a condition. Current will not move if there is no matching element after current.
-}
goToNext : (a -> Bool) -> ZipList a -> ZipList a
goToNext condition zipList =
  case zipList of
    Empty -> Empty
    Zipper _ _ after ->
      if List.any condition after
      then goToNext condition (forward zipList)
      else zipList


{-| Move current to the last element of a `ZipList` fulfilling a condition. Current will be the last element of the `ZipList` if there is no matching element.
-}
goToLast : (a -> Bool) -> ZipList a -> ZipList a
goToLast condition zipList =
  let newZipList = goToIndex ((length zipList) - 1) zipList in
  if isCurrent condition newZipList
  then newZipList
  else goToPrevious condition newZipList


{-| Move current to the previous element fulfilling a condition. Current will not move if there is no matching element before current.
-}
goToPrevious : (a -> Bool) -> ZipList a -> ZipList a
goToPrevious condition zipList =
  case zipList of
    Empty -> Empty
    Zipper before _ _ ->
      if List.any condition before
      then goToPrevious condition (backward zipList)
      else zipList


{-| Apply a function to every element of a `ZipList`.
-}
map : (a -> b) -> ZipList a -> ZipList b
map func zipList =
  case zipList of
    Empty -> Empty
    Zipper before elem after ->
      Zipper
        (List.map func before)
        (func elem)
        (List.map func after)


{-| Same as `map` but the function is also applied to the index of each element (starting at zero).
-}
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


{-| Same as `map` but the function also takes a boolean indicating wether it is current/the selected element.
-}
selectedMap : (Bool -> a -> b) -> ZipList a -> ZipList b
selectedMap func zipList =
  case zipList of
    Empty -> Empty
    Zipper before elem after ->
      Zipper
        (List.map (func False) before)
        (func True elem)
        (List.map (func False) after)


{-| Same as `map` but the function also takes the index of the element (starting at zero) and a boolean indicating wether it is current/the selected element.
-}
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


{-| Decoder for `ZipList`s.
-}
zipListDecoder : Decoder a -> Decoder (ZipList a)
zipListDecoder decoderA =
  Decode.list decoderA
  |> Decode.map fromList


-- not exposed code

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
