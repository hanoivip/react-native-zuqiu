local AssetFinder = require("ui.common.AssetFinder")
local HonorPalaceItemModel = require("ui.models.honorPalace.HonorPalaceItemModel")

local TrophyRoomItemView = class(unity.base)

function TrophyRoomItemView:ctor()
    self.rewardImg = self.___ex.rewardImg
    self.nameTxt = self.___ex.nameTxt
    self.descTxt = self.___ex.descTxt
    self.timeTxt = self.___ex.timeTxt
    self.achieveTxt = self.___ex.achieveTxt
    self.mark = self.___ex.mark
    self.selectBtn = self.___ex.selectBtn
end

function TrophyRoomItemView:start()
    self.selectBtn:regOnButtonClick(function ()
        if self.onClickRoomItem then
            self.onClickRoomItem()
        end
    end)
end

function TrophyRoomItemView:InitView(data)
    local honorPalaceItemModel = HonorPalaceItemModel.new(data)
    self.rewardImg.overrideSprite = AssetFinder.GetHonorPalaceTrophyIcon(data.ID)
    self.rewardImg:SetNativeSize()
    self.nameTxt.text = honorPalaceItemModel:GetName()
    self.descTxt.text = honorPalaceItemModel:GetDesc()
    self.achieveTxt.text = tostring(honorPalaceItemModel:GetEffortValue())
    
    self.timeTxt.text = honorPalaceItemModel:GetTime()

    -- 为了scroll的刷新问题
    self.mark:SetActive(false)
    local showTrohpyTable = cache.getHonorShowData()
    for k, v in pairs(showTrohpyTable) do
        if tonumber(data.ID) == tonumber(v) then
            self.mark:SetActive(true)
        end
    end
end

return TrophyRoomItemView
