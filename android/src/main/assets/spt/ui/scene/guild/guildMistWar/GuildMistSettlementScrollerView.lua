local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local GameObject = UnityEngine.GameObject
local GuildSettlementItemModel = require("ui.models.guild.guildWar.GuildSettlementItemModel")

local LuaScrollRectEx = require("ui.control.scroll.LuaScrollRectEx")

local GuildMistSettlementScrollerView = class(LuaScrollRectEx)

function GuildMistSettlementScrollerView:ctor()
    self.content = self.___ex.content
    self.cScrollRect = self.___ex.cScrollRect:GetComponent("ScrollRectEx")
    self.super.ctor(self)
    self.itemDatas = {}
end

function GuildMistSettlementScrollerView:InitView(data)
    if #self.itemDatas > 0 then return end
    for i = 1, #data do
        local itemModel = GuildSettlementItemModel.new(data[i])
        table.insert(self.itemDatas, itemModel)
    end
    self:refresh()    
end

function GuildMistSettlementScrollerView:ResetItem(spt, index)
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

function GuildMistSettlementScrollerView:getItemTag(index)
    if self.itemDatas[index]:GetIsItem() then
        return "PrefabItem"
    else
        return "PrefabContent"
    end
end

function GuildMistSettlementScrollerView:createItemByTagPrefabItem()
    local path = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildMistWar/GuildMistSettlementItem.prefab"
    local node = Object.Instantiate(res.LoadRes(path, GameObject))
    return node
end

function GuildMistSettlementScrollerView:resetItemByTagPrefabItem(spt, index)
    self:ResetItem(spt, index)
end

function GuildMistSettlementScrollerView:createItemByTagPrefabContent()
    local path = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildMistWar/GuildMistSettlementContent.prefab"
    local node = Object.Instantiate(res.LoadRes(path, GameObject))
    return node
end

function GuildMistSettlementScrollerView:resetItemByTagPrefabContent(spt, index)
    self:ResetItem(spt, index)
end

return GuildMistSettlementScrollerView
