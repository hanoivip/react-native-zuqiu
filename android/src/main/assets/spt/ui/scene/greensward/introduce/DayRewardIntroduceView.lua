local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local GameObjectHelper = require("ui.common.GameObjectHelper")

local DayRewardIntroduceView = class(unity.base, "DayRewardIntroduceView")

local MaxLine = 4

function DayRewardIntroduceView:ctor()
--------Start_Auto_Generate--------
    self.contentTrans = self.___ex.contentTrans
    self.tabBtnGroupSpt = self.___ex.tabBtnGroupSpt
    self.arrowNextBtn = self.___ex.arrowNextBtn
    self.arrowPreviewBtn = self.___ex.arrowPreviewBtn
    self.tabScrollSpt = self.___ex.tabScrollSpt
    self.tabName1Txt = self.___ex.tabName1Txt
    self.tabName2Txt = self.___ex.tabName2Txt
--------End_Auto_Generate----------
    self.scrollRect = self.___ex.scrollRect
    self.contentMap = {}
end

function DayRewardIntroduceView:start()
    self.arrowNextBtn:regOnButtonClick(function()
        self:OnArrowNextClick()
    end)
    self.arrowPreviewBtn:regOnButtonClick(function()
        self:OnArrowPreviewClick()
    end)
end

function DayRewardIntroduceView:OnArrowPreviewClick()
    self.tabScrollSpt:scrollToPreviousGroup()
end

function DayRewardIntroduceView:OnArrowNextClick()
    self.tabScrollSpt:scrollToNextGroup()
end

function DayRewardIntroduceView:OnTabClick(tag)
    local regionReward = self.greenswardIntroduceModel:GetAdventureSeasonRewardByRegionID(tag)
    self.greenswardIntroduceModel:SetRegion(tag)

    local contentRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Introduce/DayContentItem.prefab")
    for i, v in pairs(regionReward) do
        local rankHigh, rankLow, rewardData
        rankHigh = v.dailyRankHigh
        rankLow = v.dailyRankLow
        rewardData = v.dailyReward
        if rankHigh > 0 and rankLow > 0 then
            local spt = self.contentMap[i]
            if not spt then
                local obj = Object.Instantiate(contentRes)
                obj.transform:SetParent(self.contentTrans, false)
                spt = obj:GetComponent("CapsUnityLuaBehav")
                self.contentMap[i] = spt
            end
            spt:InitView(rankHigh, rankLow, rewardData)
        end
    end
    self.scrollRect.verticalNormalizedPosition = 1
end

function DayRewardIntroduceView:InitView(greenswardIntroduceModel, region)
    self.greenswardIntroduceModel = greenswardIntroduceModel
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
    self:OnTabClick(region)
end

return DayRewardIntroduceView
