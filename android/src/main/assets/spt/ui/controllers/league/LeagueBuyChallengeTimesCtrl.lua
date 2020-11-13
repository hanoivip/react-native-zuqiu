local BaseCtrl = require("ui.controllers.BaseCtrl")
local CustomEvent = require("ui.common.CustomEvent")
local DialogManager = require("ui.control.manager.DialogManager")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")

local LeagueBuyChallengeTimesCtrl = class(BaseCtrl)
LeagueBuyChallengeTimesCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/League/LeagueBuyChallengeTimes.prefab"

function LeagueBuyChallengeTimesCtrl:Refresh(leagueInfoModel)
    self.leagueInfoModel = leagueInfoModel
    self:InitView()
    self:RegisterEvent()
end

function LeagueBuyChallengeTimesCtrl:RegisterEvent()
    EventSystem.AddEvent("League_BuyChallengeTimes", self, self.BuyChallengeTimes)
end

function LeagueBuyChallengeTimesCtrl:RemoveEvent()
    EventSystem.RemoveEvent("League_BuyChallengeTimes", self, self.BuyChallengeTimes)
end

function LeagueBuyChallengeTimesCtrl:InitView()
    self.view:InitView(self.leagueInfoModel)
end

function LeagueBuyChallengeTimesCtrl:BuyChallengeTimes()
    clr.coroutine(function()
        local resp = req.leagueBuyChallengeTimes()
        if api.success(resp) then
            local data = resp.val
            self.leagueInfoModel:UpdateBaseInfo(data.base)
            local playerInfoModel = PlayerInfoModel.new()
            playerInfoModel:ReduceDiamond(data.cost.num)
            CustomEvent.ConsumeDiamond(tonumber(data.cost.num), "4")
            self.view:Close()
            EventSystem.SendEvent("League_RefreshChallengeTimes")
            DialogManager.ShowToastByLang("buy_item_success")
        end
    end)
end

function LeagueBuyChallengeTimesCtrl:OnExitScene()
    self:RemoveEvent()
end

return LeagueBuyChallengeTimesCtrl