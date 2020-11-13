local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local MemberTaskRewardScrollView = class(LuaScrollRectExSameSize)

function MemberTaskRewardScrollView:ctor()
    MemberTaskRewardScrollView.super.ctor(self)

    self.scrollRect = self.___ex.scrollRect
end

function MemberTaskRewardScrollView:start()
end

function MemberTaskRewardScrollView:createItem(index)
    local prefab = "Assets/CapstonesRes/Game/UI/Scene/Activties/MascotPresent/MemberTaskRewardItem.prefab"
    local obj, spt = res.Instantiate(prefab)
    self:resetItem(spt, index)
    return obj
end

function MemberTaskRewardScrollView:resetItem(spt, index)
    local data = self.itemDatas[index]
    local isGuildTask = false
    spt:InitView(data, self.scrollRect, self.activityModel, isGuildTask)  
    self:updateItemIndex(spt, index)
end

function MemberTaskRewardScrollView:InitView(activityModel, memberRewardIndex)
    self.activityModel = activityModel
    local rewardList = self.activityModel:GetGuildOrMemberRewardData(memberRewardIndex)
    self:refresh(rewardList)
end

return MemberTaskRewardScrollView
