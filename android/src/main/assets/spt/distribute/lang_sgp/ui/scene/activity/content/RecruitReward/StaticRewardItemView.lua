local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local GameObjectHelper = require("ui.common.GameObjectHelper")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local StaticRewardItemView = class(unity.base)

function StaticRewardItemView:ctor()
    self.normalRank = self.___ex.normalRank
    self.content = self.___ex.content
    self.bg = self.___ex.bg
    self.rArrowObj = self.___ex.rArrowObj
    self.lArrowObj = self.___ex.lArrowObj
    self.cumulativeConsumeItemScrollAtOnce = self.___ex.cumulativeConsumeItemScrollAtOnce

    self.scrollRect = self.___ex.scrollRect
    self.arrowsObj = self.___ex.arrowsObj
    self.scrollRect.onValueChanged:AddListener(function(vector2)
        if self.data.contentsCount > 3 then
            if vector2.x > 0.999 then
                self:UpdateArrowState(true, false)
            elseif vector2.x < 0.001 then
                self:UpdateArrowState(false, true)
            else
                self:UpdateArrowState(true, true)
            end
        end
    end)
end 

function StaticRewardItemView:UpdateArrowState(isShowL, isShowR)
    GameObjectHelper.FastSetActive(self.lArrowObj, isShowL)
    GameObjectHelper.FastSetActive(self.rArrowObj, isShowR)
end

function StaticRewardItemView:InitView(model, index, parentRect)
    self.data = model
    if not self.data or type(self.data) ~= "table" then return end

    GameObjectHelper.FastSetActive(self.arrowsObj, self.data.contentsCount > 3)
    GameObjectHelper.FastSetActive(self.lArrowObj, false)
    GameObjectHelper.FastSetActive(self.bg, index % 2 == 0)
    local affixString = ""
    if self.data.rankHigh == self.data.rankLow then
        affixString = tostring(self.data.rankHigh)
    else
        affixString = tostring(self.data.rankHigh).."-"..tostring(self.data.rankLow)
    end
    self.normalRank.text = lang.transstr("guildwar_rank", affixString)

    self.cumulativeConsumeItemScrollAtOnce.scrollRectInParent = parentRect

    res.ClearChildren(self.content)
    local rewardParams = {
        parentObj = self.content,
        rewardData = model.contents,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
        isShowCardPieceBeforeItem = true,
    }
    RewardDataCtrl.new(rewardParams)
end

return StaticRewardItemView