local UnityEngine = clr.UnityEngine
local UI = UnityEngine.UI
local Text = UI.Text
local Vector2 = UnityEngine.Vector2
local AssetFinder = require("ui.common.AssetFinder")

local GuildJoinItemView = class(unity.base)

function GuildJoinItemView:ctor()
    self.nameTxt = self.___ex.name
    self.count = self.___ex.count
    self.level = self.___ex.level
    self.contribute = self.___ex.contribute
    self.selectImg = self.___ex.selectImg
    self.contentClick = self.___ex.contentClick
    self.logoImg = self.___ex.logo
    self.zone = self.___ex.zone
    self.power = self.___ex.power

end

function GuildJoinItemView:start()
    self.contentClick:regOnButtonClick(function()
        if type(self.clickReceive) == "function" then
            self.clickReceive()
        end
    end)
    EventSystem.AddEvent("GuildJoinScrollerView_ItemClick", self, self.EventSelectedReceived)
end

function GuildJoinItemView:InitView(itemModel)
    self.itemModel = itemModel

    self.zone.text = itemModel:GetZone()
    self.power.text = itemModel:GetPower()
    self.nameTxt.text = itemModel:GetName()
    self.count.text = itemModel:GetMemberNum() .. "/40"
    self.contribute.text = tostring(itemModel:GetContribute())
    local isopen = itemModel:GetisAutoRequest()
    self.level.text = tostring(itemModel:GetMinPlayerLvl())
    self.logoImg.overrideSprite = AssetFinder.GetGuildIcon(itemModel:GetGuildIcon())
end

function GuildJoinItemView:onDestroy()
    EventSystem.RemoveEvent("GuildJoinScrollerView_ItemClick", self, self.EventSelectedReceived)
end

function GuildJoinItemView:EventSelectedReceived(itemModel)
    local state = false
    if itemModel then
        state = itemModel:GetGid() == self.itemModel:GetGid()
    end
    self.selectImg:SetActive(state)
end

return GuildJoinItemView
