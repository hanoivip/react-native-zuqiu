local ItemModel = require("ui.models.ItemModel")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local CostDiamondHelper = require("ui.common.CostDiamondHelper")
local DialogManager = require("ui.control.manager.DialogManager")
local CoachGachaRewardCtrl = class(BaseCtrl, "OptionRewardCtrl")

CoachGachaRewardCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Coach/AssistCoachGacha/CoachGachaReward.prefab"

function CoachGachaRewardCtrl:Init(contents, gachaId, assistCoachGachaModel)
    CoachGachaRewardCtrl.super.Init(self)
    self.assistCoachGachaModel = assistCoachGachaModel
    self.view.onAgainClick = function() self:OnGachaAgain() end
    self.view.onShareClick = function() self:OnShare() end
    self.contents = contents
    self.gachaId = gachaId
end

function CoachGachaRewardCtrl:Refresh()
    CoachGachaRewardCtrl.super.Refresh(self)
    self.view:InitView(self.contents)
end

function CoachGachaRewardCtrl:OnGachaAgain()
    self.gachaId = self.assistCoachGachaModel:GetCurrentGachaId()
    self.consumeType = self.assistCoachGachaModel:GetCachaTenConsumeType(self.gachaId)

    local costCount = 1
    local costName = ""
    if self.consumeType == self.assistCoachGachaModel.Item_Gacha then
        local id = self.assistCoachGachaModel:GetCachaTenItemId(self.gachaId)
        local itemModel = ItemModel.new(id)
        costName = itemModel:GetName()
    else
        costCount = self.assistCoachGachaModel:GetCachaTenDiscountPrice(self.gachaId)
        costName = lang.transstr("diamond")  -- 钻石
    end

    local title = lang.transstr("coach_gacha_month_ten") -- 十次搜寻
    local msg = lang.transstr("coach_gacha_consume_tip", costName, costCount, title) -- 确认消耗xx xxx进行十次搜寻
    DialogManager.ShowConfirmPop(title, msg, function()
        if self.consumeType == self.assistCoachGachaModel.Item_Gacha then
            self:Gacha()
        else
            CostDiamondHelper.CostDiamond(costCount, self.view, function() self:Gacha() end)
        end
    end)
end

function CoachGachaRewardCtrl:Gacha()
    -- 点击确定回调
    self.view:coroutine(function()
        local respone = req.buyAssistantCoachGift(self.gachaId, 10, self.consumeType)
        if api.success(respone) then
            local data = respone.val
            if type(data) == "table" and next(data) then
                self.contents = data.contents
                self.view:InitView(self.contents)
                EventSystem.SendEvent("AssistCoachGachaCtrl_OnBuyRefresh", data)
            end
        end
    end)
end

function CoachGachaRewardCtrl:OnShare()

end

return CoachGachaRewardCtrl