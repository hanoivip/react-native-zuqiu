local GuildWarBaseSet = require("data.GuildWarBaseSet")
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GuildWarFightType = require("ui.models.guild.guildMistWar.GuildWarFightType")

local MistOurPartSeatsDetailView = class(unity.base)

function MistOurPartSeatsDetailView:ctor()
    self.scrollRect = self.___ex.scrollRect
    self.closeBtn = self.___ex.closeBtn
    self.challengeBtn = self.___ex.challengeBtn
    self.changeBtn = self.___ex.changeBtn
    self.disableBtn = self.___ex.disableBtn
    self.detailBtn = self.___ex.detailBtn
    self.disableTxt = self.___ex.disableTxt
    self.challengeTxt = self.___ex.challengeTxt
    self.iconImg = self.___ex.iconImg
    self.nameTxt = self.___ex.nameTxt
    self.stateTxt = self.___ex.stateTxt
    self.finish = self.___ex.finish
    self.lvlTxt = self.___ex.lvlTxt
    self.timeTxt = self.___ex.timeTxt
    self.titleTxt = self.___ex.titleTxt
    self.empty = self.___ex.empty
    self.noEmpty = self.___ex.noEmpty
    self.tip = self.___ex.tip
    self.scoreTipTxt = self.___ex.scoreTipTxt
end

function MistOurPartSeatsDetailView:InitView(index, mistOurPartSeatsDetailModel)
    self.model = mistOurPartSeatsDetailModel
    self.mistMapModel = self.model:GetMistMapModel()

    local seatsDetailData = self.model:GetSeatsDetailData()
    local guildData = self.model:GetGuardDataByIndex(index)
    self.index = guildData.index
    local fightType = self.mistMapModel:GetGuildWarFightType()

    if fightType == GuildWarFightType.Attack then
        self:InitAttackView(seatsDetailData, guildData)
    elseif fightType == GuildWarFightType.Defend then
        self:InitDefenseView(seatsDetailData, guildData)
    end
    self.transform.gameObject:SetActive(true)
    DialogAnimation.Appear(self.transform, nil)
    self:InitScrollView(seatsDetailData.record, fightType == GuildWarFightType.Attack)
    self:RegOnBtn()
end

function MistOurPartSeatsDetailView:InitAttackView(data, guildData)
    local damage = self.model:GetDamage()
    local defendLife = self.mistMapModel:GetDefendLife()
    local totalCount = self.model:GetTotalCount()
    local remainCount = self.model:GetRemainCount()
    local captureScore = self:GetCaptureScore(guildData)

    local fixLife = defendLife - damage
    if defendLife - damage < 0 then
        fixLife = 0
    end
    local canChallenge = remainCount > 0
    GameObjectHelper.FastSetActive(self.challengeBtn.gameObject, canChallenge)
    GameObjectHelper.FastSetActive(self.disableBtn.gameObject, not canChallenge)
    GameObjectHelper.FastSetActive(self.finish, fixLife <= 0)

    self.stateTxt.text = lang.trans("guild_mist_blood_remain", fixLife, defendLife)
    self.timeTxt.text = lang.trans("guild_seats_2", remainCount, totalCount)
    self.scoreTipTxt.text = lang.trans("mist_seat_attack_score", captureScore)
    -- 席位为空
    if not guildData.name then
        GameObjectHelper.FastSetActive(self.empty, true)
        GameObjectHelper.FastSetActive(self.noEmpty, false)
        return
    end
    GameObjectHelper.FastSetActive(self.noEmpty, true)
    -- 席位不为空才需设置的数据
    self.nameTxt.text = guildData.name
    self.lvlTxt.text = "LV. " .. tostring(guildData.lvl)
    TeamLogoCtrl.BuildTeamLogo(self.iconImg, guildData.logo)
    GameObjectHelper.FastSetActive(self.detailBtn.gameObject, self:IsHasAttackTwoTime(data.record))
    GameObjectHelper.FastSetActive(self.tip, not self:IsHasAttackTwoTime(data.record))
end

