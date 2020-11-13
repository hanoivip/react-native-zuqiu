local TreeNode = require("ui.models.coach.talent.tree.TreeNode")

local Tree = class("Tree")

-- @param root[TreeNode] 根节点
function Tree:ctor(root)
    -- 结点总数，算根节点
    self.count = 1
    -- 根节点，若不初值，则自动初始化
    self.root = nil

    if root ~= nil and root.isNode then
        self.root = root
    else
        self.root = TreeNode.new("root")
    end
end

-- 获得根节点
function Tree:GetRoot()
    return self.root
end

-- 获得树宽，某层最多的节点数
function Tree:GetWidth()
    local maxWidth = 0
    self:LevelTraversingCus(function(level, queue, result)
        local width = #queue
        if maxWidth < width then
            maxWidth = width
        end
    end)
    return maxWidth
end

-- 获得树高
function Tree:GetHeight()
    local result = self:DepthFirstTraversingCus(function(result, node)
        if result ~= nil and type(result) == "table" then
            table.insert(result, node:GetDepth())
        end
    end)
    local depth = -1
    for k, v in ipairs(result) do
        if depth < v then
            depth = v
        end
    end
    return depth
end

function Tree:TreeDepthAux(root)
    if not root then return 0 end

    local tempDepth = {}
    local childs = root:GetChilds()
    for k, v in pairs(childs) do
        tempDepth[k] = self:TreeDepthAux(v)
    end
    local max = -1
    for k, v in pairs(tempDepth) do
        if v > max then
            max = v
        end
    end
    return max < 0 and 0 or max + 1
end

-- 获得树的广度，网格化后最大宽度
function Tree:GetBreadth()
    return self.root:GetBreadth()
end

-- 根据id获得结点数据
-- @return [TreeNode] 返回结点数据，未找到为nil
function Tree:GetNode(nodeId)
    return self:DepthFirstSearch(tostring(nodeId))
end

-- 先序深度优先搜索
-- @return [TreeNode] 返回结点数据，未找到为nil
function Tree:DepthFirstSearch(nodeId)
    return self:DepthFirstSearchAUX(self.root, nodeId)
end

function Tree:DepthFirstSearchAUX(root, nodeId)
    if root:GetId() == nodeId then
        return root
    end

    local childs = root:GetChilds()
    for k, node in ipairs(childs or {}) do
        local result = self:DepthFirstSearchAUX(node, nodeId)
        if result ~= nil then
            return result
        end
    end
    return nil
end

-- 先序深度优先遍历，获得结点id数组
-- @return [table] 按序返回节点id的数组
function Tree:DepthFirstTraversing()
    return self:DepthFirstTraversingCus(function(result, node)
        if result ~= nil and type(result) == "table" then
            table.insert(result, node:GetId())
        end
    end)
end

-- 先序深度优先遍历，自定义返回
-- @param action [function] 自定义操作，两个参数，result用于返回的table，node标识当前访问的结点
-- @return [table] 按序返回自定义操作结果
function Tree:DepthFirstTraversingCus(action)
    local result = {}
    if action ~= nil and type(action) == "function" then
        self:DepthFirstTraversingAUX(self.root, result, action)
    end
    return result
end

function Tree:DepthFirstTraversingAUX(root, result, action)
    if action ~= nil and type(action) == "function" then
        action(result, root)
    end
    local childs = root:GetChilds()
    for k, node in ipairs(childs or {}) do
        self:DepthFirstTraversingAUX(node, result, action)
    end
end

-- 层次遍历，自定义操作
-- @param action [function] 自定义操作，三个参数，queue当前层次队列，result结果列表，level当前层次
-- @return [table] 按序返回自定义操作结果
function Tree:LevelTraversingCus(action)
    local result = {}
    local queue = {}
    if action ~= nil and type(action) == "function" then
        self:LevelTraversingAux(self.root, queue, result, action)
    end
    return result
end

function Tree:LevelTraversingAux(root, queue, result, action)
    if action == nil or type(action) ~= "function" then return end
    if queue == nil  then queue = {} end
    if root == nil then return end

    local childs = root:GetChilds()
    local num = 0
    queue[1] = root
    local level = 0
    while #queue > 0 do
        level = level + 1
        action(level, queue, result)
        num = #queue
        for i = 1, num do
            local node = queue[1]
            table.remove(queue, 1)
            for k, v in pairs(node:GetChilds()) do
                table.insert(queue, v)
            end
        end
    end
end

-- 使结点根据id有序，id为数字可用
function Tree:MakeOrderById(sortType)
    if sortType == "descending" then -- 降序
        self:MakeOrder(function(a, b)
            return tonumber(a:GetId()) > tonumber(b:GetId())
        end)
    else -- 默认升序
        self:MakeOrder(function(a, b)
            return tonumber(a:GetId()) < tonumber(b:GetId())
        end)
    end
end

-- 使结点有序，自定义排序算法
function Tree:MakeOrder(sortFunc)
    if sortFunc ~= nil and type(sortFunc) == "function" then
        self:MakeOrderAUX(self.root, sortFunc)
    end
end

-- 深度优先对结点进行规序
function Tree:MakeOrderAUX(treeNode, sortFunc)
    treeNode:SortChilds(sortFunc)
    local childs = treeNode:GetChilds()

    for k, node in ipairs(childs or {}) do
        self:MakeOrderAUX(node, sortFunc)
    end
end

-- 插入节点
function Tree:InsertNode(parentId, treeNode)
    if not treeNode.isNode then return end
    if treeNode:GetId() == tostring(parentId) then return end

    local parentNode = self:GetNode(parentId)
    if parentNode ~= nil then
        treeNode:SetParent(parentNode)
        treeNode:SetDepth(parentNode:GetDepth() + 1)
        parentNode:AddChild(treeNode)
        self.count = self.count + 1
    end
end

-- 根据id更新节点Content
function Tree:UpdateNodeById(oldNodeId, content)
    local oldTreeNode = self:GetNode(oldNodeId)
    self:UpdateNode(oldTreeNode, content)
end

-- 更新节点Content
function Tree:UpdateNode(oldTreeNode, content)
    if not oldTreeNode.isNode then return end

    oldTreeNode:SetContent(content)
end

return Tree
