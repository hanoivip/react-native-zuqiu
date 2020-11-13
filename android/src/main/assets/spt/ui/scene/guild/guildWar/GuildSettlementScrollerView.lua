local UnityEngine = clr.UnityEngine
local UI = UnityEngine.UI
local Image = UI.Image
local Text = UI.Text
local Object = UnityEngine.Object
local GameObject = UnityEngine.GameObject
local Vector2 = UnityEngine.Vector2
local ScrollRectEx = clr.ScrollRectEx
local GuildSettlementItemModel = require("ui.models.guild.guildWar.GuildSettlementItemModel")

local LuaScrollRectEx = require("ui.control.scroll.LuaScrollRectEx")

local GuildSettlementScrollerView = class(LuaScrollRectEx)

function GuildSettlementScrollerView:ctor()
    self.content = self.___ex.content
    self.cScrollRect = self.___ex.cScrollRect
    self.super.ctor(self)
    self.itemDatas = {}
end

function GuildSettlementScrollerView:InitView(data)
    if #self.itemDatas > 0 then return end
    for i = 1, #data do
        local itemModel = GuildSettlementItemModel.new(data[i])
        table.insert(self.itemDatas, itemModel)
    end
    self:refresh()    
end

function GuildSettlementScrollerView:ResetItem(spt, index)
    spt:InitView(self.itemDatas[index])
    spt.ItemClickFunc = function()
        local isSpread = clone(self.itemDatas[index]:GetIsSpread())
        local data = clone(self.itemDatas[index]:GetData())
        data.isItem = false
        local itemModel = GuildSettlementItemModel.new(data)
        if isSpread == true then
            self.itemDatas[index]:SetIsSpread(false)             
            self:removeItem(index + 1)
        else
            self.itemDatas[index]:SetIsSpread(true)             
            self:addItem(itemModel, index + 1)
        end
    end
end

function GuildSettlementScrollerView:getItemTag(index)
    if self.itemDatas[index]:GetIsItem() then
        return "PrefabItem"
    else
        return "PrefabContent"
    end
end

function GuildSettlementScrollerView:createItemByTagPrefabItem()
    local path = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildWar/GuildSettlementItem.prefab"
    local node = Object.Instantiate(res.LoadRes(path, GameObject))
    return node
end

function GuildSettlementScrollerView:resetItemByTagPrefabItem(spt, index)
    self:ResetItem(spt, index)
end

function GuildSettlementScrollerView:createItemByTagPrefabContent()
    local path = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildWar/GuildSettlementContent.prefab"
    local node = Object.Instantiate(res.LoadRes(path, GameObject))
    return node
end

function GuildSettlementScrollerView:resetItemByTagPrefabContent(spt, index)
    self:ResetItem(spt, index)
end

return GuildSettlementScrollerView
