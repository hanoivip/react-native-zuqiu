local SignTipCtrl = require("ui.controllers.activity.content.SignTipCtrl")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local ActivityContentBaseCtrl = require("ui.controllers.activity.content.ActivityContentBaseCtrl")
local SignCtrl = class(ActivityContentBaseCtrl)

function SignCtrl:InitWithProtocol()
    self.view = self.contentPrefab:GetComponent(clr.CapsUnityLuaBehav)
    self.view:InitView(self.activityModel)
    self.view.clickSign = function() self:ClickSign() end
end

function SignCtrl:ClickClose()

end

function SignCtrl:ClickSign()
    local isSigned = self.activityModel:GetSign()
    if isSigned then
        return
    end

    clr.coroutine( function()
        local response = req.activitySign()
        if api.success(response) then
            local data = response.val
            CongratulationsPageCtrl.new(data.contents)
            self.activityModel:SetSignCollect(data)
        end
    end)
end

function SignCtrl:OnRefresh()
    self.view:OnRefresh()
end

function SignCtrl:OnEnterScene()
    self.view:OnEnterScene()
end

function SignCtrl:OnExitScene()
    self.view:OnExitScene()
end

return SignCtrl
