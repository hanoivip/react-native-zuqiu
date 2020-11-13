local BaseCtrl = require("ui.controllers.BaseCtrl")
local HonorPalaceModel = require("ui.models.honorPalace.HonorPalaceModel")
local HonorPalaceItemModel = require("ui.models.honorPalace.HonorPalaceItemModel")
local TrophyRoomCtrl = require("ui.controllers.honorPalace.TrophyRoomCtrl")
local AchieveTag = require("ui.controllers.honorPalace.AchieveTag")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local TAG_MAP = {
    [AchieveTag.MAIN] = "Main",
    [AchieveTag.LEAGUE] = "League",
    [AchieveTag.GUILD] = "Guild",
    [AchieveTag.TRAINING] = "LittleGame",
    [AchieveTag.CARDCOLLECTION] = "Collection",
    [AchieveTag.FRIEND] = "Friend",
    [AchieveTag.OTHER] = "Other",
    [AchieveTag.FOOTBALLHALL] = "FootballHall",
    [AchieveTag.COACH] = "Coach",
    [AchieveTag.SHOWALL] = "ShowAll"
}

local HonorPalaceCtrl = class(BaseCtrl)
HonorPalaceCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/HonorPalace/HonorPalace.prefab"

function HonorPalaceCtrl:Refresh()
    HonorPalaceCtrl.super.Refresh(self)
    self:InitAll()
end

function HonorPalaceCtrl:AheadRequest()
    local response = req.honorInfo()
    if api.success(response) then
        local data = response.val
        self.honorPalaceModel = HonorPalaceModel.new()
        self.honorPalaceModel:InitWithProtocol(data)
    end
end

function HonorPalaceCtrl:Init()
end

function HonorPalaceCtrl:RefreshHonorView()
    local response = req.honorInfo()
    if api.success(response) then
        local data = response.val
        self.honorPalaceModel = HonorPalaceModel.new()
        self.honorPalaceModel:InitWithProtocol(data)
        self:InitAll()
    end
end

function HonorPalaceCtrl:InitAll()
    self.view.clickBack = function() self:OnBtnBack() end
    self.currentTaskType = AchieveTag.SHOWALL
    self.view.clickTaskType = function(taskType)
        if taskType == self.currentTaskType then return end
        self.currentTaskType = taskType
        self:ShowHonorPalaceItemList(self.honorPalaceModel:InitAchieveListByTag(TAG_MAP[taskType]))
    end
    self.view.trophyCollect = function(trophyID) self:OnReceiveClick(trophyID) end
    self.view.trophyCollectCallBack = function(trophyID)
        self:InitView()
    end
    self.view.showTrophyRoom = function() self:ShowTrophyView() end
    local pos = self.view.rewardScrollView:GetScrollNormalizedPosition()
    self.view.scrollPos = pos
    self:InitView()
end

function HonorPalaceCtrl:InitView()
    self.view:InitView(self.honorPalaceModel)
    self:ShowHonorPalaceItemList(self.honorPalaceModel:InitAchieveListByTag(TAG_MAP[self.currentTaskType]))
end

function HonorPalaceCtrl:OnBtnBack()
    res.PopScene()
end

function HonorPalaceCtrl:ShowTrophyView()
    local trophyRoomCtrl = TrophyRoomCtrl.new()
    trophyRoomCtrl:InitView(self.honorPalaceModel)
end

function HonorPalaceCtrl:ShowHonorPalaceItemList(achieveList)
    self.view:coroutine(function()
        unity.waitForNextEndOfFrame()
        self.view:RefreshView(achieveList)
    end)
end

function HonorPalaceCtrl:OnReceiveClick(trophyID)
    clr.coroutine(function()
        local response = req.honorReceive(trophyID)
        if api.success(response) then
            EventSystem.SendEvent("Refresh_Honor_View")
            EventSystem.SendEvent("HonorPalaceView.EventTrophyCollect", trophyID)

			local Honor = require("data.Honor")
			local trophyDesc = Honor[tostring(trophyID)].desc
            local server = cache.getCurrentServer()
            local serverCode = server.id
            local serverName = server.name
            local playerInfoModel = require("ui.models.PlayerInfoModel").new()
            local roleId = playerInfoModel:GetID()
            local roleName = playerInfoModel:GetName()
            local roleLvl = playerInfoModel:GetLevel()
			luaevt.trig("SDK_Report", "unlock_achievement", trophyDesc, serverCode, serverName, roleId, roleName, roleLvl)
        end
    end)
end

function HonorPalaceCtrl:OnEnterScene()
    self.view:RegisterEvent()
    EventSystem.AddEvent("Refresh_Honor_View", self, self.RefreshHonorView)
end

function HonorPalaceCtrl:OnExitScene()
    EventSystem.RemoveEvent("Refresh_Honor_View", self, self.RefreshHonorView)
    self.view:RemoveEvent()
end

return HonorPalaceCtrl