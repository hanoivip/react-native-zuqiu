local OtherDreamLeagueCardModel = require("ui.models.dreamLeague.OtherDreamLeagueCardModel")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local DreamSelectPlayerView = class(unity.base)

function DreamSelectPlayerView:ctor()
    self.closeBtn = self.___ex.closeBtn
    self.bgRect = self.___ex.bgRect

    DialogAnimation.Appear(self.transform, nil)

    self.cardPath = "Assets/CapstonesRes/Game/UI/Scene/DreamLeague/DreamLeagueCard.prefab"
end

function DreamSelectPlayerView:start()
    self.closeBtn:regOnButtonClick(function ()
        self:Close()
    end)
end

function DreamSelectPlayerView:InitView(playersData)
    res.ClearChildren(self.bgRect)
    for k, v in pairs(playersData) do
        obj, spt = res.Instantiate(self.cardPath)
        obj.transform:SetParent(self.bgRect, false)
        spt:InitView(OtherDreamLeagueCardModel.new(v))
    end
end

function DreamSelectPlayerView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function ()
            self.closeDialog()
        end)
    end
end

return DreamSelectPlayerView
