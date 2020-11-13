local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local AdventureFloor = require("data.AdventureFloor")
local GameObjectHelper = require("ui.common.GameObjectHelper")

local CompleteRewardIntroduceView = class(unity.base, "CompleteRewardIntroduceView")

local MaxLine = 4

function CompleteRewardIntroduceView:ctor()
--------Start_Auto_Generate--------
    self.contentTrans = self.___ex.contentTrans
    self.tabBtnGroupSpt = self.___ex.tabBtnGroupSpt
    self.arrowNextBtn = self.___ex.arrowNextBtn
    self.arrowPreviewBtn = self.___ex.arrowPreviewBtn
    self.tabScrollSpt = self.___ex.tabScrollSpt
    self.tabName1Txt = self.___ex.tabName1Txt
    self.tabName2Txt = self.___ex.tabName2Txt
    self.rewardContentTrans = self.___ex.rewardContentTrans
--------End_Auto_Generate----------

    self.contentMap = {}
    self.contentRewardMap = {}
end

function CompleteRewardIntroduceView:start()
    self.arrowNextBtn:regOnButtonClick(function()
        self:OnArrowNextClick()
    end)
    self.arrowPreviewBtn:regOnButtonClick(function()
        self:OnArrowPreviewClick()
    end)
end

function CompleteRewardIntroduceView:OnArrowPreviewClick()
    self.tabScrollSpt:scrollToPreviousGroup()
end

function CompleteRewardIntroduceView:OnArrowNextClick()
    self.tabScrollSpt:scrollToNextGroup()
end

function CompleteRewardIntroduceView:OnTabClick(tag)
    local regionReward = self.greenswardIntroduceModel:GetAdventureRewardByRegionID(tag)
    self.greenswardIntroduceModel:SetRegion(tag)

    local contentRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Introduce/CompleteScoreRewardItem.prefab")
    for i, v in pairs(regionReward) do
        local spt = self.contentRewardMap[i]
        if not spt then
            local obj = Object.Instantiate(contentRes)
            obj.transform:SetParent(self.rewardContentTrans, false)
            spt = obj:GetComponent("CapsUnityLuaBehav")
            self.contentRewardMap[i] = spt
        end
        local floor = tostring(v.floorID)
        local stageRewards = v.stageReward
        local stagePoint = tostring(AdventureFloor[floor].stagePoint)
        spt:InitView(floor, stagePoint, stageRewards)
    end
end

function CompleteRewardIntroduceView:InitView(greenswardIntroduceModel, region)
    self.greenswardIntroduceModel = greenswardIntroduceModel
    self:InitRewardMorales()

    self.tabBtnGroupSpt.menu = {}
    local allRegion = greenswardIntroduceModel:GetAllRegion()
    self.tabScrollSpt:regOnItemIndexChanged(function(index)
        local preState = index > 1
        local nextState = index <= #self.tabScrollSpt.itemDatas - MaxLine
        GameObjectHelper.FastSetActive(self.arrowPreviewBtn.gameObject, preState)
        GameObjectHelper.FastSetActive(self.arrowNextBtn.gameObject, nextState)
    end)
    self.tabScrollSpt:InitView(allRegion, self.tabBtnGroupSpt, function(tag)
        self:OnTabClick(tag)
    end)
    self.tabScrollSpt:scrollToCellImmediate(tonumber(region))
    self.tabBtnGroupSpt:selectMenuItem(tostring(region))
    self:OnTabClick(tostring(region))
end

function CompleteRewardIntroduceView:InitRewardMorales()
    local rewardMorales = self.greenswardIntroduceModel:GetCompleteRewardMoraleItems()

    local contentRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Introduce/CompleteRewardItem.prefab")
    for idx, rewardMorale in ipairs(rewardMorales) do
        local spt = self.contentMap[idx]
        if not spt then
            local obj = Object.Instantiate(contentRes)
            obj.transform:SetParent(self.contentTrans, false)
            spt = obj:GetComponent("CapsUnityLuaBehav")
            self.contentMap[idx] = spt
        end
        spt:InitView(idx, rewardMorale)
    end
end

return CompleteRewardIntroduceView
