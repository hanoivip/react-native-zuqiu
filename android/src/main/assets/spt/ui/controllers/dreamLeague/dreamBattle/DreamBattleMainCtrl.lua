local DreamBattleMainModel = require("ui.models.dreamLeague.dreamBattle.DreamBattleMainModel")
local DreamConstants = require("ui.scene.dreamLeague.dreamMain.DreamConstants")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local DialogManager = require("ui.control.manager.DialogManager")

local BaseCtrl = require("ui.controllers.BaseCtrl")

local DreamBattleMainCtrl = class(BaseCtrl)

DreamBattleMainCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/DreamLeague/DreamBattle/DreamBattleBoard.prefab"

function DreamBattleMainCtrl:AheadRequest()
    local response = req.dreamLeagueRoomList()
    if api.success(response) then
        local data = response.val
        self.dreamBattleMainModel = DreamBattleMainModel.new()
        self.dreamBattleMainModel:InitWithProtocol(data)
    end
end

function DreamBattleMainCtrl:Init()
    DreamBattleMainCtrl.super.Init(self)
end

function DreamBattleMainCtrl:Refresh(dreamBattleMainModel)
    DreamBattleMainCtrl.super.Refresh(self)
    self.dreamBattleMainModel = dreamBattleMainModel or self.dreamBattleMainModel
    self:InitView()
end

function DreamBattleMainCtrl:RegOnItemClick(data)
    if data.full then
        DialogManager.ShowToastByLang("dream_room_full_count")
        return
    end
    if not data.enterStatus then
        DialogManager.ShowToastByLang("dream_battle_not_open")
        return
    end
    res.PushDialog("ui.controllers.dreamLeague.dreamBattle.DreamBattleRoomInfoCtrl", data)
end

function DreamBattleMainCtrl:InitView()
    self.view.scrollView:RegOnItemButtonClick("enterBtn", function(data) self:RegOnItemClick(data) end)
    self.view.historyScrollView:RegOnItemButtonClick("enterBtn", function(roomData) self:OnHistoryEnterBtnClick(roomData) end)
    self.view.onHistoryBtnClick = function () self:OnHistoryBtnClick() end
    self.view.onRefreshBtnClick = function () self:OnRefreshBtnClick() end
    self.view.onBackBtnClick = function () self:OnBackBtnClick() end
    self.view.onCreateBtnClick = function () self:OnCreateBtnClick() end
    self.view:InitView(self.dreamBattleMainModel)
end

function DreamBattleMainCtrl:RefreshMainView(notNeedConnectServer)
    if notNeedConnectServer then
        self.view:InitView(self.dreamBattleMainModel)
        return
    end
    clr.coroutine(function ()
        local response = req.dreamLeagueRoomList()
        if api.success(response) then
            local data = response.val
            self.dreamBattleMainModel:InitWithProtocol(data)
            self.view:InitView(self.dreamBattleMainModel)
        end
    end)
end

function DreamBattleMainCtrl:OnBackBtnClick()
    self.view:InitMainContent(false)
end

function DreamBattleMainCtrl:OnRefreshBtnClick()
    self:RefreshMainView()
end

function DreamBattleMainCtrl:OnCreateBtnClick()
    if not self.dreamBattleMainModel:IsPlayerLevelSatisfy() then
        DialogManager.ShowToast(lang.trans("dream_create_room_level_limit", self.dreamBattleMainModel:GetPlayerLevelLimit()))
        return
    end
    if not self.dreamBattleMainModel:IsCanCreateRoom() then
        DialogManager.ShowToastByLang("dream_create_room_max")
        return
    end

    clr.coroutine(function ()
        local response = req.dreamLeagueRoomOpen()
        if api.success(response) then
            if response.val.open then
                res.PushDialog("ui.controllers.dreamLeague.dreamBattle.DreamBattleRoomCreateCtrl")
            else
                DialogManager.ShowToastByLang("dream_battle_not_open")
            end
        end
    end)
end

function DreamBattleMainCtrl:OnHistoryBtnClick()
    self.view:InitMainContent(true)
    clr.coroutine(function ()
        local response = req.dreamLeagueRoomRecord()
        if api.success(response) then
            local data = response.val
            self.view.historyScrollView:InitView(data.roomList)
        end
    end)
end

function DreamBattleMainCtrl:ReceiveReward(roomData)
    clr.coroutine(function ()
        local response = req.dreamLeagueRoomReceive(roomData.id)
        if api.success(response) then
            local data = response.val
            CongratulationsPageCtrl.new(data.contents)
            self:OnHistoryBtnClick()
        end
    end)
end

function DreamBattleMainCtrl:OnHistoryEnterBtnClick(roomData)
    if tonumber(roomData.state) == DreamConstants.ResultState.NOT_OPEN then
        local isHistoryPage = true
        res.PushDialog("ui.controllers.dreamLeague.dreamBattle.DreamBattleRoomInfoCtrl", roomData, isHistoryPage)
    end
end

function DreamBattleMainCtrl:GetStatusData()
    return self.dreamBattleMainModel
end

function DreamBattleMainCtrl:OnEnterScene()
    EventSystem.AddEvent("Dream_Battle_Refresh", self, self.RefreshMainView)
end

function DreamBattleMainCtrl:OnExitScene()
    EventSystem.RemoveEvent("Dream_Battle_Refresh", self, self.RefreshMainView)
end

return DreamBattleMainCtrl