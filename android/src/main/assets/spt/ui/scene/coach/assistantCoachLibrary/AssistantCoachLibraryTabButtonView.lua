local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local GameObjectHelper = require("ui.common.GameObjectHelper")
local LuaButton = require("ui.control.button.LuaButton")

local AssistantCoachLibraryTabButtonView = class(LuaButton, "AssistantCoachLibraryTabButtonView")

function AssistantCoachLibraryTabButtonView:ctor()
    AssistantCoachLibraryTabButtonView.super.ctor(self)
    self.upArrow = self.___ex.upArrow
    self.upArrowDown = self.___ex.upArrowDown
    self.downArrow = self.___ex.downArrow
    self.downArrowDown = self.___ex.downArrowDown
    self.tagName = self.___ex.tag
end

function AssistantCoachLibraryTabButtonView:InitView(parentModel)
    self.model = parentModel
end

function AssistantCoachLibraryTabButtonView:selectBtn()
    AssistantCoachLibraryTabButtonView.super.selectBtn(self)
    if type(self.select) == 'table' then
        local tabOrder = self.model:GetTabOrder()
        GameObjectHelper.FastSetActive(self.upArrowDown.gameObject, tabOrder)
        GameObjectHelper.FastSetActive(self.downArrowDown.gameObject, not tabOrder)
        self:SetTagActivate(false)
    end
end

function AssistantCoachLibraryTabButtonView:SetTagActivate(isShow)
    GameObjectHelper.FastSetActive(self.tagName.gameObject, isShow)
end

return AssistantCoachLibraryTabButtonView
