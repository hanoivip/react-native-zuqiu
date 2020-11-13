local FeatureSKillState = {
    ["Enable"] = 1,  -- 有技能且栏位已解锁
    ["Empty"] = 2,  -- 无技能且栏位已解锁
    ["Disable"] = 3,  -- 有技能且栏位未解锁
    ["Lock"] = 4,  -- 无技能且栏位未解锁
}
return FeatureSKillState
