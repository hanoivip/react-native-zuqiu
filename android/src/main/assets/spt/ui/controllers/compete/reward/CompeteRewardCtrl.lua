local BaseCtrl = require("ui.controllers.BaseCtrl")
local CompeteRewardModel = require("ui.models.compete.reward.CompeteRewardModel")
local CompeteRewardMailModel = require("ui.models.compete.reward.CompeteRewardMailModel")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local CompeteRewardCtrl = class(BaseCtrl, "CompeteRewardCtrl")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogManager = require("ui.control.manager.DialogManager")

CompeteRewardCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Compete/Reward/CompeteReward.prefab"

function CompeteRewardCtrl:ctor()   
end

function CompeteRewardCtrl:Init()
    self.competeRewardModel = nil
    self.view.onClickBack = function() self:OnClickBack() end

    self.view.clickCollectAll = function() self:OnBtnCollectAll() end
end

function CompeteRewardCtrl:Refresh(competeRewardModel)
    CompeteRewardCtrl.super.Refresh(self)
    self.competeRewardModel = competeRewardModel
	self:InitView()
end

function CompeteRewardCtrl:InitView()
    self:ShowTipsForMail()
    self.competeRewardMailModelMap = {}
    self.mailsModel = {}
    local mailList = self.competeRewardModel:GetMailList()
    for i, mailData in pairs(mailList) do
        local competeRewardMailModel = CompeteRewardMailModel.new(mailData)
        local mailID = competeRewardMailModel:GetMailID()
        self.competeRewardMailModelMap[tostring(mailID)] = competeRewardMailModel
        table.insert(self.mailsModel, competeRewardMailModel)
    end

    cache.setSelectedMailID(-1)  --进入时不选中任何邮件

    self.view.tabView:InitView(self.mailsModel)
    self.view:InitView(self.competeRewardModel)
end

function CompeteRewardCtrl:ShowTipsForMail()
    GameObjectHelper.FastSetActive(self.view.tipsForMail, true)
    GameObjectHelper.FastSetActive(self.view.mailContent, false)
end

function CompeteRewardCtrl:OnBtnCollectAll()
    clr.coroutine(function()
        local respone = req.worldTournamentRewardCollectAllMails()
        if api.success(respone) then
            local data = respone.val
            if type(data) == "table" and next(data) and data.contents and next(data.contents) then
                local popCongratulationsPage = function()
                    CongratulationsPageCtrl.new(data.contents, false)
                end
                self:Close(popCongratulationsPage)
            end
            if type(data) == "table" and data.modifiedNum and tonumber(data.modifiedNum) == 0 then
                DialogManager.ShowToast(lang.trans("compete_reward_noNewMails"))
            end
        end
    end)

    local menuSpts = self.view.tabView.menuSpt
    if menuSpts and next(menuSpts) then
        for k, v in pairs(menuSpts) do
            local model = v.competeRewardMailModel
            model:SetMailCollected(model.cacheData)
            v:InitEnvelopeState(true)
        end
    end
    for k, model in pairs(self.mailsModel) do
        model:SetRead(1)
    end
    GameObjectHelper.FastSetActive(self.view.btnCollectedObj, false)
    GameObjectHelper.FastSetActive(self.view.btnCollect, false)
end

function CompeteRewardCtrl:Close(popCongratulationsPage)
    popCongratulationsPage()
end

function CompeteRewardCtrl:OnClickBack()
    res.PopScene()
end

return CompeteRewardCtrl