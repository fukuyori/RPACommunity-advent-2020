let
    ソース = 
        Json.Document(
            Web.Contents(
                "https://connpass.com/api/v1/event/?count=100&start=101&series_id=" & connpass_series_id
            )
        ),
    events = ソース[events],
    テーブルに変換 = 
        Table.FromList(
            events, 
            Splitter.SplitByNothing(), 
            null, 
            null, 
            ExtraValues.Error
        ),
    項目を展開 =
        Table.ExpandRecordColumn(
            テーブルに変換, 
            "Column1", 
            {
                "event_id", 
                "title", 
                "catch", 
                "event_url", 
                "started_at", 
                "ended_at", 
                "hash_tag", 
                "accepted", 
                "waiting", 
                "place"
            }, 
            {
                "event_id", 
                "title", 
                "catch", 
                "event_url", 
                "started_at", 
                "ended_at", 
                "hash_tag", 
                "accepted", 
                "waiting", 
                "place"
            }
        ),
    並べ替えられた行 = 
        Table.Sort(
            項目を展開,
            {
                {
                    "ended_at", 
                    Order.Ascending
                }
            }
        )
in
    並べ替えられた行