local BaseCtrl = require("ui.controllers.BaseCtrl")
local DreamRuleModel = require("ui.models.dreamLeague.dreamRule.DreamRuleModel")

local DreamRuleCtrl = class(BaseCtrl, "DreamRuleCtrl")

DreamRuleCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/DreamLeague/DreamRule/DreamRule.prefab"

function DreamRuleCtrl:Init()
    self.model = DreamRuleModel.new()
    self.view:InitView(self.model)
    
    self.view:RegOnMenuGroup("MainDesc", function ()
        self:SwitchMenu("MainDesc")
    end)
    self.view:RegOnMenuGroup("Cards", function ()
        self:SwitchMenu("Cards")
    end)
    self.view:RegOnMenuGroup("Hall", function ()
        self:SwitchMenu("Hall")
    end)
    self.view:RegOnMenuGroup("MVPGuess", function ()
        self:SwitchMenu("MVPGuess")
    end)
    self.view:RegOnMenuGroup("DailyReward", function ()
        self:SwitchMenu("DailyReward")
    end)
    self.view:RegOnMenuGroup("RankReward", function ()
        self:SwitchMenu("RankReward")
    end)
end

function DreamRuleCtrl:Refresh()
    DreamRuleCtrl.super.Refresh(self)
    self:SwitchMenu("MainDesc")
end

function DreamRuleCtrl:SwitchMenu(tag)
    if tag == "MainDesc" then
        self.view:InitMainDescView()
    elseif tag == "Cards" then
        self.view:InitCardsView()
    elseif tag == "Hall" then
        self.view:InitHallView()
    elseif tag == "MVPGuess" then
        self.view:InitMVPGuessView()
    elseif tag == "DailyReward" then
        self.view:InitDailyRewardView()
    elseif tag == "RankReward" then
        self.view:InitRankRewardView()
    end
end

return DreamRuleCtrl