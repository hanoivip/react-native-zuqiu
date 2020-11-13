local BaseCtrl = require("ui.controllers.BaseCtrl")
local InfoBarCtrl = require("ui.controllers.common.InfoBarCtrl")

local TransportRuleCtrl = class(BaseCtrl)

TransportRuleCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Transfort/TransportRule.prefab"

function TransportRuleCtrl:Init()
    self.view:RegOnMenuGroup("basic", function ()
        self:SwitchMenu("basic")
    end)
    self.view:RegOnMenuGroup("sponsor", function ()
        self:SwitchMenu("sponsor")
    end)
    self.view:RegOnMenuGroup("rule", function ()
        self:SwitchMenu("rule")
    end)

    self.view:RegOnDynamicLoad(function (child)
        self.infoBarCtrl = InfoBarCtrl.new(child, self)
        self.infoBarCtrl:RegOnBtnBack(function()
            res.PopScene()
        end)
    end)
end

function TransportRuleCtrl:Refresh()
    TransportRuleCtrl.super.Refresh(self)
    self:SwitchMenu("basic")
end

function TransportRuleCtrl:SwitchMenu(tag)
    if tag == "basic" then
        self.view:InitBasicDescView()
    elseif tag == "sponsor" then
        self.view:InitSponsorDescView()
    elseif tag == "rule" then
        self.view:InitRuleDescView()
    end
end

return TransportRuleCtrl