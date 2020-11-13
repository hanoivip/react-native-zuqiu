local ActivityParentView = require("ui.scene.activity.content.ActivityParentView")
local CardBuilder = require("ui.common.card.CardBuilder")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")

local TimeLimitLeagueLetterItemView = class(ActivityParentView, "TimeLimitLeagueLetterItemView")

function TimeLimitLeagueLetterItemView:ctor()
    self.cardContainer = self.___ex.cardContainer
    self.info = self.___ex.info
    self.finish = self.___ex.finish
    self.underway = self.___ex.underway
    self.nothave = self.___ex.nothave
    self.btnCard = self.___ex.btnCard
end

function TimeLimitLeagueLetterItemView:InitView(itemData)
    self.itemData = itemData

    -- 球员头像
    local conditionData = {}
    conditionData.id = self.itemData.id
    conditionData.isFinished = (self.itemData.state == 1)
    local prefabRes = "Assets/CapstonesRes/Game/UI/Scene/PlayerLetter/PlayerConditionItem.prefab"
    res.ClearChildren(self.cardContainer)
    local obj, spt = res.Instantiate(prefabRes)
    obj.transform:SetParent(self.cardContainer, false)
    spt:InitView(conditionData)
    spt:SetActivityPlayerLetterOwnState(self.itemData.state)

    -- 描述
    self.info.text = self.itemData.desc

    -- 完成状态
    GameObjectHelper.FastSetActive(self.nothave, self.itemData.state == -1)
    GameObjectHelper.FastSetActive(self.underway, self.itemData.state == 0)
    GameObjectHelper.FastSetActive(self.finish, self.itemData.state == 1)
end

return TimeLimitLeagueLetterItemView