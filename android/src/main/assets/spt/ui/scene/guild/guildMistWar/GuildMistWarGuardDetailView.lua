local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local PlayerDetailCtrl = require("ui.controllers.playerDetail.PlayerDetailCtrl")
local GuildWarGuardDetailItemModel = require("ui.models.guild.guildWar.GuildWarGuardDetailItemModel")

local GuildMistWarGuardDetailView = class(unity.base)

function GuildMistWarGuardDetailView:ctor()
    self.close = self.___ex.close
    self.currItem = self.___ex.currItem
    self.emptyItem = self.___ex.emptyItem
    self.scrollerView = self.___ex.scrollerView
end

function GuildMistWarGuardDetailView:start()
    DialogAnimation.Appear(self.transform)

    self.close:regOnButtonClick(function()
        self:Close()
    end)

    self.scrollerView.onItemBtnPlaceClick = function(pid)
        self.onItemBtnPlaceClick(pid)
    end

    self.scrollerView.onItemBtnChangeClick = function(pid)
        self.onItemBtnChangeClick(pid)
    end
end

function GuildMistWarGuardDetailView:InitView(model)
    local currMember = model:GetCurrentMember()
    if currMember then
        self.emptyItem:SetActive(false)
        self.currItem.gameObject:SetActive(true)
        local itemModel = GuildWarGuardDetailItemModel.new(currMember)
        self.currItem:InitView(itemModel)
        self.currItem.onViewDetail = function() self:OnViewDetail(itemModel:GetPid(), itemModel:GetSid()) end
    else
        self.emptyItem:SetActive(true)
        self.currItem.gameObject:SetActive(false)
    end
    self.scrollerView:InitView(model:GetMemberList(), currMember)    
end

function GuildMistWarGuardDetailView:Close()
    DialogAnimation.Disappear(self.transform, nil, function()
        if type(self.closeDialog) == "function" then
            self.closeDialog()
        end
    end)
end

function GuildMistWarGuardDetailView:OnViewDetail(pid, sid)
    PlayerDetailCtrl.ShowPlayerDetailView(function() return req.friendsDetail(pid, sid) end, pid, sid)
end

return GuildMistWarGuardDetailView