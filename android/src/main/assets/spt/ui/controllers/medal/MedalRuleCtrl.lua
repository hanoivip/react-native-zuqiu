local BaseCtrl = require("ui.controllers.BaseCtrl")
local PeakInfoBarCtrl = require("ui.controllers.peak.PeakInfoBarCtrl")

local MedalRuleCtrl = class(BaseCtrl)

MedalRuleCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Medal/Prefab/MedalRule.prefab"

function MedalRuleCtrl:Init()
    self.view:InitView()
       self.view:RegOnMenuGroup("baseDesc", function ()
        self:SwitchMenu("baseDesc")
    end)
    self.view:RegOnMenuGroup("qualityDesc", function ()
        self:SwitchMenu("qualityDesc")
    end)
    self.view:RegOnMenuGroup("breakDesc", function ()
        self:SwitchMenu("breakDesc")
    end)

    self.view:RegOnDynamicLoad(function (child)
        self.infoBarCtrl = PeakInfoBarCtrl.new(child, self)
        self.infoBarCtrl:RegOnBtnBack(function()
            res.PopScene()
        end)
    end)
end

function MedalRuleCtrl:Refresh()
    self:SwitchMenu("baseDesc")
end

function MedalRuleCtrl:SwitchMenu(tag)
    if tag == "baseDesc" then
        self.view:InitBaseDescView()
    elseif tag == "qualityDesc" then
        self.view:InitQualityDescView()
    elseif tag == "breakDesc" then
        self.view:InitBreakDescView()
    end
end

return MedalRuleCtrl