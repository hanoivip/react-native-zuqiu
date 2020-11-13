local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local DialogManager = require("ui.control.manager.DialogManager")
local DialogMultipleConfirmation = require("ui.control.manager.DialogMultipleConfirmation")
local CustomEvent = require("ui.common.CustomEvent")
local CostDiamondHelper = require("ui.common.CostDiamondHelper")
local UserStrengthCtrl = class()

function UserStrengthCtrl:ctor(notShowActivityTip)
    self.notShowActivityTip = notShowActivityTip
    self.playerInfoModel = nil
    self.strengthView = nil
    self:Init()
end

function UserStrengthCtrl:Init()
    self:GetStrengthInfo()
    -- self:UpdateStrengthData()
end

local function showTipsMessage(key)
    DialogManager.ShowToastByLang(key)
end

function UserStrengthCtrl:BuyStrength(costDiamond)
    CostDiamondHelper.CostDiamond(costDiamond, self.strengthView, function()
		local confirmCallback = function()
			clr.coroutine(function()
				local response = req.buyStrength()
				if api.success(response) then
					local data = response.val
					local cost = data.cost
					local sp = data.sp
					self.playerInfoModel:CostDetail(cost)
					CustomEvent.ConsumeDiamond("1", tonumber(cost.num))
					self.playerInfoModel:SetStrength(sp.curr_num)
					local info = data.info
					self.strengthView:InitView(info.cnt, info.totalCnt, info.cost, self.playerInfoModel)
					showTipsMessage("strength_successTips")
				end
			end)
		end
		DialogMultipleConfirmation.MultipleConfirmation(lang.trans("tips"), lang.trans("buy_sp"), confirmCallback)
    end)
end

function UserStrengthCtrl:GetStrengthInfo()
    clr.coroutine(function()
        local response = req.getStrengthInfo(nil, nil, false)
        if api.success(response) then
            local data = response.val
            self.playerInfoModel = PlayerInfoModel.new()
            local dialog, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Common/User/BuyStrength.prefab", "camera", true, true)
            self.strengthView = dialogcomp.contentcomp
            self.strengthView.activity:SetActive(data.rewardActivity and not self.notShowActivityTip)
            self.strengthView.BuyStrength = function(selector, costDiamond) self:BuyStrength(costDiamond) end
            self.strengthView:InitView(data.cnt, data.totalCnt, data.cost, self.playerInfoModel, self.notShowActivityTip)
        end
        self:UpdateStrengthData()
    end)
end

function UserStrengthCtrl:UpdateStrengthData()
    clr.coroutine(function()
        local response = req.spRecover(nil, nil, true)
        if api.success(response) then
            local data = response.val
            local sp = tonumber(data.sp)
            local nextTime = tonumber(data.next)
            local fullTime = tonumber(data.full)
            self.strengthView:UpdateStrengthView(sp, nextTime, fullTime)
        end
    end)
end

return UserStrengthCtrl
