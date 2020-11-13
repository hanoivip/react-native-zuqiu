local GameObjectHelper = require("ui.common.GameObjectHelper")
local PasterAvailableNode = class(unity.base)

function PasterAvailableNode:ctor()
    self.pasterView = self.___ex.pasterView
    self.btnUse = self.___ex.btnUse
end

function PasterAvailableNode:start()
    self.btnUse:regOnButtonClick(function()
        self:OnUseClick()
    end)
end

function PasterAvailableNode:OnUseClick()
    if self.clickUse then 
        self.clickUse(self.index, self.cardPasterModel)
    end
end

function PasterAvailableNode:InitView(cardPasterModel, pasterRes)
    self.cardPasterModel = cardPasterModel
    self.pasterView:InitView(cardPasterModel, nil, pasterRes)
end

function PasterAvailableNode:UpdateItemIndex(index)
    self.index = index
end

return PasterAvailableNode
