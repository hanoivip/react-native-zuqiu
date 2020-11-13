local UnityEngine = clr.UnityEngine
local UI = UnityEngine.UI
local Text = UI.Text
local Vector2 = UnityEngine.Vector2
local AssetFinder = require("ui.common.AssetFinder")

local GuildInvitationItemView = class(unity.base)

function GuildInvitationItemView:ctor()
    self.mName = self.___ex.mName
    self.count = self.___ex.count
    self.level = self.___ex.level
    self.contribute = self.___ex.contribute
    self.selectImg = self.___ex.selectImg
    self.contentClick = self.___ex.contentClick
    self.logoImg = self.___ex.logo
    self.zone = self.___ex.zone
    self.power = self.___ex.power

end

function GuildInvitationItemView:start()
    self.contentClick:regOnButtonClick(function()
        if type(self.clickReceive) == "function" then
            self.clickReceive(self.itemModel)
        end
    end)
end

function GuildInvitationItemView:InitView(itemdata)
    self.itemModel = itemdata

    self.zone.text = itemdata.serverName
    self.power.text = tostring(itemdata.power)
    self.mName.text = itemdata.name
    self.count.text = itemdata.memberNum .. "/40"
    self.contribute.text = tostring(itemdata.cumulativeTotalLastThreeDay)
    local isopen = tonumber(itemdata.requestAcceptType) == 1
    self.level.text = tostring(itemdata.minPlayerLvl)
    self.logoImg.overrideSprite = AssetFinder.GetGuildIcon("GuildLogo" .. itemdata.eid)
end

return GuildInvitationItemView