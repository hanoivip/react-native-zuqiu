local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local GuildRequestItemModel = require("ui.models.guild.GuildRequestItemModel")
local PlayerDetailCtrl = require("ui.controllers.playerDetail.PlayerDetailCtrl")
local GuildRequestScrollerView = class(LuaScrollRectExSameSize)

function GuildRequestScrollerView:ctor()
    GuildRequestScrollerView.super.ctor(self)
end

function GuildRequestScrollerView:start()
end

function GuildRequestScrollerView:createItem(index)
    local prefab = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildRequestItem.prefab"
    local obj, spt = res.Instantiate(prefab)
    self:resetItem(spt, index)
    return obj
end

function GuildRequestScrollerView:resetItem(spt, index)
    local itemModel = GuildRequestItemModel.new(self.data[index])
    spt:InitView(itemModel)
    spt.onViewDetail = function() self:OnViewDetail(itemModel:GetPid(), itemModel:GetSid()) end
    spt.onBtnCancelClick = function()
        if type(self.onBtnCancelClick) == "function" then
            self.onBtnCancelClick(itemModel:GetPid())
        end
    end
    spt.onBtnComfirmClick = function()
        if type(self.onBtnComfirmClick) == "function" then
            self.onBtnComfirmClick(itemModel:GetPid())
        end
    end
    self:updateItemIndex(spt, index)
end

function GuildRequestScrollerView:InitView(data)
    self.data = data
    self:refresh(self.data)
end

function GuildRequestScrollerView:OnViewDetail(pid, sid)
    PlayerDetailCtrl.ShowPlayerDetailView(function() return req.friendsDetail(pid, sid) end, pid, sid)
end

return GuildRequestScrollerView