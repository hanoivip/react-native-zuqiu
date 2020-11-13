local GameObjectHelper = require("ui.common.GameObjectHelper")
local ReqEventModel = require("ui.models.event.ReqEventModel")
local HomeEnterBtnGroupView = class(unity.base)

function HomeEnterBtnGroupView:ctor()
    self.carnivalPos = self.___ex.carnivalPos
    self.btnSevenDayHappy = self.___ex.btnSevenDayHappy
    self.btnOldPlayer = self.___ex.btnOldPlayer
    -- 红点
    self.btnOldPlayerRed = self.___ex.btnOldPlayerRed
end

function HomeEnterBtnGroupView:start()
    self:RegButton()
    self:UpdateOldPlayer()
    EventSystem.AddEvent("ReqEventModel_activity", self, self.UpdateOldPlayer)
    EventSystem.AddEvent("RefreshHomeEnterBtnState", self, self.RefreshBtnState)
end

function HomeEnterBtnGroupView:RegButton()
    self.btnOldPlayer:regOnButtonClick(function()
        self:OnBtnOldPlayerClick()
    end)
    self.btnSevenDayHappy:regOnButtonClick(function()
        self:OnBtnSevenDayClick()
    end)
end

function HomeEnterBtnGroupView:onDestroy()
    EventSystem.RemoveEvent("ReqEventModel_activity", self, self.UpdateOldPlayer)
    EventSystem.RemoveEvent("RefreshHomeEnterBtnState", self, self.RefreshBtnState)
end

--暂不做红点
function HomeEnterBtnGroupView:UpdateOldPlayer()
    local activity = ReqEventModel.GetInfo("activity")
    local tempFlag = activity and activity.OlduserComeback
    GameObjectHelper.FastSetActive(self.btnOldPlayerRed, tempFlag)
end

function HomeEnterBtnGroupView:OnBtnOldPlayerClick()
    if self.clickOldPlayer then
        self.clickOldPlayer()
    end
end

function HomeEnterBtnGroupView:OnBtnSevenDayClick()
    if self.clickSevenDay then
        self.clickSevenDay()
    end
end

function HomeEnterBtnGroupView:InitView()
    self:RefreshBtnState()
end

function HomeEnterBtnGroupView:RefreshBtnState()
    local flags = clone(cache.getEnterBtnGroupShowFlags())
    GameObjectHelper.FastSetActive(self.carnivalPos, not not flags.bcShow)
    GameObjectHelper.FastSetActive(self.btnSevenDayHappy.gameObject, not not flags.sevenDayShow)
    GameObjectHelper.FastSetActive(self.btnOldPlayer.gameObject, not not flags.oldPlayerShow)
end

return HomeEnterBtnGroupView
