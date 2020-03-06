module MyList exposing (indexedAny, sumStringList, countWhere)

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

countWhere : (a -> Bool) -> List a -> Int
countWhere condition list =
  List.map condition list
  |> countWhereLoop 0

countWhereLoop : Int -> List Bool -> Int
countWhereLoop count boolList =
  case boolList of
    [] -> count
    head :: queue ->
      if head
      then countWhereLoop (count + 1) queue
      else countWhereLoop count queue

sumStringList : List String -> String
sumStringList list =
  sumStringListLoop "" list

sumStringListLoop : String -> List String -> String
sumStringListLoop acc list =
  case list of
    [] -> acc
    head :: queue ->
      sumStringListLoop (acc ++ head) queue
