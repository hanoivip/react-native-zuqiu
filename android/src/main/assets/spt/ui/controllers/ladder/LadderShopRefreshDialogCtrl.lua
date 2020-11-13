local PlayerInfoModel = require("ui.models.PlayerInfoModel")

local LadderShopRefreshDialogCtrl = class()

function LadderShopRefreshDialogCtrl:ctor(view)
    self.view = view
    self.playerInfoModel = PlayerInfoModel.new()
    self.playerInfoModel:Init()
end

function LadderShopRefreshDialogCtrl:InitView(ladderModel)
    self.ladderModel = ladderModel
    self.view.onRefresh = function() self:OnRefresh() end
    self.view:InitView(self.ladderModel)
end

function LadderShopRefreshDialogCtrl:OnRefresh()
    clr.coroutine(function()
        local respone = req.ladderStoreRefresh()
        if api.success(respone) then
            local data = respone.val
            -- 更新花费
            if data.cost and data.cost.type == "d" then
                self.playerInfoModel:SetDiamond(data.cost.curr_num)
            end
            if data.count then
                self.ladderModel:SetShopCostRefreshRemainTimes(data.count)
            end
            if data.goods then
                self.ladderModel:RefreshShopList(data.goods)
            end
            self.view:Close()
        end
    end)
end

return LadderShopRefreshDialogCtrl