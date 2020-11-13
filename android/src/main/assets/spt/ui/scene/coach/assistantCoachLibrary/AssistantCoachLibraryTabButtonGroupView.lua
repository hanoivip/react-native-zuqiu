local ButtonGroup = require("ui.control.button.ButtonGroup")

local AssistantCoachLibraryTabButtonGroupView = class(ButtonGroup, "AssistantCoachLibraryTabButtonGroupView")

function AssistantCoachLibraryTabButtonGroupView:ctor()
    AssistantCoachLibraryTabButtonGroupView.super.ctor(self)
end

function AssistantCoachLibraryTabButtonGroupView:InitView(parentModel)
    self.model = parentModel
    for tag, menuBtn in pairs(self.menu) do
        menuBtn:InitView(self.model)
        menuBtn:setMultiClickEnabled(true)
    end
    self:selectMenuItem(self.model:GetTabTag())
end

-- 选中指定tag的按钮
function AssistantCoachLibraryTabButtonGroupView:selectMenuItem(tag)
    local oldMenuBtn
    local menuBtn = self.menu[tag]
    if menuBtn then
        if self.currentMenuTag then
            local oldMenuBtn = self.menu[self.currentMenuTag]
            oldMenuBtn:unselectBtn()
            oldMenuBtn:SetTagActivate(true)
        end
        self.currentMenuTag = tag
        menuBtn:selectBtn()
    end
end

return AssistantCoachLibraryTabButtonGroupView
