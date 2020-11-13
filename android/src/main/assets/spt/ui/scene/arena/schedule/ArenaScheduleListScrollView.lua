local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local ArenaScheduleTeamModel = require("ui.models.arena.schedule.ArenaScheduleTeamModel")
local LuaScrollRectEx = require("ui.control.scroll.LuaScrollRectEx")
local ArenaScheduleListScrollView = class(LuaScrollRectEx)

function ArenaScheduleListScrollView:ctor()
    ArenaScheduleListScrollView.super.ctor(self)
    self.content = self.___ex.content
    self.cScrollRect = self.___ex.cScrollRect
end

-- 构建数据
function ArenaScheduleListScrollView:InitView(arenaTeamMatchModel, groupIndex)
    self.groupIndex = groupIndex
    local newData = {}
    local scoreData = arenaTeamMatchModel:GetScoreData(groupIndex)
    local score = {}
    score.title = "score"
    score.list = scoreData
    score.index = 1
    newData[1] = score
    local groupData = arenaTeamMatchModel:GetGroupData(groupIndex)
    for i, v in ipairs(groupData) do
        local group = {}
        group.title = "group"
        group.list = v
        group.index = i
        newData[i + 1] = group
    end
    self:refresh(newData)
end

function ArenaScheduleListScrollView:GetScoreRes()
    if not self.scoreRes then 
        self.scoreRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Arena/Prefab/TeamScoreInfo.prefab")
    end
    return self.scoreRes
end

function ArenaScheduleListScrollView:GetGroupBarRes()
    if not self.groupBarRes then 
        self.groupBarRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Arena/Prefab/GroupBar.prefab")
    end
    return self.groupBarRes
end

function ArenaScheduleListScrollView:CreateItemGroup(node)
    local nodeScript = node:GetComponent(clr.CapsUnityLuaBehav)
    node.script = nodeScript
    node.transform:SetParent(self.content, false)
    return node
end

function ArenaScheduleListScrollView:ResetItemGroup(spt, index)
    spt:InitView(self.itemDatas[index].index, self.itemDatas[index].list, ArenaScheduleTeamModel.GetInstance())
end

function ArenaScheduleListScrollView:CreateItemScore(node)
    local nodeScript = node:GetComponent(clr.CapsUnityLuaBehav)
    node.script = nodeScript
    node.transform:SetParent(self.content, false)
    return node
end

function ArenaScheduleListScrollView:ResetItemScore(spt, index)
    spt:InitView(self.itemDatas[index].list,  ArenaScheduleTeamModel.GetInstance(), self.groupIndex)
end

function ArenaScheduleListScrollView:getItemTag(index)
    if self.itemDatas[index].title == "score" then 
        return "PrefabScore"
    elseif self.itemDatas[index].title == "group" then 
        return "PrefabGroup"
    end
end

function ArenaScheduleListScrollView:createItemByTagPrefabScore(index)
    local node = Object.Instantiate(self:GetScoreRes())
    self:CreateItemScore(node)
    return node
end

function ArenaScheduleListScrollView:resetItemByTagPrefabScore(spt, index)
    self:ResetItemScore(spt, index)
end

function ArenaScheduleListScrollView:createItemByTagPrefabGroup(index)
    local node = Object.Instantiate(self:GetGroupBarRes())
    self:CreateItemGroup(node)
    return node
end

function ArenaScheduleListScrollView:resetItemByTagPrefabGroup(spt, index)
    self:ResetItemGroup(spt, index)
end

function ArenaScheduleListScrollView:Clear()
    self.cScrollRect:ClearData()
end

return ArenaScheduleListScrollView
