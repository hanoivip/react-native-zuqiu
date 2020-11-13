local BaseCtrl = require("ui.controllers.BaseCtrl")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local DialogManager = require("ui.control.manager.DialogManager")
local FancyCardsMapModel = require("ui.models.fancy.FancyCardsMapModel")
local CurrencyType = require("ui.models.itemList.CurrencyType")
local FancyGachaInfoBarCtrl = require("ui.controllers.common.FancyGachaInfoBarCtrl")
local FancyStarUpCtrl = class(BaseCtrl, "FancyStarUpCtrl")
FancyStarUpCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Fancy/FancyHome/FancyStarUp.prefab"

function FancyStarUpCtrl:Refresh(card)
	self.card = card
    self:InitView()
end

function FancyStarUpCtrl:InitView()
    self.view.InfoBar:RegOnDynamicLoad(function (child)
        local param = {}
        param.isHideFancyTicket1 = true
        param.isHideFancyTicket10 = true
        param.isHideBack = true
        self.infoBarCtrl = FancyGachaInfoBarCtrl.new(child, param)
    end)
    self.view:InitView(self.card)
    self.view.StarUp = function() self:StarUp() end
end

local function GetCostStr(count, str)
    if count > 0 then
        return str .. 'x' .. string.formatNumWithUnit(count) .. '、'
    end
    return ""
end

function FancyStarUpCtrl:StarUp()
	if not self.card:IsHaveNextStar() then
		--滿了
		return
	end
	local playerInfoModel = PlayerInfoModel.new()
	local starConfig = self.card:GetStarUpConfig()
    if starConfig.fancyCard > self.card:GetCount() then
    	DialogManager.ShowToast(lang.trans("fancyGroupStarUpTips"))
        return
    end
    if starConfig.d > playerInfoModel:GetDiamond() then
    	DialogManager.ShowToast(lang.trans("diamondNotEnough"))
    	return
    end
    if starConfig.m > playerInfoModel:GetMoney() then
    	DialogManager.ShowToast(lang.trans("goldCoinNotEnough"))
    	return
    end
    if starConfig.fs > playerInfoModel:GetFS() then
        DialogManager.ShowToast(lang.trans("fsNotEnough"))
        return
    end
    if starConfig.fancyPiece > playerInfoModel:GetFancyPiece() then
        DialogManager.ShowToast(lang.trans("fancyPieceNotEnough"))
        return
    end
    local func = function()
        clr.coroutine(function()
            local response = req.fancyCardStarUp(self.card.staticData.groupID, self.card.id)
            if api.success(response) then
                local data = response.val
                local FancyCardsMapModel = FancyCardsMapModel.new()
                FancyCardsMapModel:UpdateCardData(self.card.id, data.card)
                if data.cost then
                    for k, v in pairs(data.cost) do
                        if v.type == CurrencyType.Money then
                            playerInfoModel:SetMoney(v.curr_num)
                        elseif v.type == CurrencyType.Diamond then
                            playerInfoModel:SetDiamond(v.curr_num)
                        elseif v.type == CurrencyType.Fs then
                            playerInfoModel:SetFs(v.curr_num)
                        elseif v.type == CurrencyType.FancyPiece then
                            playerInfoModel:SetFancyPiece(v.curr_num)
                        end
                    end
                end
                EventSystem.SendEvent("FancyUpStar")
            end
        end)
    end
    local str = ""
    str = str .. GetCostStr(starConfig.fancyCard, self.card:GetName())
    str = str .. GetCostStr(starConfig.d, lang.transstr("diamond"))
    str = str .. GetCostStr(starConfig.m, lang.transstr("goldCoin"))
    str = str .. GetCostStr(starConfig.fs, lang.transstr("fancyCard_fs"))
    str = str .. GetCostStr(starConfig.fancyPiece, lang.transstr("fancyCard_fancyPiece"))
    str = string.sub(tostring(str), 1, -4)
    DialogManager.ShowConfirmPop(lang.trans("fancy_starup_title"), lang.trans("fancy_starup_content", str), func)
end

function FancyStarUpCtrl:GetStatusData()
    return self.card
end

return FancyStarUpCtrl