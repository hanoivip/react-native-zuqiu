local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")

local StaticRewardScrollView = class(LuaScrollRectExSameSize)

function StaticRewardScrollView:ctor()
    self.super.ctor(self)
    self.scrollRect = self.___ex.scrollRect
end

function StaticRewardScrollView:start()
end

function StaticRewardScrollView:InitView(rewardList)
    local dataList = self:DataListPretreatment(rewardList)
    self:refresh(dataList)
end

function StaticRewardScrollView:createItem(index)
    local prefab = "Assets/CapstonesRes/Game/UI/Scene/Activties/RecruitReward/StaticRewardItem.prefab"
    local obj, spt = res.Instantiate(prefab)
    self:resetItem(spt, index)
    return obj
end

function StaticRewardScrollView:resetItem(spt, index)
    local data = self.itemDatas[index]
    if index == 1 then 
        data.rankHigh = self.itemDatas[index].rankLow
    else
        data.rankHigh = self.itemDatas[index - 1].rankLow + 1
    end
    spt:InitView(data, index, self.scrollRect)
    self:updateItemIndex(spt, index)
end

function StaticRewardScrollView:DataListPretreatment(rewardList)
    for k, v in pairs(rewardList) do
        local count = 0
        for key, value in pairs(v.contents) do
            if type(value) == "table" then
                for kk, vv in pairs(value) do
                    count = count + 1
                end
            else
                count = count + 1
            end
        end
        v.contentsCount = count
    end

    return rewardList
end

return StaticRewardScrollView