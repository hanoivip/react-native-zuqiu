local CoachTaskState = {
    ["Unaccepted"] = 0,  -- 没有接受
    ["Accepted"] = 1,  -- 已接受  
    ["Executing"] = 2,  -- 执行中
    ["Reward"] = 3,  -- 可领取奖励
    ["Complete"] = 4,  -- 完成状态
}

return CoachTaskState
