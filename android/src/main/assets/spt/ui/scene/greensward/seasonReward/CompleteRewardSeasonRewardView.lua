local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local GameObjectHelper = require("ui.common.GameObjectHelper")

local CompleteRewardSeasonRewardView = class(unity.base, "CompleteRewardSeasonRewardView")

function CompleteRewardSeasonRewardView:ctor()
--------Start_Auto_Generate--------
    self.myRegionTxt = self.___ex.myRegionTxt
    self.maxCompleteTxt = self.___ex.maxCompleteTxt
    self.contentTrans = self.___ex.contentTrans
--------End_Auto_Generate----------
    self.txtMoraleReward = self.___ex.txtMoraleReward
    self.scrollRect = self.___ex.scrollRect
    self.contentMap = {}
end

function CompleteRewardSeasonRewardView:start()
end

function CompleteRewardSeasonRewardView:InitView(greenswardSeasonRewardModel, region)
    self.greenswardSeasonRewardModel = greenswardSeasonRewardModel
    self:InitSelfInfoArea()
    self:InitMyReward(region)
end

function CompleteRewardSeasonRewardView:InitSelfInfoArea()
    local regionName = self.greenswardSeasonRewardModel:GetRegionName()
    local content = lang.transstr("adventure_my_region_1", regionName) .. " "
    content = content .. lang.transstr("adventure_seasonreward_max_complete")
    content = content .. tostring(self.greenswardSeasonRewardModel:GetInitialPower()) .. " ,"
    content = content .. lang.transstr("adventure_seasonreward_fight_tip")
    self.maxCompleteTxt.text = content
end

-- 赛季开始时初始战力在战区中所占百分比决定通关每一层后获得多少士气
-- 弃用
function CompleteRewardSeasonRewardView:InitPowerMoraleReward()
    local morale, low, high = self.greenswardSeasonRewardModel:GetMoraleReward()
    if high ~= nil then
        self.txtMoraleReward.text = lang.trans("adventure_seasonreward_complete_reward_morale", low, high)
    else
        self.txtMoraleReward.text = lang.trans("adventure_seasonreward_complete_reward_morale_1", low)
    end
end

function CompleteRewardSeasonRewardView:InitMyReward(region)
    local regionReward = self.greenswardSeasonRewardModel:GetAdventureRewardByRegionID(region)
    self.greenswardSeasonRewardModel:SetRegion(region)

    local contentRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Introduce/CompleteContentItem.prefab")
    for i, v in ipairs(regionReward) do
        local spt = self.contentMap[i]
        if not spt then
            local obj = Object.Instantiate(contentRes)
            obj.transform:SetParent(self.contentTrans, false)
            spt = obj:GetComponent("CapsUnityLuaBehav")
            self.contentMap[i] = spt
        end
        spt:InitView(i, v)
    end
    self.scrollRect.verticalNormalizedPosition = 1
end

return CompleteRewardSeasonRewardView
