local GameObjectHelper = require("ui.common.GameObjectHelper")
local HonorGroupView = class(unity.base)

function HonorGroupView:ctor()
    self.bar1 = self.___ex.bar1
    self.bar2 = self.___ex.bar2
    self.bar1.clickReward = function(id) self:OnclickReward(id) end
    self.bar2.clickReward = function(id) self:OnclickReward(id) end
end

function HonorGroupView:OnclickReward(id) 
    if self.clickReward then
        self.clickReward(id)
    end
end

function HonorGroupView:ShowReward(barData, barView, arenaModel, arenaHonorModel)
    if barData then 
        barView:InitView(barData, arenaModel, arenaHonorModel)
    end

    GameObjectHelper.FastSetActive(barView.gameObject, tobool(barData))
end

function HonorGroupView:InitView(data, arenaModel, arenaHonorModel)
    local barData1 = data[1]
    local barData2 = data[2]
    self:ShowReward(barData1, self.bar1, arenaModel, arenaHonorModel)
    self:ShowReward(barData2, self.bar2, arenaModel, arenaHonorModel)
end

return HonorGroupView
