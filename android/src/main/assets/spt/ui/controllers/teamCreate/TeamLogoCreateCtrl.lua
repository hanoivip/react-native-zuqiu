local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local WaitForSeconds = UnityEngine.WaitForSeconds
local BaseCtrl = require("ui.controllers.BaseCtrl")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local TeamLogoModel = require("ui.models.common.TeamLogoModel")
local TeamLogoButtonCtrl = require("ui.controllers.teamCreate.TeamLogoButtonCtrl")
local ClubNameGenerate = require("data.ClubNameGenerate")
local DialogManager = require("ui.control.manager.DialogManager")
local TeamLogoCreateCtrl = class(BaseCtrl, "TeamLogoCreateCtrl")

TeamLogoCreateCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/TeamCreate/Prefab/TeamLogoCreate.prefab"

local isAllRandom = false

function TeamLogoCreateCtrl:Init()
    self.view:RegOnRandomLogoClick(function (eventData)
        if isAllRandom then
            self.currentTeamLogoData = nil
            self.currentTeamLogoCtrl = nil
            local teamLogos = self:GenerateTeamLogoAllRandom()
            self.view:InitView(teamLogos)
        else
            if type(self.currentTeamLogoData) == "table" then
                self.currentTeamLogoData = nil
                self.currentTeamLogoCtrl = nil
                self.teamLogoButtonCtrl:StopAnimation()
            end

            local teamLogoData = self:RandomTeamLogoData()
            self.view:SetTouchMask(true)
            self.teamLogoButtonCtrl:PlayDisappearAnimation()
            self.view:coroutine(function()
                coroutine.yield(WaitForSeconds(0.66))
                self.teamLogoButtonCtrl:Init(teamLogoData)
                self.teamLogoButtonCtrl:PlayAppearAnimation()
                self.view:SetTouchMask(false)
            end)
            --[[
            self.teamLogoButtonCtrl:Init(teamLogoData)
            self.teamLogoButtonCtrl:PlayAppearAnimationWithImageOnly()
            --]]
        end
    end)
    self.view:RegOnConfirmBtnClick(function (eventData)
        local teamLogoCtrl = self.currentTeamLogoCtrl
        local data = self.currentTeamLogoData
        if teamLogoCtrl and data then
            clr.coroutine(function ()
                local playerInfoModel = PlayerInfoModel.new()
                local response
                if type(data) == "table" then
                    response = req.setTeamLogo(data)
                    if api.success(response) then
                        local logo = {
                            boardId = data.boardId,
                            colorId = data.colorId,
                            figureId = data.iconId,
                            frameId = data.borderId,
                            ribbonId = data.ribbonId,
                        }
                        playerInfoModel:SetTeamLogo(logo)
                        playerInfoModel:ClearTeamUniform()
                        self:DoSelectAnimation(teamLogoCtrl)
                    end
                else
                    response = req.setTeamLogo(data)
                    if api.success(response) then
                        playerInfoModel:SetTeamLogo(data)
                        playerInfoModel:ClearTeamUniform()
                        self:DoSelectAnimation(teamLogoCtrl)
                    end
                end
                luaevt.trig("HoolaiBISendCounterTask", 13)
                luaevt.trig("SendBIReport", "logo", "25")
                luaevt.trig("HoolaiBISendGameinfo", "logo", "25")
            end)
        else
            DialogManager.ShowToastByLang("team_logo_empty_warning")
        end
    end)
    self.view:RegOnBackBtnClick(function (eventData)
        self.exitFunc = function ()
            local lastSceneData = res.ctrlStack[#res.ctrlStack]
            local ctrlPath = "ui.controllers.login.LoginCtrl"
            if lastSceneData.path == ctrlPath then
                res.PopSceneWithoutCurrent()
            else
                res.ChangeScene(ctrlPath)
            end
        end
        self.view:DoExitSceneAnimation()
    end)
    self.view:RegOnExitScene(function ()
        if type(self.exitFunc) == "function" then
            self.exitFunc()
        end
    end)
end

function TeamLogoCreateCtrl:Refresh()
    TeamLogoCreateCtrl.super.Refresh(self)
    local playerInfoModel = PlayerInfoModel.new()
    local teamLogos = self:GenerateTeamLogos()
    self.view:InitView(teamLogos)
end

function TeamLogoCreateCtrl:GetStatusData()
    return nil
end

function TeamLogoCreateCtrl:OnEnterScene()
    self.view:DoEnterSceneAnimation()
end

function TeamLogoCreateCtrl:GenerateTeamLogo(teamLogoData, isShowBase)
    local teamLogoCtrl = TeamLogoButtonCtrl.new()
    teamLogoCtrl:Init(teamLogoData, isShowBase)
    teamLogoCtrl:RegOnButtonClick(function (data)
        self:OnLogoSelect(teamLogoCtrl, data)
    end)
    return teamLogoCtrl
end

function TeamLogoCreateCtrl:GenerateTeamLogoAllRandom()
    local teamLogos = {}
    for i = 1, 15 do
        local teamLogoData = self:RandomTeamLogoData()
        local teamLogoCtrl = self:GenerateTeamLogo(teamLogoData, isShowBase)
        table.insert(teamLogos, teamLogoCtrl.view)
    end
    return teamLogos
end

function TeamLogoCreateCtrl:GenerateTeamLogos()
    local teamLogos
    if isAllRandom then
        teamLogos = self:GenerateTeamLogoAllRandom()
    else
        teamLogos = self:GenerateDefaultTeamLogos()
        local teamLogoData = self:RandomTeamLogoData()
        self.teamLogoButtonCtrl = self:GenerateTeamLogo(teamLogoData)
        table.insert(teamLogos, self.teamLogoButtonCtrl.view)
    end
    return teamLogos
end

function TeamLogoCreateCtrl:GenerateDefaultTeamLogos()
    local teamLogos = {}
    for i, v in ipairs(TeamLogoModel.InitTeamLogos) do
         local teamLogoCtrl = nil
        if i ~= 15 then
            teamLogoCtrl = self:GenerateTeamLogo(v.id, true)
        else
            teamLogoCtrl = self:GenerateTeamLogo(v.id, false)
        end
        table.insert(teamLogos, teamLogoCtrl.view)
    end
    return teamLogos
end

function TeamLogoCreateCtrl:OnLogoSelect(teamLogoCtrl, data)
    if self.currentTeamLogoCtrl == teamLogoCtrl and self.currentTeamLogoData == data then
        return
    end
    if self.currentTeamLogoCtrl then
        self.currentTeamLogoCtrl:StopAnimation()
    end
    self.currentTeamLogoCtrl = teamLogoCtrl
    self.currentTeamLogoData = data
    teamLogoCtrl:PlaySelectAnimation()
end

function TeamLogoCreateCtrl:DoSelectAnimation(teamLogoCtrl)
    self.view:SetTouchMask(true)
    self.exitFunc = function ()
        self.view:SetTouchMask(false)
        res.ChangeScene("ui.controllers.teamCreate.TeamUniformCtrl")
    end

    self.view:DoExitSceneAnimation()
end

function TeamLogoCreateCtrl:RandomTeamLogoData()
    local boardRandomNumber = math.random(1, #TeamLogoModel.Board)
    local borderRandomNumber = math.random(1, #TeamLogoModel.Border)
    local iconRandomNumber = math.random(0, #TeamLogoModel.Icon)
    local ribbonRandomNumber = math.random(0, #TeamLogoModel.Ribbon)
    local data = {
        boardId = TeamLogoModel.Board[boardRandomNumber],
        borderId = TeamLogoModel.Border[borderRandomNumber],
        iconId = TeamLogoModel.Icon[iconRandomNumber],
        ribbonId = TeamLogoModel.Ribbon[ribbonRandomNumber],
    }
    local boardColorRandomNumber = math.random(1, #TeamLogoModel.BoardColorDict[data.boardId])
    data.colorId = TeamLogoModel.BoardColorDict[data.boardId][boardColorRandomNumber]
    return data
end

return TeamLogoCreateCtrl

