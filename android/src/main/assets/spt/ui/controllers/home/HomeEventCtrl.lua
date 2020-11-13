local PlayerHomeEventModel = require("ui.models.PlayerHomeEventModel")
local HomeEventCtrl = class()

function HomeEventCtrl:ctor(homeEventModel)
    if not homeEventModel then 
        homeEventModel = PlayerHomeEventModel.new()
    end
    self.homeEventModel = homeEventModel

    self:InitView()
end

function HomeEventCtrl:InitView()
    self:SignPlateEvent()
end

-- 特殊处理签到在不重新登陆直接到下一天回主界面后主动弹出签到面板（中文版手动签到）
function HomeEventCtrl:SignPlateEvent()
    local HasSignPlate = self.homeEventModel:HasSignPlate()
    if HasSignPlate then 
        local signPlate = self.homeEventModel:GetSignNoteData()
        local signModel = require("ui.models.activity.SignModel").new(signPlate)
        local isSigned = signModel:GetSign()
        if isSigned then return end

        local signCtrl = require("ui.controllers.loginPlate.SignPlateCtrl")
        if not signCtrl.isOpenSignedPage then
            signCtrl.new("Assets/CapstonesRes/Game/UI/Scene/Activties/Calendar/CalendarBoard.prefab", self, signModel)
        end
    end
end

return HomeEventCtrl
