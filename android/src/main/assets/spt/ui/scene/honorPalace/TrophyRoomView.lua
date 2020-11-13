local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object

local TrophyRoomView = class(unity.base)

function TrophyRoomView:ctor()
    self.scrollView = self.___ex.scrollView
    self.closeBtn = self.___ex.closeBtn
    self.finishTxt = self.___ex.finishTxt
    self.finishBarTxt = self.___ex.finishBarTxt
    self.finishSlider = self.___ex.finishSlider
end

function TrophyRoomView:start()
    self.closeBtn:regOnButtonClick(function()
        self:Close()
    end)
end

function TrophyRoomView:InitView(honorPalaceModel)
    self.scrollView:InitView(honorPalaceModel:GetTrophyList())
    local playerTrophyNum = honorPalaceModel:GetTrophyNum()
    self.finishBarTxt.text = tostring(playerTrophyNum) .. " / " .. tostring(honorPalaceModel:GetHonorNumFromTable())
    self.finishSlider.maxValue = tonumber(honorPalaceModel:GetHonorNumFromTable())
    self.finishSlider.value = tonumber(playerTrophyNum)
    self.finishTxt.text = lang.trans("honor_palace_collectionDegree_1", tostring(honorPalaceModel:GetCollectedTrophyPercent(playerTrophyNum)))
end

function TrophyRoomView:Close()
    if type(self.closeDialog) == "function" then
        cache.setHonorChangePos(nil)
        self.closeDialog()
    end
end

return TrophyRoomView