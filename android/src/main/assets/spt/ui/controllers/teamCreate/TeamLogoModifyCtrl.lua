local BaseCtrl = require("ui.controllers.BaseCtrl")
local InfoBarCtrl = require("ui.controllers.common.InfoBarCtrl")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local TeamLogoModel = require("ui.models.common.TeamLogoModel")
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local TeamLogoButtonCtrl = require("ui.controllers.teamCreate.TeamLogoButtonCtrl")
local TeamLogoBorderCtrl = require("ui.controllers.teamCreate.TeamLogoBorderCtrl")
local TeamLogoColorCtrl = require("ui.controllers.teamCreate.TeamLogoColorCtrl")
local TeamLogoIconCtrl = require("ui.controllers.teamCreate.TeamLogoIconCtrl")
local TeamLogoRibbonCtrl = require("ui.controllers.teamCreate.TeamLogoRibbonCtrl")
local TeamLogoModifyCtrl = class(BaseCtrl, "TeamLogoModifyCtrl")
local UISoundManager = require("ui.control.manager.UISoundManager")

TeamLogoModifyCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/TeamCreate/Prefab/TeamLogoModify.prefab"

function TeamLogoModifyCtrl:Init()
    self.view:RegOnDynamicLoad(function(child)
        self.infoBarCtrl = InfoBarCtrl.new(child, self)
    end)

    self.view:RegOnSave(function()
        UISoundManager.play("Player/encourageSound", 1)
        self.view:coroutine(function()
            local resp = req.changeTeamLogo(self.currentTeamLogoData)
            if api.success(resp) then
                PlayerInfoModel.new():SetTeamLogo(self.currentTeamLogoData)
                res.PopScene()
            end
        end)
    end)

    self:InitScrollArea()

    self.view:RegOnMenuBorder(function()
        self:SwitchMenu("border")
    end)

    self.view:RegOnMenuColor(function()
        self:SwitchMenu("color")
    end)

    self.view:RegOnMenuIcon(function()
        self:SwitchMenu("icon")
    end)

    self.view:RegOnMenuRibbon(function()
        self:SwitchMenu("ribbon")
    end)
end

function TeamLogoModifyCtrl:InitScrollArea()
    local borderScroll, colorScroll, iconScroll, ribbonScroll = self.view:GetScroll()
    self:InitBorderScrollArea(borderScroll)
    self:InitColorScrollArea(colorScroll)
    self:InitIconScroll(iconScroll)
    self:InitRibbonScrollArea(ribbonScroll)
    borderScroll.enabled = false
end

function TeamLogoModifyCtrl:InitBorderScrollArea(borderScroll)
    borderScroll:regOnCreateItem(function (scrollSelf, index)
        local ctrl = TeamLogoBorderCtrl.new()
        scrollSelf:resetItem(ctrl.view, index)
        ctrl:RegOnButtonClick(function (data)
            if type(self.currentTeamLogoData) ~= "table" then
                self.currentTeamLogoData = {
                    boardId = "Board1",
                    colorId = "13",
                    borderId = "Frame1_1",
                }
            end

            if self.currentTag == "border" then
                self.currentTeamLogoData.borderId = data.borderId
            end
            local teamLogo = TeamLogoCtrl.new()
            teamLogo:Init(self.currentTeamLogoData)
            self.view:SetTeamLogo(teamLogo.view)
            EventSystem.SendEvent("ClickLogoBorder", ctrl.view)
        end)

        return ctrl.view.gameObject
    end)
    borderScroll:regOnResetItem(function (scrollSelf, spt, index)
        spt.ctrl:Init(self.borderData[index] ~= "empty" and self.borderData[index] or nil)
        scrollSelf:updateItemIndex(spt, index)
    end)
end

function TeamLogoModifyCtrl:InitColorScrollArea(colorScroll)
    colorScroll:regOnCreateItem(function (scrollSelf, index)
        local ctrl = TeamLogoColorCtrl.new()
        scrollSelf:resetItem(ctrl.view, index)
        ctrl:RegOnButtonClick(function (data)
            if type(self.currentTeamLogoData) ~= "table" then
                self.currentTeamLogoData = {
                    boardId = "Board1",
                    colorId = "13",
                    borderId = "Frame1_1",
                }
            end

            if self.currentTag == "color" then
                self.currentTeamLogoData.boardId = data.boardId
                self.currentTeamLogoData.colorId = data.colorId
            end
            local teamLogo = TeamLogoCtrl.new()
            teamLogo:Init(self.currentTeamLogoData)
            self.view:SetTeamLogo(teamLogo.view)
            EventSystem.SendEvent("ClickLogoColor", ctrl.view)
        end)

        return ctrl.view.gameObject
    end)
    colorScroll:regOnResetItem(function (scrollSelf, spt, index)
        spt.ctrl:Init(self.colorData[index] ~= "empty" and self.colorData[index] or nil)
        scrollSelf:updateItemIndex(spt, index)
    end)
