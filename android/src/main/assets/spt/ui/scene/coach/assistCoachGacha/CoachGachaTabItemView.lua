local LuaButton = require("ui.control.button.LuaButton")
local GameObjectHelper = require("ui.common.GameObjectHelper")

local CoachGachaTabItemView = class(LuaButton)

function CoachGachaTabItemView:ctor()
    CoachGachaTabItemView.super.ctor(self)
    self.btnName = self.___ex.btnName
    self:regOnButtonClick(function()
        EventSystem.SendEvent("AssistCoachGachaCtrl_OnTabCkick", self.tabData)
        EventSystem.SendEvent("CoachGachaTabItemView_SetSelectState")
        self:selectBtn()
    end)
end

function CoachGachaTabItemView:InitView(tabData)
    self.tabData = tabData
    self.btnName.text = tabData.name
    self:RegEvent()
end

function CoachGachaTabItemView:RegEvent()
    EventSystem.AddEvent("CoachGachaTabItemView_SetSelectState", self, self.OnSelectStateChange)
    EventSystem.AddEvent("CoachGachaTabItemView_SetSelectStateByIndex", self, self.SetSelectStateByIndex)
end

function CoachGachaTabItemView:UnRegEvent()
    EventSystem.RemoveEvent("CoachGachaTabItemView_SetSelectState", self, self.OnSelectStateChange)
    EventSystem.RemoveEvent("CoachGachaTabItemView_SetSelectStateByIndex", self, self.SetSelectStateByIndex)
end

function CoachGachaTabItemView:OnSelectStateChange(state)
    if state then
        self:selectBtn()
    else
        self:unselectBtn()
    end
end

function CoachGachaTabItemView:OnSelectStateChange(state)
    if state then
        self:selectBtn()
    else
        self:unselectBtn()
    end
end

function CoachGachaTabItemView:SetSelectStateByIndex(index)
    local currIndex = self.tabData.gachaId
    if tonumber(currIndex) == tonumber(index) then
        EventSystem.SendEvent("CoachGachaTabItemView_SetSelectState")
        self:selectBtn()
    end
end

function CoachGachaTabItemView:onDestroy()
    self:UnRegEvent()
end

return CoachGachaTabItemView
