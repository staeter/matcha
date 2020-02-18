module MyList exposing (indexedAny, sumStringList)

indexedAny : (a -> Bool) -> List a -> Maybe Int
indexedAny condition list =
  List.map condition list
  |> indexedAnyLoop 0

indexedAnyLoop : Int -> List Bool -> Maybe Int
indexedAnyLoop index boolList =
  case boolList of
    [] -> Nothing
    head :: queue ->
      if head
      then Just index
      else indexedAnyLoop (index + 1) queue

sumStringList : List String -> String
sumStringList list =
  sumStringListLoop "" list

sumStringListLoop : String -> List String -> String
sumStringListLoop acc list =
  case list of
    [] -> acc
    head :: queue ->
      sumStringListLoop (acc ++ head) queue
