local BaseCtrl = require("ui.controllers.BaseCtrl")
local WorldBossChallengeModel = require("ui.models.activity.worldBossActivity.WorldBossChallengeModel")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local CostDiamondHelper = require("ui.common.CostDiamondHelper")
local DialogManager = require("ui.control.manager.DialogManager")
local ItemModel = require("ui.models.ItemModel")
local ItemsMapModel = require("ui.models.ItemsMapModel")
local WorldBossChallengeCtrl = class(BaseCtrl)

WorldBossChallengeCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/WorldBossActivity/WorldBossChallengeBroad.prefab"

WorldBossChallengeCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

function WorldBossChallengeCtrl:Init(data, fatherModel)
    self.data = data
    self.fatherModel = fatherModel
    if not self.worldBossChallengeModel then
        self.worldBossChallengeModel = WorldBossChallengeModel.new(data, fatherModel)
        self.worldBossChallengeModel:InitWithProtocol()
    end
end

function WorldBossChallengeCtrl:GetStatusData()
    return self.data, self.fatherModel, self.worldBossChallengeModel
end

function WorldBossChallengeCtrl:Refresh(data, fatherModel, worldBossChallengeModel)
    if worldBossChallengeModel then
        self.worldBossChallengeModel = worldBossChallengeModel
    end
    self:InitView()
end

function WorldBossChallengeCtrl:InitView()
    self.view.onChallenge = function(isSweep) self:OnChallenge(isSweep) end
    self.view:InitView(self.worldBossChallengeModel)
end

function WorldBossChallengeCtrl:OnChallenge(isSweep)
    if not self.worldBossChallengeModel:GetCanMatch() then
        DialogManager.ShowToast(lang.trans("worldBossActivity_cannot_challenge"))
        return
    end
    if self.worldBossChallengeModel:GetRediusCount() == 0 then
        DialogManager.ShowConfirmPop(lang.trans("league_buyChallengeTimes"), 
            lang.trans("peak_buy_challenge_time", self.worldBossChallengeModel:GetBuyChallengeTimeConsume()), function ()
                CostDiamondHelper.CostDiamond(self.worldBossChallengeModel:GetBuyChallengeTimeConsume(), nil, function ()
                    self:CanChallenge(isSweep)
                end)
            end, nil, nil, DialogManager.DialogType.GeneralBox)
    else
        self:CanChallenge(isSweep)
    end
end

function WorldBossChallengeCtrl:CanChallenge(isSweep)
    if not isSweep then
        self.view:CloseImmediate()
        clr.coroutine(function()
            local response = req.activityWorldBossMatch(self.worldBossChallengeModel:GetOppendId())
            if api.success(response) then
                self:CostDiamond(response.val.cost)
                EventSystem.SendEvent("WorldBossActivityGoToMatch")
                local MatchLoader = require("coregame.MatchLoader")
                MatchLoader.startMatch(response.val)
            end
        end)
    else
        if not self:ReduceSweepCost() then
            return
        end
        clr.coroutine(function()
            local response = req.activityWorldBossSweep(self.worldBossChallengeModel:GetOppendId())
            if api.success(response) then
                self.worldBossChallengeModel:UpdateMatchTimes(response.val.matchTimes)
                res.PushDialog("ui.controllers.activity.content.worldBossActivity.WorldBossMatchDetailCtrl", response.val, self.worldBossChallengeModel:GetTeamData())
                if response.val.gift and next(response.val.gift) then
                    CongratulationsPageCtrl.new(response.val.gift)
                end
                self:CostDiamond(response.val.cost)
                self.view:ResetCount(self.worldBossChallengeModel:GetRediusCount())
                self.itemsMapModel = ItemsMapModel.new()
                self.itemsMapModel:UpdateFromReward(self.SweepConsume)
                EventSystem.SendEvent("WorldBossActivityCtrlRefreshData")
            end
        end)
    end
end

local SweepTicket = 2
local SweepConsume = {item = {{id = 2,num = 28,reduce = 1}}}
function WorldBossChallengeCtrl:ReduceSweepCost()
    local itemModel = ItemModel.new(SweepTicket)
    self.SweepConsume = SweepConsume
    self.SweepConsume.item[1].num = itemModel:GetItemNum() - 1
    if itemModel:GetItemNum() <= 0 then
        self:AskBuySweepCuponOrNot()
        return false
    end
    return true
end

--- 询问是否购买扫荡券
function WorldBossChallengeCtrl:AskBuySweepCuponOrNot()
    DialogManager.ShowConfirmPopByLang("tips", "sweepCuponNotEnoughAndBuy", function ()
        clr.coroutine(function ()
            coroutine.yield(clr.UnityEngine.WaitForSeconds(0.05))
            local StoreModel = require("ui.models.store.StoreModel")
            res.PushScene("ui.controllers.store.StoreCtrl", StoreModel.MenuTags.ITEM)
        end)
    end)
end

function WorldBossChallengeCtrl:CostDiamond(cost)
    if cost and tonumber(cost.num) > 0 then
        if not self.playerInfoModel then
            self.playerInfoModel = require("ui.models.PlayerInfoModel").new()
        end
        self.playerInfoModel:ReduceDiamond(tonumber(cost.num))
    end
end

return WorldBossChallengeCtrl