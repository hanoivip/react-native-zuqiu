local QualityType = {
    Quality_All = 0,
    Quality_White = 1,
    Quality_Green = 2,
    Quality_Blue = 3,
    Quality_Purple = 4,
    Quality_Orange = 5,
    Quality_Red = 6,
}

QualityType.QualityDescMap =
{
    { Desc = "card_whiteQuality", Quality = 1}, 
    { Desc = "card_greenQuality", Quality = 2}, 
    { Desc = "card_blueQuality", Quality = 3}, 
    { Desc = "card_purpleQuality", Quality = 4}, 
    { Desc = "card_orangeQuality", Quality = 5}, 
    { Desc = "card_redQuality", Quality = 6}, 
    { Desc = "card_allQuality", Quality = 0}
}

return QualityType