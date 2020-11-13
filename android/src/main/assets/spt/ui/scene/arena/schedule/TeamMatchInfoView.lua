local UnityEngine = clr.UnityEngine
local UI = UnityEngine.UI
local Dropdown = UI.Dropdown
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local GroupType = require("ui.scene.arena.schedule.GroupType")
local TeamMatchInfoView = class(unity.base)

function TeamMatchInfoView:ctor()
    self.dropDown = self.___ex.dropDown
    self.barMap = self.___ex.barMap
    self.btnArrow = self.___ex.btnArrow
    self:Init()
end

function TeamMatchInfoView:start()
    self.btnArrow:regOnButtonClick(function()
        self.dropDown:Show()
    end)
    for k, barView in pairs(self.barMap) do
        local index = tonumber(string.sub(k, 2))
        barView.btnCheck:regOnButtonClick(function()
            self:OnClickCheckFormation(index)
        end)
    end
end

function TeamMatchInfoView:OnClickCheckFormation(index)
    if self.onClickCheckFormation then 
        local playerInfo = self.scoreData[index]
        local id = playerInfo.id
        local sid = playerInfo.sid
        self.onClickCheckFormation(id, sid)
    end
end

function TeamMatchInfoView:InitView(scoreData, arenaScheduleTeamModel, groupIndex)
    self.scoreData = scoreData
    local playerInfoModel = PlayerInfoModel.new()
    local playerId = playerInfoModel:GetID()
    for i, v in ipairs(scoreData) do
        local barView = self.barMap["s" .. i]
        barView:InitView(v, playerId, arenaScheduleTeamModel)
    end
    self.dropDown.value = groupIndex - 1
    self.dropDown:RefreshShownValue()
end

function TeamMatchInfoView:Init()
    self.dropDown.options:Clear()
    for i, group in ipairs(GroupType.Group) do
        local tempData = Dropdown.OptionData()
        tempData.text = lang.trans("group_num", group)
        self.dropDown.options:Add(tempData)
    end

    local ClickDropdown = function(index) -- index 从0
        local groupIndex = index + 1
        EventSystem.SendEvent("ArenaGroupMenuClick", groupIndex)
    end
    self.dropDown.onValueChanged:AddListener(ClickDropdown)
end

return TeamMatchInfoView
