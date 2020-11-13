local ActivityContentBaseCtrl = require("ui.controllers.activity.content.ActivityContentBaseCtrl")

local NationalWelfareCtrl = class(ActivityContentBaseCtrl)

function NationalWelfareCtrl:InitWithProtocol()
    self.view = self.contentPrefab:GetComponent(clr.CapsUnityLuaBehav)
    self.view:InitView(self.activityModel)
    self.view.onVip = function () self:onVip() end
end

function NationalWelfareCtrl:OnRefresh()
end
--[[
function NationalWelfareCtrl:ResetCousume()
    -- 更新数据
    clr.coroutine(function()
        local response = req.activityList(nil, nil, true)
        if api.success(response) then
            local data = response.val
            for k, v in pairs(data.list) do
                if v.type == "CumulativePay" then
                    self.activityModel.singleData = v
                    break
                end
            end
        end
    end)
end]]

function NationalWelfareCtrl:onVip()
    res.PushDialog("ui.controllers.charge.ChargeAndVIPCtrl", "vip")
end

function NationalWelfareCtrl:OnEnterScene()
    self.view:OnEnterScene()
end

function NationalWelfareCtrl:OnExitScene()
    self.view:OnExitScene()
end

return NationalWelfareCtrl

