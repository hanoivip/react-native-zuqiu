local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local PasterUpgradeSortType = require("ui.scene.pasterUpgrade.PasterUpgradeSortType")

local PasterUpgradeView = class(unity.base)

function PasterUpgradeView:ctor()
    self.confirmBtn = self.___ex.confirmBtn
    self.closeBtn = self.___ex.closeBtn
    self.originParentTrans = self.___ex.originParentTrans
    self.pasterScrollView = self.___ex.pasterScrollView
    self.pasterTrans = {self.___ex.paster1Trans, self.___ex.paster2Trans, self.___ex.paster3Trans}
    self.rateImg = self.___ex.rateImg
    self.sortQualityBtn = self.___ex.sortQualityBtn
    self.sortSkillBtn = self.___ex.sortSkillBtn
    self.filterBtn = self.___ex.filterBtn
    self.helpBtn = self.___ex.helpBtn
    self.pasterSptsMap = {}
    self.sortBtnDownState = {}
end

function PasterUpgradeView:start()
    EventSystem.AddEvent("PasterUpgrade_UnselectPaster", self, self.UnselectPaster)
    EventSystem.AddEvent("PasterUpgrade_SelectPaster", self, self.SelectPaster)
    EventSystem.AddEvent("PasterUpgrade_OnFilterConfirmClick", self, self.OnFilterConfirmClick)
    EventSystem.AddEvent("CardPastersMapModel_RemovePasterData", self, self.EventRemovePaster)
    EventSystem.AddEvent("PasterUpgradeView_RefreshOriginPaster", self, self.RefreshOriginPaster)

    self.closeBtn:regOnButtonClick(function()
        self:Close()
    end)

    self.sortQualityBtn:regOnButtonClick(function()
        self:OnSortClick(PasterUpgradeSortType.Quality)
    end)

    self.sortSkillBtn:regOnButtonClick(function()
        self:OnSortClick(PasterUpgradeSortType.Skill)
    end)

    self.filterBtn:regOnButtonClick(function()
        self:OnFilterClick()
    end)

    self.confirmBtn:regOnButtonClick(function()
        self:OnConfirmClick()
    end)

    self.helpBtn:regOnButtonClick(function()
        self:OnHelpClick()
    end)

    DialogAnimation.Appear(self.transform, nil)
end

function PasterUpgradeView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function()
            self.closeDialog()
        end)
    end
end

function PasterUpgradeView:GetPasterCardRes()
    if not self.pasterCardRes then 
        self.pasterCardRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Paster/PasterCard.prefab")
    end
    return self.pasterCardRes
end

function PasterUpgradeView:GetPasterRes()
    if not self.pasterRes then 
        self.pasterRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Paster/Paster.prefab")
    end
    return self.pasterRes
end

function PasterUpgradeView:InstantiatePaster(parentTrans)
    local obj = Object.Instantiate(self:GetPasterCardRes())
    obj.transform:SetParent(parentTrans, false)
    local spt = res.GetLuaScript(obj)
    return spt
end

function PasterUpgradeView:InitView(pasterUpgradeModel, cardResourceCache)
    self.cardResourceCache = cardResourceCache
    self.pasterUpgradeModel = pasterUpgradeModel
    self.pasterSpt = self:InstantiatePaster(self.originParentTrans)
    self.pasterRes = self:GetPasterRes()
    self:RefreshContent()
end

function PasterUpgradeView:RefreshContent()
    local cardPasterModel = self.pasterUpgradeModel:GetCardPasterModel()
    local canPasterUpgrade = cardPasterModel:CanPasterUpgrade()
    if not canPasterUpgrade then
        self:Close()
    end
    self.pasterSpt:InitView(cardPasterModel, self.cardResourceCache, self.pasterRes)
    local competePasterListSortModel = self.pasterUpgradeModel:GetListModel()
    local selectedMap = self.pasterUpgradeModel:GetSelectedMap()
    self.pasterScrollView:InitView(competePasterListSortModel, cardResourceCache, selectedMap)
    self.sortQualityBtn:unselectBtn()
    self.sortSkillBtn:unselectBtn()
    self:RefreshRateArea()
end

function PasterUpgradeView:EventRemovePaster(ptid)
    for i, v in ipairs(self.pasterScrollView.itemDatas) do
        if tostring(v:GetId()) == tostring(ptid) then
            self.pasterScrollView:removeItem(i)
            self.pasterUpgradeModel:RemovePasterModel(ptid)
            break
        end
    end
end

