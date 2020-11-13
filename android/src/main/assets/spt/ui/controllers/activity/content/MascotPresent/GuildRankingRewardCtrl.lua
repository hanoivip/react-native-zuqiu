local BaseCtrl = require("ui.controllers.BaseCtrl")
local DialogManager = require("ui.control.manager.DialogManager")
local GuildRankingRewardCtrl = class(BaseCtrl, "GuildRankingRewardCtrl")

GuildRankingRewardCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

GuildRankingRewardCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/MascotPresent/GuildRankingReward.prefab"

function GuildRankingRewardCtrl:ctor()
end

function GuildRankingRewardCtrl:Init(mascotPresentModel)
    self.view.clickRanking = function() self:OnRankingClick() end
    self.view.clickReward = function() self:OnRewardClick() end

    self.activityModel = mascotPresentModel or {}
    self.view:InitView(self.activityModel)
end

function GuildRankingRewardCtrl:OnRankingClick()
    self.view:ShowRankingScrollArea(true)
end

function GuildRankingRewardCtrl:OnRewardClick()
    self.view:ShowRankingScrollArea(false)
end

function GuildRankingRewardCtrl:EventRankingItemDetailClick(gid)
    self.view:coroutine(function()
        local respone = req.GuildDetail(gid)
        if api.success(respone) then
            local data = respone.val
            if data.base.isExsit == true then
                res.PushDialog("ui.controllers.guild.GuildDetailCtrl", data.base)
            end
        end
    end)
end

function GuildRankingRewardCtrl:OnEnterScene()
    EventSystem.AddEvent("GuildRankingItem_Detail", self, self.EventRankingItemDetailClick)
end

function GuildRankingRewardCtrl:OnExitScene()
    EventSystem.RemoveEvent("GuildRankingItem_Detail", self, self.EventRankingItemDetailClick)
end

return GuildRankingRewardCtrl