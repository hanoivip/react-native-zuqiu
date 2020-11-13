local UnityEngine = clr.UnityEngine
local UI = UnityEngine.UI
local Image = UI.Image
local Text = UI.Text
local Object = UnityEngine.Object
local GameObject = UnityEngine.GameObject
local RectTransform = UnityEngine.RectTransform
local Vector2 = UnityEngine.Vector2
local Vector3 = UnityEngine.Vector3

local FormationConstants = require("ui.scene.formation.FormationConstants")
local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")

local CandidateScrollerView = class(LuaScrollRectExSameSize)

function CandidateScrollerView:ctor()
    CandidateScrollerView.super.ctor(self)
    self.content = self.___ex.content
    self.scrollRect = self.___ex.scrollRect
    self.scrollRectTrans = self.___ex.scrollRectTrans
    self.cScrollRect = self.___ex.cScrollRect:GetComponent(clr.ScrollRectExSameSize)
    -- 分割线节点
    self.lineNode = nil
    -- 候补球员数据（不重复的）
    self.waitPlayersNoRepeatList = nil
    -- 候补球员数据（重复的）
    self.waitPlayersRepeatList = nil
    -- 不重复球员的数量
    self.noRepeatNum = 0
    -- 重复球员的数量
    self.repeatNum = 0
    -- 当前卡牌显示类型
    self.nowCardShowType = 0
    self.maxPerLine = 1

    -- PlayerCardCircle资源路径
    self.playerCardCirclePath = "Assets/CapstonesRes/Game/UI/Scene/Formation/PlayerCardCircle.prefab"
end

function CandidateScrollerView:InitView(waitPlayersNoRepeatList, waitPlayersRepeatList, nowCardShowType, formationSpt, specialEventsMatchId)
    self.waitPlayersNoRepeatList = waitPlayersNoRepeatList
    self.waitPlayersRepeatList = waitPlayersRepeatList
    self.noRepeatNum = #self.waitPlayersNoRepeatList
    self.repeatNum = #self.waitPlayersRepeatList
    self.nowCardShowType = nowCardShowType
    self.formationSpt = formationSpt
    self.specialEventsMatchId = specialEventsMatchId
    self.itemDatas = {}
    table.imerge(self.itemDatas, self.waitPlayersNoRepeatList)
    table.imerge(self.itemDatas, self.waitPlayersRepeatList)
end

function CandidateScrollerView:SetCardResCache(cardResourceCache)
    if cardResourceCache then 
        self.cardResourceCache = cardResourceCache 
    end
end

function CandidateScrollerView:BuildPage()
    self:refresh(self.itemDatas, self:getScrollNormalizedPos())
end

--- 根据索引
function CandidateScrollerView:GetPlayerCardModelByIndex(index)
    local playerCardModel = nil

    if index <= self.noRepeatNum then
        playerCardModel = self.waitPlayersNoRepeatList[index]
    else
        index = index - self.noRepeatNum
        playerCardModel = self.waitPlayersRepeatList[index]
    end

    return playerCardModel
end

function CandidateScrollerView:createItem(index)
    local playerCardModel = self:GetPlayerCardModelByIndex(index)
    local coupleInfo = self.formationSpt:GetCoupleInfo(playerCardModel:GetPcid())     
    local node = Object.Instantiate(res.LoadRes(self.playerCardCirclePath, GameObject))
    local nodeScript = node:GetComponent(clr.CapsUnityLuaBehav)
    node.script = nodeScript
    node.transform:SetParent(self.content, false)
    nodeScript:SetCardResCache(self.cardResourceCache)
    nodeScript:initDataByModel(index, self:GetPlayerCardModelByIndex(index), self.nowCardShowType, FormationConstants.PlayersClassifyInFormation.WAIT, nil, nil, nil, self.specialEventsMatchId)
    nodeScript:SetChemical(coupleInfo)
    nodeScript:SetCoupleState(self.formationSpt:GetCoupleState())
    nodeScript:SetScrollRectParent(self.scrollRect)
    self:updateItemIndex(nodeScript, index)
    return node
end

function CandidateScrollerView:resetItem(spt, index)
    self:updateItemIndex(spt, index)
    local playerCardModel = self:GetPlayerCardModelByIndex(index)
    local coupleInfo = self.formationSpt:GetCoupleInfo(playerCardModel:GetPcid())
    spt:SetCardResCache(self.cardResourceCache)
    spt:initDataByModel(index, self:GetPlayerCardModelByIndex(index), self.nowCardShowType, FormationConstants.PlayersClassifyInFormation.WAIT, nil, nil, nil, self.specialEventsMatchId)
    spt:SetChemical(coupleInfo)
    spt:SetCoupleState(self.formationSpt:GetCoupleState())
    spt:BuildPage()
end

function CandidateScrollerView:destroyItem(index)
    EventSystem.SendEvent("RemoveWaitPlayer")
end

function CandidateScrollerView:updateItemIndex(spt, index)
    spt.dataIndex = index
end

function CandidateScrollerView:DeleteItem(index)
    self:removeItem(index)
end

function CandidateScrollerView:RefreshScroller()
    for i = 1, self.content.childCount do
        local node = self.content:GetChild(i - 1).gameObject
        local nodeScript = node:GetComponent(clr.CapsUnityLuaBehav)
        if nodeScript ~= nil then
            nodeScript:SetShowType(self.nowCardShowType)
            nodeScript:BuildPage()
        end
    end
end

function CandidateScrollerView:Clear()
    self.cScrollRect.ClearData()
end

function CandidateScrollerView:ResetWidth(width)
    self:ResetWithViewSize(width, self.scrollRectTrans.sizeDelta.y)
end

return CandidateScrollerView