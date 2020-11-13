local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local GameObjectHelper = require("ui.common.GameObjectHelper")

local AllRewardIntroduceView = class(unity.base, "AllRewardIntroduceView")

local MaxLine = 4

function AllRewardIntroduceView:ctor()
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

function AllRewardIntroduceView:start()
    self.arrowNextBtn:regOnButtonClick(function()
        self:OnArrowNextClick()
    end)
    self.arrowPreviewBtn:regOnButtonClick(function()
        self:OnArrowPreviewClick()
    end)
end

function AllRewardIntroduceView:OnArrowPreviewClick()
    self.tabScrollSpt:scrollToPreviousGroup()
end

function AllRewardIntroduceView:OnArrowNextClick()
    self.tabScrollSpt:scrollToNextGroup()
end

function AllRewardIntroduceView:OnTabClick(tag)
    local regionReward = self.greenswardIntroduceModel:GetAdventureRewardByRegionID(tag)
    self.greenswardIntroduceModel:SetRegion(tag)

    local contentRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Introduce/AllRewardContentItem.prefab")
    for i, v in pairs(regionReward) do
        local spt = self.contentMap[i]
        if not spt then
            local obj = Object.Instantiate(contentRes)
            obj.transform:SetParent(self.contentTrans, false)
            spt = obj:GetComponent("CapsUnityLuaBehav")
            self.contentMap[i] = spt
        end
        spt:InitView(i, v.fullStageReward)
    end
    self.scrollRect.verticalNormalizedPosition = 1
end

function AllRewardIntroduceView:InitView(greenswardIntroduceModel, region)
    self.greenswardIntroduceModel = greenswardIntroduceModel
    self.tabBtnGroupSpt.menu = {}
    local allRegion = self.greenswardIntroduceModel:GetAllRegion()
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

return AllRewardIntroduceView
