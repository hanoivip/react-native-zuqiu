local ButtonGroup = require("ui.control.button.ButtonGroup")

local AssistantCoachSystemButtonGroupView = class(ButtonGroup, "AssistantCoachSystemButtonGroupView")

function AssistantCoachSystemButtonGroupView:ctor()
    AssistantCoachSystemButtonGroupView.super.ctor(self)
    self.names = self.___ex.names
end

function AssistantCoachSystemButtonGroupView:SetMenuItemName(tag, name)
    local txtName = self.names[tag]
    if txtName then
        txtName.text = name
    end
end

-- 选中指定tag的按钮
function AssistantCoachSystemButtonGroupView:selectMenuItem(tag)
    local menuBtn = self.menu[tag]
    if menuBtn then
        local data = menuBtn:GetData()
        if tag ~= self.currentMenuTag and not data.isLocked then
            if self.currentMenuTag then
                local oldMenuBtn = self.menu[self.currentMenuTag]
                oldMenuBtn:unselectBtn()
                oldMenuBtn:onPointEventHandle(true)
            end
            self.currentMenuTag = tag
            menuBtn:selectBtn()
            menuBtn:onPointEventHandle(false)
        end
    end
end

return AssistantCoachSystemButtonGroupView
