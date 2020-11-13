local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local ServerListView = class(unity.base)

function ServerListView:ctor()
    self.recommendList = self.___ex.recommendList
    self.otherList = self.___ex.otherList
    self.accountList = self.___ex.accountList
    DialogAnimation.Appear(self.transform, nil)
end

function ServerListView:Clear()
    res.ClearChildren(self.recommendList)
    res.ClearChildren(self.otherList)
    res.ClearChildren(self.accountList)
end

function ServerListView:Init(recommendItems, otherItems, accountItems)
    self:Clear()
    for i, v in ipairs(recommendItems) do
        v.transform:SetParent(self.recommendList, false)
    end
    for i, v in ipairs(otherItems) do
        v.transform:SetParent(self.otherList, false)
    end
    for i, v in ipairs(accountItems) do
        v.transform:SetParent(self.accountList, false)
    end
end

function ServerListView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function()
            self.closeDialog()
        end)
    end
end

return ServerListView

