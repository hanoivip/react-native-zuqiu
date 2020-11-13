local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local PastertMainType = require("ui.scene.paster.PasterMainType")
local CardOpenFromType = require("ui.controllers.cardDetail.CardOpenFromType")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local PasterQueueView = class(unity.base)

function PasterQueueView:ctor()
    self.scrollView = self.___ex.scrollView
    self.title = self.___ex.title
    self.btnClose = self.___ex.btnClose
    self.competeLimit = self.___ex.competeLimit
    self.weekLimit = self.___ex.weekLimit
    self.btnOneClickUnload = self.___ex.btnOneClickUnload
    self.btnActivateExPaster = self.___ex.btnActivateExPaster
    self.btnFilter = self.___ex.btnFilter
    self.filterTxt = self.___ex.filterTxt

    self.scrollView.clickAppend = function() self:OnClickAppend() end
    self.scrollView.clickUse = function(cardAppendPasterModel) self:OnClickUse(cardAppendPasterModel) end
    self.scrollView.clickCardPaster = function(cardAppendPasterModel) self:OnClickCardPaster(cardAppendPasterModel) end
    self.scrollView.clickSkill = function(cardAppendPasterModel) self:OnClickSkill(cardAppendPasterModel) end
end

function PasterQueueView:start()
    self.btnActivateExPaster:regOnButtonClick(function()
        self:OnBtnActivateExPaster()
    end)
    self.btnFilter:regOnButtonClick(function()
        self:OnBtnFilter()
    end)
    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)
    self.btnOneClickUnload:regOnButtonClick(function()
        if self.onBtnOneClickUnloadClick and type(self.onBtnOneClickUnloadClick) == "function" then
            self.onBtnOneClickUnloadClick()
        end
    end)

    if luaevt.trig("__SGP__VERSION__") then
        GameObjectHelper.FastSetActive(self.btnOneClickUnload.gameObject, false)
        GameObjectHelper.FastSetActive(self.competeLimit.gameObject, false)
        GameObjectHelper.FastSetActive(self.weekLimit.gameObject, false)
        GameObjectHelper.FastSetActive(self.btnFilter.gameObject, false)
    end

    DialogAnimation.Appear(self.transform)
end

function PasterQueueView:Close()
    DialogAnimation.Disappear(self.transform, nil, function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end)
end

function PasterQueueView:OnBtnActivateExPaster()
    if self.onClickActivateExPaster then
        self.onClickActivateExPaster()
    end
end

function PasterQueueView:OnBtnFilter()
    res.PushDialog("ui.controllers.paster.PasterSearchCtrl", self.pasterQueueModel)
end

function PasterQueueView:InitView(pasterQueueModel)
    self.pasterQueueModel = pasterQueueModel
    self.cardModel = pasterQueueModel:GetCardModel()
    self.selectCardAppendPasterModel = pasterQueueModel:GetSelectCardAppendPasterModel()
    self.scrollView:InitView(self.pasterQueueModel)
    local name = self.cardModel:GetName()
    self.title.text = lang.trans("paster_title", name)
    self:SetButtonState(self.cardModel)
    self.filterTxt.text = lang.trans("pasterSplit_activity_sortOutPaster")

    self:UpdateCompeteLimitText(self.cardModel)
    self:UpdateWeekLimitText(self.cardModel)
end

function PasterQueueView:SetButtonState(cardModel)
    local pasterTypeTags, levelTag, skillTag = self.pasterQueueModel:GetPasterSearchList()
    local btnOneClickUnloadState = not (next(pasterTypeTags) or levelTag or skillTag)
    GameObjectHelper.FastSetActive(self.btnOneClickUnload.gameObject, btnOneClickUnloadState and cardModel:HasPaster())
    GameObjectHelper.FastSetActive(self.btnActivateExPaster.gameObject, cardModel:HasPasterSKillExAvailable())
    GameObjectHelper.FastSetActive(self.btnFilter.gameObject, not cardModel:GetIsPasterPokedex())
    if luaevt.trig("__SGP__VERSION__") then
        GameObjectHelper.FastSetActive(self.btnOneClickUnload.gameObject, false)
        GameObjectHelper.FastSetActive(self.btnFilter.gameObject, false)
    end
