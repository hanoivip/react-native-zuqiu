local CoachGuideSlotState = {
    ["Used"] = 1,  -- 已放置球员
    ["Unlock"] = 2,  -- 可放置球员
    ["Lock"] = 3,  -- 未解锁且可购买
    ["Disable"] = 4,  -- 不可解锁
    ["CanNotBuy"] = 5,  -- 未解锁且不可购买
}

return CoachGuideSlotState
