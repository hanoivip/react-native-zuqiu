local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local DreamPlayerHistoryDetailView = class(unity.base)

function DreamPlayerHistoryDetailView:ctor()
    self.score = self.___ex.score
    self.playerName = self.___ex.playerName
    self.detailGrid = self.___ex.detailGrid
    self.close = self.___ex.close
end

function DreamPlayerHistoryDetailView:InitView(data)
    self.close:regOnButtonClick(function()
        self:Close()
    end)
    self.score.text = tostring(data.score)
    self.playerName.text = data.nameIdCn or ""
    local gridData = {}
    gridData.members = {}
    table.insert(gridData.members, data)
    self.detailGrid:InitView(gridData)
end

function DreamPlayerHistoryDetailView:Close()
    DialogAnimation.Disappear(self.transform, nil, function()
        if type(self.closeDialog) == "function" then
            self.closeDialog()
        end
    end)
end

return DreamPlayerHistoryDetailView