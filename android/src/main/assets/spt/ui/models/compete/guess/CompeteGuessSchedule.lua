-- local CompeteGuessSchedule = require("ui.models.compete.guess.CompeteGuessSchedule")

local CompeteGuessSchedule = {
    guessing = "guessing",     -- 可以竞猜
    accounting = "accounting", -- 结算中
    resulting = "resulting"    -- 比赛结束
}

-- 淘汰赛开始时间19:00
CompeteGuessSchedule.MatchStartTime = {
    hour = 19,
    minute = 0,
    second = 0
}

-- 淘汰赛结束时间20:00
CompeteGuessSchedule.MatchOverTime = {
    hour = 20,
    minute = 0,
    second = 0
}

CompeteGuessSchedule.Countdown = 68400 -- 倒计时进度的分母，从0点开始到19:00:00的秒数

CompeteGuessSchedule.RoundNameMap = {
    "compete_round_name_1", -- 16强赛
    "compete_round_name_2", -- 8强赛
    "compete_round_name_3", -- 4强赛
    "compete_round_name_4", -- 半决赛
    "compete_round_name_5", -- 决赛
}

CompeteGuessSchedule.Confirm = {
    noconfirm = -1,
    yes = 0,
    no = 1
}

return CompeteGuessSchedule
