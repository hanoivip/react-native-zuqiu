local CompeteChampionWallModel = require("ui.models.compete.championWall.CompeteChampionWallModel")
local CompeteSchedule = require("ui.models.compete.main.CompeteSchedule")
local BaseCtrl = require("ui.controllers.BaseCtrl")

local CompeteChampionWallCtrl = class(BaseCtrl, "CompeteChampionWallCtrl")

CompeteChampionWallCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Compete/ChampionWall/Prefabs/CompeteChampionWall.prefab"

function CompeteChampionWallCtrl:AheadRequest()
    if self.view then
        self.view:ShowDisplayArea(false)
    end

    local response = req.competeGuessChampions()
    if api.success(response) then
        local data = response.val
        if type(data) == "table" then
            if not self.model then
                self.model = CompeteChampionWallModel.new()
            end
            self.model:InitWithProtocol(data)
            self.view:ShowDisplayArea(true)
        end
    end
end

function CompeteChampionWallCtrl:Init()
    CompeteChampionWallCtrl.super.Init(self)

    self.view.onClickBtnBack = function() self:OnClickBtnBack() end
    self.view.onClickTab = function(tag) self:OnClickTab(tag) end
    self.view.onFilterItemChoosed = function(id, filterType) self:OnFilterItemChoosed(id, filterType) end
    self.view.onChampionItemClick = function(itemData) self:OnChampionItemClick(itemData) end
    self.view.onClickBtnOverview = function() self:OnClickBtnOverview() end

    self.view:InitView(self.model)
end

function CompeteChampionWallCtrl:Refresh(currTag, currBigEarGroup, currSmallEarGroup, currFixIdx)
    CompeteChampionWallCtrl.super.Refresh(self)
    if not self.model then
        return
    end
    if currTag == nil then
        currTag = self.model:GetCurrTag() or self.view.menuTags.big_ear
    end
    if currBigEarGroup == nil then
        currBigEarGroup = self.model:GetCurrBigEarGroup()
    end
    if currSmallEarGroup == nil then
        currSmallEarGroup = self.model:GetCurrSmallEarGroup()
    end
    if currFixIdx == nil then
        currFixIdx = self.model:GetCurrFixIdx()
    end
    self.model:SetCurrTag(currTag)
    self.model:SetCurrBigEarGroup(currBigEarGroup)
    self.model:SetCurrSmallEarGroup(currSmallEarGroup)
    self.model:SetCurrFixIdx(currFixIdx)

    self.view:RefreshView()
end

function CompeteChampionWallCtrl:GetStatusData()
    self.model:GetStatusData()
end

function CompeteChampionWallCtrl:OnEnterScene()
    self.view:OnEnterScene()
end

function CompeteChampionWallCtrl:OnExitScene()
    self.view:OnExitScene()
end

-- 事件回调
function CompeteChampionWallCtrl:OnClickBtnBack()
    res.PopScene()
end

function CompeteChampionWallCtrl:OnClickTab(tag)
    if self.model:GetCurrTag() == tag then
        return
    end

    self.model:SetCurrTag(tag)
    if tag == self.view.menuTags.big_ear then
        self:OnClickTabBigEar(tag)
    elseif tag == self.view.menuTags.small_ear then
        self:OnClickTabSmallEar(tag)
    end
end

function CompeteChampionWallCtrl:OnClickTabBigEar(tag)
    self.view:RefreshRightBoardView()
end

function CompeteChampionWallCtrl:OnClickTabSmallEar(tag)
    self.view:RefreshRightBoardView()
end

function CompeteChampionWallCtrl:OnFilterItemChoosed(id, filterType)
    local filterModel = self.model:GetFilterModel()
    self.model:SetCurrGroup(id)
    self.view:RefreshScrollView()
end

-- 点击右侧列表中某项
function CompeteChampionWallCtrl:OnChampionItemClick(itemData)
    local itemDatas = self.model:GetCurrList()
    local oldIdx = self.model:GetCurrIdx()
    local oldFixIdx = self.model:GetCurrFixIdx()
    local newIdx = itemData.idx
    local newFixIdx = itemData.fixIdx
    if newFixIdx ~= oldFixIdx then
        self.model:SetCurrFixIdx(newFixIdx)
        if oldIdx and oldIdx > 0 and self.model:IsItemInCurrList(oldFixIdx) then
            self.view:UpdateScrollItem(oldIdx, self.model:GetItemDataByFixIdx(oldFixIdx))
        end
        if newIdx and newIdx > 0 then
            self.view:UpdateScrollItem(newIdx, self.model:GetItemDataByFixIdx(newFixIdx))
        end
        self.view:RefreshLeftBoadView()
    end
end

-- 点击冠军总览
function CompeteChampionWallCtrl:OnClickBtnOverview()
    res.PushDialog("ui.controllers.compete.championWall.CompeteChampionWallOverviewCtrl", self.model:GetOverviewModel())
end

return CompeteChampionWallCtrl
