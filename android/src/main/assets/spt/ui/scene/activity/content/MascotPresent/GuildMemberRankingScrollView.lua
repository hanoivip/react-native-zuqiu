local PlayerDetailCtrl = require("ui.controllers.playerDetail.PlayerDetailCtrl")
local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local GuildMemberContributeRankingItemModel = require("ui.models.activity.mascotPresent.GuildMemberContributeRankingItemModel")
local GuildMemberRankingScrollView = class(LuaScrollRectExSameSize)

function GuildMemberRankingScrollView:ctor()
    GuildMemberRankingScrollView.super.ctor(self)
end

function GuildMemberRankingScrollView:createItem(index)
    local prefab = "Assets/CapstonesRes/Game/UI/Scene/Activties/MascotPresent/GuildMemberRankingItem.prefab"
    local obj, spt = res.Instantiate(prefab)
    self:resetItem(spt, index)
    return obj
end

function GuildMemberRankingScrollView:resetItem(spt, index)
    local itemModel = GuildMemberContributeRankingItemModel.new(self.data[index])
    spt:InitView(itemModel)
    spt.onBtnDetailClick = function(pid, sid)
        self:OnDetailClick(pid, sid)
    end
end

function GuildMemberRankingScrollView:InitView(mascotPresentModel)
    self.activityModel = mascotPresentModel
    local rankingList = self.activityModel:GetGmContributeRankingList()

    self.playerInfoModel = PlayerInfoModel.new()
    self.playerInfoModel:Init()

    self.data = rankingList
    self:refresh(rankingList)
end

function GuildMemberRankingScrollView:OnDetailClick(pid, sid)
    PlayerDetailCtrl.ShowPlayerDetailView(function() return req.friendsDetail(pid, sid) end, pid, sid)
end

return GuildMemberRankingScrollView