local Mall = require("data.Mall")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local CustomEvent = require("ui.common.CustomEvent")
local DialogManager = require("ui.control.manager.DialogManager")
local PlayerGenericModel = require("ui.models.playerGeneric.PlayerGenericModel")
local CostDiamondHelper = require("ui.common.CostDiamondHelper")
local PlayerLimitCtrl = class()

local PlayerCapacity = 4 -- 对应服务器球员上限ID
function PlayerLimitCtrl:ctor()
    local searchDlg, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/PlayerList/PlayerLimitBuy.prefab", "camera", true, true)
    self.searchView = dialogcomp.contentcomp

    self.searchView.clickConfirm = function(costNum) self:OnBtnConfirm(costNum) end

    clr.coroutine(function()
        local respone = req.mallInfo(nil, nil, true)
        if api.success(respone) then
            local data = respone.val
            local useData = data[tostring(PlayerCapacity)]
            if useData then
                self:InitView(useData.cnt)
            end
        end
    end)

    self.playerGenericModel = PlayerGenericModel.new()
    self.playerInfoModel = PlayerInfoModel.new()
end

function PlayerLimitCtrl:InitView(useTime)
    self.searchView:InitView(useTime, PlayerCapacity)
end

function PlayerLimitCtrl:OnBtnConfirm(costNum)
    CostDiamondHelper.CostDiamond(costNum, self.searchView, function()
        clr.coroutine(function()
            local respone = req.mallBuy(PlayerCapacity)
            if api.success(respone) then
                local data = respone.val
                local cost = data.cost
                cost.num = cost.cost
                local add = data.gift.bagLimit
                self.playerGenericModel:AddPlayerCapacity(add)
                self:InitView(data.cnt)
                self.playerInfoModel:CostDetail(cost)
                CustomEvent.ConsumeDiamond("1", tonumber(cost.cost))
                DialogManager.ShowToast(lang.trans("playerCapacity_successTips", add))
            end
        end)
    end)
end

return PlayerLimitCtrl