end

function PasterQueueView:UpdateCompeteLimitText(cardModel)
    if cardModel:GetOpenFromPageType() ~=  CardOpenFromType.HANDBOOK then
        self.competeLimit.text = lang.trans("paster_compete_limit", tostring(cardModel:GetWorldPasterNum()), tostring(cardModel:GetWorldPasterLimit()))
    end
end

function PasterQueueView:UpdateWeekLimitText(cardModel)
    if cardModel:GetOpenFromPageType() ~=  CardOpenFromType.HANDBOOK then
        self.weekLimit.text = lang.trans("paster_week_limit", tostring(cardModel:GetWeekPasterNum()), tostring(cardModel:GetWeekPasterLimit()))
    end
end

function PasterQueueView:OnClickAppend()
    if self.clickAppend then 
        self.clickAppend()
    end
end

function PasterQueueView:OnClickUse(cardAppendPasterModel)
    if self.clickUse then 
        self.clickUse(cardAppendPasterModel)
    end
end

function PasterQueueView:OnClickCardPaster(cardAppendPasterModel)
    if self.clickCardPaster then 
        self.clickCardPaster(cardAppendPasterModel)
    end
end

function PasterQueueView:OnClickSkill(cardAppendPasterModel)
    self.selectCardAppendPasterModel = cardAppendPasterModel
    if self.clickSkill then 
        self.clickSkill(cardAppendPasterModel)
    end
end

function PasterQueueView:EventPasterUpdate(cardModel)
    self.pasterQueueModel:SetCardModel(cardModel)
    self.scrollView:InitView(self.pasterQueueModel)
    self:UpdateCompeteLimitText(cardModel)
    self:UpdateWeekLimitText(cardModel)
    self:SetButtonState(cardModel)
end

function PasterQueueView:EventUpdateSkillLevelUp(pcid)
    self.scrollView:UpdateSkillLevelUp(self.selectCardAppendPasterModel)
end

function PasterQueueView:EventPasterLevelUp()
	self:EventPasterUpdate(self.cardModel)
end

function PasterQueueView:OnSearch()
    local pasterTypeTags, levelTag, skillTag = self.pasterQueueModel:GetPasterSearchList()
    if next(pasterTypeTags) or levelTag or skillTag then
        self.filterTxt.text = lang.trans("pos_be_selected_title")
        GameObjectHelper.FastSetActive(self.btnOneClickUnload.gameObject, false)
    else
        self.filterTxt.text = lang.trans("pasterSplit_activity_sortOutPaster")
        GameObjectHelper.FastSetActive(self.btnOneClickUnload.gameObject, true)
    end
    self.scrollView:InitView(self.pasterQueueModel)
end

function PasterQueueView:EnterScene()
    EventSystem.AddEvent("Paster_AppendToCard", self, self.EventPasterUpdate)
    EventSystem.AddEvent("Paster_UnloadToCard", self, self.EventPasterUpdate)
    EventSystem.AddEvent("Paster_Replace", self, self.EventPasterUpdate)
	EventSystem.AddEvent("Paster_LevelUp", self, self.EventPasterLevelUp)
    EventSystem.AddEvent("PlayerCardModel_UpdateSkillLevelUp", self, self.EventUpdateSkillLevelUp)
    EventSystem.AddEvent("PasterSearch_OnSearch", self, self.OnSearch)
end

function PasterQueueView:ExitScene()
    EventSystem.RemoveEvent("Paster_AppendToCard", self, self.EventPasterUpdate)
    EventSystem.RemoveEvent("Paster_UnloadToCard", self, self.EventPasterUpdate)
    EventSystem.RemoveEvent("Paster_Replace", self, self.EventPasterUpdate)
	EventSystem.RemoveEvent("Paster_LevelUp", self, self.EventPasterLevelUp)
    EventSystem.RemoveEvent("PlayerCardModel_UpdateSkillLevelUp", self, self.EventUpdateSkillLevelUp)
    EventSystem.RemoveEvent("PasterSearch_OnSearch", self, self.OnSearch)
end

return PasterQueueView
