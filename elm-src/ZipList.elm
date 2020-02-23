module ZipList exposing
    ( ZipList
    , fromList, singleton, empty
    , current, toList, length, currentIndex, isCurrent
    , remove, replace, insert, insertAfter, insertBefore
    , forward, backward, jumpForward, jumpBackward
    , goToIndex, goToFirst, goToNext, goToLast, goToPrevious
    , map, indexedMap, selectedMap, indexedSelectedMap
    , zipListDecoder
    )


{-| A `ZipList` is a list that has a single selected element. We call it current as "the one that is currently selected".

To get more explicit examples, I'm gona represent `ZipList`s as `List`s that have the selected element between "<...>":
    let
      myZL = fromList ["a", "b", "c"]
    in
      length myZL == 3

      current myZL            == Just "a"
      forward myZL |> current == Just "b"

      myZL |> currentIndex          == Just 0
      forward myZL |> currentIndex  == Just 1

      toList myZL == ["a", "b", "c"]
>>> BECOMES >>>
    fromList ["a", "b", "c"] == [<"a">, "b", "c"]

    length [<"a">, "b", "c"] == 3

    current [<"a">, "b", "c"] == Just "a"
    currentIndex [<"a">, "b", "c"] == Just 0

    forward [<"a">, "b", "c"] == ["a", <"b">, "c"]

    current ["a", <"b">, "c"] == Just "b"
    currentIndex ["a", <"b">, "c"] == Just 1

    toList ["a", <"b">, "c"] == ["a", "b", "c"]
This representation will not compile but it makes the documentation way more enjoyable.

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


{-| A `ZipList` is a list that has a single selected element. We call it current as "the one that is currently selected".
-}
type ZipList a
    = Empty
    | Zipper (List a) a (List a)


{-| Craft a new `ZipList` out of a `List`. Current is the first element of the `List`.

    let
      myFullZipList = fromList [0, 1, 2, 3, 4]
    in
      current myFullZipList == Just 0
      length myFullZipList == 5

    let
      myEmptyZipList = fromList []
    in
      current myEmptyZipList == Nothing
      length myEmptyZipList == 0
-}
fromList : List a -> ZipList a
fromList list =
    case list of
        [] ->
            Empty

        head :: queue ->
            Zipper [] head queue


{-| Create a new `ZipList` with a single element in it.

    current (singleton "my element")  == Just "my element"
    length (singleton "my element")   == 1
-}
singleton : a -> ZipList a
singleton item =
    Zipper [] item []


{-| Create an empty `ZipList`.

    current empty == Nothing
    length empty  == 0
-}
empty : a -> ZipList a
empty item =
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

    let
      myZipList = fromList myOriginalList
      backToList = toList myZipList
    in
      backToList == myOriginalList
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

    length [0, 1, <2>, 3, 4]  == 5
    length [<0>, 1, 2]        == 3
    length []                 == 0
-}
length : ZipList a -> Int
length zipList =
    case zipList of
        Empty ->
            0

        Zipper before _ after ->
            1 + List.length before + List.length after


{-| Return the index (starting at zero) of the current element. `Nothing` will be returned if a `ZipList` is empty.

    currentIndex [0, 1, <2>, 3, 4]  == Just 2
    currentIndex [<0>, 1, 2]        == Just 0
    currentIndex []                 == Nothing
-}
currentIndex : ZipList a -> Maybe Int
currentIndex zipList =
  case zipList of
    Empty -> Nothing
    Zipper before _ _ ->
      List.length before |> Just


{-| Test wether current passes a condition. If the `ZipList` is empty returns `False`.

    isCurren condition [0, <1>, 2]  == condition 1
    isCurren condition []           == False
-}
isCurrent : (a -> Bool) -> ZipList a -> Bool
isCurrent condition zipList =
  current zipList
  |> Maybe.map condition
  |> Maybe.withDefault False


{-| Remove current from a `ZipList`. The new current is in priority the `ZipList`'s next element.

    remove [0, 1, <2>, 3, 4] == [0, 1, <3>, 4]
    remove [0, 1, <2>]       == [0, <1>]
    remove []                == []
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

    replace 9 [0, 1, <2>, 3, 4] == [0, 1, <9>, 3, 4]
    replace 9 [0, 1, <2>]       == [0, 1, <9>]
    replace 9 []                == []
-}
replace : a -> ZipList a -> ZipList a
replace newElem zipList =
  case zipList of
    Empty -> Empty
    Zipper before _ after ->
      Zipper before newElem after


{-| Insert a new value in a `ZipList`. The current will be pushed backward to let the new value take its place.

    insert 9 [0, 1, <2>, 3, 4] == [0, 1, 2, <9>, 3, 4]
    insert 9 [0, 1, <2>]       == [0, 1, 2, <9>]
    insert 9 []                == [<9>]
-}
insert : a -> ZipList a -> ZipList a
insert newElem zipList =
  case zipList of
    Empty -> Zipper [] newElem []
    Zipper before elem after ->
      Zipper (elem :: before) newElem after


