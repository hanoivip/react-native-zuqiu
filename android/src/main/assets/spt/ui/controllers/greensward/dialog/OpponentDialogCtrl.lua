local MatchLoader = require("coregame.MatchLoader")
local DialogManager = require("ui.control.manager.DialogManager")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local GreenswardDetailCtrl = require("ui.controllers.playerDetail.GreenswardDetailCtrl")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local OpponentDialogCtrl = class(BaseCtrl, "OpponentDialogCtrl")

OpponentDialogCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Dialog/OpponentDialog.prefab"

OpponentDialogCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function OpponentDialogCtrl:AheadRequest(eventModel, greenswardResourceCache)
    local row, col = eventModel:GetRow(), eventModel:GetCol()
    local respone = req.greenswardAdventureOpponent(row, col, nil, nil, true)
    if api.success(respone) then
        local data = respone.val
        self.data = data
        self.view:ShowDetail(eventModel, data)
    elseif respone.msg then
        DialogManager.ShowToast(respone.msg)
    end
end

function OpponentDialogCtrl:GetStatusData()
    return self.eventModel, self.greenswardResourceCache
end

function OpponentDialogCtrl:OnEnterScene()
    self.view:EnterScene()
end

function OpponentDialogCtrl:OnExitScene()
    self.view:ExitScene()
end

function OpponentDialogCtrl:Init(eventModel, greenswardResourceCache)
    self.eventModel = eventModel
    self.greenswardResourceCache = greenswardResourceCache
    self.view.challengeClick = function() self:ChallengeClick() end
    self.view.buyOverClick = function() self:BuyOverClick() end
    self.view.detailClick = function() self:DetailClick() end
    self.view.opponentClick = function() self:OpponentClick() end
    self.view.powerWeaken = function() self:PowerWeaken() end
    self.view.onWeakenOpponent = function() self:OnWeakenOpponent() end
    self.view:InitView(eventModel, greenswardResourceCache)
end

function OpponentDialogCtrl:OpponentClick()
    local row, col = self.eventModel:GetRow(), self.eventModel:GetCol()
    GreenswardDetailCtrl.ShowPlayerDetailView(function() return req.greenswardAdventureOpponentDetail(row, col) end, pid, sid, true)
end

function OpponentDialogCtrl:DetailClick()
    local info = self.data.info
    local floorData = self.eventModel:GetAdventureFloorData()
    local technologyMap = {}
    table.insert(technologyMap, {["TypeName"] = info.grass, ["TechnologyLvl"] = floorData.grassLv})
    table.insert(technologyMap, {["TypeName"] = info.wea, ["TechnologyLvl"] = floorData.weatherLv})
    res.PushDialog("ui.controllers.court.technologyHall.TechnologyDisplayCtrl", technologyMap)
    EventSystem.SendEvent("DisableUpperHierarchy")
end

function OpponentDialogCtrl:ChallengeClick()
    local notEnough = self.eventModel:HasMoraleConsumeNotEnough()
    if not notEnough then
        self.view:coroutine(function()
            local row, col = self.eventModel:GetRow(), self.eventModel:GetCol()
            local respone = req.greenswardAdventureMatch(row, col, "morale")
            if api.success(respone) then
                local data = respone.val
                res.RemoveCurrentSceneDialogsInfo()
                local match = data.ret and data.ret.match or {}
                MatchLoader.startMatch(match)
            end
        end)
    end
end

function OpponentDialogCtrl:BuyOverClick()
    local notEnough = self.eventModel:HasFightConsumeNotEnough()
    if not notEnough then
        local callback = function()
            self.view:coroutine(function()
                local row, col = self.eventModel:GetRow(), self.eventModel:GetCol()
                local respone = req.greenswardAdventureBribe(row, col, "fight")
                if api.success(respone) then
                    local data = respone.val
                    local ret = data.ret or {}
                    local content = ret.contents or {}
                    if next(content) then
                        CongratulationsPageCtrl.new(content)
                    end
                    local buildModel = self.eventModel:GetBuildModel()
                    local stageReward = ret.stageReward
                    if stageReward then
                        local greenswardMatchModel = require("ui.models.greensward.build.GreenswardMatchModel").new()
                        local matchData = {["settlement"] = {["stageReward"] = stageReward}}
                        greenswardMatchModel:InitProtocolData(matchData)
                        res.PushDialog("ui.controllers.greensward.dialog.ChapterRewardCtrl", greenswardMatchModel, buildModel)
                    end

                    -- 下一层通关需要 通关奖励数据
                    local base = data.base or {}
                    local map = data.ret and data.ret.map or {}
                    buildModel:RefreshBaseInfo(base)
                    buildModel:RefreshEventModel(map)
                    self.view:Close()
                end
            end)
        end
        local name = self.eventModel:GetEventName()
        local needPowerNum = self.eventModel:GetConsumeFight()
        local tips = lang.trans("adventure_buyOver_tips", needPowerNum, name)
        DialogManager.ShowConfirmPop(lang.trans("tips"), tips, callback)
    end
end

-- 削弱战力
function OpponentDialogCtrl:PowerWeaken()
    res.PushDialog("ui.controllers.greensward.dialog.WeakenOpponentCtrl", self.eventModel)
end

function OpponentDialogCtrl:OnWeakenOpponent()
    local row, col = self.eventModel:GetRow(), self.eventModel:GetCol()
    self.view:coroutine(function()
        local respone = req.greenswardAdventureOpponent(row, col, nil, nil, true)
        if api.success(respone) then
            local data = respone.val
            self.data = data
            self.view:ShowDetail(self.eventModel, data)
        elseif respone.msg then
            DialogManager.ShowToast(respone.msg)
        end
    end)
end

return OpponentDialogCtrl
