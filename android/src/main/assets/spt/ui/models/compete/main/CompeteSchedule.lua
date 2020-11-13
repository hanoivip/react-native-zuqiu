-- local CompeteSchedule = require("ui.models.compete.main.CompeteSchedule")

-- 与服务器定义一致
local CompeteSchedule = {
    Big_Ear_Match = 1, -- 大耳朵杯赛
    Big_Ear_Match_Team = 2, -- 大耳朵杯小组赛
    Big_Ear_Match_Kick_Off = 3, -- 大耳朵杯预选淘汰赛
    Small_Ear_Match = 4, -- 小耳朵杯赛
    Small_Ear_Match_Team = 5, -- 小耳朵杯小组赛
    Small_Ear_Match_Kick_Off = 6, -- 小耳朵杯预选淘汰赛

    Local_Match_Super = 7, -- 超级联赛
    Local_Match_Winner = 8, -- 冠军联赛
    Local_Match_A = 9, -- 甲级联赛
    Local_Match_B = 10, -- 乙级联赛
    Local_Match_Area = 11 -- 地区联赛
}

return CompeteSchedule
