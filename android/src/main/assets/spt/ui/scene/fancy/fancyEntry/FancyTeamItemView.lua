local UnityEngine = clr.UnityEngine
local Vector3 = UnityEngine.Vector3
local Color = UnityEngine.Color
local FancyGroup = require("data.FancyGroup")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local FancyCardsMapModel = require("ui.models.fancy.FancyCardsMapModel")
local FancyCardModel = require("ui.models.fancy.FancyCardModel")
local FancyTeamItemView = class(unity.base)

function FancyTeamItemView:ctor()
--------Start_Auto_Generate--------
    self.lightNumTxt = self.___ex.lightNumTxt
    self.teamNameTxt = self.___ex.teamNameTxt
    self.newTipGo = self.___ex.newTipGo
    self.teamDetailBtn = self.___ex.teamDetailBtn
    self.teamTrans = self.___ex.teamTrans
--------End_Auto_Generate----------
    self.scrollAtOnce = self.___ex.scrollAtOnce
    self.scrollRect = self.___ex.scrollRect

    self.param ={
        isShowNew = true,
        isShowName = true,
        nameColor = Color(0.8, 0.8, 0.8),
        nameSize = 20,
        showStar = true,
    }
    self.fancyCardsMapModel = FancyCardsMapModel.new()
end

function FancyTeamItemView:start()
    self:BindButtonHandler()
end

function FancyTeamItemView:BindButtonHandler()
    self.teamDetailBtn:regOnButtonClick(function()
        res.PushScene('ui.controllers.fancy.fancyHome.FancyGroupCtrl', self.groupId, self.fancyCardsMapModel)
    end)
end

function FancyTeamItemView:InitView(groupId, parentScrollRect, temporaryNew)
    self.groupId = tostring(groupId)
    local groupData = FancyGroup[groupId]
    local groupName = groupData.groupName
    local fancyCard = groupData.fancyCard
    self.temporaryNew = temporaryNew
    self.teamNameTxt.text = groupName
    self:InitFancyCardArea(fancyCard)
    self.scrollAtOnce.scrollRectInParent = parentScrollRect
    self:RefreshNew()
end

function FancyTeamItemView:InitFancyCardArea(fancyCard)
    self.sptList = {}
    self.fancyCardModels = self:SortFancyCard(fancyCard)
    local cardPath = "Assets/CapstonesRes/Game/UI/Common/Fancy/Prefab/FancyCardSmall.prefab"
    res.ClearChildrenImmediate(self.teamTrans)
    local lightCount = 0
    for i, v in ipairs(self.fancyCardModels) do
        local info = v:GetFancyInfo()
        if info then
            lightCount = lightCount + 1
        end
        local itemObj, itemSpt = res.Instantiate(cardPath)
        itemObj.transform:SetParent(self.teamTrans, false)
        itemSpt:InitView(v, self.param)
        itemSpt.OnBtnClick = function() 
            if info then
                res.PushDialogImmediate("ui.controllers.fancy.fancyHome.FancyStarUpCtrl", v)
            else
                res.PushDialogImmediate("ui.controllers.fancy.fancyHome.FancyPreviewCtrl", 2, v)
            end
            v:ResetNew()
            self:ClickChangeNew()
        end
        self.temporaryNew[v:GetID()] = true
        table.insert(self.sptList, itemSpt)
    end
    self.lightNumTxt.text = lang.trans("fancy_light_count", lightCount)
    self.scrollRect.horizontalNormalizedPosition = 0
end

function FancyTeamItemView:Refresh()
    if self.sptList then
        for k, v in pairs(self.sptList) do
            v:RefreshStar()
        end
    end
end

function FancyTeamItemView:RefreshNew()
    local bNew = false
    for i, v in ipairs(self.fancyCardModels) do
        if v:IsNew() then
            bNew = true
            break
        end
    end
    GameObjectHelper.FastSetActive(self.newTipGo, bNew)
end

function FancyTeamItemView:ClickChangeNew()
    self:RefreshNew()
    if self.sptList then
        for k, v in pairs(self.sptList) do
            v:RefreshNewTip()
        end
    end
end

function FancyTeamItemView:SortFancyCard(fancyCard)
    local models = {}
    for i, v in ipairs(fancyCard) do
        local fancyCardModel = FancyCardModel.new(v)
        fancyCardModel:InitData(v, self.fancyCardsMapModel)
        table.insert(models, fancyCardModel)
    end
    table.sort(models, function(a, b)
            local aQuality = a:GetQuality()
            local bQuality = b:GetQuality()
            return aQuality > bQuality
    end)
    return models
end

return FancyTeamItemView