end

function TeamLogoModifyCtrl:InitIconScroll(iconScroll)
    iconScroll:regOnCreateItem(function (scrollSelf, index)
        local ctrl = TeamLogoIconCtrl.new()
        scrollSelf:resetItem(ctrl.view, index)
        ctrl:RegOnButtonClick(function (data)
            if type(self.currentTeamLogoData) ~= "table" then
                self.currentTeamLogoData = {
                    boardId = "Board1",
                    colorId = "13",
                    borderId = "Frame1_1",
                }
            end

            if self.currentTag == "icon" then
                self.currentTeamLogoData.iconId = data and data.iconId or nil
            end
            local teamLogo = TeamLogoCtrl.new()
            teamLogo:Init(self.currentTeamLogoData)
            self.view:SetTeamLogo(teamLogo.view)
            EventSystem.SendEvent("ClickLogoIcon", ctrl.view)
        end)

        return ctrl.view.gameObject
    end)
    iconScroll:regOnResetItem(function (scrollSelf, spt, index)
        spt.ctrl:Init(self.iconData[index] ~= "empty" and self.iconData[index] or nil)
        scrollSelf:updateItemIndex(spt, index)
    end)
end

function TeamLogoModifyCtrl:InitRibbonScrollArea(ribbonScroll)
    ribbonScroll:regOnCreateItem(function (scrollSelf, index)
        local ctrl = TeamLogoRibbonCtrl.new()
        scrollSelf:resetItem(ctrl.view, index)
        ctrl:RegOnButtonClick(function (data)
            if type(self.currentTeamLogoData) ~= "table" then
                self.currentTeamLogoData = {
                    boardId = "Board1",
                    colorId = "13",
                    borderId = "Frame1_1",
                }
            end

            if self.currentTag == "ribbon" then
                self.currentTeamLogoData.ribbonId = data and data.ribbonId or nil
            end
            local teamLogo = TeamLogoCtrl.new()
            teamLogo:Init(self.currentTeamLogoData)
            self.view:SetTeamLogo(teamLogo.view)
            EventSystem.SendEvent("ClickLogoRibbon", ctrl.view)
        end)

        return ctrl.view.gameObject
    end)
    ribbonScroll:regOnResetItem(function (scrollSelf, spt, index)
        spt.ctrl:Init(self.ribbonData[index] ~= "empty" and self.ribbonData[index] or nil)
        scrollSelf:updateItemIndex(spt, index)
    end)
end

function TeamLogoModifyCtrl:Refresh(tag)
    tag = tag or "border"
    TeamLogoModifyCtrl.super.Refresh(self)
    self:SwitchMenu(tag)
    self.view.buttonGroup:selectMenuItem(tag)

    local playerInfoModel = PlayerInfoModel.new()
    self.currentTeamLogoData = clone(playerInfoModel:GetTeamLogo())
    local teamLogo = TeamLogoCtrl.new()
    teamLogo:Init(self.currentTeamLogoData)
    self.view:SetTeamLogo(teamLogo.view)
end

function TeamLogoModifyCtrl:GetStatusData()
    return self.currentTag
end

function TeamLogoModifyCtrl:SwitchMenu(tag)
    self.currentTag = tag
    local data = {}
    local borderData = {}
    local colorData = {}
    local iconData = {}
    local ribbonData = {}

    if tag == "border" then
        for i, v in ipairs(TeamLogoModel.Border) do
            table.insert(borderData, {borderId = v})
        end
        self.borderData = borderData
        self.view:ShowScrollArea(self.currentTag, borderData)
    elseif tag == "color" then
        for i, boardId in ipairs(TeamLogoModel.Board) do
            local boardData = {borderId = "Frame1_1", boardId = boardId}
            local colors = TeamLogoModel.BoardColorDict[boardId]
            for j, colorId in ipairs(colors) do
                local clonedData = clone(boardData)
                clonedData.colorId = colorId
                table.insert(colorData, clonedData)
            end
        end
        self.colorData = colorData
        self.view:ShowScrollArea(self.currentTag, colorData)
    elseif tag == "icon" then
        table.insert(iconData, "empty")
        for i, v in ipairs(TeamLogoModel.Icon) do
            table.insert(iconData, {iconId = v})
        end
        self.iconData = iconData
        self.view:ShowScrollArea(self.currentTag, iconData)
    elseif tag == "ribbon" then
        table.insert(ribbonData, "empty")
        for i, v in ipairs(TeamLogoModel.Ribbon) do
            table.insert(ribbonData, {ribbonId = v})
        end
        self.ribbonData = ribbonData
        self.view:ShowScrollArea(self.currentTag, ribbonData)
    end
    self.data = data
    self.view:JudgeScrollBarVisibility(self.currentTag)
end

return TeamLogoModifyCtrl
