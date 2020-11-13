local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local GuildJoinItemModel = require("ui.models.guild.GuildJoinItemModel")
local CardTrainingMenuScrollView = class(LuaScrollRectExSameSize)

function CardTrainingMenuScrollView:ctor()
    CardTrainingMenuScrollView.super.ctor(self)
end

function CardTrainingMenuScrollView:start()
end

function CardTrainingMenuScrollView:createItem(index)
    local prefab = "Assets/CapstonesRes/Game/UI/Scene/CardTraining/Prefabs/MenuItem.prefab"
    local obj, spt = res.Instantiate(prefab)
    self:resetItem(spt, index)
    return obj
end

function CardTrainingMenuScrollView:resetItem(spt, index)
    spt:InitView(self.data[index])
    self:updateItemIndex(spt, index)
end

function CardTrainingMenuScrollView:InitView(data)
    self.data = data
    self:refresh(self.data)
end

return CardTrainingMenuScrollView