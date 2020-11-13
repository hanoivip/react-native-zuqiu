local GameObjectHelper = require("ui.common.GameObjectHelper")
local LuaButton = require("ui.control.button.LuaButton")
local CommonConstants = require("ui.common.CommonConstants")
local AssetFinder = require("ui.common.AssetFinder")
local RewardMenuLabelView = class(LuaButton)

function RewardMenuLabelView:ctor()
    RewardMenuLabelView.super.ctor(self)
    self.title = self.___ex.title
    self.title1 = self.___ex.title1
end

function RewardMenuLabelView:Init(title, tag)
    self.title.text = title
    self.title1.text = title
end

function RewardMenuLabelView:InitButtonState()
end

function RewardMenuLabelView:SetRedPoint(showRedPoint)

end

function RewardMenuLabelView:ChangeState(tag)
end

function RewardMenuLabelView:onDestroy()
end

return RewardMenuLabelView

