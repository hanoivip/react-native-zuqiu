local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector3 = UnityEngine.Vector3
local Vector2 = UnityEngine.Vector2
local GameObjectHelper = require("ui.common.GameObjectHelper")

local CoachTalentTreeView = class(unity.base, "CoachTalentTreeView")

-- Parameter = {
--     offset_x = 0,  -- 整体x方向偏移
--     offset_y = 0,  -- 整体y方向偏移
--     nodeWidth = 100,  -- 结点宽度
--     nodeHeight = 100,  -- 结点高度
--     nodeMargin_x = 0,  -- 结点x方向间距
--     nodeMargin_y = 0,  -- 结点y方向间距
--     arrowOffset_x = 0,  -- 箭头x方向偏移
--     arrowOffset_y = 0,  -- 箭头y方向偏移
--     isFix = false, -- 是否可以滑动
-- }

function CoachTalentTreeView:ctor()
    self.objScroll = self.___ex.objScroll
    self.rctScrollContainer = self.___ex.rctScrollContainer
    self.rctFixContainer = self.___ex.rctFixContainer
    -- 对象池控制脚本
    self.sptPool = self.___ex.sptPool

    self.sptNodes = {} -- 结点的列表
end

function CoachTalentTreeView:start()
    self:RegBtnEvent()
end

function CoachTalentTreeView:InitView(capacity)
    self.sptPool:InitView(capacity)
end

function CoachTalentTreeView:OnEnterScene()
end

function CoachTalentTreeView:OnExitScene()
end

function CoachTalentTreeView:RegBtnEvent()
end

-- 回收所有对象
function CoachTalentTreeView:CollectAllObjs()
    self.sptPool:CollectAllObjs()
    res.ClearChildren(self.rctScrollContainer)
    res.ClearChildren(self.rctFixContainer)
    self.sptNodes = {}
end

-- 更新天赋树
function CoachTalentTreeView:RefreshTreeView(talentTree, param)
    -- 整体
    self.offset_x = param.offset_x or 0
    self.offset_y = param.offset_y or 0
    -- 结点
    self.nodeWidth = param.nodeWidth or 100
    self.nodeHeight = param.nodeHeight or 100
    self.nodeMargin_x = param.nodeMargin_x or 20
    self.nodeMargin_y = param.nodeMargin_y or 20
    -- 箭头&线
    self.arrowOffset_x = param.arrowOffset_x or 0
    self.arrowOffset_y = param.arrowOffset_y or 0
    -- 是否可以滑动
    self.isFix = param.isFix or false
    -- 短横线长度
    self.shortLineLength = self.nodeMargin_x * 0.618
    -- 长箭头长度
    self.longArrowLength = self.nodeMargin_x * 2
    -- 短箭头长度
    self.shortArrowLength = self.nodeMargin_x * (2 - 0.618)

    self.talentTree = talentTree

    self:CollectAllObjs()

    local treeBreadth = self.talentTree:GetBreadth() -- 树的广度

    if self.isFix then
        GameObjectHelper.FastSetActive(self.rctFixContainer.gameObject, true)
        GameObjectHelper.FastSetActive(self.objScroll.gameObject, false)
    else
        GameObjectHelper.FastSetActive(self.rctFixContainer.gameObject, false)
        GameObjectHelper.FastSetActive(self.objScroll.gameObject, true)
        self.rctScrollContainer.sizeDelta = Vector2(self.rctScrollContainer.sizeDelta.x, treeBreadth * (self.nodeHeight + 2 * self.nodeMargin_y) + math.abs(self.offset_y))
    end
    -- 利用层次遍历生成树形
    -- 先确定结点位置，再计算连线
    self.talentTree:LevelTraversingCus(function(level, queue, result)
        local addedBreadth = 0
        for k, node in pairs(queue) do
            if node:GetContent() then -- 排除虚根
                local x = 0 -- 广度方向的位置
                local y = node:GetDepth() -- 深度方向的位置
                if node:IsRoot() then
                    -- 根节点，以整棵树的广度中心生成x位置
                    x = math.ceil(treeBreadth / 2)
                else
                    x = addedBreadth + 1
                    local breadth = node:GetBreadth()
                    -- 根据父结点位置调整，x不能超过父结点x
                    local parent = node:GetParent()
                    if parent ~= nil and not parent:IsRoot() then
                        local parentSpt = self.sptNodes[parent:GetId()]
                        if parentSpt ~= nil then
                            local parentX = parentSpt:GetGrid().x
                            if x < parentX then
                                x = parentX
                                addedBreadth = parentX - breadth
                            end
                        end
                    end
                    addedBreadth = addedBreadth + breadth
                end
                -- 生成结点并初始化内容
                local obj, spt = self:InstantiateNode()
                if obj == nil or spt == nil then break end
                self:SetParent(obj)
                spt:InitView(node)
                spt:SetGrid(x, y)
                self.sptNodes[node:GetId()] = spt
            end
        end
    end)
    -- 设置结点位置
    for id, nodeSpt in pairs(self.sptNodes) do
        local grid = nodeSpt:GetGrid()
        local node = nodeSpt:GetNode()
        local childsCount = node:GetChildsCount()
        if node:IsRoot() and childsCount % 2 <= 0 then
            -- 有偶数个根节点特殊处理
            nodeSpt:SetPosition(self:CalcRootPosition(grid.x, grid.y))
        else
            nodeSpt:SetPosition(self:CalcNodePosition(grid.x, grid.y))
        end
    end
    -- 根据结点位置划线并设置位置
    for id, nodeSpt in pairs(self.sptNodes) do
        local node = nodeSpt:GetNode()
        local nodePos = nodeSpt:GetPosition()
        -- 生成左侧箭头
        local parent = node:GetParent()
        if not node:IsRoot() and parent:GetContent() then
            local arrowObj, arrowSpt = self.sptPool:GetArrow()
            self:SetParent(arrowObj)
            self:SetSiblingIndex(arrowObj, 0)
            if parent:GetChildsCount() > 1 then
                arrowSpt:InitView(self:CalcShortArrowPosition(nodePos.x, nodePos.y), self.shortArrowLength) -- 短箭头
            else
                arrowSpt:InitView(self:CalcArrowPosition(nodePos.x, nodePos.y), self.longArrowLength) -- 长箭头
            end
            nodeSpt:SetFrontArrow(arrowSpt)
            nodeSpt:InitArrowState()
        end
        -- 若有多个子结点，生成右侧多路出口
        if not node:IsLeaf() and node:GetChildsCount() > 1 then
            -- 生成多叉
            -- 一个短横线
            local shortObj, shortSpt = self.sptPool:GetLine()
            self:SetParent(shortObj)
            shortSpt:InitView(self:CalcShortLinePosition(nodePos.x, nodePos.y), self.shortLineLength, "horizontal")
            -- 根据子结点位置生成竖线
            local min, max
            for k, child in pairs(node:GetChilds()) do
                local childId = child:GetId()
                local childSpt = self.sptNodes[childId]
                if childSpt then
                    local pos = childSpt:GetPosition()
                    if min == nil or min:GetPosition().y > pos.y then
                        min = childSpt
                    end
                    if max == nil or max:GetPosition().y < pos.y then
                        max = childSpt
                    end
                end
            end
            local maxPos = max:GetPosition() -- Unity中向下是y的负方向，因此max为最上面的点
            local longObj, longSpt = self.sptPool:GetLine()
            self:SetParent(longObj)
            longSpt:InitView(self:CalcVerLinePosition(maxPos.x, maxPos.y), math.abs(maxPos.y - min:GetPosition().y))
            local lines = {}
            table.insert(lines, shortSpt)
            table.insert(lines, longSpt)
            nodeSpt:SetBehindLines(lines)
            nodeSpt:InitLineState()
        end
    end
