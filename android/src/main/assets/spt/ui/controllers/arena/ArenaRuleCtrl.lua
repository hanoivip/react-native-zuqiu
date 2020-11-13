local ArenaInfoBarCtrl = require("ui.controllers.common.ArenaInfoBarCtrl")
local RuleType = require("ui.scene.arena.RuleType")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local ArenaRuleCtrl = class(BaseCtrl, "ArenaRuleCtrl")

ArenaRuleCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Arena/Prefab/ArenaRule.prefab"

function ArenaRuleCtrl:Init()
    self.view:RegOnDynamicLoad(function (child)
        self.infoBarCtrl = ArenaInfoBarCtrl.new(child, self)
    end)
end

function ArenaRuleCtrl:Refresh(ruleType)
    local selectRule = ruleType or RuleType.ExplainType
    self.view:SwitchPanel(selectRule)
end

function ArenaRuleCtrl:SwitchPanel(tag)
    self.view.menuGroup:selectMenuItem(tag)
end

return ArenaRuleCtrl
