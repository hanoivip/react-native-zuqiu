local Vector3 = clr.UnityEngine.Vector3
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local WorldBossSeverRank = require("data.WorldBossSeverRank")
local WorldBossSingleRank = require("data.WorldBossSingleRank")
local WorldBossRankRuleView = class(unity.base)

function WorldBossRankRuleView:ctor()
    self.closeBtn = self.___ex.closeBtn
    self.scrollView = self.___ex.scrollView
    self.group = self.___ex.group
    self.descText = self.___ex.descText
end

function WorldBossRankRuleView:start()
    self.closeBtn:regOnButtonClick(function ()
        self:Close()
    end)
    DialogAnimation.Appear(self.transform, nil)
end

function WorldBossRankRuleView:InitView(isSelf)
    local ruleList = isSelf and WorldBossSingleRank or WorldBossSeverRank
    self.descText.text = isSelf and lang.trans("worldBossActivity_rank_single_rule") or lang.trans("worldBossActivity_rank_server_rule")
    local index = 1
    for k,v in pairs(ruleList) do
        self:CreateItems(ruleList[tostring(index)])
        index = index + 1
    end
end

function WorldBossRankRuleView:CreateItems(itemData)
    local obj,spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Activties/WorldBossActivity/WorldBossRankRuleItem.prefab")
    obj.transform:SetParent(self.group.transform, true)
    obj.transform.localScale = Vector3.one
    obj.transform.localPosition = Vector3.zero
    obj.transform.localEulerAngles = Vector3.zero
    spt:InitView(itemData)
end

function WorldBossRankRuleView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function ()
            self.closeDialog()
        end)
    end
end

return WorldBossRankRuleView
