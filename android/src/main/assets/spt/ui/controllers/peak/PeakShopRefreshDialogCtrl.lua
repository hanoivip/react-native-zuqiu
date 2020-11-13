local PlayerInfoModel = require("ui.models.PlayerInfoModel")

local PeakShopRefreshDialogCtrl = class()

function PeakShopRefreshDialogCtrl:ctor(view)
    self.view = view
    self.playerInfoModel = PlayerInfoModel.new()
    self.playerInfoModel:Init()
end


function PeakShopRefreshDialogCtrl:InitView(peakStoreModel)
    self.peakStoreModel = peakStoreModel
    self.view.onRefresh = function() self:OnRefresh() end
    self.view:InitView(self.peakStoreModel)
end

function PeakShopRefreshDialogCtrl:OnRefresh()
    clr.coroutine(function()
        local response = req.peakShopRefresh()
        if api.success(response) then
            local data = response.val
            self.peakStoreModel:SetDataList(data.refreshData)
            self.peakStoreModel:SetRefreshPrice(data.refreshPrice)
            self.peakStoreModel:SetRefreshTimes(data.refreshTimes)
            if data.cost.type == "d" then
                self.playerInfoModel:SetDiamond(data.cost.curr_num)
            end
            self.view:Close()
        end
    end)
end

return PeakShopRefreshDialogCtrl