local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local AdventureRegion = require("data.AdventureRegion")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GreenswardIntroduceType = require("ui.controllers.greensward.introduce.GreenswardIntroduceType")
local GreenswardIntroduceType = require("ui.controllers.greensward.introduce.GreenswardIntroduceType")
local GreenswardRankView = class(unity.base)

local MaxLine = 4

function GreenswardRankView:ctor()
--------Start_Auto_Generate--------
    self.buttonGroupSpt = self.___ex.buttonGroupSpt
    self.rewardDetailBtn = self.___ex.rewardDetailBtn
    self.tabBtnGroupSpt = self.___ex.tabBtnGroupSpt
    self.arrowPreviewBtn = self.___ex.arrowPreviewBtn
    self.preNormalGo = self.___ex.preNormalGo
    self.preHighlightGo = self.___ex.preHighlightGo
    self.arrowNextBtn = self.___ex.arrowNextBtn
    self.nextNormalGo = self.___ex.nextNormalGo
    self.nextHighlightGo = self.___ex.nextHighlightGo
    self.tabScrollSpt = self.___ex.tabScrollSpt
    self.tabName1Txt = self.___ex.tabName1Txt
    self.tabName2Txt = self.___ex.tabName2Txt
    self.myTitleGo = self.___ex.myTitleGo
    self.myRegionTxt = self.___ex.myRegionTxt
    self.myRankTxt = self.___ex.myRankTxt
    self.myScoreTxt = self.___ex.myScoreTxt
    self.scrollSpt = self.___ex.scrollSpt
    self.noneGo = self.___ex.noneGo
    self.playTipBtn = self.___ex.playTipBtn
    self.closeBtn = self.___ex.closeBtn
--------End_Auto_Generate----------
    self.tabStateList = {}
    self.tabStateList[GreenswardIntroduceType.FinalReward] = true
    self.tabStateList[GreenswardIntroduceType.PlayTips] = true
    self.tabStateList[GreenswardIntroduceType.RewardReview] = true
end

function GreenswardRankView:start()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
    self.rewardDetailBtn:regOnButtonClick(function()
        self:OnRewardDetailClick()
    end)
    self.closeBtn:regOnButtonClick(function()
        self:Close()
    end)
    self.arrowNextBtn:regOnButtonClick(function()
        self.tabScrollSpt:scrollToNextGroup()
    end)
    self.arrowPreviewBtn:regOnButtonClick(function()
        self.tabScrollSpt:scrollToPreviousGroup()
    end)
    self.playTipBtn:regOnButtonClick(function()
        self:OnPlayTipClick()
    end)

    self.tabScrollSpt:regOnItemIndexChanged(function(index)
        local preState = index > 1
        local nextState = index <= #self.tabScrollSpt.itemDatas - MaxLine
        GameObjectHelper.FastSetActive(self.preNormalGo, not preState)
        GameObjectHelper.FastSetActive(self.preHighlightGo, preState)
        GameObjectHelper.FastSetActive(self.nextNormalGo, not nextState)
        GameObjectHelper.FastSetActive(self.nextHighlightGo, nextState)
    end)
end

function GreenswardRankView:OnSeasonTabClick(seasonTag)
    self.tabBtnGroupSpt.menu = {}
    local allRegion = self.greenswardRankModel:GetAllRegion()
    local myRegion = self.greenswardRankModel:GetMyRegion()
    self.tabScrollSpt:InitView(allRegion, self.tabBtnGroupSpt, function(regionTag)
        self:OnRegionTabClick(seasonTag, regionTag)
    end)
    local regionTag = "1"
    local mySeason = self.greenswardRankModel:GetMySeason()
    if mySeason == seasonTag then
        regionTag = self.greenswardRankModel:GetMyRegion()
    end
    regionTag = tostring(regionTag)
    self:OnRegionTabClick(seasonTag, regionTag)
    self.tabBtnGroupSpt:selectMenuItem(regionTag)
    self.tabScrollSpt:scrollToCellImmediate(tonumber(regionTag))
end

