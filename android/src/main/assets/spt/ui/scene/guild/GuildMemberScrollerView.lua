local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local GuildMemberItemModel = require("ui.models.guild.GuildMemberItemModel")
local PlayerDetailCtrl = require("ui.controllers.playerDetail.PlayerDetailCtrl")
local GuildMemberScrollerView = class(LuaScrollRectExSameSize)

function GuildMemberScrollerView:ctor()
    GuildMemberScrollerView.super.ctor(self)
end

function GuildMemberScrollerView:start()
end

function GuildMemberScrollerView:createItem(index)
    local prefab = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildMemberItem.prefab"
    local obj, spt = res.Instantiate(prefab)
    self:resetItem(spt, index)
    return obj
end

function GuildMemberScrollerView:resetItem(spt, index)
    local itemModel = GuildMemberItemModel.new(self.data[index])
    local SETAUTHORITYTYPE = itemModel.GetAuthorityEnum()
    local selfAuthority = self.model:GetMyselfAuthority()
    spt:InitView(itemModel, selfAuthority)
    spt.onViewDetail = function() self:OnViewDetail(itemModel:GetPid(), self.data[index].sid) end
    spt.onBtnUpClick = function() self:OnBtnClick(SETAUTHORITYTYPE.UP, itemModel) end
    spt.onBtnDownClick = function() self:OnBtnClick(SETAUTHORITYTYPE.DOWN, itemModel) end
    spt.onBtnOutClick = function() self:OnBtnClick(SETAUTHORITYTYPE.OUT, itemModel) end
    self:updateItemIndex(spt, index)
end

function GuildMemberScrollerView:InitView(model)
    self.model = model
    self.data = self.model:GetMemberList()
    self:refresh(self.data)
end

function GuildMemberScrollerView:OnBtnClick(type, itemModel)
    EventSystem.SendEvent("MemberItem_SetAuthority", type, itemModel)
end

function GuildMemberScrollerView:OnViewDetail(pid, sid)
    PlayerDetailCtrl.ShowPlayerDetailView(function() return req.friendsDetail(pid, sid) end, pid, sid)
end

return GuildMemberScrollerView