function MistOurPartSeatsDetailView:InitDefenseView(data, guildData)
    GameObjectHelper.FastSetActive(self.timeTxt.gameObject, false)
    GameObjectHelper.FastSetActive(self.challengeBtn.gameObject, false)
    GameObjectHelper.FastSetActive(self.disableBtn.gameObject, false)
    GameObjectHelper.FastSetActive(self.tip, false)
    local damage = self.model:GetDamage()
    local defendLife = self.mistMapModel:GetDefendLife()
    local captureScore = self:GetCaptureScore(guildData)
    local fixLife = defendLife - damage
    if defendLife - damage < 0 then
        fixLife = 0
    end
    self.stateTxt.text = lang.trans("guild_mist_blood_remain", fixLife, defendLife)
    self.scoreTipTxt.text = lang.trans("mist_seat_defend_score", captureScore)
    GameObjectHelper.FastSetActive(self.finish, fixLife <= 0)
    -- 席位为空
    if not guildData.name then
        GameObjectHelper.FastSetActive(self.empty, true)
        GameObjectHelper.FastSetActive(self.noEmpty, false)
        return
    end
    GameObjectHelper.FastSetActive(self.noEmpty, true)
    TeamLogoCtrl.BuildTeamLogo(self.iconImg, guildData.logo)
    self.nameTxt.text = guildData.name
    self.lvlTxt.text = "LV. " .. tostring(guildData.lvl)
end

function MistOurPartSeatsDetailView:InitScrollView(record, isAttackPage)
    local function resetRecordData(record)
        local recordSorted = {}
        for k, v in pairs(record) do
            table.insert(recordSorted, v)
        end
        return recordSorted
    end

    record = resetRecordData(record)
    self.scrollRect:regOnCreateItem(function (scrollSelf, index)
        local prefab = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildMistWar/MistOurPartSeatsDetailItem.prefab"
        local obj, spt = res.Instantiate(prefab)
        scrollSelf:resetItem(spt, index)
        return obj
    end)

    self.scrollRect:regOnResetItem(function (scrollSelf, spt, index)
        local data = scrollSelf.itemDatas[index]
        spt:Init(data, isAttackPage)
        spt.onView = function ()
            self:coroutine(function()
                local response = req.guildWarViewVideoMist(data.v_id)
                if api.success(response) then
                    local ReplayCheckHelper = require("coregame.ReplayCheckHelper")
                    ReplayCheckHelper.StartReplay(response.val, data.v_id)
                end
            end)
        end
        scrollSelf:updateItemIndex(spt, index)
    end)

    self.scrollRect:refresh(record)
end

function MistOurPartSeatsDetailView:RegOnBtn()
    self.closeBtn:regOnButtonClick(function ()
        self:Close()
    end)

    self.challengeBtn:regOnButtonClick(function ()
        if type(self.onClickChallengeBtn) == "function" then
            self.onClickChallengeBtn(self.index)
        end
    end)

    self.changeBtn:regOnButtonClick(function ()
        if type(self.onClickChangeBtn) == "function" then
            self.onClickChangeBtn()
        end
    end)

    self.detailBtn:regOnButtonClick(function()
        if type(self.onClickDetailBtn) == "function" then
            self.onClickDetailBtn()
        end
    end)
end

function MistOurPartSeatsDetailView:IsHasAttackTwoTime(record)
    local record = clone(record)
    local time = 0
    for k, v in pairs(record) do
        if v.genre == 4 or v.genre == 1 then
            time = time + 1
        end
    end

    return time >= 2
end

function MistOurPartSeatsDetailView:OnEnterScene()
end

function MistOurPartSeatsDetailView:OnExitScene()
end

function MistOurPartSeatsDetailView:GetCaptureScore(guildData)
    local level = tostring(guildData.level)
    local defendLevelScore = GuildWarBaseSet.mist.defendLevelScore[level]
    return defendLevelScore.score
end

function MistOurPartSeatsDetailView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function()
            self.closeDialog()
        end)
    end
end

return MistOurPartSeatsDetailView