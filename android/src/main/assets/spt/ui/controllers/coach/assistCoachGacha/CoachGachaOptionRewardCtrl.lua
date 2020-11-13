local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local DialogManager = require("ui.control.manager.DialogManager")
local RewardNameHelper = require("ui.scene.itemList.RewardNameHelper")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local CoachGachaOptionRewardCtrl = class(BaseCtrl, "OptionRewardCtrl")

CoachGachaOptionRewardCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Coach/AssistCoachGacha/AssistantCoachGachaOptionReward.prefab"

CoachGachaOptionRewardCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function CoachGachaOptionRewardCtrl:Init()
    CoachGachaOptionRewardCtrl.super.Init(self)
    self.view.onExchangeGift = function(gachaId, data) self:ExchangeGift(gachaId, data) end
end

function CoachGachaOptionRewardCtrl:Refresh(contents, gachaId, isLackLuckyPoint)
    CoachGachaOptionRewardCtrl.super.Refresh(self)
    self.isLackLuckyPoint = isLackLuckyPoint
    self.view:InitView(contents, gachaId)
end

function CoachGachaOptionRewardCtrl:ExchangeGift(gachaId, data)
    if self.isLackLuckyPoint then
        DialogManager.ShowToastByLang("lucky_point_lack")
        return
    end

    DialogManager.ShowConfirmPop(lang.trans("tips"), lang.trans("itemList_select_tip", RewardNameHelper.GetSingleContentName(data.contents)),function ()
        self.view:coroutine(function ()
            local response = req.exchangeAssistantCoachGift(gachaId, data.contentId)
            if api.success(response) then
                local reqData = response.val
                CongratulationsPageCtrl.new(reqData.contents)
                self.view:Close()
                EventSystem.SendEvent("AssistCoachGachaCtrl_OnExchangeGift", self.gachaId, reqData)
            end
        end)
    end)
end

return CoachGachaOptionRewardCtrl