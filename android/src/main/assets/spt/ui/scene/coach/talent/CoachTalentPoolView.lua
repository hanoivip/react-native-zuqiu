local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector3 = UnityEngine.Vector3
local Vector2 = UnityEngine.Vector2
local GameObjectHelper = require("ui.common.GameObjectHelper")

local CoachTalentPoolView = class(unity.base, "CoachTalentPoolView")

CoachTalentPoolView.nodePre = "Assets/CapstonesRes/Game/UI/Scene/Coach/Talent/Prefabs/CoachTalentNode.prefab"
CoachTalentPoolView.arrowPre = "Assets/CapstonesRes/Game/UI/Scene/Coach/Talent/Prefabs/CoachTalentArrow.prefab"
CoachTalentPoolView.linePre = "Assets/CapstonesRes/Game/UI/Scene/Coach/Talent/Prefabs/CoachTalentLine.prefab"

function CoachTalentPoolView:ctor()
    self.rctContainer = self.___ex.rctContainer

    self.nodes = {}
    self.arrows = {}
    self.lines = {}

    self.capacity = nil -- 对象池容量
    self.nodeCapacity = 0
    self.arrowCapacity = 0
    self.lineCapacity = 0
end

function CoachTalentPoolView:start()
    self:RegBtnEvent()
end

function CoachTalentPoolView:InitView(capacity)
    self.capacity = capacity or 20
    res.ClearChildren(self.rctContainer)

    self.nodeCapacity = self.capacity
    self.arrowCapacity = self.capacity
    self.lineCapacity = self.capacity * 2

    self.currNodeIdx = 1
    for i = 1, self.nodeCapacity do
        local obj, nodeSpt = res.Instantiate(self.nodePre)
        obj.transform:SetParent(self.rctContainer, false)
        obj.transform.localScale = Vector3.one
        obj.transform.localRotation = Vector3.zero
        obj.transform.localPosition = Vector3.zero
        nodeSpt._poolIdx = i
        self.nodes[i] = nodeSpt
    end

    self.currArrowIdx = 1
    for i = 1, self.arrowCapacity do
        local obj, arrowSpt = res.Instantiate(self.arrowPre)
        obj.transform:SetParent(self.rctContainer, false)
        obj.transform.localScale = Vector3.one
        obj.transform.localRotation = Vector3.zero
        obj.transform.localPosition = Vector3.zero
        arrowSpt._poolIdx = i
        self.arrows[i] = arrowSpt
    end

    self.currLineIdx = 1
    for i = 1, self.lineCapacity do
        local obj, lineSpt = res.Instantiate(self.linePre)
        obj.transform:SetParent(self.rctContainer, false)
        obj.transform.localScale = Vector3.one
        obj.transform.localRotation = Vector3.zero
        obj.transform.localPosition = Vector3.zero
        lineSpt._poolIdx = i
        self.lines[i] = lineSpt
    end
end

function CoachTalentPoolView:OnEnterScene()
    -- EventSystem.AddEvent("CoachBaseInfoUpdate_UpdateAfterFormationUpgrade", self, self.UpdateAfterFormationUpgrade)
    -- EventSystem.AddEvent("CoachBaseInfoUpdate_UpdateAfterTacticUpgrade", self, self.UpdateAfterTacticUpgrade)
end

function CoachTalentPoolView:OnExitScene()
    -- EventSystem.RemoveEvent("CoachBaseInfoUpdate_UpdateAfterFormationUpgrade", self, self.UpdateAfterFormationUpgrade)
    -- EventSystem.RemoveEvent("CoachBaseInfoUpdate_UpdateAfterTacticUpgrade", self, self.UpdateAfterTacticUpgrade)
end

function CoachTalentPoolView:RegBtnEvent()
    -- self.btnIntro:regOnButtonClick(function()
    --     if self.onBtnIntroClick then
    --         self.onBtnIntroClick()
    --     end
    -- end)
end

function CoachTalentPoolView:CollectAllObjs()
    self:CollectAllNodes()
    self:CollectAllArrows()
    self:CollectAllLines()
end

function CoachTalentPoolView:GetCapacity()
    return self.capacity
end

function CoachTalentPoolView:SetCapacity(capacity)
    self.capacity = capacity
end

function CoachTalentPoolView:GetNode()
    if self.currNodeIdx > self.nodeCapacity then
        return nil, nil
    end
    local nodeSpt = self.nodes[self.currNodeIdx]
    self.currNodeIdx = self.currNodeIdx + 1
    return nodeSpt.gameObject, nodeSpt
end

function CoachTalentPoolView:CollectAllNodes()
    for i = self.currNodeIdx, 1, -1 do
        self.nodes[i]:ResetState()
        self.nodes[i].transform:SetParent(self.rctContainer, false)
    end
    self.currNodeIdx = 1
end

function CoachTalentPoolView:GetArrow()
    if self.currArrowIdx > self.arrowCapacity then
        return nil, nil
    end
    local arrowSpt = self.arrows[self.currArrowIdx]
    self.currArrowIdx = self.currArrowIdx + 1
    return arrowSpt.gameObject, arrowSpt
end

function CoachTalentPoolView:CollectAllArrows()
    for i = self.currArrowIdx, 1, -1 do
        self.arrows[i]:ResetState()
        self.arrows[i].transform:SetParent(self.rctContainer, false)
    end
    self.currArrowIdx = 1
end

function CoachTalentPoolView:GetLine()
    if self.currLineIdx > self.lineCapacity then
        return nil, nil
    end
    local lineSpt = self.lines[self.currLineIdx]
    self.currLineIdx = self.currLineIdx + 1
    return lineSpt.gameObject, lineSpt
end

function CoachTalentPoolView:CollectAllLines()
    for i = self.currLineIdx, 1, -1 do
        self.lines[i]:ResetState()
        self.lines[i].transform:SetParent(self.rctContainer, false)
    end
    self.currLineIdx = 1
end

return CoachTalentPoolView
