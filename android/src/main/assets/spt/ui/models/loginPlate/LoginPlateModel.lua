local Model = require("ui.models.Model")
local LoginPlateModel = class(Model)
-- 登录弹板的model
function LoginPlateModel:ctor(plateRes)
    self.plateRes = plateRes
    LoginPlateModel.super.ctor(self)
end

function LoginPlateModel:Init(data)
    if not data then
        data = cache.getLoginPlate()
    end
    self.data = data or {}
end

function LoginPlateModel:GetPlateCount()
    local plateCount = 0
    if self.data then 
        plateCount = table.nums(self.data)
    end
    return plateCount
end

function LoginPlateModel:GetPlateData()
    return self.data
end

local FirstIndex = 1
function LoginPlateModel:GetNextPlateData()
    local nextPlateModel, plateType, plateId
    local nextPlateData = self.data[FirstIndex]
    if nextPlateData then
        plateType = nextPlateData.type
        plateId = nextPlateData.id
        local modelPath = self.plateRes:GetPlateModelPath(plateType, plateId)
        if not modelPath then
            modelPath = "ui.models.loginPlate.PlateBaseModel"
        end
        nextPlateModel = require(modelPath).new(nextPlateData)
    end
    return nextPlateModel, plateType, plateId
end

-- 每关掉一个弹板清除其model数据
function LoginPlateModel:RemovePreviousPlate()
    local plateCount = self:GetPlateCount()
    if plateCount > 0 then 
        table.remove(self.data, FirstIndex)
        self:InitWithProtocol(self.data)
    end
end

function LoginPlateModel:InitWithProtocol(data)
    cache.setLoginPlate(data)
    self:Init(data)
end

return LoginPlateModel
