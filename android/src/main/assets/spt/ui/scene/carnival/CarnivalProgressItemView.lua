local GameObjectHelper = require("ui.common.GameObjectHelper")
local CarnivalProgressItemView = class(unity.base)

function CarnivalProgressItemView:ctor()
    self.disableObj = self.___ex.disableObj
    self.enableObj = self.___ex.enableObj
    self.getObj = self.___ex.getObj
    self.progressNum = self.___ex.progressNum
    self.btnEnable = self.___ex.btnEnable
    self.btnDisable = self.___ex.btnDisable
end

function CarnivalProgressItemView:start()
    EventSystem.AddEvent("CarnivalProgressItem.UpdateState", self, self.UpdateState)
    self.btnDisable:regOnButtonClick(function()
        self:OpenPopBoard()
    end)
    self.btnEnable:regOnButtonClick(function()
        self:GetReward()
    end)
end

function CarnivalProgressItemView:InitView(rewardData, playerProgress)
    self.model = rewardData
    self.playerProgress = playerProgress
    self.number = rewardData.condition
    self.progressNum.text = tostring(rewardData.condition)
    self:UpdateState()
end

function CarnivalProgressItemView:UpdateState()
    GameObjectHelper.FastSetActive(self.disableObj, self.model.status == -1)
    GameObjectHelper.FastSetActive(self.enableObj, self.model.status == 0)
    GameObjectHelper.FastSetActive(self.getObj, self.model.status == 1)
end

function CarnivalProgressItemView:OpenPopBoard()
    if self.onItemClick then
        self.onItemClick()
    end
end

function CarnivalProgressItemView:GetReward()
    if self.onItemGetRewardClick then
        self.onItemGetRewardClick()
    end
end

function CarnivalProgressItemView:onDestroy()
    EventSystem.RemoveEvent("CarnivalProgressItem.UpdateState", self, self.UpdateState)
end

return CarnivalProgressItemView