end

function CoachTalentTreeView:InstantiateNode()
    local obj, spt
    if self.sptPool then
        obj, spt =  self.sptPool:GetNode()
    end
    return obj, spt
end

function CoachTalentTreeView:SetSiblingIndex(obj, index)
    obj.transform:SetSiblingIndex(index)
end

-- 根据结点网格位置，生成RectTransform位置
function CoachTalentTreeView:CalcNodePosition(x, y)
    return Vector2((y - 1) * (self.nodeWidth + 2 * self.nodeMargin_x) + self.offset_x,
                    (x - 1) * -(self.nodeHeight + 2 * self.nodeMargin_y) + self.offset_y)
end

-- 根据结点网格位置，生成Rectran
function CoachTalentTreeView:CalcRootPosition(x, y)
    return Vector2((y - 1) * (self.nodeWidth + 2 * self.nodeMargin_x) + self.offset_x,
                (x - 1) * -(self.nodeHeight + 2 * self.nodeMargin_y) + self.offset_y - self.nodeHeight / 2)
end

-- 生成箭头位置，参数为子结点位置
function CoachTalentTreeView:CalcArrowPosition(node_x, node_y)
    return Vector2(node_x - self.longArrowLength + self.arrowOffset_x,
                    node_y - self.nodeHeight / 2 + self.arrowOffset_y)
end

-- 多叉的短横线位置，参数为父结点位置
function CoachTalentTreeView:CalcShortLinePosition(node_x, node_y)
    return Vector2(node_x + self.nodeWidth + self.arrowOffset_x,
                    node_y - self.nodeHeight / 2 + self.arrowOffset_y)
end

-- 多叉的竖向直线，参数为子节点位置
function CoachTalentTreeView:CalcVerLinePosition(node_x, node_y)
    return Vector2(node_x - math.ceil(self.shortArrowLength) + self.arrowOffset_x,
                    node_y - self.nodeHeight / 2 + self.arrowOffset_y)
end

-- 多叉的短箭头位置，参数为子结点位置
function CoachTalentTreeView:CalcShortArrowPosition(node_x, node_y)
    return Vector2(node_x -  math.floor(self.shortArrowLength) + self.arrowOffset_x,
                    node_y - self.nodeHeight / 2 + self.arrowOffset_y)
end

-- 设置父级
function CoachTalentTreeView:SetParent(obj)
    if self.isFix then
        obj.transform:SetParent(self.rctFixContainer, false)
    else
        obj.transform:SetParent(self.rctScrollContainer, false)
    end
end

return CoachTalentTreeView
