local BaseCtrl = require("ui.controllers.BaseCtrl")
local PeakRuleModel = require("ui.models.peak.PeakRuleModel")
local PeakInfoBarCtrl = require("ui.controllers.peak.PeakInfoBarCtrl")

local PeakRuleCtrl = class(BaseCtrl)

PeakRuleCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Peak/PeakRule.prefab"

function PeakRuleCtrl:Init()
    self.view:InitView(PeakRuleModel.new())
    self.view:RegOnMenuGroup("desc", function ()
        self:SwitchMenu("desc")
    end)
    self.view:RegOnMenuGroup("daily", function ()
        self:SwitchMenu("daily")
    end)
    self.view:RegOnMenuGroup("season", function ()
        self:SwitchMenu("season")
    end)

    self.view:RegOnMenuGroup("score", function ()
        self:SwitchMenu("score")
    end)

    self.view:RegOnDynamicLoad(function (child)
        self.infoBarCtrl = PeakInfoBarCtrl.new(child, self)
        self.infoBarCtrl:RegOnBtnBack(function()
            res.PopScene()
        end)
    end)
end

function PeakRuleCtrl:Refresh()
    PeakRuleCtrl.super.Refresh(self)
    self:SwitchMenu("desc")
end

function PeakRuleCtrl:SwitchMenu(tag)
    if tag == "desc" then
        self.view:InitDescView()
    elseif tag == "daily" then
        self.view:InitDailyRewardView()
    elseif tag == "season" then
        self.view:InitSeasonRewardView()
    elseif tag == "score" then
        self.view:InitScoreView()
    end
end

return PeakRuleCtrl