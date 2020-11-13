local ArenaModel = require("ui.models.arena.ArenaModel")
local ArenaType = require("ui.scene.arena.ArenaType")
local ArenaStateType = require("ui.scene.arena.ArenaStateType")
local ArenaInfoBarCtrl = require("ui.controllers.common.ArenaInfoBarCtrl")
local ArenaScheduleTeamModel = require("ui.models.arena.schedule.ArenaScheduleTeamModel")
local ArenaPlayerTeamsModel = require("ui.models.arena.formation.ArenaPlayerTeamsModel")
local DialogManager = require("ui.control.manager.DialogManager")
local FormationConstants = require("ui.scene.formation.FormationConstants")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local ArenaMainCtrl = class(BaseCtrl, "CourtMainCtrl")
local ArenaRankConstants = require("ui.scene.arena.rank.ArenaRankConstants")
local ArenaRankModel = require("ui.models.arena.rank.ArenaRankModel")

ArenaMainCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Arena/Prefab/Arena.prefab"

function ArenaMainCtrl:Init()
    self.view:RegOnDynamicLoad(function (child)
        self.infoBarCtrl = ArenaInfoBarCtrl.new(child, self)
        self.infoBarCtrl:RegOnBtnBack(function()
            res.PushScene("ui.controllers.home.HomeMainCtrl")
        end)
    end)

    self.view.clickState = function(arenaType, state) self:OnClickState(arenaType, state) end
    self.view.clickStage = function(arenaType) self:OnClickStage(arenaType) end
    self.view.refresh = function(arenaType) self:ManualRefresh(arenaType) end
    self.view.clickFormation = function(arenaType) self:OnClickFormation(arenaType) end

    self.view.clickRank = function() self:OnClickRank() end
    self.view.clickStories = function() self:OnClickStories() end
    self.view.clickStore = function() self:OnClickStore() end
    self.view.clickHonor = function() self:OnClickHonor() end
    self.view.clickRule = function() self:OnClickRule() end
end

function ArenaMainCtrl:OnClickRule()
    res.PushScene("ui.controllers.arena.ArenaRuleCtrl")
end

-- 菜单按钮
function ArenaMainCtrl:OnClickRank()
    clr.coroutine(function()
        local respone = req.arenaRankInfo(ArenaRankConstants.Zone.Silver, ArenaRankConstants.Type.Server)
        if api.success(respone) then
            local data = respone.val
            if data then
                local aranaRankModel = ArenaRankModel.new()
                aranaRankModel:InitPlayerRankInfo(self.arenaModel)
                aranaRankModel:InitWithProtocol(data)
                res.PushScene("ui.controllers.arena.rank.ArenaRankMainCtrl", aranaRankModel, self.arenaModel)
            end
        end
    end)
end

function ArenaMainCtrl:OnClickStories()
    DialogManager.ShowToast(lang.trans("functionNotOpen"))
end

function ArenaMainCtrl:OnClickStore()
    res.PushScene("ui.controllers.arena.store.ArenaStoreCtrl")
end

function ArenaMainCtrl:OnClickHonor()
    res.PushScene("ui.controllers.arena.honor.HonorCtrl")
end

function ArenaMainCtrl:OnEnterScene()
    self.view:OnEnterScene()
end

function ArenaMainCtrl:OnExitScene()
    self.view:OnExitScene()
end

function ArenaMainCtrl:ManualRefresh(arenaType)
    self:Refresh()
end

function ArenaMainCtrl:OnClickStage(arenaType)
    EventSystem.SendEvent("ArenaStageClick", arenaType)
end

function ArenaMainCtrl:OnShowGeneralBox(titleText, contentText, button1Text, button2Text, callback) 
    local content = { }
    content.title = titleText
    content.content = contentText
    content.button1Text = button1Text
    content.button2Text = button2Text
    content.onButton2Clicked = function()
        callback()
    end
    local resDlg, dialogcomp = res.ShowDialog('Assets/CapstonesRes/Game/UI/Control/Dialog/GeneralBox.prefab', 'overlay', true, true, nil, nil, 10000)
    dialogcomp.contentcomp:initData(content)
