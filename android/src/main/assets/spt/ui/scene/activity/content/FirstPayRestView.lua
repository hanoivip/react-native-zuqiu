local UnityEngine = clr.UnityEngine
local Application = UnityEngine.Application
local FirstPayRestView = class(unity.base)

function FirstPayRestView:ctor() 
    self.goBuyBtn = self.___ex.goBuyBtn
end

function FirstPayRestView:start()
    self.goBuyBtn:regOnButtonClick(function()
        res.PushDialog("ui.controllers.charge.ChargeAndVIPCtrl")
    end)
end

return FirstPayRestView
