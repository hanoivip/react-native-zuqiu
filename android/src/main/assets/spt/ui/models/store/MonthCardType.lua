local MonthCardType = {}

MonthCardType.MonthCardConfigMap = {
    [1] = "Normal_MonthCard",
    [2] = "Supreme_MonthCard"
}

MonthCardType.MonthCardMap = {
    Normal_MonthCard = {
        name = "month_card_normal",
        configID = 1
    },
    Supreme_MonthCard = {
        name = "month_card_supreme",
        configID = 2
    }
}

return MonthCardType
