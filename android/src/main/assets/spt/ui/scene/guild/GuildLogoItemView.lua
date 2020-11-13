local UnityEngine = clr.UnityEngine
local UI = UnityEngine.UI
local Text = UI.Text
local Image = UI.Image
local Vector2 = UnityEngine.Vector2
local AssetFinder = require("ui.common.AssetFinder")

local GuildLogoItemView = class(unity.base)

function GuildLogoItemView:ctor()
    self.icon = self.___ex.icon
    self.iconClick = self.___ex.iconClick
    self.effect1 = self.___ex.effect1
    self.effect2 = self.___ex.effect2
    self.animator = self.___ex.animator

    EventSystem.AddEvent("Guild_LogoItemClick", self, self.EventLogoItemClick)
end

function GuildLogoItemView:onEnable()
end

function GuildLogoItemView:start()
    self.iconClick:regOnButtonClick(function() 
        if type(self.onIconClickFunc) == "function" then
            self.onIconClickFunc()
        end
    end)
end

function GuildLogoItemView:InitView(itemModel)
    self.itemModel = itemModel
    self.icon.sprite = AssetFinder.GetGuildIcon(itemModel:GetPicIndex())
    self.icon.type = Image.Type.Filled
    self:coroutine(function()
        coroutine.yield(UnityEngine.WaitForSeconds(0.1))
        self:PlayAnimation()
    end)
end

function GuildLogoItemView:PlayAnimation()
    self.animator:Play("GuildLogoItem")
end

function GuildLogoItemView:SetSelectedState(state)
    self.effect1:SetActive(state)
    self.effect2:SetActive(state)
end

function GuildLogoItemView:EventLogoItemClick(selectIndex)
    local index = self.itemModel:GetIndex()
    local isSelected = index == selectIndex
    self:SetSelectedState(isSelected)
end

function GuildLogoItemView:onDestroy()
    EventSystem.RemoveEvent("Guild_LogoItemClick", self, self.EventLogoItemClick)
end

return GuildLogoItemView
