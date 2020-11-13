local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local SeasonRankListView = class(unity.base)

function SeasonRankListView:ctor()
    self.bigEar = self.___ex.bigEar
    self.smallEar = self.___ex.smallEar
    self.bigEarTitle = self.___ex.bigEarTitle
    self.smallEarTitle = self.___ex.smallEarTitle
end

function SeasonRankListView:start()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function SeasonRankListView:InitView(competeMainModel)
    local bigEarData = competeMainModel:GetBigEarSortBorder()
    local smallEarData = competeMainModel:GetSmallEarSortBorder()
    local sceasonID = competeMainModel:GetSeasonID()
    for i,v in ipairs(bigEarData) do
        local index = tostring(i)
        if self.bigEar[index] then
            self.bigEar[index]:InitView(v)
        end
    end
    for i,v in ipairs(smallEarData) do
        local index = tostring(i)
        if self.smallEar[index] then
            self.smallEar[index]:InitView(v)
        end
    end
    self.bigEarTitle.text = tostring(sceasonID)
    self.smallEarTitle.text = lang.trans("compete_sort_smallear", sceasonID)
end

function SeasonRankListView:Close()
    local callback = function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end
    EventSystem.SendEvent("Compete_OnSeasonRankClose")
    DialogAnimation.Disappear(self.transform, nil, callback)
end

return SeasonRankListView
