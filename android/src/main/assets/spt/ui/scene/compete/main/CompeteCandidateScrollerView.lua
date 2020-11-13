local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local GameObject = UnityEngine.GameObject

local FormationConstants = require("ui.scene.formation.FormationConstants")
local CandidateScrollerView = require("ui.scene.formation.CandidateScrollerView")

local CompeteCandidateScrollerView = class(CandidateScrollerView)

function CompeteCandidateScrollerView:ctor()
    CompeteCandidateScrollerView.super.ctor(self)
    
    -- PlayerCardCircle资源路径
    self.playerCardCirclePath = "Assets/CapstonesRes/Game/UI/Scene/Compete/Main/Prefab/CompetePlayerCardCircle.prefab"
end

function CompeteCandidateScrollerView:InitView(waitPlayersNoRepeatList, waitPlayersRepeatList, nowCardShowType, formationSpt, specialEventsMatchId, formationCacheDataModel)
    self.waitPlayersNoRepeatList = waitPlayersNoRepeatList
    self.waitPlayersRepeatList = waitPlayersRepeatList
    self.noRepeatNum = #self.waitPlayersNoRepeatList
    self.repeatNum = #self.waitPlayersRepeatList
    self.nowCardShowType = nowCardShowType
    self.formationSpt = formationSpt
    self.specialEventsMatchId = specialEventsMatchId
    self.formationCacheDataModel = formationCacheDataModel
    self.itemDatas = {}
    table.imerge(self.itemDatas, self.waitPlayersNoRepeatList)
    table.imerge(self.itemDatas, self.waitPlayersRepeatList)
end

function CompeteCandidateScrollerView:createItem(index)
    local playerCardModel = self:GetPlayerCardModelByIndex(index)
    local coupleInfo = self.formationSpt:GetCoupleInfo(playerCardModel:GetPcid())     
    local node = Object.Instantiate(res.LoadRes(self.playerCardCirclePath, GameObject))
    local nodeScript = node:GetComponent(clr.CapsUnityLuaBehav)
    local competeSpecialTeamData = self.formationCacheDataModel and self.formationCacheDataModel.competeSpecialTeamData or nil
    node.script = nodeScript
    node.transform:SetParent(self.content, false)
    nodeScript:SetCardResCache(self.cardResourceCache)
    nodeScript:initDataByModel(index, self:GetPlayerCardModelByIndex(index), self.nowCardShowType, FormationConstants.PlayersClassifyInFormation.WAIT, nil, nil, nil, self.specialEventsMatchId, competeSpecialTeamData)
    nodeScript:SetChemical(coupleInfo)
    nodeScript:SetCoupleState(self.formationSpt:GetCoupleState())
    nodeScript:SetScrollRectParent(self.scrollRect)
    self:updateItemIndex(nodeScript, index)
    return node
end

function CompeteCandidateScrollerView:resetItem(spt, index)
    self:updateItemIndex(spt, index)
    local playerCardModel = self:GetPlayerCardModelByIndex(index)
    local coupleInfo = self.formationSpt:GetCoupleInfo(playerCardModel:GetPcid())
    local competeSpecialTeamData = self.formationCacheDataModel and self.formationCacheDataModel.competeSpecialTeamData or nil
    spt:SetCardResCache(self.cardResourceCache)
    spt:initDataByModel(index, self:GetPlayerCardModelByIndex(index), self.nowCardShowType, FormationConstants.PlayersClassifyInFormation.WAIT, nil, nil, nil, self.specialEventsMatchId, competeSpecialTeamData)
    spt:SetChemical(coupleInfo)
    spt:SetCoupleState(self.formationSpt:GetCoupleState())
    spt:BuildPage()
end

return CompeteCandidateScrollerView