{-| Insert a new value in a `ZipList` right after current.

    insertAfter 9 [0, 1, <2>, 3, 4] == [0, 1, <2>, 9, 3, 4]
    insertAfter 9 [0, 1, <2>]       == [0, 1, <2>, 9]
    insertAfter 9 []                == [<9>]
-}
insertAfter : a -> ZipList a -> ZipList a
insertAfter newElem zipList =
  case zipList of
    Empty -> Zipper [] newElem []
    Zipper before elem after ->
      Zipper before elem (newElem :: after)


{-| Insert a new value in a `ZipList` right before current.

    insertBefore 9 [0, 1, <2>, 3, 4] == [0, 1, 9, <2>, 3, 4]
    insertBefore 9 []                == [<9>]
-}
insertBefore : a -> ZipList a -> ZipList a
insertBefore newElem zipList =
  case zipList of
    Empty -> Zipper [] newElem []
    Zipper before elem after ->
      Zipper (newElem :: before) elem after


{-| Move current forward. Current will not move if it is at the end of the `ZipList`.

    forward [0, 1, <2>, 3, 4] == [0, 1, 2, <3>, 4]
    forward [0, 1, <2>]       == [0, 1, <2>]
    forward []                == []
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

    backward [0, 1, <2>, 3, 4] == [0, <1>, 2, 3, 4]
    backward [<0>, 1, 2]       == [<0>, 1, 2]
    backward []                == []
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

    jumpForward 2 [0, <1>, 2, 3, 4] == [0, 1, 2, <3>, 4]
    jumpForward 2 [0, <1>, 2]       == [0, 1, <2>]
    jumpForward 2 []                == []
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

    jumpBackward 2 [0, 1, 2, <3>, 4] == [0, <1>, 2, 3, 4]
    jumpBackward 2 [0, <1>, 2]       == [<0>, 1, 2]
    jumpBackward 2 []                == []
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

    goToIndex 2 [0, 1, 2, 3, <4>] == [0, 1, <2>, 3, 4]
    goToIndex 5 [0, <1>, 2]       == [0, 1, <2>]
    goToIndex 1 [0, <1>, 2]       == [0, <1>, 2]
    goToIndex 2 []                == []
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

    goToFirst isEven [8, 1, 2, 3, <4>] == [<8>, 1, 2, 3, 4]
    goToFirst isEven [5, <1>, 2]       == [5, 1, <2>]
    goToFirst isEven [1, <1>, 7]       == [<1>, 1, 7]
    goToFirst isEven []                == []
-}
goToFirst : (a -> Bool) -> ZipList a -> ZipList a
goToFirst condition zipList =
  let newZipList = goToIndex 0 zipList in
  if isCurrent condition newZipList
  then newZipList
  else goToNext condition newZipList


{-| Move current to the next element fulfilling a condition. Current will not move if there is no matching element after current.

    goToNext isEven [0, 1, <2>, 3, 4] == [0, 1, 2, 3, <4>]
    goToNext isEven [8, 2, <1>, 3, 7] == [8, 2, <1>, 3, 7]
    goToNext isEven [5, <1>, 2, 3]    == [5, 1, <2>, 3]
    goToNext isEven []                == []
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

    goToLast isOdd [0, 1, <2>, 3, 4] == [0, 1, 2, <3>, 4]
    goToLast isOdd [8, 2, <1>, 3, 7] == [8, 2, 1, 3, <7>]
    goToLast isOdd [2, <4>, 6, 8]    == [2, 4, 6, <8>]
    goToLast isOdd []                == []
-}
goToLast : (a -> Bool) -> ZipList a -> ZipList a
goToLast condition zipList =
  let newZipList = goToIndex ((length zipList) - 1) zipList in
  if isCurrent condition newZipList
  then newZipList
  else goToPrevious condition newZipList


{-| Move current to the previous element fulfilling a condition. Current will not move if there is no matching element before current.

    goToPrevious isOdd [0, 1, <2>, 3, 4] == [0, <1>, 2, 3, 4]
    goToPrevious isOdd [8, 2, 1, 4, <7>] == [8, 2, <1>, 4, 7]
    goToPrevious isOdd [2, <4>, 3, 5]    == [2, <4>, 3, 5]
    goToPrevious isOdd []                == []
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

    map String.fromInt [0, 1, <2>, 3, 4] == ["0", "1", <">"), "3", "4"]
    map String.fromInt [2, <4>, 3, 5]    == ["2", <">"), "3", "5"]
    map String.fromInt []                == []
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

    indexedMap Tuple.pair [1, <2>, 4]     == [(0, 1), <(1, 2)>, (2, 4)]
    indexedMap Tuple.pair ["hi", <"wow">] == [(0, "hi"), <(1, "wow")>]
    indexedMap Tuple.pair []              == []
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

    selectedMap Tuple.pair [<2>, 4]             == [<(True, 2)>, (False, 4)]
    selectedMap Tuple.pair ["en", "fr", <"ge">] == [(False, "en"), (False, "fr"), <(True, "ge")>]
    selectedMap Tuple.pair []                   == []
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

    let
      myFun =
        (\ index isCurrent elem ->
          (index, isCurrent, String.fromInt elem)
        )
    in
      selectedMap myFun [1, <2>, 4] == [(0, False, "1"), <(1, True, "2")>, (2, False, "4")]
      selectedMap myFun []          == []
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
