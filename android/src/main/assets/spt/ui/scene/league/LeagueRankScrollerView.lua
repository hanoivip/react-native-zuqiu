local UnityEngine = clr.UnityEngine
local UI = UnityEngine.UI
local Image = UI.Image
local Text = UI.Text
local Object = UnityEngine.Object
local GameObject = UnityEngine.GameObject

local LuaScrollRectEx = require("ui.control.scroll.LuaScrollRectEx")

local LeagueRankScrollerView = class(LuaScrollRectEx)

function LeagueRankScrollerView:ctor()
    self.content = self.___ex.content
    self.cScrollRect = self.___ex.cScrollRect
    -- model
    self.leagueInfoModel = nil
    -- 排行榜数据
    self.rankData = nil
    -- 玩家ID
    self.playerID = nil
    self.super.ctor(self)
end

function LeagueRankScrollerView:InitView(leagueInfoModel)
    self.leagueInfoModel = leagueInfoModel
    self.rankData = self.leagueInfoModel:GetRankData()
    self.playerID = self.leagueInfoModel:GetPlayerID()
    self.itemDatas = self.rankData.rankLeague
    
    self:BuildPage()
end

function LeagueRankScrollerView:start()
end

function LeagueRankScrollerView:BuildPage()
    self:refresh()
end

function LeagueRankScrollerView:CreateItem(index, node)
    local nodeScript = node:GetComponent(clr.CapsUnityLuaBehav)
    node.script = nodeScript
    node.transform:SetParent(self.content, false)
    nodeScript:InitView(index, self.itemDatas[index], self.playerID)
    return node
end

function LeagueRankScrollerView:ResetItem(spt, index)
    spt:InitView(index, self.itemDatas[index], self.playerID)
    spt:BuildPage()
end

function LeagueRankScrollerView:getItemTag(index)
    if index <= 3 then
        return "PrefabTop"
    else
        return "PrefabNormal"
    end
end

function LeagueRankScrollerView:createItemByTagPrefabTop(index)
    local node = Object.Instantiate(res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/League/LeagueRankTopBar.prefab", GameObject))
    self:CreateItem(index, node)
    return node
end

function LeagueRankScrollerView:resetItemByTagPrefabTop(spt, index)
    self:ResetItem(spt, index)
end

function LeagueRankScrollerView:createItemByTagPrefabNormal(index)
    local node = Object.Instantiate(res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/League/LeagueRankNormalBar.prefab", GameObject))
    self:CreateItem(index, node)
    return node
end

function LeagueRankScrollerView:resetItemByTagPrefabNormal(spt, index)
    self:ResetItem(spt, index)
end

function LeagueRankScrollerView:Clear()
    self.cScrollRect:ClearData()
end

return LeagueRankScrollerView
