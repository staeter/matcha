module MyList exposing (indexedAny)

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
