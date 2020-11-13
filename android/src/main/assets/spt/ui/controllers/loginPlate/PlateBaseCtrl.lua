local PlateBaseCtrl = class()

function PlateBaseCtrl:ctor(viewPath, parentScript, plateModel)
    local dialog, dialogcomp = res.ShowDialog(viewPath, "camera", false, true)
    self.parentScript = parentScript
    self.plateModel = plateModel
    self.dialogcomp = dialogcomp
    self.view = self.dialogcomp.contentcomp
    self.dialogcomp.OnExitScene = function() self:OnExitDialog() end
    self:InitWithProtocol()
    self:OnEnterScene()
end 

function PlateBaseCtrl:InitWithProtocol()
end

-- 与pushscene 保持一致
function PlateBaseCtrl:OnEnterScene()
end

function PlateBaseCtrl:OnExitScene()
end

function PlateBaseCtrl:OnExitDialog()
    self:OnExitScene()
    self:ClosePlate()
end

function PlateBaseCtrl:Close()
    self.dialogcomp.closeDialog()
end

function PlateBaseCtrl:ClosePlate()
    if self.closePlate then 
        self.closePlate()
    end
end

return PlateBaseCtrl
