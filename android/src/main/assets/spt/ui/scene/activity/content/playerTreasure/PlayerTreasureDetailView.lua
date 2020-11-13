local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local PlayerTreasureDetailView = class(unity.base)

function PlayerTreasureDetailView:ctor()
    self.closeBtn = self.___ex.closeBtn
    self.content = self.___ex.content
    self.scroll = self.___ex.scroll

    self.closeBtn:regOnButtonClick(function()
        self:Close()
    end)
end

function PlayerTreasureDetailView:InitView(treasureBonus)
    DialogAnimation.Appear(self.transform, nil)
    res.ClearChildren(self.content)
    local treasurePath = "Assets/CapstonesRes/Game/UI/Scene/Activties/PlayerTreasure/TreasureDetailItem.prefab"
    for i,v in ipairs(treasureBonus) do
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

function PlayerTreasureDetailView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function()
            self.closeDialog()
        end)
    end
end

return PlayerTreasureDetailView
