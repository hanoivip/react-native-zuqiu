local StartGameConstants = {}

--- 功能数据
--- @param VIEW_ID 代表功能独一无二的ID
--- @param LIMIT_ID 代表LevelLimit表中的Id，0表示默认开启，-1表示默认关闭
StartGameConstants.ViewConstants = {
    -- 主线
    QUEST = {
        VIEW_ID = 1,
        LIMIT_ID = 0,
    },
    -- 联赛
    LEAGUE = {
        VIEW_ID = 3,
        LIMIT_ID = 2,
    },
    -- 训练基地
    TRAIN = {
        VIEW_ID = 4,
        LIMIT_ID = 3,
    },
    -- 天梯
    LADDER = {
        VIEW_ID = 5,
        LIMIT_ID = 5,
    },
    -- 特殊赛事
    SPECIAL_QUEST = {
        VIEW_ID = 6,
        LIMIT_ID = 10,
    },
    -- 巅峰对决
    PEAK = {
        VIEW_ID = 7,
        LIMIT_ID = 11,
    },
    -- 冠军联赛
    ARENA = {
        VIEW_ID = 8,
        LIMIT_ID = 8,
    },
    -- 劫镖
    TRANSFORT = {
        VIEW_ID = 9,
        LIMIT_ID = 14,
    },
    -- 梦幻联赛
    DREAM = {
        VIEW_ID = 102,
        LIMIT_ID = 15,
    },
    -- 争霸赛
    COMPETE = {
        VIEW_ID = 10,
        LIMIT_ID = 16,
    },
    -- 英雄殿堂
    HERO_HALL = {
        VIEW_ID = 11,
        LIMIT_ID = 17,
    },
    -- 竞拍大厅
    AUCTION = {
        VIEW_ID = 12,
        LIMIT_ID = 18
    },
    -- 教练
    COACH = {
        VIEW_ID = 13,
        LIMIT_ID = 19
    },
    -- 绿茵征途
    GREENSWARD = {
        VIEW_ID = 14,
        LIMIT_ID = 20
    },
    -- 梦幻11人
    Fancy = {
        VIEW_ID = 15,
        LIMIT_ID = 21
    }
}

-- 不在征途功能包含，但具有一样意义的功能开启
StartGameConstants.OtherFunctionConstants = {
    -- 转会市场
    TRANSFER = {
        VIEW_ID = 101,
        LIMIT_ID = 1,
    },
}

return StartGameConstants