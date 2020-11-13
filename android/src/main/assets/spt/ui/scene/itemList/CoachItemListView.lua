local UnityEngine = clr.UnityEngine
local CoachItemType = require("ui.models.coach.common.CoachItemType")
local MenuType = require("ui.controllers.itemList.MenuType")
local CoachItemListView = class(unity.base, "CoachItemListView")

function CoachItemListView:ctor()
    self.scrollView = self.___ex.scrollView
    self.btnCoachItem = self.___ex.btnCoachItem
    self.btnCoachFeatureItem = self.___ex.btnCoachFeatureItem
    self.btnCoachFeatureSkill = self.___ex.btnCoachFeatureSkill
    self.btnCoachContent = self.___ex.btnCoachContent
end

function CoachItemListView:start()
    self.btnCoachItem:regOnButtonClick(function()
        self:OnBtnItem()
    end)
    self.btnCoachFeatureItem:regOnButtonClick(function ()
        self:OnBtnFeatureItem()
    end)
    self.btnCoachFeatureSkill:regOnButtonClick(function ()
        self:OnBtnFeatureSkill()
    end)
    self.btnCoachContent:regOnButtonClick(function ()
        self:OnBtnCoachContent()
    end)
end

function CoachItemListView:OnBtnItem()
    self:HandleSelectTag(CoachItemType.CoachTacticsItem)
end

function CoachItemListView:OnBtnFeatureItem()
    self:HandleSelectTag(CoachItemType.PlayerTalentFunctionalityItem)
end

function CoachItemListView:OnBtnFeatureSkill()
    self:HandleSelectTag(CoachItemType.PlayerTalentSkillBook)
end

function CoachItemListView:OnBtnCoachContent()
    self:HandleSelectTag(CoachItemType.Normal)
end

function CoachItemListView:HandleSelectTag(coachItemType)
    if self.coachTag == coachItemType then return end
    EventSystem.SendEvent("ItemListMainCtrl_OnCurrentOrderChanged", coachItemType)
    self:InitView(self.model, coachItemType)
end

-- 阵型/战术升级书
function CoachItemListView:GetItemModels()
    local itemModels = {}
    local modelMaps = self.model:GetAllCoachTacticItemModels() or {}
    for id, itemModel in pairs(modelMaps) do
        table.insert(itemModels, itemModel)
    end

    table.sort(itemModels, function(a, b)
        return tonumber(a:GetId()) < tonumber(b:GetId())
    end)
    return itemModels
end

-- 特性道具
function CoachItemListView:GetFeatureItemModels()
    local itemModels = {}
    local modelMaps = self.model:GetAllPlayerTalentFuncItemModels() or {}
    for id, itemModel in pairs(modelMaps) do
        table.insert(itemModels, itemModel)
    end
    return itemModels
end

-- 特性技能书
function CoachItemListView:GetFeatureBookModels()
    local itemModels = {}
    local modelMaps = self.model:GetAllPlayerTalentSkillBookModels() or {}
    for id, itemModel in pairs(modelMaps) do
        table.insert(itemModels, itemModel)
    end
    return itemModels
end

-- 特性道具
function CoachItemListView:AllContentModels()
    local itemModels = {}
    local modelMaps = self.model:AllContentModel() or {}
    for id, itemModel in pairs(modelMaps) do
        table.insert(itemModels, itemModel)
    end
    return itemModels
end

function CoachItemListView:InitView(coachItemListModel, coachItemType)
    self.model = coachItemListModel
    coachItemType = tonumber(coachItemType)
    if coachItemType == 0 then
        coachItemType = CoachItemType.Normal
    end
    local itemModels = {}
    self.coachTag = coachItemType
    self:SetButtonState()
    if coachItemType == CoachItemType.CoachTacticsItem then 
        itemModels = self:GetItemModels()
    elseif coachItemType == CoachItemType.PlayerTalentSkillBook then 
        itemModels = self:GetFeatureBookModels()
    elseif coachItemType == CoachItemType.PlayerTalentFunctionalityItem then 
        itemModels = self:GetFeatureItemModels()
    elseif coachItemType == CoachItemType.Normal then 
        itemModels = self:AllContentModels()
    end
    self.scrollView:removeAll()
    self.scrollView:SetCoachItemListType(coachItemType)
    self.scrollView:SetCoachItemListModel(coachItemListModel)
    if coachItemType == CoachItemType.Normal then
        self.scrollView.onClick = function(model) self:OnClick(model) end
        self.scrollView:InitView(itemModels, MenuType.ITEM)
    else
        self.scrollView:InitView(itemModels, true, true, false, true)
    end
end

function CoachItemListView:SetButtonState()
    if self.currentBtn then 
        self.currentBtn:unselectBtn()
    end    

    if self.coachTag == CoachItemType.CoachTacticsItem then 
        self.btnCoachItem:selectBtn()
        self.currentBtn = self.btnCoachItem
    elseif self.coachTag == CoachItemType.PlayerTalentSkillBook then 
        self.btnCoachFeatureSkill:selectBtn()
        self.currentBtn = self.btnCoachFeatureSkill
    elseif self.coachTag == CoachItemType.PlayerTalentFunctionalityItem then 
        self.btnCoachFeatureItem:selectBtn()
        self.currentBtn = self.btnCoachFeatureItem
    elseif self.coachTag == CoachItemType.Normal then 
        self.btnCoachContent:selectBtn()
        self.currentBtn = self.btnCoachContent
    end
end

function CoachItemListView:OnClick(model)
    self.currentSelectId = model:GetId()
    local usage = model:GetUsage()
    if tonumber(usage) == 1 then
        res.PushDialog("ui.controllers.itemList.GiftBoxDetailCtrl", model)
        return
    end

    res.PushDialog("ui.controllers.itemList.ItemDetailCtrl", currentMenu, model, ItemOriginType.ITEMLIST)
end

return CoachItemListView
