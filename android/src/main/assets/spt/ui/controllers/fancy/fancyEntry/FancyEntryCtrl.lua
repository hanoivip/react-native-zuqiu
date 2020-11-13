local FancyEntryModel = require("ui.models.fancy.fancyEntry.FancyEntryModel")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local BaseCtrl = require("ui.controllers.BaseCtrl")

local FancyEntryCtrl = class(BaseCtrl, "FancyEntryCtrl")

FancyEntryCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Fancy/FancyEntry/FancyEntry.prefab"

function FancyEntryCtrl:ctor()
    FancyEntryCtrl.super.ctor(self)
end

function FancyEntryCtrl:Init()
    self.model = FancyEntryModel.new()
    GuideManager.InitCurModule("fancy")
end

function FancyEntryCtrl:Refresh(fancyHomeModel)
    FancyEntryCtrl.super.Refresh(self)
    self.view:InitView(self.model)
    GuideManager.Show(self)
end

function FancyEntryCtrl:GetStatusData()
    return self.model
end

-- 点击返回按钮
function FancyEntryCtrl:OnBtnBackClick()
    res.PopScene()
end

return FancyEntryCtrl
