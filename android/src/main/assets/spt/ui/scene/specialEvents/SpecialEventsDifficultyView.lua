local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local EventSystem = require("EventSystem")

local SpecialEventsDifficultyView = class(unity.base)

function SpecialEventsDifficultyView:ctor()
    self.menuButtonGroup = self.___ex.menuButtonGroup
    self.tabScrollView = self.___ex.tabScrollView
    self.infoBarDynParent = self.___ex.infoBarDynParent
    self.animator = self.___ex.animator
    self.flag = self.___ex.flag
    self.chineseTitle = self.___ex.chineseTitle
    self.englishTitle = self.___ex.englishTitle
    self.reportText = self.___ex.reportText
    self.leftCount = self.___ex.leftCount
    self.needStrength = self.___ex.needStrength
    self.vipSweep = self.___ex.vipSweep
    self.commonSweep = self.___ex.commonSweep
    self.openAbility = self.___ex.openAbility
    self.challengeButtonScript = self.___ex.challengeButtonScript
    self.challengeButton = self.___ex.challengeButton
    self.challengeButtonText = self.___ex.challengeButtonText
    self.firstRewardContent = self.___ex.firstRewardContent
    self.cleanRewardContent = self.___ex.cleanRewardContent
    self.editButtonScript = self.___ex.editButtonScript
    self.recordButtonScript = self.___ex.recordButtonScript
    self.bgMask = self.___ex.bgMask
end

function SpecialEventsDifficultyView:InitView(eventId, model, index)
    self.eventId = eventId
    self.model = model
    self.index = index
    self:InitScrollView()
end

function SpecialEventsDifficultyView:InitScrollView()
    self.menuButtonGroup.menu = {}
    self.tabScrollView:regOnCreateItem(function (scrollSelf, index)
        local prefab = "Assets/CapstonesRes/Game/UI/Scene/SpecialEvents/BtnDiff.prefab"
        local obj, spt = res.Instantiate(prefab)
        scrollSelf:resetItem(spt, index)
        return obj
    end)

    self.tabScrollView:regOnResetItem(function (scrollSelf, spt, index)
        local data = scrollSelf.itemDatas[index]
        self.menuButtonGroup.menu[index] = spt
        self:InitMenuItem(spt, data, index)
        self.menuButtonGroup:BindMenuItem(index, function()
            if self.onMenuItemClick then
                self.onMenuItemClick(data, index)
            end
        end)
        scrollSelf:updateItemIndex(spt, index)
    end)
    self.tabScrollView:refresh(self.model)
end

function SpecialEventsDifficultyView:InitMenuItem(spt, value, index)
    local indexStr = lang.transstr("number_" .. index)
    spt.___ex.upText.text = lang.transstr("special_events_difficulty_label", indexStr)
    spt.___ex.downText.text = spt.___ex.upText.text
    spt.___ex.finished:SetActive(value.initial > 0)
    spt:unselectBtn()
    spt:onPointEventHandle(true)
    if self.index == index then
        spt:selectBtn()
        spt:onPointEventHandle(false)
    end
end

function SpecialEventsDifficultyView:RegOnInfoBarDynamicLoad(func)
    self.infoBarDynParent:RegOnDynamicLoad(func)
end

function SpecialEventsDifficultyView:InitMatchView(value, index, power)
    self.index = index
    self.value = value

    local sprite =
        res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/SpecialEvents/Image/Difficulty/Bg" .. self.eventId .. ".png")
    self.flag.overrideSprite = sprite
    self.chineseTitle.text = value.title or ""
    self.englishTitle.text = value.titleEnglish or ""
    self.reportText.text = string.format(value.coachPage, value.attenuation)
    self.leftCount.text = lang.trans("special_events_leftCount", value.times)
    self.needStrength.text =
        lang.trans("special_events_needStrength", value.energyCost > 9 and value.energyCost or " " .. value.energyCost)
    self.vipSweep.text = lang.trans("special_events_vipSweep", value.vipQuickPass)
    self.commonSweep.text = lang.trans("special_events_commonSweep", value.winTimes, value.cumulativePass)
    self.openAbility.text = lang.trans("special_events_open_ability", value.openAbility)

    self:RefreshChallengeButton(value, index, power)

    res.ClearChildren(self.firstRewardContent)

    local rewardParams = {
        parentObj = self.firstRewardContent,
        rewardData = value.firstReward.contents,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
        isShowCardPieceBeforeItem = true
    }

    RewardDataCtrl.new(rewardParams)

    res.ClearChildren(self.cleanRewardContent)

    for k, reward in pairs(value.cleanRewards) do
        rewardParams = {
            parentObj = self.cleanRewardContent,
            rewardData = reward.contents,
            isShowName = false,
            isReceive = false,
            isShowBaseReward = true,
            isShowCardReward = true,
            isShowDetail = true,
            isShowCardPieceBeforeItem = true
        }

        RewardDataCtrl.new(rewardParams)
    end

    local spriteId = value.isSkill and "Skill" or tostring(self.eventId)
    local glowChildName = "BG" .. spriteId .. "Glow"
    for i = 0, self.bgMask.childCount - 1 do
        local child = self.bgMask:GetChild(i)
        child.gameObject:SetActive(child.gameObject.name == glowChildName)
    end
end

function SpecialEventsDifficultyView:RefreshChallengeButton(value, index, power)
    if power ~= nil then
        self.power = power
    end
    self.challengeButton.interactable = false

    if value.openStatus ~= "open" then
        self.challengeButtonText.text = lang.trans("special_events_not_open")
        return
    end

    if (value.preID and value.preID ~= "") and (not value.initial or value.initial == 0) then
        local preIndex = tonumber(index) - 1
        local preValue = self.model[preIndex]
        if not preValue.initial or preValue.initial == 0 then
            self.challengeButtonText.text =
                lang.trans("special_events_closed_preMatch", lang.transstr("number_" .. preIndex))
            return
        end
    end

    if self.power < value.openAbility then
        self.challengeButtonText.text = lang.trans("special_events_closed_ability")
        return
    end

    if value.times <= 0 then
        self.challengeButtonText.text = lang.trans("special_events_closed_times")
        return
    end

    local playerInfoModel = PlayerInfoModel.new()
    local strengthPower = tonumber(playerInfoModel:GetStrengthPower())
    if strengthPower < value.energyCost then
        self.challengeButtonText.text = lang.trans("special_events_closed_strength")
        return
    end

    self.challengeButton.interactable = true
    local vipLevel = tonumber(playerInfoModel:GetVipLevel())
    --按钮继续显示挑战二字（原来显示扫荡）
    self.challengeButtonText.text = lang.trans("special_events_open_challenge")
    if vipLevel >= value.vipQuickPass and value.initial > 0 then
        self.challengeButtonScript.sweep = true
        self.challengeButtonScript.isVIP = true
    elseif value.initial > 0 and value.winTimes >= value.cumulativePass then
        self.challengeButtonScript.sweep = true
    else
        self.challengeButtonScript.sweep = false
    end
end

function SpecialEventsDifficultyView:OnEnterScene()
    EventSystem.AddEvent("SpecialEventsMainModel:UpdateDifficulty", self, self.UpdateDifficulty)
end

function SpecialEventsDifficultyView:OnExitScene()
    EventSystem.RemoveEvent("SpecialEventsMainModel:UpdateDifficulty", self, self.UpdateDifficulty)
end

function SpecialEventsDifficultyView:UpdateDifficulty()
    if self.value and self.index then
        self:InitMatchView(self.value, self.index)
    end
end
return SpecialEventsDifficultyView
