local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local DialogManager = require("ui.control.manager.DialogManager")
local AdventureFloor = require("data.AdventureFloor")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local RewardUpdateCacheModel = require("ui.models.common.RewardUpdateCacheModel")
local ChapterRewardView = class(unity.base)

function ChapterRewardView:ctor()
--------Start_Auto_Generate--------
    self.titleTxt = self.___ex.titleTxt
    self.passDescTxt = self.___ex.passDescTxt
    self.contentTrans = self.___ex.contentTrans
    self.scoreTxt = self.___ex.scoreTxt
--------End_Auto_Generate----------
end

function ChapterRewardView:start()
    DialogAnimation.Appear(self.transform)
end

function ChapterRewardView:Close()
    DialogAnimation.Disappear(self.transform, nil, self.closeDialog)
    self.matchModel:ClearMatch()
    EventSystem.SendEvent("GreenswardPlaneEffectShow", true)

    local totalFloor = self.greenswardBuildModel:GetTotalFloor()
    local currentFloor = self.greenswardBuildModel:GetCurrentFloor()
    if currentFloor < totalFloor then
        DialogManager.ShowToast(lang.trans("plane_lang_tip"))
    end
end

function ChapterRewardView:InitView(matchModel, greenswardBuildModel)
    self.greenswardBuildModel = greenswardBuildModel
    local currentFloor = greenswardBuildModel:GetCurrentFloor()
    self.passDescTxt.text = lang.trans("chapter_pass_reward_desc", currentFloor)
    self.matchModel = matchModel
    local contents = matchModel:GetPassContents()
    local rewardParams = {
        parentObj = self.contentTrans,
        rewardData = contents,
        isShowName = true,
        isReceive = true,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = false,
        itemParams = {
            numFont = 18
        },
    }
    RewardDataCtrl.new(rewardParams)

    local currentFloor = self.greenswardBuildModel:GetCurrentFloor()
    local floorData = AdventureFloor[tostring(currentFloor)] or {}
    local score = floorData.stagePoint or 0
    self.scoreTxt.text = lang.trans("pass_score", score)
    self.rewardUpdateCacheModel = RewardUpdateCacheModel.new()
    self.rewardUpdateCacheModel:UpdateCache(contents)
end

return ChapterRewardView
