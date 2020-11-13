local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object

local ObjectPool = class()

function ObjectPool:ctor(prefab)
    self.prefab = prefab
    self.pool = {}
end

function ObjectPool:getObject()
    if #self.pool == 0 then
        if self.prefab and self.prefab ~= clr.null then
            return Object.Instantiate(self.prefab)
        end
    else
        return table.remove(self.pool)
    end
end

function ObjectPool:returnObject(obj)
    if type(self.pool) == "table" then
        table.insert(self.pool, obj)
    end
end

function ObjectPool:allocate(parent, count)
    if self.prefab and self.prefab ~= clr.null then
        for i = 1, count do
            local obj = Object.Instantiate(self.prefab)
            obj.transform:SetParent(parent, false)
            obj:SetActive(false)
            table.insert(self.pool, obj)
        end
    end
end

function ObjectPool:getCount()
    if type(self.pool) == "table" then
        return #self.pool
    else
        return 0
    end
end

function ObjectPool:destroy()
    self.prefab = nil
    self.pool = nil
end

return ObjectPool
