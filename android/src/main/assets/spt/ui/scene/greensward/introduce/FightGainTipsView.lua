local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local AdventureEvent = require("data.AdventureEvent")
local AdventureFloor = require("data.AdventureFloor")

local FightGainTipsView = class(unity.base, "FightGainTipsView")

local NotShow = {10, 14, 15, 17}

local function IsShow(eventType)
    eventType = tonumber(eventType)
    for k, event in ipairs(NotShow) do
        if eventType == event then
            return false
        end
    end
    return true
end

function FightGainTipsView:ctor()
--------Start_Auto_Generate--------
    self.contentTrans = self.___ex.contentTrans
--------End_Auto_Generate----------
    self.contentMap = {}
    self.contentPath = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Introduce/FightGainTipsItem.prefab"
end

function FightGainTipsView:InitView()
    local config = AdventureFloor["1"] -- 只用1层即可，策划要求
    local fightConfig = {}
    local fightRewardDatas = {}
    for eventType, baseFight in pairs(config.baseFight or {}) do
        if IsShow(eventType) then
            local item = {}
            item.eventType = eventType
            item.eventName = AdventureEvent[eventType].eventName
            item.baseFight = baseFight
            fightConfig[eventType] = item
        end
    end
    for eventType, goalFight in pairs(config.goalFight or {}) do
        if IsShow(eventType) then
            if fightConfig[eventType] ~= nil then
                fightConfig[eventType].goalFight = goalFight
            else
                dump("Please check the config of AdventureFloor.goalFight where eventType = " .. eventType)
            end
        end
    end
    for eventType, item in pairs(fightConfig) do
        table.insert(fightRewardDatas, item)
    end
    table.sort(fightRewardDatas, function(a, b) return tonumber(a.eventType) < tonumber(b.eventType) end)

    local contentRes = res.LoadRes(self.contentPath)
    for idx, fightRewardData in ipairs(fightRewardDatas) do
        local spt = self.contentMap[idx]
        if not spt then
            local obj = Object.Instantiate(contentRes)
            obj.transform:SetParent(self.contentTrans, false)
            spt = obj:GetComponent("CapsUnityLuaBehav")
            self.contentMap[idx] = spt
        end
        spt:InitView(fightRewardData)
    end
end

return FightGainTipsView