end

local SignCancelTime = "21:55"
function ArenaMainCtrl:OnClickState(arenaType, state)
    if state == ArenaStateType.RegistType then 
        local callback = function() 
            clr.coroutine(function()
                local response = req.arenaSign(arenaType)
                if api.success(response) then
                    local data = response.val
                    self.arenaModel:SetSign(data.isSign, data.zone, data.cd)
                    EventSystem.SendEvent("ArenaStateChange", self.arenaModel)
                    -- 只在报名或者取消报名才会更新队伍数据
                    ArenaScheduleTeamModel.ClearInstance()
                end
            end)
        end
        local titleText = lang.trans("arena_sign_title")
        local contentText = lang.trans("arena_sign_content")
        local button2Text = lang.trans("regist")
        self:OnShowGeneralBox(titleText, contentText, nil, button2Text, callback) 
    elseif state == ArenaStateType.AllotType then 
        local callback = function() 
            clr.coroutine(function()
                local response = req.arenaUnsign(arenaType)
                if api.success(response) then
                    local data = response.val
                    self.arenaModel:SetUnSign(data.isSign, data.zone)
                    EventSystem.SendEvent("ArenaStateChange", self.arenaModel)
                    -- 只在报名或者取消报名才会更新队伍数据
                    ArenaScheduleTeamModel.ClearInstance()
                end
            end)
        end
        local titleText = lang.trans("regist_cancel")
        local arenaDesc = lang.transstr(arenaType .. "_arena")
        local contentText = lang.transstr("regist_cancel_content", arenaDesc, SignCancelTime)
        local button2Text = lang.trans("regist_cancel")
        self:OnShowGeneralBox(titleText, contentText, nil, button2Text, callback) 
    elseif state == ArenaStateType.MatchType then 
        if self.arenaModel:IsMatchValid(arenaType) then -- 加入赛程过期判断
            local isFirst = self.arenaModel:IsFirstGroup(arenaType)
            if isFirst then 
                res.PushScene("ui.controllers.arena.ArenaAllotTeamCtrl", arenaType)
            else
                res.PushScene("ui.controllers.arena.schedule.ArenaScheduleCtrl", arenaType, true)
            end
        else
            res.PushScene("ui.controllers.arena.schedule.ArenaScheduleCtrl", arenaType, true)
        end
    elseif state == ArenaStateType.OccupyType then 
        DialogManager.ShowToast(lang.trans("occupy_tip"))
    end
end

function ArenaMainCtrl:Refresh()
    ArenaMainCtrl.super.Refresh(self)
    clr.coroutine(function()
        local response = req.arenaInfo()
        if api.success(response) then
            local data = response.val
            self.arenaModel = ArenaModel.new()
            self.arenaModel:InitWithProtocol(data)
            self.view:InitView(self.arenaModel)
        end
    end)
end

function ArenaMainCtrl:OnClickFormation(arenaType)
    clr.coroutine(function()
        local respone = req.arenaGetTeam(arenaType)
        if api.success(respone) then
            local data = respone.val
            local matchArenaType = self.arenaModel:GetMatchArena(arenaType)
            local arenaPlayerTeamsModel = ArenaPlayerTeamsModel.new(arenaType, matchArenaType, self.arenaModel)
            arenaPlayerTeamsModel:InitWithProtocol(data)
			arenaPlayerTeamsModel:SetCourtTeamType(FormationConstants.TeamType.ARENA)
            arenaPlayerTeamsModel:SetTeamType(arenaType)
            res.PushScene("ui.controllers.arena.formation.ArenaFormationPageCtrl", arenaPlayerTeamsModel)
        end
    end)
end

return ArenaMainCtrl