function PasterUpgradeView:SelectPaster(cardPasterModel)
    local ptid = cardPasterModel:GetId()
    local index = self.pasterUpgradeModel:AddSelectedMap(ptid)
    if index then
        self:AddSelectPaster(index, cardPasterModel)
        self:RefreshRateArea()
    end
end

function PasterUpgradeView:UnselectPaster(cardPasterModel)
    local ptid = cardPasterModel:GetId()
    local index = self.pasterUpgradeModel:RemoveSelectedMap(ptid)
    if index then
        self:RemoveSelectPaster(index)
        self:RefreshRateArea()
    end
end

function PasterUpgradeView:AddSelectPaster(index, cardPasterModel)
    GameObjectHelper.FastSetActive(self.pasterTrans[index].gameObject, true)
    if not self.pasterSptsMap[index] then
        self.pasterSptsMap[index] = self:InstantiatePaster(self.pasterTrans[index])
    end
    local pasterRes = self:GetPasterRes()
    self.pasterSptsMap[index]:InitView(cardPasterModel, self.cardResourceCache, pasterRes)
end

function PasterUpgradeView:RemoveSelectPaster(index)
    GameObjectHelper.FastSetActive(self.pasterTrans[index].gameObject, false)
end

function PasterUpgradeView:RemoveAllSelectPaster()
    for k,v in pairs(self.pasterTrans) do
        GameObjectHelper.FastSetActive(v.gameObject, false)
    end
end

function PasterUpgradeView:RefreshRateArea()
    local successRate = self.pasterUpgradeModel:GetSuccessRate()
    self.rateImg.fillAmount = successRate
end

function PasterUpgradeView:OnSortClick(pasterUpgradeSortType)
    local sortModelList = {}
    self.sortQualityBtn:unselectBtn()
    self.sortSkillBtn:unselectBtn()
    if pasterUpgradeSortType == PasterUpgradeSortType.Quality then
        local sortState = self.sortBtnDownState[PasterUpgradeSortType.Quality]
        sortModelList = self.pasterUpgradeModel:GetQualitySortList(sortState)
        self.sortQualityBtn:selectBtn()
    elseif pasterUpgradeSortType == PasterUpgradeSortType.Skill then
        local sortState = self.sortBtnDownState[PasterUpgradeSortType.Quality]
        sortModelList = self.pasterUpgradeModel:GetSkillSortList(sortState)
        self.sortSkillBtn:selectBtn()
    end

    for k,v in pairs(PasterUpgradeSortType) do
        self.sortBtnDownState[v] = not self.sortBtnDownState[v]
    end
    self.sortQualityBtn:SetDown(self.sortBtnDownState[PasterUpgradeSortType.Quality])
    self.sortSkillBtn:SetDown(self.sortBtnDownState[PasterUpgradeSortType.Skill])

    local selectedMap = self.pasterUpgradeModel:GetSelectedMap()
    self.pasterScrollView:InitView(sortModelList, self.cardResourceCache, selectedMap)
end

function PasterUpgradeView:RefreshOriginPaster(pasterData)
    self.pasterUpgradeModel:SetCardPasterData(pasterData)
    self.pasterUpgradeModel:SetFilterMap(nil)
    self.pasterUpgradeModel:InitSelectedMap()
    self:RemoveAllSelectPaster()
    self:RefreshContent()
end

function PasterUpgradeView:OnFilterClick()
    if self.clickFilter then 
        self.clickFilter()
    end
end

function PasterUpgradeView:OnConfirmClick()
    if self.clickConfirm then 
        self.clickConfirm()
    end
end

function PasterUpgradeView:OnHelpClick()
    res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/PasterUpgrade/PasterUpgradeRuleBoard.prefab", "camera", true, true)
end

function PasterUpgradeView:OnFilterConfirmClick(filterMap)
    self.pasterUpgradeModel:SetFilterMap(filterMap)
    self:RefreshContent()
end

function PasterUpgradeView:onDestroy()
    EventSystem.RemoveEvent("PasterUpgrade_UnselectPaster", self, self.UnselectPaster)
    EventSystem.RemoveEvent("PasterUpgrade_SelectPaster", self, self.SelectPaster)
    EventSystem.RemoveEvent("PasterUpgrade_OnFilterConfirmClick", self, self.OnFilterConfirmClick)
    EventSystem.RemoveEvent("CardPastersMapModel_RemovePasterData", self, self.EventRemovePaster)
    EventSystem.RemoveEvent("PasterUpgradeView_RefreshOriginPaster", self, self.RefreshOriginPaster)
end

return PasterUpgradeView