function GreenswardRankView:OnRegionTabClick(seasonTag, regionTag)
    self.greenswardRankModel:SetSeasonAndRegionTag(seasonTag, regionTag)
    if self.switchTag then
        self.switchTag(seasonTag, regionTag)
    end
end

function GreenswardRankView:InitView(greenswardRankModel)
    self.greenswardRankModel = greenswardRankModel
    local seasonList = self.greenswardRankModel:GetSeasonList()
    local myPoint = self.greenswardRankModel:GetMyPoint()
    local myRegion = self.greenswardRankModel:GetMyRegion()
    local myRank = self.greenswardRankModel:GetMyRank()
    myRank = myRank or lang.transstr("train_rankOut")
    local seasonTag, regionTag = self.greenswardRankModel:GetCurrentTag()
    self.buttonGroupSpt.menu = {}
    local tabRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Rank/RankSeasonTabItem.prefab")
    for i, v in ipairs(seasonList) do
        local tag = v.seasonID
        local spt
        local obj = Object.Instantiate(tabRes)
        obj.transform:SetParent(self.buttonGroupSpt.transform, false)
        spt = obj:GetComponent("CapsUnityLuaBehav")
        self.buttonGroupSpt.menu[tag] = spt
        self.buttonGroupSpt:BindMenuItem(tag, function()
            self:OnSeasonTabClick(tag)
        end)
        spt:InitView(v)
    end
    self:SetTags(seasonTag, regionTag)
    self.myScoreTxt.text = tostring(myPoint)
    self.myRegionTxt.text = AdventureRegion[tostring(myRegion)].regionName
    self.myRankTxt.text = tostring(myRank)
    self.tabScrollSpt:scrollToCellImmediate(tonumber(myRegion))
end

function GreenswardRankView:OnRewardDetailClick()
    local seasonTag, regionTag = self.greenswardRankModel:GetCurrentTag()
    local introduceTab = GreenswardIntroduceType.FinalReward
    local greenswardBuildModel = self.greenswardRankModel:GetGreenswardBuildModel()
    local introduceCtrl = "ui.controllers.greensward.introduce.GreenswardIntroduceCtrl"
    res.PushDialog(introduceCtrl, greenswardBuildModel, introduceTab, regionTag, self.tabStateList)
end

function GreenswardRankView:OnPlayTipClick()
    local introduceTab = GreenswardIntroduceType.PlayTips
    local greenswardBuildModel = self.greenswardRankModel:GetGreenswardBuildModel()
    local introduceCtrl = "ui.controllers.greensward.introduce.GreenswardIntroduceCtrl"
    res.PushDialog(introduceCtrl, greenswardBuildModel, introduceTab, nil, self.tabStateList)
end

function GreenswardRankView:SetTags(seasonTag, regionTag)
    seasonTag = seasonTag or self.defaultSeasonTag
    regionTag = regionTag or self.defaultRegionTag
    self:OnRegionTabClick(seasonTag, regionTag)
    self:OnSeasonTabClick(seasonTag)
    self.buttonGroupSpt:selectMenuItem(seasonTag)
    self.tabBtnGroupSpt:selectMenuItem(regionTag)
end

function GreenswardRankView:RefreshScroll(tagData)
    local seasonTag, regionTag = self.greenswardRankModel:GetCurrentTag()
    local mySeason = self.greenswardRankModel:GetMySeason()
    mySeason = tostring(mySeason)
    seasonTag = tostring(seasonTag)
    GameObjectHelper.FastSetActive(self.noneGo, #tagData < 1)
    GameObjectHelper.FastSetActive(self.myTitleGo, mySeason == seasonTag)
    GameObjectHelper.FastSetActive(self.rewardDetailBtn.gameObject, mySeason == seasonTag)
    self.scrollSpt:InitView(tagData)
end

function GreenswardRankView:Close()
    DialogAnimation.Disappear(self.transform, self.canvasGroup, function()
        if type(self.closeDialog) == "function" then
            self.closeDialog()
        end
    end)
end

return GreenswardRankView
