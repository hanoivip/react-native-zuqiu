local BaseCtrl = require("ui.controllers.BaseCtrl")
local UnlockModel = require("ui.models.common.UnlockModel")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local StartGameConstants = require("ui.scene.startGame.StartGameConstants")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local UIBgmManager = require("ui.control.manager.UIBgmManager")
local DialogManager = require("ui.control.manager.DialogManager")
local PlayerNewFunctionModel = require("ui.models.PlayerNewFunctionModel")

local StartGameMainCtrl = class(BaseCtrl)

StartGameMainCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/StartGame/StartGame.prefab"

function StartGameMainCtrl:Init(isPlayAnimation)
    self.unlockModel = UnlockModel.new()
    self.playerInfoModel = PlayerInfoModel.new()
end

function StartGameMainCtrl:Refresh(isPlayAnimation)
    StartGameMainCtrl.super.Refresh(self)
    self:InitView(isPlayAnimation)
    self:RegisterEvent()
end

function StartGameMainCtrl:GetStatusData()
    return true
end

function StartGameMainCtrl:InitView(isPlayAnimation)
    local level = self.playerInfoModel:GetLevel()
    self.unlockModel:SetCurrentLevel(level)
    self.view:InitView(self.unlockModel)
    if isPlayAnimation then
        local loadType = self:GetLoadType()
        if loadType ~= res.LoadType.Pop then
            self.view:PlayMoveInAnim()
        else
            self.view:PlayStayAnim()
        end
    end
end

function StartGameMainCtrl:RegisterEvent()
    self.view:EnterScene()
    EventSystem.AddEvent("StartGame.OnClickViewBtn", self, self.OnClickViewBtn)
end

function StartGameMainCtrl:RemoveEvent()
    self.view:ExitScene()
    EventSystem.RemoveEvent("StartGame.OnClickViewBtn", self, self.OnClickViewBtn)
end

function StartGameMainCtrl:OnClickViewBtn(viewId)
    if viewId == StartGameConstants.ViewConstants.GREENSWARD.VIEW_ID then
        self.view:coroutine(function()
            local response = req.greenswardAdventureIndex()
            if api.success(response) then
                local data = response.val
                local time = tonumber(data.time)
                if time > 0 then
                    local timeStr =  string.convertSecondToTime(tonumber(time))
                    local tips = lang.trans("adventure_start", timeStr)
                    DialogManager.ShowToast(tips)
                    return
                else
                    self.view:CloseImmediate()
                    res.ChangeScene("ui.controllers.greensward.GreenswardMainCtrl")
                    return
                end
            end
        end)
    else
        self.view:CloseImmediate()
        if viewId == StartGameConstants.ViewConstants.QUEST.VIEW_ID then
            clr.coroutine(function()
                unity.waitForEndOfFrame()
                UIBgmManager.play("Quest/questEnter")
                local questPageCtrl = res.PushSceneImmediate("ui.controllers.quest.QuestPageCtrl", nil, nil, nil, true)
                if not GuideManager.GuideIsOnGoing("main") then
                    EventSystem.SendEvent("GuideManager.MainGuideEnd")
                end
                -- 点击主线按钮进入主线页面
                GuideManager.Show(questPageCtrl)
            end)
        elseif viewId == StartGameConstants.ViewConstants.LEAGUE.VIEW_ID then
            UIBgmManager.play("League/leagueEnter")
            self:OpenNewFunction("league")
            require("ui.controllers.league.LeagueCtrl").new()
        elseif viewId == StartGameConstants.ViewConstants.TRAIN.VIEW_ID then
            UIBgmManager.play("Training/trainingEnter")
            self:OpenNewFunction("littleGame")
            res.PushScene("ui.controllers.training.TrainCtrl")
        elseif viewId == StartGameConstants.ViewConstants.LADDER.VIEW_ID then
            UIBgmManager.play("Ladder/ladderEnter")
            self:OpenNewFunction("ladder")
            res.PushScene("ui.controllers.ladder.LadderMainCtrl")
        elseif viewId == StartGameConstants.ViewConstants.ARENA.VIEW_ID then
            self:OpenNewFunction("arena")
            res.PushScene("ui.controllers.arena.ArenaMainCtrl")
        elseif viewId == StartGameConstants.ViewConstants.SPECIAL_QUEST.VIEW_ID then
            self:OpenNewFunction("specific")
            res.PushScene("ui.controllers.specialEvents.SpecialEventsMainCtrl")
        elseif viewId == StartGameConstants.ViewConstants.PEAK.VIEW_ID then
            clr.coroutine(function ()
                local response = req.peakCheckOpen()
                if api.success(response) then
                    local data = response.val
                    if tonumber(data.open) == 1 then
                        self:OpenNewFunction("peak")
                        res.PushScene("ui.controllers.peak.PeakMainCtrl")
                    elseif tonumber(data.open) == 0 then
                        if tonumber(data.nextTime) ~= -1 then
                            DialogManager.ShowToast(lang.trans("peak_next_open", string.formatTimestampBetweenYearAndDay(data.nextTime)))
                        else
                            DialogManager.ShowToast(lang.trans("peak_full_service"))
                        end
                    end
                end
            end)
        elseif viewId == StartGameConstants.ViewConstants.TRANSFORT.VIEW_ID then
            res.PushScene("ui.controllers.transfort.TransportMainCtrl")
        elseif viewId == StartGameConstants.ViewConstants.DREAM.VIEW_ID then
            clr.coroutine(function ()
                local response = req.dreamLeagueMatchOpen()
                if api.success(response) then
                    local data = response.val
                    if data.open then
                        res.PushScene("ui.controllers.dreamLeague.dreamMain.DreamMainCtrl")
                    else
                        DialogManager.ShowToastByLang("dream_is_open_dream_league")
                    end
                end
            end)
        elseif viewId == StartGameConstants.ViewConstants.COMPETE.VIEW_ID then
            local remainTime = self.playerInfoModel:GetCompeteRemainTime()
            if remainTime > 0 then
                local time = string.convertSecondToTimeTrans(remainTime)
                DialogManager.ShowToast(lang.trans("compete_remainTime", time))
            else
                res.PushScene("ui.controllers.compete.main.CompeteMainCtrl")
            end
        elseif viewId == StartGameConstants.ViewConstants.HERO_HALL.VIEW_ID then
            res.PushScene("ui.controllers.heroHall.main.HeroHallMainCtrl")
        elseif viewId == StartGameConstants.ViewConstants.AUCTION.VIEW_ID then
            res.PushScene("ui.controllers.auction.main.AuctionMainCtrl")
        elseif viewId == StartGameConstants.ViewConstants.Fancy.VIEW_ID then
            res.PushScene("ui.controllers.fancy.fancyEntry.FancyEntryCtrl")
        end
    end
end

function StartGameMainCtrl:OnExitScene()
    self:RemoveEvent()
end

function StartGameMainCtrl:OpenNewFunction(functionName)
    local playerNewFunctionList = PlayerNewFunctionModel.new()
    if playerNewFunctionList:IsOpend() then
        if playerNewFunctionList:CheckFirstEnterScene(functionName) then
            clr.coroutine(function()
                local response = req.setEnterSenceList(functionName, 2)
                if api.success(response) then
                    playerNewFunctionList:SetWithProtocol(response.val, functionName)
                end
            end)
        end
    end
end

return StartGameMainCtrl