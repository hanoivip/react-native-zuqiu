local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local GuildTaskRewardScrollView = class(LuaScrollRectExSameSize)

function GuildTaskRewardScrollView:ctor()
    GuildTaskRewardScrollView.super.ctor(self)

    self.scrollRect = self.___ex.scrollRect
end

function GuildTaskRewardScrollView:start()
end

function GuildTaskRewardScrollView:createItem(index)
    local prefab = "Assets/CapstonesRes/Game/UI/Scene/Activties/MascotPresent/GuildTaskRewardItem.prefab"
    local obj, spt = res.Instantiate(prefab)
    self:resetItem(spt, index)
    return obj
end

function GuildTaskRewardScrollView:resetItem(spt, index)
    local data = self.itemDatas[index]
    local isGuildTask = true
    spt:InitView(data, self.scrollRect, self.activityModel, isGuildTask)  
    self:updateItemIndex(spt, index)
end

function GuildTaskRewardScrollView:InitView(activityModel, guildRewardIndex)
    self.activityModel = activityModel
    local rewardList = self.activityModel:GetGuildOrMemberRewardData(guildRewardIndex)
    self:refresh(rewardList)
end

return GuildTaskRewardScrollView
