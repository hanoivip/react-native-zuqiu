local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local GameObjectHelper = require("ui.common.GameObjectHelper")
local ButtonGroup = require("ui.control.button.ButtonGroup")

local CardMemorySelectSortView = class(ButtonGroup, "CardMemorySelectSortView")

function CardMemorySelectSortView:ctor()
    CardMemorySelectSortView.super.ctor(self)
end

function CardMemorySelectSortView:start()
    if type(self.menu) == 'table' then
        for k, v in pairs(self.menu) do
            local menuTag = k
            local menuBtn = v
            v:selectWhenClick()
            v:regOnButtonClick('changeState', function(eventData)
                self:selectMenuItem(menuTag)
            end)
            v:ShowSortOrder(false)
        end
    end
end

function CardMemorySelectSortView:InitView(cardMemorySelectModel)
    self.cardMemorySelectModel = cardMemorySelectModel
end

-- 选中指定tag的按钮
function CardMemorySelectSortView:selectMenuItem(tag)
    local menuBtn = self.menu[tag]
    if menuBtn then
        if tag ~= self.currentMenuTag then
            if self.currentMenuTag then
                local oldMenuBtn = self.menu[self.currentMenuTag]
                oldMenuBtn:unselectBtn()
                oldMenuBtn:ShowSortOrder(false)
            end
            self.currentMenuTag = tag
            menuBtn:selectBtn()
            menuBtn:ShowSortOrder(true)
        end
        menuBtn:SetSortOrder(self.cardMemorySelectModel:GetCurrSortOrder())
    end
end

return CardMemorySelectSortView
