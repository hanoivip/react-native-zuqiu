local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local CurrencyType = require("ui.models.itemList.CurrencyType")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local ActivityContentBaseCtrl = require("ui.controllers.activity.content.ActivityContentBaseCtrl")
local SimpleIntroduceModel = require("ui.models.common.SimpleIntroduceModel")

local TimeLimitGuildCarnivalCtrl = class(ActivityContentBaseCtrl, "TimeLimitGuildCarnivalCtrl")

function TimeLimitGuildCarnivalCtrl:InitWithProtocol()
    self.view = self.contentPrefab:GetComponent(clr.CapsUnityLuaBehav)
    self.view.onClickBtnLog = function() self:OnClickBtnLog() end
    self.view.onClickBtnAddGuild = function() self:OnClickBtnAddGuild() end
    self.view.onClickBtnIntro = function() self:OnClickBtnIntro() end
    self.view.onClickPurchase = function(subID, num) self:OnClickPurchase(subID, num) end
    self.view.resetCousume = function (func) self:ResetCousume(func) end
    self.view:InitView(self.activityModel)
end

function TimeLimitGuildCarnivalCtrl:OnClickBtnLog()
    res.PushDialog("ui.controllers.activity.content.timeLimitGuildCarnival.TimeLimitGuildCarnivalLogCtrl")
end

function TimeLimitGuildCarnivalCtrl:OnClickBtnAddGuild()
    res.PushScene("ui.controllers.guild.GuildJoinCtrl")
end

function TimeLimitGuildCarnivalCtrl:OnClickBtnIntro()
    local simpleIntroduceModel = SimpleIntroduceModel.new()
    simpleIntroduceModel:InitModel(3, "TimeLimitGuildCarnival")
    res.PushDialog("ui.controllers.common.SimpleIntroduceCtrl", simpleIntroduceModel)
end

function TimeLimitGuildCarnivalCtrl:OnClickPurchase(subID, num)
    clr.coroutine(function()
        local response = req.guildCarnivalBuy(subID, num)
        if api.success(response) then
            local data = response.val
            CongratulationsPageCtrl.new(data.contents)
            if not self.playerInfoModel then
                self.playerInfoModel = PlayerInfoModel.new()
            end
            for currencyType, cost_num in pairs(data.cost) do
                if currencyType == CurrencyType.Money then-- 欧元
                    self.playerInfoModel:SetMoney(self.playerInfoModel:GetMoney() - tonumber(cost_num))
                elseif currencyType == CurrencyType.Diamond then-- 钻石
                    self.playerInfoModel:ReduceDiamond(tonumber(cost_num))
                elseif currencyType == CurrencyType.BlackDiamond then-- 豪门币
                    self.playerInfoModel:SetBlackDiamond(self.playerInfoModel:GetBlackDiamond() - tonumber(cost_num))
                else
                    dump("illegal currency type, please check the config")
                end
            end
            self.activityModel:UpdateAfterPurchased(subID, num, data.score)
            self.view:UpdateAfterPurchased()
        end
    end)
end

function TimeLimitGuildCarnivalCtrl:OnEnterScene()
    self.view:OnEnterScene()
end

function TimeLimitGuildCarnivalCtrl:OnExitScene()
    self.view:OnExitScene()
end

return TimeLimitGuildCarnivalCtrl