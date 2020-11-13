local UnityEngine = clr.UnityEngine
local EventSystems = UnityEngine.EventSystems
local WaitForSeconds = UnityEngine.WaitForSeconds
local ItemsMapModel = require("ui.models.ItemsMapModel")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local FancyMultipleRewardCtrl = class(BaseCtrl, "FancyMultipleRewardCtrl")

FancyMultipleRewardCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Fancy/FancyGacha/FancyMultipleReward.prefab"

function FancyMultipleRewardCtrl:Init()
    FancyMultipleRewardCtrl.super.Init(self)
    self.view.onAgainClick = function() self:OnGachaAgain() end
end

function FancyMultipleRewardCtrl:Refresh(rewardData, gachaCtrl)
    self.view:InitView(rewardData)
    self.gachaCtrl = gachaCtrl
end

-- 再次招募（十次）
function FancyMultipleRewardCtrl:OnGachaAgain()
    local itemsMapModel = ItemsMapModel:new()
    local gachaId = self.gachaCtrl.view.curGachaGroup:GetId()
    local costItem = self.gachaCtrl.view.curGachaGroup:GetGachaItemId(10)
    if itemsMapModel:GetItemNum(costItem) < 1 then
        self.gachaCtrl.infoBarCtrl:OnBtnFancyTenTicket()
        return
    end
    clr.coroutine(function()
        local response = req.fancyCardGachaTen(gachaId)
        if api.success(response) then
            local data = response.val
            if data.contents then
                self.view:InitView(data.contents)
                local currentEventSystem = EventSystems.EventSystem.current
                currentEventSystem.enabled = false
                coroutine.yield(WaitForSeconds(2.5))
                currentEventSystem.enabled = true
            end
            if data.cost then
                itemsMapModel:ResetItemNum(data.cost.id, data.cost.num)
            end
            EventSystem.SendEvent("FancyGachaStart")
        end
    end)
end

return FancyMultipleRewardCtrl