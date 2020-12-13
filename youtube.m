let
    ソース = 
        Json.Document(
            Web.Contents(
                "https://www.googleapis.com/youtube/v3/search?key=" & 
                Youtube_Key & 
                "&part=id,snippet&type=video&maxResults=50&order=date&channelId=" & 
                Youtube_channelId
            )
        ),
    items = 
        ソース[items],
    テーブルに変換 = 
        Table.FromList(
            items, 
            Splitter.SplitByNothing(), 
            null, 
            null, 
            ExtraValues.Error
        ),
    #"展開された Column1" = 
        Table.ExpandRecordColumn(
            テーブルに変換,
            "Column1", 
            {
                "id", 
                "snippet"
            }, 
            {
                "Column1.id", 
                "Column1.snippet"
            }
        ),
    #"展開された Column1.id" = 
        Table.ExpandRecordColumn(
            #"展開された Column1", 
            "Column1.id", 
            {"videoId"}, 
            {"videoId"}),
    #"展開された Column1.snippet" = 
        Table.ExpandRecordColumn(
            #"展開された Column1.id", 
            "Column1.snippet", 
            {
                "publishedAt", 
                "channelId", 
                "title", 
                "description", 
                "thumbnails", 
                "channelTitle"
            }, 
            {
                "publishedAt", 
                "channelId", 
                "title", 
                "description", 
                "thumbnails", 
                "channelTitle"
            }
        ),
    #"展開された thumbnails" = 
        Table.ExpandRecordColumn(
            #"展開された Column1.snippet", 
            "thumbnails", 
            {"default"}, 
            {"default"}
        ),
    #"展開された default" = 
        Table.ExpandRecordColumn(
            #"展開された thumbnails", 
            "default", 
            {"url"}, 
            {"url"}
        ),
    発行日の型を日時に変更 = 
        Table.TransformColumnTypes(
            #"展開された default",
            {
                {
                    "publishedAt", 
                    type datetime
                }
            }
        ),
    追加されたプレフィックス = 
        Table.TransformColumns(
            発行日の型を日時に変更,
            {
                {
                    "videoId", 
                    each "https://www.youtube.com/watch?v=" & _, 
                    type text
                }
            }
        ),
    列名を変更 = 
        Table.RenameColumns(
            追加されたプレフィックス,
            {
                {
                    "publishedAt", 
                    "登録日"
                }, 
                {
                    "title", 
                    "タイトル"
                }, 
                {
                    "description", 
                    "内容"
                }
            }
        )
in
    列名を変更