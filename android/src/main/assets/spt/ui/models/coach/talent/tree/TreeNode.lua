local TreeNode = class("TreeNode")

function TreeNode:ctor(id, content, parent, childs)
    -- 唯一id
    self.id = nil
    -- 结点的内容，自定义数据或对象
    self.content = nil
    -- 父结点对象
    self.parent = nil
    -- 子树结点对象数组
    self.childs = {}
    -- 深度
    self.depth = 1
    -- 本棵子树的广度
    self.breadth = 0

    self.isNode = true

    self:SetId(id)
    self:SetContent(content)
    self:SetParent(parent)
    self:SetChilds(childs)
end

-- 获取唯一标识
function TreeNode:GetId()
    return self.id
end

-- 设置唯一标识
function TreeNode:SetId(id)
    if id ~= nil and type(id) == "string" then
        self.id = id
    end
end

-- 获取内容
function TreeNode:GetContent()
    return self.content
end

-- 设置内容
function TreeNode:SetContent(content)
    if content ~= nil then
        self.content = content
    end
end

-- 获取父结点
function TreeNode:GetParent()
    return self.parent
end

-- 设置父结点
function TreeNode:SetParent(parent)
    if parent ~= nil and type(parent) == "table" then
        self.parent = parent
    end
end

-- 是否是根节点
function TreeNode:IsRoot()
    return tobool(self.parent == nil)
end

function TreeNode:IsLeaf()
    return tobool(self:GetChildsCount() <= 0)
end

-- 获取子结点table
function TreeNode:GetChilds()
    return self.childs
end

-- 设置子结点table
function TreeNode:SetChilds(childs)
    if childs ~= nil and type(childs) == "table" then
        self.childs = childs
    end
end

-- 根据id获取单个子结点
function TreeNode:GetChild(childId)
    for k, child in ipairs(self.childs) do
        if child:GetId() == childId then
            return child
        end
    end
    return nil
end

-- 增加/更新一个子结点
function TreeNode:AddChild(child)
    if child ~= nil and type(child) == "table" then
        table.insert(self.childs, child)
    end
end

-- 获取子节点数目
function TreeNode:GetChildsCount()
    return table.nums(self.childs)
end

-- 子节点排序
function TreeNode:SortChilds(sortFunc)
    if sortFunc ~= nil and type(sortFunc) == "function" then
        table.sort(self.childs, sortFunc)
    end
end

-- 获得深度
function TreeNode:GetDepth()
    return self.depth
end

-- 设置深度
function TreeNode:SetDepth(depth)
    self.depth = depth
end

-- 获得广度
function TreeNode:GetBreadth()
    if self:IsLeaf() then self.breadth = 1 end -- 叶子结点，返回1
    if self.breadth > 0 then return self.breadth end

    self.breadth = 0
    for k, child in pairs(self.childs) do
        self.breadth = self.breadth + child:GetBreadth()
    end
    return self.breadth
end

function TreeNode:ResetBreadth()
    self.breadth = 0
end

return TreeNode
