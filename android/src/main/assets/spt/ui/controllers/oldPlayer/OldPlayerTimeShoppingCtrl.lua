local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local OldPlayerContentBaseCtrl = require("ui.controllers.oldPlayer.OldPlayerContentBaseCtrl")
local CostDiamondHelper = require("ui.common.CostDiamondHelper")
local DialogManager = require("ui.control.manager.DialogManager")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local OldPlayerTimeShoppingCtrl = class(OldPlayerContentBaseCtrl)

function OldPlayerTimeShoppingCtrl:ctor(parentContent, oldPlayerModel)
    self.oldPlayerModel = oldPlayerModel
    OldPlayerTimeShoppingCtrl.super.ctor(self, parentContent, "Assets/CapstonesRes/Game/UI/Scene/OldPlayer/OldPlayerHorizontalCommonBoard.prefab")
end

function OldPlayerTimeShoppingCtrl:SpreadButtonReg()
    self.view.onBuy = function(recvData, reqCallBack) self:OnBuy(recvData, reqCallBack) end
end

local ItemPath = "Assets/CapstonesRes/Game/UI/Scene/OldPlayer/OldPlayerTimeShoppingItem.prefab"
function OldPlayerTimeShoppingCtrl:InitView()
    self.view:InitView(self.oldPlayerModel:GetCurrContentData(), ItemPath)
end

function OldPlayerTimeShoppingCtrl:OnBuy(recvData, reqCallBack)
    CostDiamondHelper.CostDiamond(recvData.payAmount[1], nil, function()
        DialogManager.ShowConfirmPop(lang.trans("tips"), lang.trans("oldPlayer_buy_tip"), function()
            if self.isReq then return end
            if type(reqCallBack) == "function" then
                self.isReq = true
                clr.coroutine(function()
                    local response = req.oldPlayerCallBackBuy(tonumber(recvData.subID))
                    self.isReq = false
                    if api.success(response) then
                        local data = response.val
                        local currData = self.oldPlayerModel:SetCurrItemReduce(recvData.index)
                        reqCallBack(currData)
                        if data.gift and next(data.gift) then
                            CongratulationsPageCtrl.new(data.gift)
                        end
                        if data.cost and next(data.cost) then
                            if data.cost.type == "d" then
                                local playerInfoModel = PlayerInfoModel.new()
                                local playerDiamondNum = playerInfoModel:ReduceDiamond(tonumber(data.cost.num))
                            end
                        end
                    end
                end)
            end
        end)
    end)
end

function OldPlayerTimeShoppingCtrl:OnEnterScene()
end

function OldPlayerTimeShoppingCtrl:OnExitScene()

end

return OldPlayerTimeShoppingCtrl