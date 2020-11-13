local OldPlayerModel = require("ui.models.oldPlayer.OldPlayerModel")
local OldPlayerTabType = require("ui.scene.oldPlayer.OldPlayerTabType")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local OldPlayerCtrl = class(BaseCtrl, "OldPlayerCtrl")
OldPlayerCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/OldPlayer/OldPlayerBoard.prefab"
OldPlayerCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

function OldPlayerCtrl:Init(oldPlayerModel)
    self.oldPlayerModel = oldPlayerModel
    self.contentCtrlMap = {}
    self.view.clickTab = function(pos) self:OnTabClick(pos) end
    self.view.onClose = function() self:OnClose() end
end

function OldPlayerCtrl:Refresh()
    OldPlayerCtrl.super.Refresh(self)
    self:InitView()
end

function OldPlayerCtrl:GetStatusData()
    return self.oldPlayerModel
end

function OldPlayerCtrl:InitView()
    self.view:InitView(self.oldPlayerModel)
end

function OldPlayerCtrl:OnClose()
    EventSystem.SendEvent("HomeEnterBtnAtuoShow")
end

function OldPlayerCtrl:OnTabClick(pos)
    if self.currScript then
        self.currScript:HideView()
    end
    self.oldPlayerModel:SetSelectMenu(pos)
    self.currScript = self.contentCtrlMap[pos]
    if not self.currScript then
        self:CreateCtrl(pos)
    end
    self.currScript:InitView()
    self.currScript:ShowView()
end

function OldPlayerCtrl:CreateCtrl(pos)
    if pos == OldPlayerTabType.LoginReward.pos then
        self.contentCtrlMap[pos] = require("ui.controllers.oldPlayer.OldPlayerLoginRewardCtrl").new(self.view.content, self.oldPlayerModel)
        self.contentCtrlMap[pos]:SpreadButtonReg()
    elseif pos == OldPlayerTabType.VipActivity.pos then
        self.contentCtrlMap[pos] = require("ui.controllers.oldPlayer.OldPlayerVipActivityCtrl").new(self.view.content, self.oldPlayerModel)
        self.contentCtrlMap[pos]:SpreadButtonReg()
    elseif pos == OldPlayerTabType.LevelActivity.pos then
        self.contentCtrlMap[pos] = require("ui.controllers.oldPlayer.OldPlayerLevelActivityCtrl").new(self.view.content, self.oldPlayerModel)
        self.contentCtrlMap[pos]:SpreadButtonReg()
    elseif pos == OldPlayerTabType.RechargeActivity.pos then
        self.contentCtrlMap[pos] = require("ui.controllers.oldPlayer.OldPlayerRechargeActivityCtrl").new(self.view.content, self.oldPlayerModel)
        self.contentCtrlMap[pos]:SpreadButtonReg()
    elseif pos == OldPlayerTabType.TimeShopping.pos then
        self.contentCtrlMap[pos] = require("ui.controllers.oldPlayer.OldPlayerTimeShoppingCtrl").new(self.view.content, self.oldPlayerModel)
        self.contentCtrlMap[pos]:SpreadButtonReg()
    end
    self.currScript = self.contentCtrlMap[pos]
end

return OldPlayerCtrl