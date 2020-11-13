local GameObjectHelper = require("ui.common.GameObjectHelper")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local CardHelper = require("ui.scene.cardDetail.CardHelper")
local StaticCardModel = require("ui.models.cardDetail.StaticCardModel")
local MedalListView = class(unity.base)

function MedalListView:ctor()
    self.listScrollView = self.___ex.listScrollView
    self.medalView = self.___ex.medalView
    self.infoBoard = self.___ex.infoBoard
    self.nameTxt = self.___ex.name
    self.medalType = self.___ex.medalType
    self.btnSplit = self.___ex.btnSplit
    self.buttonSplit = self.___ex.buttonSplit
    self.btnStrengthin = self.___ex.btnStrengthin
    self.btnMenu = self.___ex.btnMenu
    self.btnAutoSplit = self.___ex.btnAutoSplit
    self.btnSearch = self.___ex.btnSearch
    self.benedictionName = self.___ex.benedictionName
    self.benedictionBar = self.___ex.benedictionBar
    self.medalAttrMap = self.___ex.medalAttrMap
    self.benediction = self.___ex.benediction
    self.stardust = self.___ex.stardust
    self.searchText = self.___ex.searchText
    self.infoBarDynParent = self.___ex.infoBarDynParent
    self.helpBtn = self.___ex.helpBtn
    self.filterBoard = self.___ex.filterBoard
    self.filterClickMask = self.___ex.filterClickMask
    self.txtCarrier = self.___ex.txtCarrier
end

function MedalListView:RegOnInfoBarDynamicLoad(func)
    self.infoBarDynParent:RegOnDynamicLoad(func)
end

function MedalListView:start()
    self.listScrollView.clickMedal = function(medalModel) self:OnClickMedal(medalModel) end
    self.btnSplit:regOnButtonClick(function()
        self:OnClickSplit()
    end)
    self.btnStrengthin:regOnButtonClick(function()
        self:OnClickStrengthin()
    end)
    self.btnMenu:regOnButtonClick(function()
        self:OnBtnMenu()
    end)
    self.btnAutoSplit:regOnButtonClick(function()
        self:OnAutoSplit()
    end)
    self.btnSearch:regOnButtonClick(function()
        self:OnBtnSearch()
    end)
    self.helpBtn:regOnButtonClick(function()
        if self.clickHelp then
            self.clickHelp()
        end
    end)
    self.filterClickMask:regOnButtonClick(function()
        self:ActiveFilterMask(false)
        EventSystem.SendEvent("MedalListFilter_OnClickFilterMask", false) -- close all filter boxes
    end)
end

function MedalListView:OnBtnSearch()
    if self.clickSearch then
        self.clickSearch()
    end
end

function MedalListView:OnAutoSplit()
    if self.clickAutoSplit then
        self.clickAutoSplit()
    end
end

function MedalListView:OnBtnMenu()
    if self.clickMenu then
        self.clickMenu()
    end
end

function MedalListView:OnClickSplit()
    if self.clickSplit then 
        self.clickSplit(self.medalModel)
    end
end

function MedalListView:OnClickStrengthin()
    if self.clickStrengthin then 
        self.clickStrengthin(self.medalModel)
    end
end

function MedalListView:InitView(medalListModel)
    GameObjectHelper.FastSetActive(self.infoBoard, false)
    self.medalListModel = medalListModel
    self.listScrollView:InitView(medalListModel)
    self.filterBoard:InitView(medalListModel)

    self:ShowMedalMaterial()
    self.searchText.text = self.medalListModel:IsSearch() and lang.trans("pos_be_selected_title") or lang.trans("select")
end

function MedalListView:ShowMedalMaterial()
    local playerInfoModel = PlayerInfoModel.new()
    self.stardust.text = "x" .. tonumber(playerInfoModel:GetStardustCount())
    self.benediction.text = "x" .. tonumber(playerInfoModel:GetBenedictionCount())
end

