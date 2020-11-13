local LoginPlateModel = require("ui.models.loginPlate.LoginPlateModel")
local LoginPlateRes = require("ui.scene.loginPlate.LoginPlateRes")
local LoginPlateCtrl = class()

function LoginPlateCtrl:ctor()
    self.loginPlateRes = LoginPlateRes.new()
    self.loginPlateModel = LoginPlateModel.new(self.loginPlateRes)
    self:Init()
end

function LoginPlateCtrl:Init()
    local plateCount = self.loginPlateModel:GetPlateCount()
    if plateCount > 0 then 
        self:PopNextPlate()
    end
end

function LoginPlateCtrl:ClosePlate()
    self.loginPlateModel:RemovePreviousPlate()
    self:PopNextPlate()
end

function LoginPlateCtrl:PopNextPlate()
    local plateModel, plateType, plateId = self.loginPlateModel:GetNextPlateData()
    if plateModel then
        local prefabRes = self.loginPlateRes:GetPlatePrefabPath(plateType, plateId)
        if prefabRes then
            local plateCtrlPath = self.loginPlateRes:GetPlateControllerPath(plateType, plateId)
            if not plateCtrlPath then 
                plateCtrlPath = "ui.controllers.loginPlate.PlateBaseCtrl"
            end
            local plateCtrl = require(plateCtrlPath).new(prefabRes, self, plateModel)
            plateCtrl.closePlate = function() self:ClosePlate() end
        end
    end
end

return LoginPlateCtrl
