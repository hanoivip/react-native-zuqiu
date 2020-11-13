local DreamConstants = {}

DreamConstants.dateMark = {
    YESTERDAY = -1,
    TODAY = 0,
    TOMORROW = 1
}

-- 1-每日助攻王 2-金球奖 3-金靴奖 4-助攻王
DreamConstants.Lottery = {
    EVERY_MVP = 1,
    GOLD = 2,
    BOOTS = 3,
    ASIST = 4
}

DreamConstants.ResultState = {
    LOSING_LOTTERY = -2,
    NOT_OPEN = -1,
    NOT_ACCEPT = 0,
    ACCEPT = 1
}

DreamConstants.DreamCardLockState = {
    USER_LOCK = 1,
    SYSTEM_LOCK = 2
}

return DreamConstants