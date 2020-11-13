local GameObjectHelper = require("ui.common.GameObjectHelper")
local EventSystem = require("EventSystem")
local ProgressRewardItemView = class(unity.base)

function ProgressRewardItemView:ctor()
    self.disableObj = self.___ex.disableObj
    self.enableObj = self.___ex.enableObj
    self.getObj = self.___ex.getObj
    self.progressNum = self.___ex.progressNum
    self.btnClick = self.___ex.btnClick
    self.rBarBg = self.___ex.rBarBg
    self.rBar = self.___ex.rBar
end

function ProgressRewardItemView:start()
    EventSystem.AddEvent("ActivityProgressItem_UpdateState", self, self.UpdateState)
    self.btnClick:regOnButtonClick(function()
        self:OpenPopBoard()
    end)
end

function ProgressRewardItemView:InitView(rewardData)
    self.model = rewardData
    self.progressNumber = tonumber(rewardData.count)
    self.nextProgressNumber = tonumber(rewardData.nextCount)
    self.progressNum.text = tostring(rewardData.count)
    self:UpdateState()
end

function ProgressRewardItemView:UpdateState(id)
    if not id then
        GameObjectHelper.FastSetActive(self.disableObj, self.model.status == -1)
        GameObjectHelper.FastSetActive(self.enableObj, self.model.status == 0)
        GameObjectHelper.FastSetActive(self.getObj, self.model.status == 1)
    else
        if tonumber(self.model.count) == tonumber(id) then
            GameObjectHelper.FastSetActive(self.disableObj, false)
            GameObjectHelper.FastSetActive(self.enableObj, false)
            GameObjectHelper.FastSetActive(self.getObj, true)
        end
    end
end

function ProgressRewardItemView:OpenPopBoard()
    if self.onItemClick then
        self.onItemClick()
    end
end

function ProgressRewardItemView:onDestroy()
    EventSystem.RemoveEvent("ActivityProgressItem_UpdateState", self, self.UpdateState)
end

return ProgressRewardItemView