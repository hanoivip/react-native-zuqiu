local CardTrainingBaseRuleModel = require("ui.models.cardTraining.CardTrainingBaseRuleModel")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local CardTrainingBaseRuleCtrl = class(BaseCtrl)

CardTrainingBaseRuleCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/CardTraining/Prefabs/CardTrainingBaseRuleBoard.prefab"

local TabName = {
    {key = "pattern", text = "card_training_rule_tab1", pos = 1}, 
    {key = "train", text = "card_training_rule_tab2", pos = 2}, 
}

function CardTrainingBaseRuleCtrl:Init(cid)
    self.cid = cid
    self.cardTrainingBaseRuleModel = CardTrainingBaseRuleModel.new(cid)
    self.initMap = {}
end

local DefualtPos = 2
function CardTrainingBaseRuleCtrl:Refresh()
    self.view.menuButtonGroup:CreateMenuItems(
        TabName,
        function(spt, value, index)
            self.view:InitMenuItem(spt, value, index)
        end,
        function(value, index)
            self:OnMenuItemClick(value, index)
        end
    )
    self:OnMenuItemClick(TabName[DefualtPos])
end

function CardTrainingBaseRuleCtrl:OnMenuItemClick(value, index)
    if value.pos == self.selectedTabIndex then
        return
    end
    if not self.initMap[value.key] then
        self.view:OnInitList(value.key, self.cardTrainingBaseRuleModel:GetItemDataList(value.key))
        self.initMap[value.key] = true
    end
    self:SwitchStatus(value)
end

function CardTrainingBaseRuleCtrl:SwitchStatus(value)
    self.view.menuButtonGroup:selectMenuItem(value.pos)
    if self.selectedTabIndex then
        self.view.contentAear[TabName[self.selectedTabIndex].key]:SetActive(false)
    end
    self.view.contentAear[value.key]:SetActive(true)
    self.selectedTabIndex = value.pos
end


return CardTrainingBaseRuleCtrl
