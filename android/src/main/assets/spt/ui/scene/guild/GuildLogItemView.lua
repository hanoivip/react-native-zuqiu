local UnityEngine = clr.UnityEngine
local UI = UnityEngine.UI
local Text = UI.Text
local Vector2 = UnityEngine.Vector2

local GuildLogItemView = class(unity.base)

function GuildLogItemView:ctor()
    self.content = self.___ex.content
    self.time = self.___ex.time
end

function GuildLogItemView:start()
end

function GuildLogItemView:InitView(itemModel)
    self.itemModel = itemModel
    self.content.text = itemModel:GetContent()
    self.time.text = itemModel:GetTime()
end

function GuildLogItemView:onDestroy()
end

return GuildLogItemView