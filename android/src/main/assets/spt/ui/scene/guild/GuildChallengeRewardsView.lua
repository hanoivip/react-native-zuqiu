local UnityEngine = clr.UnityEngine
local EventSystems = UnityEngine.EventSystems
local Object = UnityEngine.Object
local Vector2 = UnityEngine.Vector2
local WaitForSeconds = UnityEngine.WaitForSeconds
local Color = UnityEngine.Color
local UI = UnityEngine.UI
local Image = UI.Image

local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local UISoundManager = require("ui.control.manager.UISoundManager")
local MusicManager = require("ui.control.manager.MusicManager")
local AudioManager = require("unity.audio")
local ItemDetailModel = require("ui.models.itemDetail.ItemDetailModel")
local AssetFinder = require("ui.common.AssetFinder")
local GameObjectHelper = require("ui.common.GameObjectHelper")

local GuildChallengeRewardsView = class(unity.base)

function GuildChallengeRewardsView:ctor()
    -- 星级
    self.starGroup = self.___ex.starGroup
    -- 获得战利品滚动内容框
    self.rewardScrollerContent = self.___ex.rewardScrollerContent
    -- 确定按钮
    self.confirmBtn = self.___ex.confirmBtn
    self.animator = self.___ex.animator
    self.debrisObj = self.___ex.debrisObj
    self.nameTxt = self.___ex.nameTxt
    self.countTxt = self.___ex.countTxt
    self.debrisImg = self.___ex.debrisImg
    -- 结算数据
    self.settlementData = nil
    -- 当前星级
    self.nowStar = nil
end

function GuildChallengeRewardsView:InitView(settlementData)
    self.settlementData = settlementData
    self.nowStar = settlementData.star
    self:InitDebrisDate()
    self:BuildPage()
end

function GuildChallengeRewardsView:start()
    self.starSoundAudioPlayer = AudioManager.GetPlayer("starSound")
    self:BindAll()
end

function GuildChallengeRewardsView:BuildPage()
    self:BuildStarGroup()
    self:BuildRewardScroller()
end

--- 构建通关星级
function GuildChallengeRewardsView:BuildStarGroup()
    for i = 1, 3 do
        local starBox = self.starGroup:GetChild(i - 1)
        local star = starBox:GetChild(0)

        if i <= self.nowStar then
            star:GetComponent(Image).color = Color.white
        else
            star:GetComponent(Image).color = Color(0, 1, 1)
        end
    end

    if self.nowStar == 3 then
        UISoundManager.play('getThreeStars', 1)
    else
        UISoundManager.play('notGetThreeStars', 1)
    end
    local i = 0
    self:coroutine(function()
        coroutine.yield(WaitForSeconds(1))
        while i < tonumber(self.nowStar) do
            i = i + 1
            if self.starSoundAudioPlayer then
                self.starSoundAudioPlayer.PlayAudio("Assets/CapstonesRes/Game/Audio/UI/starSound.wav", 1)
            end
            coroutine.yield(WaitForSeconds(0.1))
        end
    end)
end

--- 构建战利品
function GuildChallengeRewardsView:BuildRewardScroller()
    local rewardParams = {
        parentObj = self.rewardScrollerContent,
        rewardData = self.settlementData.contents,
        isShowName = true,
        isReceive = true,
        isShowBaseReward = true,
        isShowCardReward = false,
        isShowDetail = false,
    }
    RewardDataCtrl.new(rewardParams)
end

function GuildChallengeRewardsView:BindAll()
    -- 确定按钮
    self.confirmBtn:regOnButtonClick(function ()
        self:Close()
    end)
end

function GuildChallengeRewardsView:Close()
    MusicManager.fadeVolume(0.4)
    self.animator:Play("QuestRewardsClose")
end

function GuildChallengeRewardsView:OnAnimEnd()
    self:Destroy()
end

function GuildChallengeRewardsView:InitDebrisDate()
    local id = cache.getRequiredEquipId()
    local itemModel = nil
    if id then
        itemModel = ItemDetailModel.new(id)
    else
        return
    end
    local isHasCurrItem = self:IsHasCurrItem(id)
    if not isHasCurrItem then return end
    
    self.debrisObj:SetActive(true)
    local need_num = itemModel:GetCompositePieceNum()
    local name = itemModel:GetName()
    local curr_num = itemModel:GetEquipPieceNum()

    self.nameTxt.text = itemModel:GetName()
    self.debrisImg.overrideSprite = AssetFinder.GetItemIcon(id)

    if tonumber(need_num) == 1 then
        self.countTxt.text = lang.trans("sweepEqsCanWear")
        return
    end
    if need_num <= curr_num then
        self.countTxt.text = lang.trans("sweepEqsCanWear_1")
    else
        self.countTxt.text = lang.trans("sweepDebris", tostring(curr_num), tostring(need_num))
    end
end

function GuildChallengeRewardsView:IsHasCurrItem(id)
    for k, v in pairs(self.settlementData.contents) do
        if k == "eqs" or k == "equipPiece" then
            for k1, v1 in pairs(v) do
                if tostring(v1.eid) == tostring(id) then
                    return true
                end
            end
        end
    end
    return false
end

function GuildChallengeRewardsView:Destroy()
    if type(self.closeDialog) == "function" then
        self.closeDialog()
    end
end

function GuildChallengeRewardsView:onDestroy()
    Object.Destroy(self.starSoundAudioPlayer.gameObject)
end

return GuildChallengeRewardsView
