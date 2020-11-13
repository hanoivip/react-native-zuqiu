local AssetFinder = require("ui.common.AssetFinder")
local HonorPalaceItemModel = require("ui.models.honorPalace.HonorPalaceItemModel")

local TrophyRoomScrollBarView = class(unity.base)

function TrophyRoomScrollBarView:ctor()
    self.trophyImage = self.___ex.trophyImage
    self.touchArea = self.___ex.touchArea
    self.trophyItemArea = self.___ex.trophyItemArea
end

function TrophyRoomScrollBarView:start()
    self.touchArea:regOnButtonClick(function()
        self:ShowTrophyInfo()
    end)
end

function TrophyRoomScrollBarView:InitView(data, index)
    self.honorPalaceItemModel = HonorPalaceItemModel.new(data)
    self.trophyID = self.honorPalaceItemModel:GetID()
    self.trophyImage.overrideSprite = AssetFinder.GetHonorPalaceTrophyIcon(self.trophyID)
    self.trophyImage:SetNativeSize()
    self.index = index
end

function TrophyRoomScrollBarView:ShowTrophyInfo()
    local isTrophyBeShowed = self.honorPalaceItemModel:IsTrophyBeShowed()
    EventSystem.SendEvent("TrophyRoomView.ShowTrophyDetail", self.honorPalaceItemModel, self.index)
end

return TrophyRoomScrollBarView
