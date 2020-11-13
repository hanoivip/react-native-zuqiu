local CardEnumerator = {}

-- 五维属性
-- 普通球员
CardEnumerator.NormalPlayerAttribute = {
    "pass",         -- 带
    "dribble",      -- 传
    "shoot",        -- 射
    "intercept",    -- 拦
    "steal",        -- 抢
}

-- 门将
CardEnumerator.GoalKeeperAttribute = {
    "goalkeeping",  -- 门线技术
    "anticipation", -- 球路判断
    "commanding",   -- 防线指挥
    "composure",    -- 心理素质
    "launching"     -- 发起进攻
}

return CardEnumerator
