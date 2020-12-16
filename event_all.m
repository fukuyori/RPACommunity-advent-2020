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
    // タイムゾーン情報を削除し、日本時間で表示するように
    開始日時追加 = 
        Table.AddColumn(
            jsonデータを追加,
            "開始日時", 
            each DateTimeZone.RemoveZone(DateTimeZone.From([started_at])), 
            type datetime
        ),
    終了日時追加 = 
        Table.AddColumn(
            開始日時追加,
            "終了時間", 
            each DateTimeZone.RemoveZone(DateTimeZone.From([ended_at])), 
            type datetime
        ),
    // 現在時間と比較を行うために、タイムゾーン付きの時間を取っておく
    解析開始日時 = 
        Table.TransformColumns(
            終了日時追加,
            {
                {
                    "started_at", 
                    each DateTime.From(DateTimeZone.From(_)), 
                    type datetime
                }
            }
        ),
    解析終了日時 = 
        Table.TransformColumns(
            解析開始日時,
            {
                {
                    "ended_at", 
                    each DateTime.From(DateTimeZone.From(_)), 
                    type datetime
                }
            }
        ),
    数値変更 = 
        Table.TransformColumnTypes(
            解析終了日時,
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
                    "accepted", 
                    "参加者数"
                }, 
                {
                    "place", 
                    "開催会場"
                } 
            }
        )
in
    項目名変更