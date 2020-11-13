local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local PowerShootDetailView = class(unity.base)

function PowerShootDetailView:ctor()
    self.closeBtn = self.___ex.closeBtn
    self.content = self.___ex.content
    self.scroll = self.___ex.scroll

    self.closeBtn:regOnButtonClick(function()
        self:Close()
    end)
end

function PowerShootDetailView:InitView(rewardBonus)
    DialogAnimation.Appear(self.transform, nil)
    res.ClearChildren(self.content)
    local treasurePath = "Assets/CapstonesRes/Game/UI/Scene/Activties/TimeLimitPowerShoot/PowerShootDetailItem.prefab"
    for i,v in ipairs(rewardBonus) do
        local treasureObj, treasureSpt = res.Instantiate(treasurePath)
        treasureObj.transform:SetParent(self.content, false)
        treasureSpt:InitView(v)
    end
    self:coroutine(function()
        unity.waitForNextEndOfFrame()
        unity.waitForNextEndOfFrame()
        self.scroll.verticalNormalizedPosition = 1
    end)
end

function PowerShootDetailView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function()
            self.closeDialog()
        end)
    end
end

return PowerShootDetailView
