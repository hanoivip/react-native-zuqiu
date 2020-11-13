local BaseCtrl = require("ui.controllers.BaseCtrl")
local PlayerLetterModel = require("ui.models.playerLetter.PlayerLetterModel")
local PlayerLetterViewModel = require("ui.models.playerLetter.PlayerLetterViewModel")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local PlayerLetterInsidePlayerModel = require("ui.models.playerLetter.PlayerLetterInsidePlayerModel")
local CustomEvent = require("ui.common.CustomEvent")

local PlayerLetterCtrl = class(BaseCtrl)
PlayerLetterCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/PlayerLetter/PlayerLetter.prefab"

function PlayerLetterCtrl:Refresh(playerLetterViewModel, hasOpenDialog)
    self.playerLetterViewModel = playerLetterViewModel
    self.hasOpenDialog = hasOpenDialog
    self.playerLetterModel = nil
    self:RegisterEvent()
    self:RequestData()
end

function PlayerLetterCtrl:RequestData()
    clr.coroutine(function()
        local response = req.playerLetterInfo()
        if api.success(response) then
            self.playerLetterModel = PlayerLetterModel.new()
            self.playerLetterModel:InitWithProtocol(response.val.list)
            PlayerLetterInsidePlayerModel.new():InitWithProtocol(response.val.list)
            if self.playerLetterViewModel == nil then
                self.playerLetterViewModel = PlayerLetterViewModel.new()
            end
            local ID = self.playerLetterModel:GetFirstNoReadOrFinishedLetterID()
            if ID and not self.hasOpenDialog then
                res.PushDialog("ui.controllers.playerLetter.PlayerLetterDetailCtrl", ID)
            end
            self.playerLetterViewModel:SetModel(self.playerLetterModel)
            EventSystem.SendEvent("PlayerLetter.InitView", self.playerLetterViewModel)
            EventSystem.SendEvent("PlayerLetter.OnEnterView")
            EventSystem.SendEvent("PlayerLetterDetail.Refresh")
        end
    end)
end

function PlayerLetterCtrl:RegisterEvent()
    EventSystem.AddEvent("PlayerLetter.ReadLetter", self, self.UpdateLetterReadState)
    EventSystem.AddEvent("PlayerLetter.SwitchTag", self, self.UpdateTagType)
    EventSystem.AddEvent("PlayerLetter.SetScrollNormalizedPosition", self, self.SetScrollNormalizedPosition)
    EventSystem.AddEvent("PlayerLetter.ReplyLetter", self, self.ReplyLetter)
    EventSystem.AddEvent("PlayerLetter.OpenLetterDetail", self, self.OpenLetterDetail)
    EventSystem.AddEvent("PlayerLetterDetail.OnExitView", self, self.CloseLetterDetail)
end

function PlayerLetterCtrl:RemoveEvent()
    EventSystem.RemoveEvent("PlayerLetter.ReadLetter", self, self.UpdateLetterReadState)
    EventSystem.RemoveEvent("PlayerLetter.SwitchTag", self, self.UpdateTagType)
    EventSystem.RemoveEvent("PlayerLetter.SetScrollNormalizedPosition", self, self.SetScrollNormalizedPosition)
    EventSystem.RemoveEvent("PlayerLetter.ReplyLetter", self, self.ReplyLetter)
    EventSystem.RemoveEvent("PlayerLetter.OpenLetterDetail", self, self.OpenLetterDetail)
    EventSystem.RemoveEvent("PlayerLetterDetail.OnExitView", self, self.CloseLetterDetail)
end

--- 更新标签（现界面中已存在信函对象）
function PlayerLetterCtrl:OpenLetterDetail()
    self.hasOpenDialog = true
end

--- 更新标签（现界面中不存在信函对象）
function PlayerLetterCtrl:CloseLetterDetail()
    self.hasOpenDialog = false
end

--- 更新信件阅读状态
function PlayerLetterCtrl:UpdateLetterReadState(letterID)
    self.playerLetterModel:UpdateLetterReadState(letterID)
    EventSystem.SendEvent("PlayerLetter.RefreshLetterReadState", letterID)
end

--- 更新选择的标签类型
function PlayerLetterCtrl:UpdateTagType(tagType)
    self.playerLetterViewModel:SetTagType(tagType)
    EventSystem.SendEvent("PlayerLetter.InitView", self.playerLetterViewModel)
    EventSystem.SendEvent("PlayerLetter.OnEnterView")
end

--- 回复信函，即领取奖励
function PlayerLetterCtrl:ReplyLetter(letterID)
    clr.coroutine(function()
        local resp = req.playerLetterReceiveReward(letterID)
        if api.success(resp) then
            local data = resp.val
            if next(data) then
                if data.gift.d and tonumber(data.gift.d) > 0 then
                    CustomEvent.GetDiamond("2", tonumber(data.gift.d))
                end
                if data.gift.m and tonumber(data.gift.m) > 0 then
                    CustomEvent.GetMoney("4", tonumber(data.gift.m))
                end
                CongratulationsPageCtrl.new(data.gift)
                self.playerLetterModel:UpdateDataOnReceiveAward(letterID)
                EventSystem.SendEvent("PlayerLetter.InitView", self.playerLetterViewModel)
                EventSystem.SendEvent("PlayerLetter.OnEnterView")
                EventSystem.SendEvent("PlayerLetterDetail.BuildReplyBtn")
                EventSystem.SendEvent("PlayerLetter.SendCardId", data.gift.card.cid)               
            end
        end
    end)
end

--- 存储滚动列表的滚动位置
function PlayerLetterCtrl:SetScrollNormalizedPosition(scrollNormalizedPosition)
    self.playerLetterViewModel:SetScrollNormalizedPosition(scrollNormalizedPosition)
end

function PlayerLetterCtrl:GetStatusData()
    return self.playerLetterViewModel, self.hasOpenDialog
end

function PlayerLetterCtrl:OnExitScene()
    EventSystem.SendEvent("PlayerLetter.OnExitView")
    self:RemoveEvent()
end

return PlayerLetterCtrl