function MedalListView:OnClickMedal(medalModel)
    if medalModel then
        local hasBenediction = false
        local medalName, benedictionName = "", ""
        self.medalView:InitView(medalModel)
        self.medalView:ClearName()
        medalName = medalModel:GetName()
        self.medalModel = medalModel
        local benediction = medalModel:GetBenediction()
        if next(benediction) then
            hasBenediction = true
            local name, lvl = medalModel:GetBenedictionNameAndLvl()
            benedictionName = name .. "Lv" .. lvl
        end
        self.benedictionName.text = benedictionName
        self.nameTxt.text = medalName
        self.medalType.text = medalModel:GetMedalTypeName()
        local hasBaseAttr, hasExaAttr, hasSkillAttr = false, false, false
        local baseAttr = medalModel:GetBaseAttr()
        if next(baseAttr) then
            local title = lang.transstr("breakThrough_baseAttr")
            local name, lvl = next(baseAttr)
            name = lang.transstr(name)
            lvl = "+" .. lvl
            local data = { title = title, name = name, lvl = lvl }
            self.medalAttrMap["s1"]:InitView(data)
            hasBaseAttr = true
        end
        local exaAttr = medalModel:GetExAttr()
        if next(exaAttr) then
            local maxPercent = medalModel:GetExAttrMaxPercent()
            local title = lang.transstr("extra_attr")
            local name, plus = next(exaAttr)
            local max = tobool(plus >= maxPercent) and "\n(MAX)" or ""
            name = lang.transstr(name)
            plus = plus * 100
            plus = "+" .. plus .. "%" .. max
            local data = { title = title, name = name, lvl = plus }
            self.medalAttrMap["s2"]:InitView(data)
            hasExaAttr = true
        end
        local skillAttr = medalModel:GetSkill()
        if next(skillAttr) then
            local title = lang.transstr("skill_attr")
            local name, lvl = medalModel:GetSkillNameAndLvl()
            lvl = "+Lv" .. lvl
            local data = { title = title, name = name, lvl = lvl }
            self.medalAttrMap["s3"]:InitView(data)
            hasSkillAttr = true
        end
        GameObjectHelper.FastSetActive(self.medalAttrMap["s1"].gameObject, hasBaseAttr)
        GameObjectHelper.FastSetActive(self.medalAttrMap["s2"].gameObject, hasExaAttr)
        GameObjectHelper.FastSetActive(self.medalAttrMap["s3"].gameObject, hasSkillAttr)
        GameObjectHelper.FastSetActive(self.benedictionBar.gameObject, hasBenediction)
        -- 携带者
        local carrierText = lang.trans("medal_new_filter_equiped_2")
        if medalModel:HasEquiped() then
            local cid = medalModel:GetCarrierCid()
            local carrierCard = StaticCardModel.new(cid)
            local quality = lang.transstr(CardHelper.QualitySign[tostring(carrierCard:GetCardFixQuality())])
            local name = carrierCard:GetName()
            carrierText = lang.trans("medal_new_carrier", quality, name)
        end
        self.txtCarrier.text = carrierText
        self.buttonSplit.interactable = not medalModel:HasEquiped()
        if self.onClickMedalItem then
            self.onClickMedalItem(medalModel)
        end
    end
    GameObjectHelper.FastSetActive(self.infoBoard, medalModel and true or false)
end

function MedalListView:EventResetMedal(pmid)
    self.listScrollView:ResetMedal(pmid)
end

function MedalListView:EventRemoveMedal(pmid)
    self.listScrollView:RemoveMedal(pmid)
end

function MedalListView:EventRemoveMedals(pmids)
    self.medalListModel:FinalSearch(self.medalListModel:GetCurrSearchState())
    local medalArray = self.medalListModel:GetCurrList()
    self.listScrollView:SearchSort(medalArray)
end

function MedalListView:SearchSort(medalArray)
    GameObjectHelper.FastSetActive(self.infoBoard, false)
    self.listScrollView:SearchSort(medalArray)
    local isSearch = self.medalListModel:IsSearch()
    self.searchText.text = isSearch and lang.trans("pos_be_selected_title") or lang.trans("select")
end

function MedalListView:EnterScene()
    EventSystem.AddEvent("MedalsMapModel_ResetMedalModel", self, self.EventResetMedal)
    EventSystem.AddEvent("MedalsMapModel_RemoveMedalData", self, self.EventRemoveMedal)
    EventSystem.AddEvent("MedalsMapModel_RemoveMedalsData", self, self.EventRemoveMedals)
    EventSystem.AddEvent("MedalListModel_SearchSort", self, self.SearchSort)
    EventSystem.AddEvent("PlayerInfo", self, self.ShowMedalMaterial)
    EventSystem.AddEvent("MedalListFilter_OnFilterTitleClick", self, self.OnFilterTitleClick)
    EventSystem.AddEvent("MedalListFilter_OnFilterItemChoosed", self, self.OnFilterItemChoosed)
    self.filterBoard:EnterScene()
end

function MedalListView:ExitScene()
    EventSystem.RemoveEvent("MedalsMapModel_ResetMedalModel", self, self.EventResetMedal)
    EventSystem.RemoveEvent("MedalsMapModel_RemoveMedalData", self, self.EventRemoveMedal)
    EventSystem.RemoveEvent("MedalsMapModel_RemoveMedalsData", self, self.EventRemoveMedals)
    EventSystem.RemoveEvent("MedalListModel_SearchSort", self, self.SearchSort)
    EventSystem.RemoveEvent("PlayerInfo", self, self.ShowMedalMaterial)
    EventSystem.RemoveEvent("MedalListFilter_OnFilterTitleClick", self, self.OnFilterTitleClick)
    EventSystem.RemoveEvent("MedalListFilter_OnFilterItemChoosed", self, self.OnFilterItemChoosed)
    EventSystem.SendEvent("MedalListFilter_OnClickFilterMask")
    self.filterBoard:ExitScene()
end

-- 新筛选相关
function MedalListView:OnFilterTitleClick(isOpen)
    self:ActiveFilterMask(isOpen)
end

function MedalListView:OnFilterItemChoosed(id, filterType)
    self:ActiveFilterMask(false)
    if self.onFilterItemChoosed then
        self.onFilterItemChoosed(id, filterType)
    end
end

function MedalListView:ActiveFilterMask(isActive)
    GameObjectHelper.FastSetActive(self.filterClickMask.gameObject, isActive)
end

return MedalListView
