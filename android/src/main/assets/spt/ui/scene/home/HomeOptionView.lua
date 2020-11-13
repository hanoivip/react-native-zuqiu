local UnityEngine = clr.UnityEngine
local WaitForSeconds = UnityEngine.WaitForSeconds
local Vector2 = UnityEngine.Vector2
local GameObjectHelper = require("ui.common.GameObjectHelper")
local LeagueInfoModel = require("ui.models.league.LeagueInfoModel")
local PlayerGenericModel = require("ui.models.playerGeneric.PlayerGenericModel")
local ReqEventModel = require("ui.models.event.ReqEventModel")
local Timer = require("ui.common.Timer")
local HomeOptionView = class(unity.base)

function HomeOptionView:ctor()
    self.btnStroy = self.___ex.btnStroy
    self.btnLeague = self.___ex.btnLeague
    self.btnTrain = self.___ex.btnTrain
    self.btnGuild = self.___ex.btnGuild
    self.btnCourt = self.___ex.btnCourt
    self.timeLimitChallenge = self.___ex.timeLimitChallenge
    self.questLimitRedPoint = self.___ex.questLimitRedPoint
    self.questLimitLeftTime = self.___ex.questLimitLeftTime
    self.crusade = self.___ex.crusade
    self.crusadeLeftTime = self.___ex.crusadeLeftTime

    self.leagueLock = self.___ex.leagueLock
    self.leagueLockText = self.___ex.leagueLockText
    self.trainLock = self.___ex.trainLock
    self.trainLockText = self.___ex.trainLockText
    self.guildLock = self.___ex.guildLock
    self.guildLockText = self.___ex.guildLockText
    self.courtLock = self.___ex.courtLock
    self.courtLockText = self.___ex.courtLockText
    -- 二态
    self.leagueInteractable = self.___ex.leagueInteractable
    self.trainInteractable = self.___ex.trainInteractable
    self.guildInteractable = self.___ex.guildInteractable
    self.courtInteractable = self.___ex.courtInteractable

    -- 扫光
    self.stroySweep = self.___ex.stroySweep
    self.leagueSweep = self.___ex.leagueSweep
    self.trainSweep = self.___ex.trainSweep
    self.guildSweep = self.___ex.guildSweep
    self.courtSweep = self.___ex.courtSweep

    -- 特效
    self.stroyEffect = self.___ex.stroyEffect
    self.leagueEffect = self.___ex.leagueEffect
    self.trainEffect = self.___ex.trainEffect
    self.guildEffect = self.___ex.guildEffect
    self.courtEffect = self.___ex.courtEffect

    self.stroyEffectOriginPos = self.stroyEffect.transform.anchoredPosition
    self.leagueEffectOriginPos = self.leagueEffect.transform.anchoredPosition
    self.trainEffectOriginPos = self.trainEffect.transform.anchoredPosition
    self.guildEffectOriginPos = self.guildEffect.transform.anchoredPosition
    self.courtEffectOriginPos = self.courtEffect.transform.anchoredPosition

    -- 信息
    self.leagueLevelObj = self.___ex.leagueLevelObj
    self.leagueLevelText = self.___ex.leagueLevelText

    self.otherBtnsAnimator = self.___ex.otherBtnsAnimator
    self.otherBtnsKey = {"crusadfe", "timeLimitChallenge"}
end

-- 动画移动粒子效果跟随
local EffestMovePosX = 10000
local EffestMovePosY = 10000
function HomeOptionView:OnEffectPosSet(isEnter)
    local movePos = Vector2.zero
    if not isEnter then 
        movePos = Vector2(EffestMovePosX, EffestMovePosY)
    end
    self.stroyEffect.transform.anchoredPosition = self.stroyEffectOriginPos + movePos
    self.leagueEffect.transform.anchoredPosition = self.leagueEffectOriginPos + movePos
    self.trainEffect.transform.anchoredPosition = self.trainEffectOriginPos + movePos
    self.guildEffect.transform.anchoredPosition = self.guildEffectOriginPos + movePos
    self.courtEffect.transform.anchoredPosition = self.courtEffectOriginPos + movePos
end

function HomeOptionView:start()
    EventSystem.AddEvent("ReqEventModel_questLimit", self, self.IsShowQuestLimitRedPoint)
end

