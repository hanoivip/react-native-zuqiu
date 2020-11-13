local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local DialogManager = require("ui.control.manager.DialogManager")
local GameObjectHelper = require("ui.common.GameObjectHelper")

local ActivityQuestConditionItemView = class(unity.base)

function ActivityQuestConditionItemView:ctor()
    -- 标题
    self.title = self.___ex.title
    -- 标志
    self.doneIcon = self.___ex.doneIcon
    self.emptytIcon = self.___ex.emptytIcon
    self.underwayIcon = self.___ex.underwayIcon
    --球员头像
    self.cardArea = self.___ex.cardArea
end

function ActivityQuestConditionItemView:InitView(conditionData)
    self.conditionData = conditionData
    self:BuildPage()
end

function ActivityQuestConditionItemView:start()
end

function ActivityQuestConditionItemView:BuildPage()
    local conditionData = {}
    conditionData.id = self.conditionData.id
    conditionData.isFinished = false
    self.title.text = self.conditionData.dec
    GameObjectHelper.FastSetActive(self.emptytIcon, self.conditionData.state == -1)
    GameObjectHelper.FastSetActive(self.underwayIcon, self.conditionData.state == 0)
    GameObjectHelper.FastSetActive(self.doneIcon, self.conditionData.state == 1)
    if self.conditionData.state == 1 then 
        conditionData.isFinished = true
    end
    local obj = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/PlayerLetter/PlayerConditionItem.prefab")
    res.ClearChildren(self.cardArea)
    local viewObj = Object.Instantiate(obj)
    viewObj.transform:SetParent(self.cardArea, false)
    local script = viewObj:GetComponent(clr.CapsUnityLuaBehav)
    script:InitView(conditionData)
    script:SetActivityPlayerLetterOwnState(self.conditionData.state)
end

return ActivityQuestConditionItemView
