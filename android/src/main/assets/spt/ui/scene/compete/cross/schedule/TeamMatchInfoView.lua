local UnityEngine = clr.UnityEngine
local UI = UnityEngine.UI
local Dropdown = UI.Dropdown
local CompeteEnumHelper = require("ui.scene.compete.cross.CompeteEnumHelper")
local TeamMatchInfoView = class(unity.base)

function TeamMatchInfoView:ctor()
    self.dropDown = self.___ex.dropDown
    self.barMap = self.___ex.barMap
    self.btnArrow = self.___ex.btnArrow
    self:Init()
end

function TeamMatchInfoView:start()
    self.btnArrow:regOnButtonClick(function()
        self.dropDown.Show()  --Lua assist checked flag
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
        local id = playerInfo.pid
        local sid = playerInfo.sid
        self.onClickCheckFormation(id, sid)
    end
end

function TeamMatchInfoView:InitView(scoreData, scheduleModel, groupIndex)
    self.scoreData = scoreData
    local playerId = scheduleModel:GetPlayerRoleId()
    for i, v in ipairs(scoreData) do
        local barView = self.barMap["s" .. i]
		if barView then 
			barView:InitView(v, playerId, scheduleModel)
		end
    end
    self.dropDown.value = groupIndex - 1
    self.dropDown:RefreshShownValue()
end

function TeamMatchInfoView:Init()
    self.dropDown.options:Clear()
    for i, group in ipairs(CompeteEnumHelper.ShortScoreSymbol) do
        local tempData = Dropdown.OptionData()
        tempData.text = lang.trans("group_num", group)
        self.dropDown.options:Add(tempData)
    end

    local ClickDropdown = function(index) -- index 从0
        local groupIndex = index + 1
        EventSystem.SendEvent("CompeteGroupMenuClick", groupIndex)
    end
    self.dropDown.onValueChanged:AddListener(ClickDropdown)
end

return TeamMatchInfoView
