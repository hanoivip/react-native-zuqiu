local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local StaticCardModel = require("ui.models.cardDetail.StaticCardModel")
local CardBuilder = require("ui.common.card.CardBuilder")
local LuaScrollRectEx = require("ui.control.scroll.LuaScrollRectEx")
local CourtScoutPlayerListScrollView = class(LuaScrollRectEx)

function CourtScoutPlayerListScrollView:ctor()
    CourtScoutPlayerListScrollView.super.ctor(self)
    self.content = self.___ex.content
    self.cScrollRect = self.___ex.cScrollRect
end

local function sortQualityAsc(aModel, bModel)
    return aModel:GetCardQuality() > bModel:GetCardQuality()
end

-- 优化多等级不同大小显示按每6个为一栏作为一个itemlist整体
local FixedColumn = 6
function CourtScoutPlayerListScrollView:InitView(data, cardResourceCache, scoutLvl, courtBuildModel)
    self.scoutLvl = scoutLvl
    self.cardResourceCache = cardResourceCache
    self.courtBuildModel = courtBuildModel
    local newData = {}
    local count, row = 0, 0
    for i, v in ipairs(data) do
        local begin = #newData + 1
        newData[begin] = {title = {}}
        count = 0 

        local cardModelMap = {}
        for m, cid in ipairs(v) do
            local playerCardStaticModel = StaticCardModel.new(cid)
            table.insert(cardModelMap, playerCardStaticModel)
        end
        table.sort(cardModelMap, sortQualityAsc)

        for index, model in ipairs(cardModelMap) do
            row = math.floor(count / FixedColumn)
            if count % FixedColumn == 0 then 
                newData[begin + row + 1] = {itemList = {}}
            end
            table.insert(newData[begin + row + 1].itemList, model)
            count = count + 1
        end
        newData[begin].title.index = i
        newData[begin].title.playerNum = #v
    end
    self:refresh(newData)
    local sortIndex = courtBuildModel:GetScoutPlayerSortIndex()
    if sortIndex then 
        self:scrollToCellImmediate(sortIndex)
        courtBuildModel:SetScoutPlayerSortIndex(nil)
    end
end

function CourtScoutPlayerListScrollView:OnBtnCard(cid, sortIndex)
    self.courtBuildModel:SetScoutPlayerSortIndex(sortIndex)
    local currentModel = CardBuilder.GetBaseCardModel(cid)
    res.PushScene("ui.controllers.cardDetail.CardDetailMainCtrl", {cid}, 1, currentModel)
end

function CourtScoutPlayerListScrollView:GetPlayerRes()
    if not self.playerRes then 
        self.playerRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Court/Prefab/ScoutPlayer.prefab")
    end
    return self.playerRes
end

function CourtScoutPlayerListScrollView:GetCardRes()
    if not self.cardRes then 
        self.cardRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Card/Prefab/Card.prefab")
    end
    return self.cardRes
end

function CourtScoutPlayerListScrollView:GetPlayerBarRes()
    if not self.playerBarRes then 
        self.playerBarRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Court/Prefab/ScoutPlayerBar.prefab")
    end
    return self.playerBarRes
end

function CourtScoutPlayerListScrollView:GetPlayerBarTitleRes()
    if not self.playerBarTileRes then 
        self.playerBarTileRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Court/Prefab/ScoutPlayerBarTitle.prefab")
    end
    return self.playerBarTileRes
end

function CourtScoutPlayerListScrollView:CreateItem(node)
    local nodeScript = node:GetComponent(clr.CapsUnityLuaBehav)
    node.script = nodeScript
    node.script.clickCard = function(cid, sortIndex) self:OnBtnCard(cid, sortIndex) end
    node.transform:SetParent(self.content, false)
    return node
end

function CourtScoutPlayerListScrollView:ResetItem(spt, index)
    local playerRes = self:GetPlayerRes()
    local cardRes = self:GetCardRes()
    spt:InitView(index, self.itemDatas[index].itemList, playerRes, cardRes, self.cardResourceCache)
end

function CourtScoutPlayerListScrollView:CreateItemTitle(node)
    local nodeScript = node:GetComponent(clr.CapsUnityLuaBehav)
    node.script = nodeScript
    node.transform:SetParent(self.content, false)
    return node
end

function CourtScoutPlayerListScrollView:ResetItemTitle(spt, index)
    spt:InitView(self.itemDatas[index].title.index, self.itemDatas[index].title.playerNum, self.scoutLvl)
end

function CourtScoutPlayerListScrollView:getItemTag(index)
    if self.itemDatas[index].title then 
        return "PrefabTitle"
    else
        return "PrefabNormal"
    end
end

function CourtScoutPlayerListScrollView:createItemByTagPrefabTitle(index)
    local node = Object.Instantiate(self:GetPlayerBarTitleRes())
    self:CreateItemTitle(node)
    return node
end

function CourtScoutPlayerListScrollView:resetItemByTagPrefabTitle(spt, index)
    self:ResetItemTitle(spt, index)
end

function CourtScoutPlayerListScrollView:createItemByTagPrefabNormal(index)
    local node = Object.Instantiate(self:GetPlayerBarRes())
    self:CreateItem(node)
    return node
end

function CourtScoutPlayerListScrollView:resetItemByTagPrefabNormal(spt, index)
    self:ResetItem(spt, index)
end

function CourtScoutPlayerListScrollView:Clear()
    self.cScrollRect:ClearData()
end

return CourtScoutPlayerListScrollView