function HomeOptionView:InitView(playerInfoModel, unlockModel, contentOpenOption)
    local level = playerInfoModel:GetLevel()
    unlockModel:SetCurrentLevel(level)

    for key, v in pairs(contentOpenOption) do
        local isOpen = unlockModel:GetStateById(v.Id)
        if self[v.LockObjPath] then 
            GameObjectHelper.FastSetActive(self[v.LockObjPath], not isOpen)
        end
        if self[v.LockObjIcon] then 
            self[v.LockObjIcon].interactable = isOpen
        end
        if self[v.SweepPath] then 
            GameObjectHelper.FastSetActive(self[v.SweepPath], isOpen)
        end
        if not isOpen then 
            if self[v.LockObjTextPath] then 
                local optionData = unlockModel:GetTipsById(v.Id)
                self[v.LockObjTextPath].text = "Level " .. optionData.playerLevel
            end
        end
    end

    self:ShowLeagueInfo(contentOpenOption.League.Id, unlockModel)
    self:PlayOtherBtnsAnim()
end

function HomeOptionView:SetTimeLimitChallengeState(questLimit)
    if type(questLimit) == "table" then
        if self.questLimitTimer ~= nil then
            self.questLimitTimer:Destroy()
        end
        self.questLimitTimer = Timer.new(questLimit.remainTime, function (time)
            self:ShowLeftTime(time)
        end)
        table.insert(self.availableBtnsKey, "timeLimitChallenge")
    else
        self.timeLimitChallenge.gameObject:SetActive(false)
    end
end

function HomeOptionView:SetCrusadeState(crusade)
    if type(crusade) == "table" then
        if self.crusadeTimer ~= nil then
            self.crusadeTimer:Destroy()
        end
        self.crusadeTimer = Timer.new(crusade.cd, function (time)
            self:ShowCrusadeLeftTime(time)
        end)
        table.insert(self.availableBtnsKey, "crusade")
    else
        self.crusade.gameObject:SetActive(false)
    end
end

function HomeOptionView:ShowLeftTime(time)
    local timeTable = string.convertSecondToTimeTable(time)
    self.questLimitLeftTime.text = lang.trans("gacha_left_time", timeTable.day, timeTable.hour, timeTable.minute)
end

function HomeOptionView:ShowCrusadeLeftTime(time)
    local timeTable = string.convertSecondToTimeTable(time)
    self.crusadeLeftTime.text = lang.trans("gacha_left_time", timeTable.day, timeTable.hour, timeTable.minute)
end

-- 联赛等级
function HomeOptionView:ShowLeagueInfo(id, unlockModel)
    local isOpen = unlockModel:GetStateById(id)
    GameObjectHelper.FastSetActive(self.leagueLevelObj, isOpen)
    if isOpen then 
        local leagueInfoModel = LeagueInfoModel.new()
        local baseInfo = leagueInfoModel:GetBaseInfo()
        local level = 1
        if baseInfo then 
            level = leagueInfoModel:GetLeagueLevel()
        else
            local playerGenericModel = PlayerGenericModel.new()
            level = playerGenericModel:GetLeagueDiff()
        end
        local levelStr = "CLASS\n" .. "<size=23>" .. level .. "</size>"
        self.leagueLevelText.text = levelStr
    end
end

function HomeOptionView:IsShowQuestLimitRedPoint()
    local questLimit = ReqEventModel.GetInfo("questLimit")
    if tonumber(questLimit) > 0 then
        self.questLimitRedPoint:SetActive(true)
    else
        self.questLimitRedPoint:SetActive(false)
    end
end

function HomeOptionView:onDestroy()
    if self.questLimitTimer ~= nil then
        self.questLimitTimer:Destroy()
    end
    if self.crusadeTimer ~= nil then
        self.crusadeTimer:Destroy()
    end
    EventSystem.RemoveEvent("ReqEventModel_questLimit", self, self.IsShowQuestLimitRedPoint)
end

function HomeOptionView:PlayOtherBtnsAnim()
    if type(self.availableBtnsKey) == "table" then
        if #self.availableBtnsKey > 1 then
            for i, v in ipairs(self.availableBtnsKey) do
                self[v].gameObject:SetActive(false)
            end
            local curIndex = 0
            self:coroutine(function()
                while true do
                    local lastIndex = (curIndex - 1) % #self.availableBtnsKey + 1
                    curIndex = curIndex % #self.availableBtnsKey + 1
                    self[self.availableBtnsKey[curIndex]].gameObject:SetActive(true)
                    self[self.availableBtnsKey[lastIndex]].gameObject:SetActive(false)
                    self.otherBtnsAnimator:Play("HomeCanvasOterhParentAnimation")
                    coroutine.yield(WaitForSeconds(3))
                    self.otherBtnsAnimator:Play("HomeCanvasOterhParentLeaveAnimation")
                    coroutine.yield(WaitForSeconds(0.5))
                end
            end)
        else
            for i, v in ipairs(self.availableBtnsKey) do
                self[v].gameObject:SetActive(true)
            end
        end
    end
end

return HomeOptionView
