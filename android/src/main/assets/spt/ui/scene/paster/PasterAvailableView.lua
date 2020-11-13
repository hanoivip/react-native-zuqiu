local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local PasterAvailableView = class(unity.base)

function PasterAvailableView:ctor()
    self.scrollView = self.___ex.scrollView
    self.btnClose = self.___ex.btnClose
    self.scrollView.clickUse = function(cardAppendPasterModel) self:OnClickUse(cardAppendPasterModel) end
end

function PasterAvailableView:start()
    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)
    DialogAnimation.Appear(self.transform)
end

function PasterAvailableView:Close()
    DialogAnimation.Disappear(self.transform, nil, function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end)
end

function PasterAvailableView:InitView(cardModel)
    self.scrollView:InitView(cardModel)
end

function PasterAvailableView:OnClickUse(cardPasterModel)
    if self.clickUse then 
        self.clickUse(cardPasterModel)
    end
end

function PasterAvailableView:EventUsePaster(ptid)
    local index
    for i, v in ipairs(self.scrollView.itemDatas) do
        if tostring(v:GetId()) == tostring(ptid) then
            index = i
            break
        end
    end
    self.scrollView:removeItem(index)
end

function PasterAvailableView:EnterScene()
    EventSystem.AddEvent("CardPastersMapModel_RemovePasterData", self, self.EventUsePaster)
end

function PasterAvailableView:ExitScene()
    EventSystem.RemoveEvent("CardPastersMapModel_RemovePasterData", self, self.EventUsePaster)
end

return PasterAvailableView