local ShareConstants = {}

ShareConstants.Title = "share_title"
ShareConstants.RewardID = 3001

ShareConstants.Type = {
    Default = "",
    HomeMain = "HomeMain",
    PlayerLetter = "PlayerLetter", 
    Court = "Court",
    Gacha = "Gacha",
    GachaTen = "GachaTen",
    GachaGK = "GachaGK",
    GachaDF = "GachaDF",
    GachaMF = "GachaMF",
    GachaFW = "GachaFW",
}

-- 截屏文字Long
ShareConstants.LongText = {
    Default = "",
    HomeMain = "share_editable_homeMain",
    PlayerLetter = "share_long_playerLetter",
    Court = "share_long_court",
    GachaTen = "share_long_gachaTen",
    GachaGK = "share_long_gachaGK",
    GachaDF = "share_long_gachaDF",
    GachaMF = "share_long_gachaMF",
    GachaFW = "share_long_gachaFW",
    Gacha = "share_long_gachaTen",
}

-- 截屏文字Short
ShareConstants.ShortText = {
    Default = "",
    HomeMain = "share_editable_homeMain",
    PlayerLetter = "share_short_playerLetter",
    Court = "share_short_court",
    GachaTen = "share_short_gachaTen",
    GachaGK = "share_short_gachaGK",
    GachaDF = "share_short_gachaDF",
    GachaMF = "share_short_gachaMF",
    GachaFW = "share_short_gachaFW",
     Gacha = "share_short_gachaTen",
}

-- 分享时预编辑文字
ShareConstants.EditableText = {
    Default = "",
    HomeMain = "share_editable_homeMain",
    PlayerLetter = "share_editable_playerLetter",
    Court = "share_editable_court",    
    GachaTen = "share_editable_gacha",
    GachaGK = "share_editable_gacha",
    GachaDF = "share_editable_gacha",
    GachaMF = "share_editable_gacha",
    GachaFW = "share_editable_gacha",    
    Gacha = "share_editable_gacha",   
}

ShareConstants.MainPos = {
    Default = "",
    FW = "前锋",
    MF = "中场",
    DF = "后卫",
    GK = "门将",
}

ShareConstants.State = {
    Unfinished = -1,
    Finished = 0,
    GetReward = 1,
}

return ShareConstants