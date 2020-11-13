local FancySortModel = require("ui.models.fancy.fancyEntry.FancySortModel")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local BaseCtrl = require("ui.controllers.BaseCtrl")

local FancySortCtrl = class(BaseCtrl, "FancySortCtrl")

FancySortCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Fancy/FancyEntry/FancySort.prefab"

function FancySortCtrl:ctor()
    FancySortCtrl.super.ctor(self)
end

function FancySortCtrl:Init()
    self.model = FancySortModel.new()
    self.view.onClose = function() self:OnBtnBackClick() end
end

function FancySortCtrl:Refresh(scrollPos)
    self.scrollPos = scrollPos
    FancySortCtrl.super.Refresh(self)
    self.view:InitView(self.model, self.scrollPos)
    GuideManager.Show(self)
end

function FancySortCtrl:GetStatusData()
    self.scrollPos = self.view:GetScrollPos()
    return self.scrollPos
end

-- 点击返回按钮
function FancySortCtrl:OnBtnBackClick()
    self.scrollPos = 1
    res.PopScene()
end

return FancySortCtrl
