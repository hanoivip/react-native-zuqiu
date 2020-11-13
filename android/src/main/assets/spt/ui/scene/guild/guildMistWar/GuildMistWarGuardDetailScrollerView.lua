local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local GuildWarGuardDetailItemModel = require("ui.models.guild.guildWar.GuildWarGuardDetailItemModel")
local PlayerDetailCtrl = require("ui.controllers.playerDetail.PlayerDetailCtrl")
local GuildWarGuardDetailScrollerView = class(LuaScrollRectExSameSize)

function GuildWarGuardDetailScrollerView:ctor()
    GuildWarGuardDetailScrollerView.super.ctor(self)
end

function GuildWarGuardDetailScrollerView:start()
end

function GuildWarGuardDetailScrollerView:createItem(index)
    local prefab = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildMistWar/GuildMistWarGuardDetailItem.prefab"
    local obj, spt = res.Instantiate(prefab)
    self:resetItem(spt, index)
    return obj
end

function GuildWarGuardDetailScrollerView:resetItem(spt, index)
    local itemModel = GuildWarGuardDetailItemModel.new(self.data[index])
    spt:InitView(itemModel, self.currMember)
    spt.onViewDetail = function() self:OnViewDetail(itemModel:GetPid(), self.data[index].sid) end
    spt.onBtnPlaceClick = function() self.onItemBtnPlaceClick(itemModel:GetPid()) end
    spt.onBtnChangeClick = function() self.onItemBtnChangeClick(itemModel:GetPid()) end
    self:updateItemIndex(spt, index)
end

function GuildWarGuardDetailScrollerView:InitView(data, currMember)
    self.currMember = currMember
    self.data = data
    self:refresh(self.data)
end

function GuildWarGuardDetailScrollerView:OnViewDetail(pid, sid)
    PlayerDetailCtrl.ShowPlayerDetailView(function() return req.friendsDetail(pid, sid) end, pid, sid)
end

return GuildWarGuardDetailScrollerView