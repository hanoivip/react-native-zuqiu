local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local GameObjectHelper = require("ui.common.GameObjectHelper")

local AllRewardPageView = class(unity.base, "AllRewardPageView")

local MaxLine = 4

function AllRewardPageView:ctor()
--------Start_Auto_Generate--------
    self.myRegionTxt = self.___ex.myRegionTxt
    self.maxCompleteTxt = self.___ex.maxCompleteTxt
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

function AllRewardPageView:start()
    self.arrowNextBtn:regOnButtonClick(function()
        self:OnArrowNextClick()
    end)
    self.arrowPreviewBtn:regOnButtonClick(function()
        self:OnArrowPreviewClick()
    end)
end

function AllRewardPageView:OnArrowPreviewClick()
    self.tabScrollSpt:scrollToPreviousGroup()
end

function AllRewardPageView:OnArrowNextClick()
    self.tabScrollSpt:scrollToNextGroup()
end

function AllRewardPageView:OnTabClick(tag)
    local regionReward = self.greenswardIntroduceModel:GetAdventureRewardByRegionID(tag)
    self.greenswardIntroduceModel:SetRegion(tag)

    local contentRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/SeasonReward/AllRewardItem.prefab")
    for i, v in ipairs(regionReward) do
        local spt = self.contentMap[i]
        if not spt then
            local obj = Object.Instantiate(contentRes)
            obj.transform:SetParent(self.contentTrans, false)
            spt = obj:GetComponent("CapsUnityLuaBehav")
            self.contentMap[i] = spt
        end
        spt:InitView(v, self.receiveReward)
    end
    self.scrollRect.verticalNormalizedPosition = 1
end

function AllRewardPageView:InitView(greenswardIntroduceModel, region, receiveReward)
    self.greenswardIntroduceModel = greenswardIntroduceModel
    self.receiveReward = receiveReward
    local regionName = self.greenswardIntroduceModel:GetRegionName()
    local topFloor = self.greenswardIntroduceModel:GetTopFloor()
    self.myRegionTxt.text = regionName
    self.maxCompleteTxt.text = lang.trans("floor_order", topFloor)
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

return AllRewardPageView
