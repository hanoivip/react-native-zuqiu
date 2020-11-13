local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local OldPlayerContentBaseCtrl = class()

function OldPlayerContentBaseCtrl:ctor(parentContent, viewPath)
    local viewObject, viewSpt = res.Instantiate(viewPath)
    viewObject.transform:SetParent(parentContent.transform, false)
    self.view = viewSpt
end

function OldPlayerContentBaseCtrl:OnRecv(recvData, reqCallBack)
    if self.isReq then return end
    if type(reqCallBack) == "function" then
        self.isReq = true
        clr.coroutine(function()
            local response = req.activityReceive(recvData.type, recvData.subID)
            self.isReq = false
            if api.success(response) then
                local data = response.val
                local currData = self.oldPlayerModel:SetCurrItemReduce(recvData.index)
                reqCallBack(currData)
                if data.contents and next(data.contents) then
                    CongratulationsPageCtrl.new(data.contents)
                end
            end
        end)
    end
end

function OldPlayerContentBaseCtrl:OnEnterScene()
end

function OldPlayerContentBaseCtrl:OnExitScene()
end

function OldPlayerContentBaseCtrl:ShowView()
    self.view:ShowView()
end

function OldPlayerContentBaseCtrl:HideView()
    self.view:HideView()
end

return OldPlayerContentBaseCtrl
