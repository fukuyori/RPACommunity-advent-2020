let
    ソース = 
        Json.Document(
            Web.Contents(
                "https://connpass.com/api/v1/event/?series_id=5203&count=100" & connpass_series_id
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
    jsonデータを追加 =
        Table.Combine(
            {
                項目を展開, 
                event101
            }
        ),
    解析日時１ = 
        Table.TransformColumns(
            jsonデータを追加,
            {
                {
                    "started_at", 
                    each DateTime.From(DateTimeZone.From(_)), 
                    type datetime
                }
            }
        ),
    解析日時２ = 
        Table.TransformColumns(
            解析日時１,
            {
                {
                    "ended_at", 
                    each DateTime.From(DateTimeZone.From(_)), 
                    type datetime
                }
            }
        ),
    開始日時 = 
        Table.Sort(
            解析日時２,
            {
                {
                    "started_at", 
                    Order.Ascending
                }
            }
        ),
    数値変更 = 
        Table.TransformColumnTypes(
            開始日時,
            {
                {
                    "accepted", 
                    type number
                }, 
                {
                    "waiting", 
                    type number
                }
            }
        ),
    項目名変更 = 
        Table.RenameColumns(
            数値変更,
            {
                {
                    "started_at", 
                    "開始日時"
                }, 
                {
                    "title", 
                    "title"
                }, 
                {
                    "accepted", 
                    "参加者数"
                }, 
                {
                    "place", 
                    "開催会場"
                }, 
                {
                    "ended_at", 
                    "終了日時"
                }
            }
        )
in
    項目名変更