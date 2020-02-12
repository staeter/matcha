-- https://package.elm-lang.org/packages/guid75/ziplist/latest/ZipList

module ZipList exposing
    ( ZipList
    , fromList, singleton
    , current, toList, length
    , forward, backward
    , currentIndex, isValidIndex
    , jumpForward, jumpBackward
    , goTo, zipListDecoder
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


{-| Return the current element of a ZipList. `Nothing` will be returned if the ziplist is empty
-}
current : ZipList a -> Maybe a
current zipList =
    case zipList of
        Empty ->
            Nothing

        Zipper _ elem _ ->
            Just elem


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
currentIndex ziplist =
  case ziplist of
    Empty -> Nothing
    Zipper before _ _ ->
      List.length before |> Just

isValidIndex : Int -> ZipList a -> Bool
isValidIndex index ziplist =
  not (index < 0 || index >= length ziplist)

jumpForward : Int -> ZipList a -> ZipList a
jumpForward jumpSize ziplist =
  if jumpSize <= 0
  then ziplist
  else
    forward ziplist
    |> jumpForward (jumpSize - 1)

jumpBackward : Int -> ZipList a -> ZipList a
jumpBackward jumpSize ziplist =
  if jumpSize <= 0
  then ziplist
  else
    backward ziplist
    |> jumpBackward (jumpSize - 1)

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

goTo : Int -> ZipList a -> ZipList a
goTo newIndex ziplist =
  let
    maybeIndex = currentIndex ziplist
    delta =
      maybeIndex
      |> Maybe.map (\index -> newIndex - index)
      |> Maybe.withDefault 0
  in
  case sign delta of
    Zero -> ziplist
    Positif ->
      jumpForward delta ziplist
    Negatif ->
      jumpBackward (abs delta) ziplist

map : (a -> b) -> ZipList a -> ZipList b
map func ziplist =
  case ziplist of
    Empty -> Empty
    Zipper before elem after ->
      Zipper
        (List.map func before)
        (func elem)
        (List.map func after)

indexedMap : (Int -> a -> b) -> ZipList a -> ZipList b
indexedMap func ziplist =
  case ziplist of
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

zipListDecoder : Decoder a -> Decoder (ZipList a)
zipListDecoder decoderA =
  Decode.list decoderA
  |> Decode.map fromList
