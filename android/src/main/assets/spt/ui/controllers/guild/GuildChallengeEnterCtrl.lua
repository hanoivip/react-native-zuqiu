local BaseCtrl = require("ui.controllers.BaseCtrl")
local GuildChallengeEnterModel = require("ui.models.guild.GuildChallengeEnterModel")
local InfoBarCtrl = require("ui.controllers.common.InfoBarCtrl")
local GuildChallengeRewardsCtrl = require("ui.controllers.guild.GuildChallengeRewardsCtrl")
local GuildChallengeSweepRewardsCtrl = require("ui.controllers.guild.GuildChallengeSweepRewardsCtrl")
local DialogManager = require("ui.control.manager.DialogManager")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")

local UnityEngine = clr.UnityEngine

local GuildChallengeEnterCtrl = class(BaseCtrl)

GuildChallengeEnterCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildChallengeEnter.prefab"

function GuildChallengeEnterCtrl:Init()
    self.guildChallengeEnterModel = GuildChallengeEnterModel.new()
    self.playerInfoModel = PlayerInfoModel.new()

    self.view.onMenuItemClick = function(index)
        if index == self.guildChallengeEnterModel:GetCurrentDiff() then return end
        self.guildChallengeEnterModel:SetCurrentDiff(index)
        self:InitView()
    end

    self.view.onBtnStartClick = function()
        local maxDiff = self.guildChallengeEnterModel:GetMaxOpenedDiff()
        if self.guildChallengeEnterModel:GetCurrentDiff() > maxDiff then
            DialogManager.ShowToastByLang("challenge_diffLock")
            return
        end
        local count = self.guildChallengeEnterModel:GetLeftCount()
        if count <= 0 then
            DialogManager.ShowToastByLang("challenge_noneCount")
            return 
        end

        local strength = self.playerInfoModel:GetStrengthPower()
        if strength < self.guildChallengeEnterModel:GetCostStrength() then
            self:AskBuyStrengthOrNot()
            return
        end

        clr.coroutine(function()
            local qid = self.guildChallengeEnterModel:GetCurrentID()
            local diff = self.guildChallengeEnterModel:GetCurrentDiff()
            local response = req.challengeStart(qid, diff)
            if api.success(response) then
                res.RemoveCurrentSceneDialogsInfo()
                local MatchLoader = require("coregame.MatchLoader")
                MatchLoader.startMatch(response.val)
            end
        end)
    end

    self.view.onBtnSweepClick = function()
        local qid = self.guildChallengeEnterModel:GetCurrentID()
        local diff = self.guildChallengeEnterModel:GetCurrentDiff()
        local star = self.guildChallengeEnterModel:GetSingleDiffStar(diff)
        local count = self.guildChallengeEnterModel:GetLeftCount()
        if star < 3 then
            DialogManager.ShowToastByLang("challenge_sweepLock")
            return
        end
        if count <= 0 then
            DialogManager.ShowToastByLang("challenge_noneCount")
            return 
        end

        local strength = self.playerInfoModel:GetStrengthPower()
        if strength < self.guildChallengeEnterModel:GetCostStrength() then
            self:AskBuyStrengthOrNot()
            return
        end

        local sweepNum = self:GetSweepCuponNum()
        if sweepNum <= 0 then
            self:AskBuySweepCuponOrNot()
            return
        end
      
        GuildChallengeSweepRewardsCtrl.new(qid, diff)
    end
end

function GuildChallengeEnterCtrl:Refresh(model)
    self.guildChallengeEnterModel = model
    GuildChallengeEnterCtrl.super.Refresh(self)
    self:InitView()
    GuildChallengeRewardsCtrl.new()
end

function GuildChallengeEnterCtrl:GetStatusData()
    return self.guildChallengeEnterModel
end

function GuildChallengeEnterCtrl:InitRewardView()
    local currDiff = self.guildChallengeEnterModel:GetCurrentDiff()
    local eqsList = self.guildChallengeEnterModel:GetDiffEquipList(currDiff)
    local itemList = self.guildChallengeEnterModel:GetDiffItemList(currDiff)
    local money = self.guildChallengeEnterModel:GetMoney(currDiff)
    local diamond = self.guildChallengeEnterModel:GetDiamond(currDiff)
    self.view:InitRewardView(diamond, money, itemList, eqsList)
end

function GuildChallengeEnterCtrl:InitView()
    self.view:RegOnDynamicLoad(function (child)
        self.infoBarCtrl = InfoBarCtrl.new(child, self)
        self.infoBarCtrl:RegOnBtnBack(function()
            res.PopScene()
        end)
    end)
    self.view:InitView(self.guildChallengeEnterModel)
    self:InitRewardView()    
end

function GuildChallengeEnterCtrl:RefreshEnterView(star)
    self.guildChallengeEnterModel:SetSingleDiffStar(self.guildChallengeEnterModel:GetCurrentDiff(), star)
    self.guildChallengeEnterModel:ReduceLeftCount()
    self:InitView()
end

--- 获取扫荡券的数量
function GuildChallengeEnterCtrl:GetSweepCuponNum()
    local CommonConstants = require("ui.common.CommonConstants")
    if self.itemsMapModel == nil then
        local ItemsMapModel = require("ui.models.ItemsMapModel")
        self.itemsMapModel = ItemsMapModel.new()
    end
    return self.itemsMapModel:GetItemNum(CommonConstants.SweepItemId)
end

--- 询问是否购买体力
function GuildChallengeEnterCtrl:AskBuyStrengthOrNot()
    DialogManager.ShowConfirmPopByLang("quest_title", "strengthNotEnoughAndBuy", function ()
        local UserStrengthCtrl = require("ui.controllers.user.UserStrengthCtrl")
        UserStrengthCtrl.new()
    end)
end

--- 询问是否购买扫荡券
function GuildChallengeEnterCtrl:AskBuySweepCuponOrNot()
    DialogManager.ShowConfirmPopByLang("quest_title", "sweepCuponNotEnoughAndBuy", function ()
        clr.coroutine(function ()
            coroutine.yield(UnityEngine.WaitForSeconds(0.05))
            local StoreModel = require("ui.models.store.StoreModel")
            res.PushScene("ui.controllers.store.StoreCtrl", StoreModel.MenuTags.ITEM)
        end)
    end)
end

function GuildChallengeEnterCtrl:ReduceLeftCount()
    self.guildChallengeEnterModel:ReduceLeftCount()
    self.view:InitView(self.guildChallengeEnterModel)
end

function GuildChallengeEnterCtrl:OnEnterScene()
    EventSystem.AddEvent("ChallengeEnterView_Refresh", self, self.RefreshEnterView)
    EventSystem.AddEvent("ChallengeEnterView_SweepReduceCount", self, self.ReduceLeftCount)
end

function GuildChallengeEnterCtrl:OnExitScene()
    EventSystem.RemoveEvent("ChallengeEnterView_Refresh", self, self.RefreshEnterView)
    EventSystem.RemoveEvent("ChallengeEnterView_SweepReduceCount", self, self.ReduceLeftCount)
end

return GuildChallengeEnterCtrl