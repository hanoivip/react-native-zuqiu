local UnityEngine = clr.UnityEngine
local UI = UnityEngine.UI
local Text = UI.Text
local RectTransform = UnityEngine.RectTransform
local LayoutElement = UnityEngine.LayoutElement
local Vector2 = UnityEngine.Vector2
local Vector3 = UnityEngine.Vector3
local Quaternion = UnityEngine.Quaternion
local Euler = UnityEngine.Euler
local Object = UnityEngine.Object
local ActionLayer = clr.ActionLayer
local ShootResult = ActionLayer.ShootResult
local SaveIKGoal = ActionLayer.AthleteAction.Save.SaveIKGoal
local CoreGame = clr.CoreGame
local AthleteAction = CoreGame.AthleteAction
local ActionType = AthleteAction.ActionType
local System = clr.System
local Constants = clr.Constants
local Convert = System.Convert
local Tweening = clr.DG.Tweening
local DOTween = Tweening.DOTween
local ShortcutExtensions = Tweening.ShortcutExtensions

local AudioManager = require("unity.audio")
local MatchInfoModel = require("ui.models.MatchInfoModel")
local CommentaryConstants = require("ui.scene.match.CommentaryConstants")
local AudienceAudioConstants = require("ui.scene.match.AudienceAudioConstants")
local MatchConstants = require("ui.scene.match.MatchConstants")
local Formation = require("data.Formation")
local QuestTeam = require("data.QuestTeam")
local QuestPageViewModel = require("ui.models.quest.QuestPageViewModel")
local WeatherConstParams = require("coregame.WeatherConstParams")

local CommentaryManager = class(unity.base)
table.merge(CommentaryManager, AudioManager)
local Instance = nil

-- 所有的语音包列表
CommentaryManager.CommentList = {
    DX = "Duanxuan",
    GMH = "GuoMingHui",
}

function CommentaryOnEvent(id, event)
    if id == -10000 then
        CommentaryManager.GetInstance():PlayOpenningAudio()
    elseif id == -3 then
        CommentaryManager.GetInstance():PlayShootingAudio(id, event)
    elseif id == -2 then
        CommentaryManager.GetInstance():PlayBallPassAudio(id, event)
    elseif id == -1 then
        CommentaryManager.GetInstance():OnMatchEvent(Convert.ToInt16(event.MatchEvent), event)
    else
        CommentaryManager.GetInstance():OnPlayerEvent(id, event.athleteAction, event)
    end
end

--- 获取实例
function CommentaryManager.GetInstance()
    return Instance
end

--- 清除实例
function CommentaryManager.ClearInstance()
    Instance = nil
end

function CommentaryManager:ctor()
    self.matchInfoModel = nil
    -- 上一次的行动
    self.lastAction = nil
    -- 球员音频数据
    self.playerAudioMap = nil
    -- 球队音频数据
    self.teamAudioMap = nil
    -- 正在播放的音频的列表索引
    self.playingIndex = 0
    -- 正在播放的音频列表
    self.playingList = nil
    -- 正在播放的音频优先级
    self.playingPriority = 0
    -- 当前音频播放器
    self.nowAudioPlayer = nil
    -- 哨音播放器
    self.whistleAudioPlayer = nil
    self.toAthleteId = nil
    -- 当前胜方
    self.nowWinner = nil
    -- 玩家队是否在左边
    self.isPlayerOnLeft = false
    -- 对方队球员起始Id
    self.opponentStartId = 0
    -- 当前比分
    self.nowScore = nil
    -- 上一个比赛事件
    self.lastMatchEvent = nil
    -- 当前比赛事件
    self.nowMatchEvent = nil
    -- 上一个玩家事件
    self.lastPlayerEvent = nil
    -- 当前玩家事件
    self.nowPlayerEvent = nil
    -- 比赛节点
    self.matchNode = 0
    -- 上一个运球的球员Id
    self.lastDribbleId = nil
    -- 当前运球的球员Id
    self.nowDribbleId = nil
    -- 截断运球的球员id
    self.blockedDribbleId = nil
    -- 事件球员Id
    self.eventPlayerId = nil
    -- 事件球员Id（被动）
    self.passiveEventPlayerId = nil
    -- 比分是否相同
    self.isScoreSame = false
    -- 本方得分
    self.playerScore = 0
    -- 对方得分
    self.opponentScore = 0
    -- 是否是比赛的最后三分钟的时间
    self.isInEndThreeMinute = false
    self.pitx = nil
    self.pity = nil
    self.goalWide = nil
    self.goalHeight = nil
    -- 射门倒计时开始前的缓存数据
    self.shootAction = nil
    self.shootPlayerId = nil
    -- 播放射门技能时缓存数据
    self.shootSkillId = nil
    self.skillAudioMap = {}
    Instance = self
end

function CommentaryManager:start()
    self.lastAction = {}
    self.matchInfoModel = MatchInfoModel.GetInstance()
    self.teamAudioMap = self.matchInfoModel:GetTeamNameAndCourtAudios()
    self.nowAudioPlayer = AudioManager.GetPlayer("commentary")
    self.whistleAudioPlayer = AudioManager.GetPlayer("whistle")
    self.opponentTeamData = self.matchInfoModel:GetOpponentTeamData()
    self.opponentStartId = self.opponentTeamData.startId
    self.pitx = Constants.PitXLength
    self.pity = Constants.PitZLength
    self.goalWide = Constants.GoalPostHalfDistance * 2
    self.goalHeight = Constants.GoalCrossbarHeight
    self.isDemoMatch = self.matchInfoModel:IsDemoMatch()

    if not self.isDemoMatch then
        AudioManager.RegListener("commentary", function()
            self:PlayNextAudio()
        end, "commentary")
    end
    self:InitPlayerAudioMap()
    self:InitSkillAudioMap()
    self:RegisterEvent()
end

--- 注册事件
function CommentaryManager:RegisterEvent()
    EventSystem.AddEvent("OnMatchScoreChange", self, self.OnMatchScoreChange)
    --EventSystem.AddEvent("CommentaryManager.PlayShowFormationAudio", self, self.PlayShowFormationAudio)
    --EventSystem.AddEvent("Match_PlayerEnterCourt", self, self.PlayEnterCourtAudio)
    EventSystem.AddEvent("CommentaryManager.PlayHeroicMomentAudio", self, self.PlayHeroicMomentAudio)
    EventSystem.AddEvent("CommentaryManager.PlaySkillAudio", self, self.PlaySkillAudio)
    EventSystem.AddEvent("CommentaryManager.InEndThreeMinute", self, self.InEndThreeMinute)
    EventSystem.AddEvent("CommentaryManager.PlayShootBeforeAudio", self, self.PlayShootBeforeAudio)
end

--- 移除事件
function CommentaryManager:RemoveEvent()
    EventSystem.RemoveEvent("OnMatchScoreChange", self, self.OnMatchScoreChange)
    --EventSystem.RemoveEvent("CommentaryManager.PlayShowFormationAudio", self, self.PlayShowFormationAudio)
    --EventSystem.RemoveEvent("Match_PlayerEnterCourt", self, self.PlayEnterCourtAudio)
    EventSystem.RemoveEvent("CommentaryManager.PlayHeroicMomentAudio", self, self.PlayHeroicMomentAudio)
    EventSystem.RemoveEvent("CommentaryManager.PlaySkillAudio", self, self.PlaySkillAudio)
    EventSystem.RemoveEvent("CommentaryManager.InEndThreeMinute", self, self.InEndThreeMinute)
    EventSystem.RemoveEvent("CommentaryManager.PlayShootBeforeAudio", self, self.PlayShootBeforeAudio)
end

local function getTeamPlayerNameAudios(teamData, isPlayerTeam, commentIndex)
    local audioMap = {
        normal = {},
        passion = {},
    }
    for i, athleteData in ipairs(teamData.athletes) do
        local cardData = require("data.CardNameComment" .. commentIndex)[tostring(athleteData.cid)]
        if cardData then
            audioMap.normal[athleteData.id] = cardData.commentNormal
            audioMap.passion[athleteData.id] = cardData.commentPassion
        else
            if isPlayerTeam then
                math.randomseed(tostring(os.time()):reverse():sub(1, 7))
                local audioTable = {"13_001", "13_003"}
                audioMap.normal[athleteData.id] = audioTable[math.random(#audioTable)]
            end
            audioMap.passion[athleteData.id] = ""
        end
    end
    return audioMap
end

function CommentaryManager:InitPlayerAudioMap()
    local commentIndex = CommentaryManager.CommentList.DX

    local playerTeamData = self.matchInfoModel:GetPlayerTeamData()
    local opponentTeamData = self.matchInfoModel:GetOpponentTeamData()

    local playerAudioMap = getTeamPlayerNameAudios(playerTeamData, true, commentIndex)
    local opponentAudioMap = getTeamPlayerNameAudios(opponentTeamData, false, commentIndex)
    table.merge(playerAudioMap.normal, opponentAudioMap.normal)
    table.merge(playerAudioMap.passion, opponentAudioMap.passion)
    
    self.playerAudioMap = playerAudioMap
end

--- 播放下一个音频
function CommentaryManager:PlayNextAudio()
    self.playingIndex = self.playingIndex + 1
    local audioName = self.playingList[self.playingIndex]
    if not audioName then
        self:StopAudio()
    else
        if audioName ~= "" then
            local audioFilePath = "Assets/CapstonesRes/Game/Audio/Commentary/" .. audioName .. ".mp3"
            self.nowAudioPlayer.PlayAudio(audioFilePath, 4)
        else
            self:PlayNextAudio()
        end
    end
end

--- 停止播放音频
function CommentaryManager:StopAudio()
    self.playingIndex = 0
    self.playingList = {}
    self.playingPriority = 0
    self.nowAudioPlayer.Stop()
end

--- 销毁音频
function CommentaryManager:DestroyAudio()
    AudioManager.RegListener("commentary", nil, "commentary")
    if self.nowAudioPlayer and self.nowAudioPlayer ~= clr.null then
        self:StopAudio()
        Object.Destroy(self.nowAudioPlayer.gameObject)
    end
    if self.whistleAudioPlayer and self.whistleAudioPlayer ~= clr.null then
        Object.Destroy(self.whistleAudioPlayer.gameObject)
    end
    EventSystem.SendEvent("AudienceAudioManager.DestroyAllAudio")
end

--- 是否在播放音频
function CommentaryManager:IsPlaying()
    if self.playingList[self.playingIndex] ~= nil then
        return true
    else
        return false
    end
end

function CommentaryManager:PlayWhistleAudio(audioName)
    local audioFilePath = "Assets/CapstonesRes/Game/Audio/Commentary/" .. audioName .. ".mp3"
    self.whistleAudioPlayer.PlayAudio(audioFilePath, 0.4)
end

--- 获取随机项
function CommentaryManager:RandomItem(audioTable)
    if #audioTable <= 0 then return end

    math.randomseed(tostring(os.time()):reverse():sub(1, 7))
    return audioTable[math.random(#audioTable)]
end

--- 插入音频序列到播放列表
function CommentaryManager:InsertAudioSequence(audioSequence, priority, isAppend)
    if not audioSequence then return end
    
    local audioPlayer = AudioManager.GetPlayer("commentary")
    if audioPlayer ~= self.nowAudioPlayer then
        self:StopAudio()
        self.nowAudioPlayer = audioPlayer
    end

    if type(audioSequence) ~= "table" then
        audioSequence = {audioSequence}
    end

    if priority < self.playingPriority then
        return
    elseif priority == self.playingPriority and not isAppend then
        return
    elseif priority > self.playingPriority then
        self:StopAudio()
    end

    self.playingPriority = priority
    table.imerge(self.playingList, audioSequence)
    if not self:IsPlaying() then
        self:PlayNextAudio()
    end
end

--- 获取球员Id
function CommentaryManager:GetAthleteId(index)
    return self.toAthleteId[index]
end

--- 是否是主队球员
function CommentaryManager:IsPlayer(athleteId)
    if self.opponentTeamData then
        return athleteId < self.opponentStartId
    end
    return athleteId <= 11
end

--- 获取队伍音频
function CommentaryManager:GetTeamAudio()
    local isPlayer = self:IsPlayer(self.eventPlayerId)
    if isPlayer then
        return self.teamAudioMap.homeTeam
    else
        return self.teamAudioMap.awayTeam
    end
end

--- 获取球员普通名字音频
function CommentaryManager:GetPlayerNormalNameAudio(athleteId, isMust, isGkPlayer)
    if self:IsPlayer(athleteId) then
        return self.playerAudioMap.normal[athleteId]
    else
        if isMust then
            local candidateAudios = {}
            if isGkPlayer then
                candidateAudios = {"13_007", "13_008"}
            else
                candidateAudios = {"13_002", "13_004"}
            end
            return self:RandomItem(candidateAudios)
        else
            return ""
        end
    end
end

--- 获取球员激情名字音频
function CommentaryManager:GetPlayerPassionNameAudio(athleteId)
    return self.playerAudioMap.passion[athleteId]
end

function CommentaryManager:OnMatchEvent(eventType, frame)
    if self.isDemoMatch then
        return
    end
    if frame then
        local matchInfo = frame.MatchInfo
        self.isPlayerOnLeft = matchInfo.IsPlayerOnNorth
        self.toAthleteId = matchInfo.ToAthleteId
        -- 如果有点球大战则需要读取点球的分数
        local playerScore = 0
        local opponentScore = 0
        if ___matchUI.inPenaltyShootOut then
            local stats = json.decode(frame.MatchStatsJson)
            local playerStats = stats.player
            local opponentStats = stats.opponent
            playerScore = playerStats.score + playerStats.penaltyScore
            opponentScore = opponentStats.score + opponentStats.penaltyScore
        else
            playerScore = matchInfo.PlayerScore
            opponentScore = matchInfo.OpponentScore
        end
        self.nowScore = tostring(playerScore) .. "v" .. tostring(opponentScore)
        if playerScore > opponentScore then
            self.nowWinner = CommentaryConstants.TeamType.HOME
        elseif playerScore < opponentScore then
            self.nowWinner = CommentaryConstants.TeamType.AWAY
        else
            self.nowWinner = CommentaryConstants.TeamType.NONE
        end
    end

    self.lastMatchEvent = self.nowMatchEvent
    self.nowMatchEvent = eventType

    if self.nowMatchEvent == CommentaryConstants.MatchEventType.NONTIMEED_KICKOFF then
        -- 上半场结束
        if self.matchNode == 1 then
            self:PlayFirstHalfEndAudio()
        -- 下半场结束，有加时
        elseif self.matchNode == 2 then
            self:PlaySecondHalfEndAudio()
        -- 加时上半场结束
        elseif self.matchNode == 3 then
            self:PlayExtraFirstHalfEndAudio()
        -- 加时下半场结束，有点球
        elseif self.matchNode == 4 then
            self:PlayExtraSecondHalfEndAudio()
        -- 点球决战结束
        elseif self.matchNode == 5 then
            self:PlayPenaltyShootoutEndAudio()
        end
    else
        if self.nowMatchEvent == CommentaryConstants.MatchEventType.NORMAL_PLAYON and self.lastMatchEvent == CommentaryConstants.MatchEventType.NONTIMEED_KICKOFF then
            -- 上半场开始
            if self.matchNode == 0 then
                self:PlayFirstHalfStartAudio()
            -- 下半场开始
            elseif self.matchNode == 1 then
                self:PlaySecondHalfStartAudio()
            -- 加时上半场开始
            elseif self.matchNode == 2 then
                self:PlayExtraFirstHalfStartAudio()
            -- 加时下半场开始
            elseif self.matchNode == 3 then
                self:PlayExtraSecondHalfStartAudio()
            -- 点球决战开始
            elseif self.matchNode == 4 then
                self:PlayPenaltyShootoutStartAudio()
            end

            if self.matchNode <= 4 then
                self.matchNode = self.matchNode + 1
            end
        end
    end

    -- 进球后开球
    if self.nowMatchEvent == CommentaryConstants.MatchEventType.NORMAL_PLAYON and self.lastMatchEvent == CommentaryConstants.MatchEventType.TIMED_KICKOFF then
        self:PlayGoalKickOffAudio()
    end

    -- 边线球
    if self.nowMatchEvent == CommentaryConstants.MatchEventType.THROW_IN then
        self:PlayThrowInAudio()
    end

    -- 越位任意球
    if self.nowMatchEvent == CommentaryConstants.MatchEventType.INDIRECT_FREEKICK then
        self:PlayIndirectFreeKickAudio(frame)
    end

    -- 犯规任意球（直接打门）
    if self.nowMatchEvent == CommentaryConstants.MatchEventType.CNETER_DIRECT_FREEKICK then
        self:PlayCenterDirectFreeKickAudio(frame)
    end

    -- 犯规任意球（传球）
    if self.nowMatchEvent == CommentaryConstants.MatchEventType.WING_DIRECT_FREEKICK then
        self:PlayWingDirectFreeKickAudio()
    end

    -- 点球
    if self.nowMatchEvent == CommentaryConstants.MatchEventType.PENALTY_KICK then
        self:PlayPenaltyKickAudio()
    end

    -- 角球
    if self.nowMatchEvent == CommentaryConstants.MatchEventType.CORNERKICK then
        -- self:PlayCornerKickAudio(CommentaryConstants.AudioPriority.SHOOT)
    end

    -- 球门球
    if self.nowMatchEvent == CommentaryConstants.MatchEventType.GOALKICK then
        -- self:PlayGoalKickAudio(CommentaryConstants.AudioPriority.SHOOT)
    end

    -- 比赛结束
    if self.nowMatchEvent == CommentaryConstants.MatchEventType.GAME_OVER then
        self:PlayGameOverAudio()
    end

    if self.nowMatchEvent == CommentaryConstants.MatchEventType.NORMAL_PLAYON then
        self.shootAction = nil
        self.shootPlayerId = nil
        self.shootSkillId = nil
    end
end

function CommentaryManager:OnPlayerEvent(id, athleteAction, action)
    if PlaybackCenterWrap.InPlaybackMode() == true or self.isDemoMatch then
        return
    end
    self.lastPlayerEvent = self.nowPlayerEvent
    self.nowPlayerEvent = Convert.ToInt16(athleteAction.athleteActionType)

    -- 运球
    if self.nowPlayerEvent == CommentaryConstants.ActionType.DRIBBLE then
        self:PlayDribbleAudio(id, athleteAction.dribbleAction, action)
    -- 传球
    elseif self.nowPlayerEvent == CommentaryConstants.ActionType.PASS then
        self:PlayPassAudio(id, athleteAction.passAction, action)
    -- 接球
    elseif self.nowPlayerEvent == CommentaryConstants.ActionType.CATCH then
        self:PlayCatchAudio(id, athleteAction.passAction, action)
    -- 射门
    elseif self.nowPlayerEvent == CommentaryConstants.ActionType.SHOOT then
        self:PlayShootAudio(id, athleteAction.shootAction, action)
    -- Shoot的下一帧
    elseif self.nowPlayerEvent == CommentaryConstants.ActionType.POST_SHOOT then
        --self:PlayPostShootAudio(id, athleteAction.shootAction, action)
    -- 截球
    elseif self.nowPlayerEvent == CommentaryConstants.ActionType.INTERCEPT then
        self:PlayInterceptAudio(id, athleteAction.interceptAction, action)
    -- 救球
    elseif self.nowPlayerEvent == CommentaryConstants.ActionType.SAVE then
        self:PlaySaveAudio(id, athleteAction.saveAction, action)
    end
end

--- 播放展示阵容音频
function CommentaryManager:PlayShowFormationAudio()
    local seq = {self:RandomItem({"002", "003"})}
    self:InsertAudioSequence(seq, CommentaryConstants.AudioPriority.ENTER_MATCH)
end

--- 播放球员入场音频
function CommentaryManager:PlayEnterCourtAudio()
    if self.isDemoMatch then
        return
    end
    local seq = {"001"}
    self:InsertAudioSequence(seq, CommentaryConstants.AudioPriority.ENTER_MATCH)
end

--- 播放英雄时刻音频
function CommentaryManager:PlayHeroicMomentAudio(isShootEnabled)
    if self.isDemoMatch then
        return
    end
    local candidateAudios = {"16_087", "16_088", "16_089", "16_090", "16_091", "16_093"}
    if isShootEnabled then
        table.insert(candidateAudios, "16_092")
    end
    local seq = self:RandomItem(candidateAudios)
    self:InsertAudioSequence(seq, CommentaryConstants.AudioPriority.HEROIC_MOMENT)
end

--- 播放开场音频
function CommentaryManager:PlayOpenningAudio()
    if self.isDemoMatch then
        return
    end
    local seq = {}
    local candidateAudios = {}

    --- 时间
    local baseInfo = self.matchInfoModel:GetBaseInfo()
    local weather = WeatherConstParams.currentWeather or tostring(baseInfo.weather)
    if weather == "SummerSunny" then
        seq = {"10_001"}
    elseif weather == "SummerNight" then
        seq = {"16_001"}
    elseif weather == "WinterSunny" then
        seq = {"10_001"}
    elseif weather == "WinterNight" then
        seq = {"16_001"}
    elseif weather == "Rain" then
        seq = {"10_002"}
    elseif weather == "Snow" then
        seq = {"10_002"}
    else
        seq = {"10_001"}
    end

    --- 比赛类型
    if self.matchInfoModel:GetMatchType() == MatchConstants.MatchType.QUEST then
        -- 通过读表判断是哪个国家联赛，第几轮或者是杯赛
        local questPageViewModel = QuestPageViewModel.new()
        local matchStageId, ___, ___ = questPageViewModel:GetMatchStageId()
		local questData = QuestTeam[tostring(matchStageId)] or {}
        local questCountry = tostring(questData.questCountry)
        local questRound = tostring(questData.questRound)
        local questNature = tonumber(questData.questNature)
        if questNature == CommentaryConstants.QuestNatureType.LEAGUE then
            if questCountry == CommentaryConstants.QuestCountryType.Portugal then
                table.imerge(seq, {"16_002", questRound, "10_003_2"})
            elseif questCountry == CommentaryConstants.QuestCountryType.Netherlands then
                table.imerge(seq, {"16_003", questRound, "10_003_2"})
            elseif questCountry == CommentaryConstants.QuestCountryType.France then
                table.imerge(seq, {"16_004", questRound, "10_003_2"})
            elseif questCountry == CommentaryConstants.QuestCountryType.Italy then
                table.imerge(seq, {"16_005", questRound, "10_003_2"})
            elseif questCountry == CommentaryConstants.QuestCountryType.England then
                table.imerge(seq, {"16_006", questRound, "10_003_2"})
            elseif questCountry == CommentaryConstants.QuestCountryType.Spain then
                table.imerge(seq, {"16_007", questRound, "10_003_2"})
            end
        elseif questNature == CommentaryConstants.QuestNatureType.SUPER_CUP then
            table.insert(seq, "16_010")
        elseif questNature == CommentaryConstants.QuestNatureType.NORMAL_CUP then
            table.imerge(seq, {"16_008_1", questRound, "16_008_2"})
        elseif questNature == CommentaryConstants.QuestNatureType.SMALL_EAR_CUP then
            table.imerge(seq, {"16_009", questRound, "16_008_2"})
        elseif questNature == CommentaryConstants.QuestNatureType.BIG_EAR_CUP then
            table.imerge(seq, {"16_008", questRound, "16_008_2"})
        end
    else
        table.insert(seq, "10_005")
    end

    --- 随机
    candidateAudios = {"10_006", "16_011", "16_012", "10_009", "10_010", "16_013", "16_014", "16_015", "16_016", "10_011", "10_012", "16_017", "10_015", "10_016", "10_017"}
    table.insert(seq, self:RandomItem(candidateAudios))

    --- 天气
    local function playWeatherAudio()
        if weather == "SummerSunny" or weather == "SunShine" then
            candidateAudios = {"10_019", "10_021"}
            table.insert(seq, self:RandomItem(candidateAudios))
        elseif weather == "SummerNight" then
            candidateAudios = {"10_018", "16_018"}
            table.insert(seq, self:RandomItem(candidateAudios))
        elseif weather == "WinterSunny" then
            candidateAudios = {"10_019", "16_018"}
            table.insert(seq, self:RandomItem(candidateAudios))
        elseif weather == "WinterNight" then
            table.insert(seq, "16_020")
        elseif weather == "Rain" then
            candidateAudios = {"10_020", "16_019", "17_613"}
            table.insert(seq, self:RandomItem(candidateAudios))
        elseif weather == "Snow" then
            table.insert(seq, "17_614")
        elseif weather == "Wind" then
            table.insert(seq, "17_615")
        elseif weather == "Fog" then
            table.insert(seq, "17_616")
        elseif weather == "Heat" then
            table.insert(seq, "17_617")
        elseif weather == "Sand" then
            table.insert(seq, "17_618")
        end
    end

    --- 阵型
    local function playFormationAudio()
        local playerFormationInfo = self.matchInfoModel:GetPlayerFormationInfo()
        local opponentFormationInfo = self.matchInfoModel:GetOpponentFormationInfo()
        local function formationCommentary1()
            table.imerge(seq, {"16_022", tostring(Formation[tostring(playerFormationInfo.formation)].comment), "16_023", "16_024", tostring(Formation[tostring(opponentFormationInfo.formation)].comment), "16_025"})
        end
        local function formationCommentary2()
            table.imerge(seq, {"16_026", tostring(Formation[tostring(playerFormationInfo.formation)].comment), "16_027", tostring(Formation[tostring(opponentFormationInfo.formation)].comment)})
        end
        self:RandomItem({formationCommentary1, formationCommentary2})()
    end

    self:RandomItem({playWeatherAudio, playFormationAudio})()
    table.insert(seq, "10_022")

    self:InsertAudioSequence(seq, CommentaryConstants.AudioPriority.ENTER_MATCH)
end

--- 播放射门音频（真正射门）
function CommentaryManager:PlayShootingAudio(id, event)
    if PlaybackCenterWrap.InPlaybackMode() == true then
        return
    end
    if not self.isDemoMatch then
        local seq = {}
        local candidateAudios = {}
        local athleteId = self:GetAthleteId(event.shooterId)
        -- 技能射门
        if self.shootSkillId then
            local playerNameNormalAudioWithNotMust = self:GetPlayerNormalNameAudio(athleteId)
            local playerNameNormalAudioWithMustAndNotGk = self:GetPlayerNormalNameAudio(athleteId, true, false)
            local playerNameNormalAudioWithMustAndGk = self:GetPlayerNormalNameAudio(athleteId, true, true)
            local playerNamePassionAudio = self:GetPlayerPassionNameAudio(athleteId)
            local playSkillAudioFunc = self.skillAudioMap[tostring(self.shootSkillId)]
            if playSkillAudioFunc then
                playSkillAudioFunc(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio)
            end
            self.shootSkillId = nil
        -- 普通射门
        else
            local audioName = self:GetPlayerPassionNameAudio(athleteId)
            if audioName ~= "" then
                seq = {audioName}
            elseif self.shootAction then
                local shootAudio = self:GetShootAudio(id)
                seq = shootAudio
                self.shootAction = nil
                self.shootPlayerId = nil
            end
            if next(seq) then
                self:InsertAudioSequence(seq, CommentaryConstants.AudioPriority.SAVE)
            end
        end
    end
    EventSystem.SendEvent("AudienceAudioManager.OnEvent", AudienceAudioConstants.EventType.KICK, event)
end

--- 播放长传（球）音频
function CommentaryManager:PlayBallPassAudio(id, event)
    if PlaybackCenterWrap.InPlaybackMode() == true then
        return
    end
    local startPosition = event.startPosition
    local endPosition = event.endPosition
    local kickVolume = 0
    if startPosition then
        local distance = math.sqrt((endPosition.x - startPosition.x) * (endPosition.x - startPosition.x) + (endPosition.z - startPosition.z) * (endPosition.z - startPosition.z))
        if distance > CommentaryConstants.BallPassDistanceLowerLimit then
            kickVolume = 0.4
        else
            kickVolume = 0.15
        end
    else
        kickVolume = 0.4
    end
    EventSystem.SendEvent("AudienceAudioManager.OnEvent", AudienceAudioConstants.EventType.KICK, event, kickVolume)
end

--- 播放上半场开始音频
function CommentaryManager:PlayFirstHalfStartAudio()
    self:PlayWhistleAudio(CommentaryConstants.KickOffWhistleAudio)
    local candidateAudios = {{"homeTeam", "10_194"}, {"16_028"}, {"10_023"}}
    local seq = self:RandomItem(candidateAudios)
    self:InsertAudioSequence(seq, CommentaryConstants.AudioPriority.START_MATCH)
end

--- 播放上半场结束音频
function CommentaryManager:PlayFirstHalfEndAudio()
    self:PlayWhistleAudio(CommentaryConstants.HalfTimeWhistleAudio)
    local seq = {"10_189", self.nowScore}
    local candidateAudios = {"10_190", "16_029"}
    table.insert(seq, self:RandomItem(candidateAudios))
    self:InsertAudioSequence(seq, CommentaryConstants.AudioPriority.ENTER_MATCH)
end

--- 播放下半场开始音频
function CommentaryManager:PlaySecondHalfStartAudio()
    self:PlayWhistleAudio(CommentaryConstants.KickOffWhistleAudio)
    local seq = {"10_191_1", "awayTeam", "10_191_2"}
    local candidateAudios = {"16_030", "16_031"}
    table.insert(seq, self:RandomItem(candidateAudios))
    self:InsertAudioSequence(seq, CommentaryConstants.AudioPriority.START_MATCH)
end

--- 播放下半场结束音频，有加时
function CommentaryManager:PlaySecondHalfEndAudio()
    self:PlayWhistleAudio(CommentaryConstants.HalfTimeWhistleAudio)
    local seq = {"10_192"}
    self:InsertAudioSequence(seq, CommentaryConstants.AudioPriority.ENTER_MATCH)
end

--- 播放加时上半场开始音频
function CommentaryManager:PlayExtraFirstHalfStartAudio()
    self:PlayWhistleAudio(CommentaryConstants.KickOffWhistleAudio)
    local seq = {"16_034"}
    self:InsertAudioSequence(seq, CommentaryConstants.AudioPriority.START_MATCH)
end

--- 播放加时上半场结束音频
function CommentaryManager:PlayExtraFirstHalfEndAudio()
    self:PlayWhistleAudio(CommentaryConstants.HalfTimeWhistleAudio)
    local seq = {"10_193"}
    self:InsertAudioSequence(seq, CommentaryConstants.AudioPriority.ENTER_MATCH)
end

--- 播放加时下半场开始音频
function CommentaryManager:PlayExtraSecondHalfStartAudio()
    self:PlayWhistleAudio(CommentaryConstants.KickOffWhistleAudio)
    local seq = {"10_195"}
    self:InsertAudioSequence(seq, CommentaryConstants.AudioPriority.START_MATCH)
end

--- 播放加时下半场结束音频
function CommentaryManager:PlayExtraSecondHalfEndAudio()
    self:PlayWhistleAudio(CommentaryConstants.HalfTimeWhistleAudio)
    local seq = {"16_035"}
    self:InsertAudioSequence(seq, CommentaryConstants.AudioPriority.ENTER_MATCH)
end

--- 播放点球决战开始音频
function CommentaryManager:PlayPenaltyShootoutStartAudio()
    self:PlayWhistleAudio(CommentaryConstants.KickOffWhistleAudio)
    local seq = {"10_196"}
    self:InsertAudioSequence(seq, CommentaryConstants.AudioPriority.START_MATCH)
end

--- 播放点球决战结束音频
function CommentaryManager:PlayPenaltyShootoutEndAudio()
    self:PlayWhistleAudio(CommentaryConstants.GameOverWhistleAudio)
    local winner = ""
    if self.nowWinner == CommentaryConstants.TeamType.HOME then
        winner = "homeTeam"
    elseif self.nowWinner == CommentaryConstants.TeamType.AWAY then
        winner = "awayTeam"
    end
    local seq = {winner, "10_197"}
    self:InsertAudioSequence(seq, CommentaryConstants.AudioPriority.ENTER_MATCH)
end

--- 播放比赛结束音频
function CommentaryManager:PlayGameOverAudio()
    self:PlayWhistleAudio(CommentaryConstants.GameOverWhistleAudio)
    local seq = {}
    local candidateAudios = {"10_061", "16_032", "16_033"}
    table.insert(seq, self:RandomItem(candidateAudios))
    table.imerge(seq, {"10_062", self.nowScore})
    if self.nowWinner == CommentaryConstants.TeamType.HOME or self.nowWinner == CommentaryConstants.TeamType.AWAY then
        local winner = ""
        if self.nowWinner == CommentaryConstants.TeamType.HOME then
            winner = "homeTeam"
        elseif self.nowWinner == CommentaryConstants.TeamType.AWAY then
            winner = "awayTeam"
        end

        -- 如果是点球产生胜负
        if ___matchUI.inPenaltyShootOut then
            table.imerge(seq, {winner, "10_197"})
        else
            table.imerge(seq, {winner, "10_063"})
            if self.nowWinner == CommentaryConstants.TeamType.HOME then
                if self.playerScore - self.opponentScore > 2 then
                    candidateAudios = {"16_098"}
                else
                    candidateAudios = {"16_094", "16_096"}
                end
            elseif self.nowWinner == CommentaryConstants.TeamType.AWAY then
                if self.opponentScore - self.playerScore > 2 then
                    candidateAudios = {"16_099"}
                else
                    candidateAudios = {"16_095"}
                end
            end
            table.insert(seq, self:RandomItem(candidateAudios))
        end
    elseif self.nowWinner == CommentaryConstants.TeamType.NONE then
        candidateAudios = {"10_064", "10_065"}
        table.insert(seq, self:RandomItem(candidateAudios))
        candidateAudios = {"16_097"}
        table.insert(seq, self:RandomItem(candidateAudios))
    end
    if self.nowWinner == CommentaryConstants.TeamType.HOME then
        candidateAudios = {"10_198", "16_100", "16_101", "16_103"}
        table.insert(seq, self:RandomItem(candidateAudios))
    elseif self.nowWinner == CommentaryConstants.TeamType.AWAY then
        candidateAudios = {"10_198", "16_100", "16_102", "16_103"}
        table.insert(seq, self:RandomItem(candidateAudios))
    end

    self:InsertAudioSequence(seq, CommentaryConstants.AudioPriority.START_MATCH)
end

--- 播放进球后开球音频
function CommentaryManager:PlayGoalKickOffAudio()
    self:PlayWhistleAudio(CommentaryConstants.KickOffWhistleAudio)
    local seq = {"16_036"}
    self:InsertAudioSequence(seq, CommentaryConstants.AudioPriority.START_MATCH)
end

--- 播放边线球音频
function CommentaryManager:PlayThrowInAudio()
    local seq = {}
    local candidateAudios = {"11_081", "11_082"}
    table.insert(seq, self:RandomItem(candidateAudios))
    self:InsertAudioSequence(seq, CommentaryConstants.AudioPriority.ENTER_MATCH)
    EventSystem.SendEvent("AudienceAudioManager.OnEvent", AudienceAudioConstants.EventType.STOP_OFFENCE)
end

function CommentaryManager:playThrowInAudioWithPass()
    local seq = {}
    local candidateAudios = {}
    local playerNameAudio = self:GetPlayerNormalNameAudio(self.eventPlayerId)
    table.insert(candidateAudios, {playerNameAudio, "11_098"})
    table.insert(candidateAudios, {playerNameAudio, "11_099"})
    --self.eventPlayerId = nil
    seq = self:RandomItem(candidateAudios)
    self:InsertAudioSequence(seq, CommentaryConstants.AudioPriority.START_MATCH)
end

--- 播放越位任意球音频
function CommentaryManager:PlayIndirectFreeKickAudio(frame)
    self:PlayWhistleAudio(CommentaryConstants.FoulWhistleAudio)
    local athleteName = self:GetPlayerNormalNameAudio(self:GetAthleteId(frame.MatchInfo.FoulAthlete))
    local candidateAudios = {{athleteName, "11_085"}, {athleteName, "11_086"}, {"11_088"}}
    local seq = self:RandomItem(candidateAudios)
    self:InsertAudioSequence(seq, CommentaryConstants.AudioPriority.ENTER_MATCH)
end

--- 播放犯规任意球（直接打门）音频
function CommentaryManager:PlayCenterDirectFreeKickAudio(frame)
    self:PlayWhistleAudio(CommentaryConstants.FoulWhistleAudio)
    local seq = {"11_175"}
    local teamAudio = ""
    if self:IsPlayer(self:GetAthleteId(frame.MatchInfo.FoulAthlete)) then
        teamAudio = self.teamAudioMap.awayTeam
    else
        teamAudio = self.teamAudioMap.homeTeam
    end
    local candidateAudios = {{"11_089"}, {teamAudio, "11_090"}, {teamAudio, "11_091"}, {teamAudio, "11_092"}}
    table.imerge(seq, self:RandomItem(candidateAudios))
    self:InsertAudioSequence(seq, CommentaryConstants.AudioPriority.SHOOT)
    EventSystem.SendEvent("AudienceAudioManager.OnEvent", AudienceAudioConstants.EventType.FOUL)
end

function CommentaryManager:PlayCenterDirectFreeKickAudioWithShoot()
    local seq = {}
    local candidateAudios = {{"11_100"}}
    local playerNameAudio1 = self:GetPlayerNormalNameAudio(self.eventPlayerId)
    local playerNameAudio2 = self:GetPlayerNormalNameAudio(self.eventPlayerId, true, false)
    table.insert(candidateAudios, {playerNameAudio2, "11_093"})
    table.insert(candidateAudios, {playerNameAudio2, "11_101"})
    table.insert(candidateAudios, {playerNameAudio2, "11_102"})
    table.insert(candidateAudios, {playerNameAudio1, "11_103"})
    table.insert(candidateAudios, {playerNameAudio1, "11_121"})
    table.insert(candidateAudios, {playerNameAudio1, "11_123"})
    --self.eventPlayerId = nil
    table.imerge(seq, self:RandomItem(candidateAudios))
    self.playCenterDirectFreeKickAudioWithShoot = true
    self:InsertAudioSequence(seq, CommentaryConstants.AudioPriority.SHOOT, true)
end

--- 播放犯规任意球（传球）音频
function CommentaryManager:PlayWingDirectFreeKickAudio()
    self:PlayWhistleAudio(CommentaryConstants.FoulWhistleAudio)
    local seq = {"11_175"}
    self:InsertAudioSequence(seq, CommentaryConstants.AudioPriority.ENTER_MATCH)
    EventSystem.SendEvent("AudienceAudioManager.OnEvent", AudienceAudioConstants.EventType.FOUL)
end

--- 播放点球音频
function CommentaryManager:PlayPenaltyKickAudio()
    local playerNameAudio = self:GetPlayerNormalNameAudio(self.passiveEventPlayerId)
    local seq = {playerNameAudio, "11_176"}
    local candidateAudios = {"11_094", "11_095", "11_096", "11_097"}
    table.insert(seq, self:RandomItem(candidateAudios))
    self:InsertAudioSequence(seq, CommentaryConstants.AudioPriority.SHOOT)
    EventSystem.SendEvent("AudienceAudioManager.OnEvent", AudienceAudioConstants.EventType.PENALTY, nil, nil, self.passiveEventPlayerId)
end

function CommentaryManager:PlayPenaltyKickAudioWithShoot()
    local seq = {}
    local candidateAudios = {}
    local playerNameAudio = self:GetPlayerNormalNameAudio(self.eventPlayerId, true, false)
    table.insert(candidateAudios, {playerNameAudio, "11_106"})
    table.insert(candidateAudios, {playerNameAudio, "11_107"})
    table.insert(candidateAudios, {playerNameAudio, "11_108"})
    --self.eventPlayerId = nil
    seq = self:RandomItem(candidateAudios)
    self.playPenaltyKickAudioWithShoot = true
    self:InsertAudioSequence(seq, CommentaryConstants.AudioPriority.SHOOT, true)
end

--- 播放角球音频
function CommentaryManager:PlayCornerKickAudio(priority)
    local seq = {"11_078", "11_079"}
    self:InsertAudioSequence(seq, priority, true)
    EventSystem.SendEvent("AudienceAudioManager.OnEvent", AudienceAudioConstants.EventType.STOP_OFFENCE)
end

function CommentaryManager:PlayCornerKickAudioWithPass()
    local seq = {}
    local candidateAudios = {}
    local playerNameAudio = self:GetPlayerNormalNameAudio(self.eventPlayerId, true, false)
    table.insert(candidateAudios, {playerNameAudio, "11_109"})
    local teamAudio = self:GetTeamAudio()
    --self.eventPlayerId = nil
    table.insert(candidateAudios, {teamAudio, "11_077"})
    table.insert(candidateAudios, {"11_076_1", teamAudio, "11_076_2"})
    seq = self:RandomItem(candidateAudios)
    self:InsertAudioSequence(seq, CommentaryConstants.AudioPriority.SAVE)
end

--- 播放球门球音频
function CommentaryManager:PlayGoalKickAudio(priority)
    local seq = {"11_083"}
    self:InsertAudioSequence(seq, priority, true)
    EventSystem.SendEvent("AudienceAudioManager.OnEvent", AudienceAudioConstants.EventType.STOP_OFFENCE)
end

function CommentaryManager:PlayGoalKickAudioWithPass(isHigh)
    local seq = {}
    local candidateAudios = {}
    local playerNameAudio = self:GetPlayerNormalNameAudio(self.eventPlayerId)
    table.insert(candidateAudios, {playerNameAudio, "11_104"})
    -- 大脚开到前场
    if isHigh == 'High' then
        table.insert(candidateAudios, {playerNameAudio, "11_105"})
    end
    --self.eventPlayerId = nil
    seq = self:RandomItem(candidateAudios)
    self:InsertAudioSequence(seq, CommentaryConstants.AudioPriority.SAVE)
end

--- 播放技能音频
function CommentaryManager:PlaySkillAudio(id, skillId)
    if self:IsPlayer(id) and skillId then
        -- 当我方球员发动“带球突破”“下底传中”技能时播放音频
        if skillId == "B01" and skillId == "C03" then
            EventSystem.SendEvent("AudienceAudioManager.OnEvent", AudienceAudioConstants.EventType.SKILL, nil, nil, id)
        end
        -- 射门技能延后播放
        if skillId == "D01" or skillId == "D02" or skillId == "D03" or skillId == "D04" or skillId == "D05" or skillId == "D06" or skillId == "D07" then
            self.shootSkillId = skillId
        else
            local playerNameNormalAudioWithNotMust = self:GetPlayerNormalNameAudio(id)
            local playerNameNormalAudioWithMustAndNotGk = self:GetPlayerNormalNameAudio(id, true, false)
            local playerNameNormalAudioWithMustAndGk = self:GetPlayerNormalNameAudio(id, true, true)
            local playerNamePassionAudio = self:GetPlayerPassionNameAudio(id)
            local playSkillAudioFunc = self.skillAudioMap[tostring(skillId)]
            if playSkillAudioFunc then
                playSkillAudioFunc(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio)
            end
        end
    end
end

--- 播放运球音频
function CommentaryManager:PlayDribbleAudio(id, dribbleAction, keyframe)
    local playerNameAudio = self:GetPlayerNormalNameAudio(id)
    local candidateAudios = {}
    local nowPosition = self:GetPlayerPositon(id, keyframe.actionStartFrame.GetPosition())
    local nowRotation = self:GetPlayerRotation(id, keyframe.actionStartFrame.GetRotation().eulerAngles)
    self.lastDribbleId = self.nowDribbleId
    self.nowDribbleId = id

    if self.lastDribbleId == id then
        if self.blockedDribbleId ~= id then
            -- 中场对球的控制
            if nowPosition[3] == 'MiddleMiddle' then
                candidateAudios = {}
                candidateAudios = {{playerNameAudio, "11_002"}}
            end
            -- 过半场
            if nowPosition[4] == true and nowPosition[2] == 'MiddleMiddle' then
                candidateAudios = {}
                table.insert(candidateAudios, {playerNameAudio, "11_028"})
                table.insert(candidateAudios, {playerNameAudio, "11_029"})
            end
            -- 带球回撤
            if nowPosition[4] == false and nowRotation == 'Retreat' then
                candidateAudios = {}
                candidateAudios = {{playerNameAudio, "11_033"}}
            -- 带球推进
            elseif nowRotation == 'Attack' then
                candidateAudios = {}
                table.insert(candidateAudios, {playerNameAudio, "11_020"})
                table.insert(candidateAudios, {playerNameAudio, "11_021"})
                table.insert(candidateAudios, {playerNameAudio, "11_022"})
                table.insert(candidateAudios, {playerNameAudio, "11_023"})
            end
            -- 带球遇到很大的防守压力 寻求队友支援
            if nowPosition[4] == true and nowRotation == 'Retreat' then
                candidateAudios = {}
                table.insert(candidateAudios, {playerNameAudio, "11_003"})
                table.insert(candidateAudios, {playerNameAudio, "11_034"})
            end
            -- 左路推进
            if nowPosition[1] == 'Left' and nowRotation == 'Attack' then
                candidateAudios = {}
                candidateAudios = {{playerNameAudio, "11_031"}}
            end
            -- 右路推进
            if nowPosition[1] == 'Right' and nowRotation == 'Attack' then
                candidateAudios = {}
                candidateAudios = {{playerNameAudio, "11_032"}}
            end
            -- 沿边路带球
            if nowPosition[6] == true and nowRotation == 'Attack' then
                candidateAudios = {}
                candidateAudios = {{playerNameAudio, "11_030"}}
            end
            -- 内切 向里走
            if (nowPosition[3] == 'ForwardLeft' and nowRotation == 'AttackRight') or (nowPosition[3] == 'ForwardRight' and nowRotation == 'AttackLeft') then
                candidateAudios = {}
                table.insert(candidateAudios, {playerNameAudio, "11_024"})
                table.insert(candidateAudios, {playerNameAudio, "11_025"})
            end
            -- 带球突入禁区
            if nowPosition[5] == true then
                candidateAudios = {}
                candidateAudios = {{playerNameAudio, "11_027"}}
            end
        end
        self.blockedDribbleId = id
    else
        self.blockedDribbleId = nil
    end

    local seq = self:RandomItem(candidateAudios)
    self:InsertAudioSequence(seq, CommentaryConstants.AudioPriority.DRIBBLE)
    self.lastAction = {
        action = CommentaryConstants.ActionType.DRIBBLE,
        id = id,
    }

    -- 犯规
    if dribbleAction.isFouled then
        self.eventPlayerId = self.toAthleteId[dribbleAction.foulAthlete]
        self.passiveEventPlayerId = id
        return
    end

    -- 被抢断
    if dribbleAction.isStolen then
        local playerId = self.toAthleteId[dribbleAction.stealAthlete]
        self:PlayStealAudio(playerId, dribbleAction, keyframe)
        return
    end

    -- 敌方半场进攻
    if nowPosition[4] == true then
        EventSystem.SendEvent("AudienceAudioManager.OnEvent", AudienceAudioConstants.EventType.OFFENCE, nil, nil, id)
    end
end

--- 播放抢断音频
function CommentaryManager:PlayStealAudio(id, stealAction, keyframe)
    local seq = {}
    local playerNameAudio = self:GetPlayerNormalNameAudio(id)
    local passivePlayerNameAudio = ""
    local candidateAudios = {}
    table.insert(candidateAudios, {playerNameAudio, "11_051"})
    if type(self.lastAction) == 'table' and self.lastAction.action == CommentaryConstants.ActionType.DRIBBLE and self.lastAction.id then
        passivePlayerNameAudio = self:GetPlayerNormalNameAudio(self.lastAction.id)
        self.lastAction.id = nil
    end
    table.insert(candidateAudios, {passivePlayerNameAudio, "11_005"})
    table.insert(candidateAudios, {passivePlayerNameAudio, "11_006"})
    seq = self:RandomItem(candidateAudios)
    self:InsertAudioSequence(seq, CommentaryConstants.AudioPriority.STEAL)
    EventSystem.SendEvent("AudienceAudioManager.OnEvent", AudienceAudioConstants.EventType.STEAL, stealAction, nil, id, keyframe)
end

--- 播放传球音频
function CommentaryManager:PlayPassAudio(id, passAction, keyframe)
    local playerNameAudio = self:GetPlayerNormalNameAudio(id)
    local passivePlayerNameAudio = self:GetPlayerNormalNameAudio(self:GetAthleteId(passAction.targetAthlete))
    local seq = {}
    local candidateAudios = {}
    local targetposition = self:GetPlayerPositon(id, self:Vector2toVector3(passAction.targetPosition))
    local nowPosition = self:GetPlayerPositon(id, keyframe.actionStartFrame.GetPosition())
    if self.nowMatchEvent == CommentaryConstants.MatchEventType.NORMAL_PLAYON and keyframe.isStartOnNormalPlayOn then
        self.eventPlayerId = id
        -- 掷界外球
        if self.lastMatchEvent == CommentaryConstants.MatchEventType.THROW_IN then
            self:playThrowInAudioWithPass()
        end
        -- 角球
        if self.lastMatchEvent == CommentaryConstants.MatchEventType.CORNERKICK then
            self:PlayCornerKickAudioWithPass()
        end
        -- 球门球
        if self.lastMatchEvent == CommentaryConstants.MatchEventType.GOALKICK then
            self:PlayGoalKickAudioWithPass(passAction.passType.ToString())
        end
        -- 半场开球前/比赛中进球
        if self.lastMatchEvent == CommentaryConstants.MatchEventType.NONTIMEED_KICKOFF or self.lastMatchEvent == CommentaryConstants.MatchEventType.TIMED_KICKOFF then
            self.firstPass = true
        end
        return
    end

    -- 将球传给队友
    math.randomseed(tostring(os.time()):reverse():sub(1, 7))
    -- 在普通传球时 增大念接球人名字的比重（80%）
    -- 正常情况会在接球时播放球员的名字，所以在传球时概率不播这几个视频即可
    if math.random(5) == 1 then
        table.insert(candidateAudios, {playerNameAudio, "11_058"})
        table.insert(candidateAudios, {playerNameAudio, "11_059"})
        if math.random(5) == 1 then
            table.insert(candidateAudios, {"11_199"})
        end
        table.insert(candidateAudios, {"11_200"})
    end
    -- 球向前传
    if (nowPosition[2] == 'Back' and targetposition[2] ~= 'Back') or (nowPosition[2] == 'Middle' and targetposition[2] == 'Forward') then
        candidateAudios = {}
        table.insert(candidateAudios, {playerNameAudio, "11_197"})
    end
    -- 将球分给左边路
    if nowPosition[1] == 'Middle' and targetposition[1] == 'Left' then
        candidateAudios = {}
        table.insert(candidateAudios, {playerNameAudio, "11_202"})
        table.insert(candidateAudios, {playerNameAudio, "11_060"})
    end
    -- 将球分给右边路
    if nowPosition[1] == 'Middle' and targetposition[1] == 'Right' then
        candidateAudios = {}
        table.insert(candidateAudios, {playerNameAudio, "11_201"})
        table.insert(candidateAudios, {playerNameAudio, "11_060"})
    end
    if nowPosition[6] == false and targetposition[6] == true then
        table.insert(candidateAudios, {playerNameAudio, "11_026"})
    end
    -- 将球回敲
    if (nowPosition[2] ~= 'Back' and targetposition[2] == 'Back') or (nowPosition[2] == 'Forward' and targetposition[2] == 'Middle') then
        candidateAudios = {}
        table.insert(candidateAudios, {playerNameAudio, "11_204"})
    end
    -- 长传
    if passAction.passType.ToString() == 'High' then
        candidateAudios = {}
        -- 转移 起高空球
        table.insert(candidateAudios, {playerNameAudio, "11_065"})
        table.insert(candidateAudios, {playerNameAudio, "11_066"})
        table.insert(candidateAudios, {playerNameAudio, "11_203"})
        if nowPosition[2] == 'Back' then
            candidateAudios = {}
            if targetposition[2] == 'Forward' then
                -- 长传到前场
                table.insert(candidateAudios, {playerNameAudio, "11_061"})
            end
        end
        if type(self.lastAction) == 'table' then
            self.lastAction.PassType = 'High'
        end
    end
    -- 传到禁区
    if targetposition[5] == true then
        candidateAudios = {}
        table.insert(candidateAudios, {playerNameAudio, "11_196"})
    end
    seq = self:RandomItem(candidateAudios)
    self:InsertAudioSequence(seq, CommentaryConstants.AudioPriority.PASS)
    if type(self.lastAction) == 'table' then
        self.lastAction.PassType = 'Ground'
    end
end

--- 播放接球音频
function CommentaryManager:PlayCatchAudio(id, catchAction, keyframe)
    local playerNameAudio = self:GetPlayerNormalNameAudio(id)
    local seq = {}
    local candidateAudios = {}
    local targetposition = self:GetPlayerPositon(id, self:Vector2toVector3(catchAction.targetPosition))
    local nowPosition = self:GetPlayerPositon(id, keyframe.actionStartFrame.GetPosition())
    if self.firstPass then
        self.firstPass = false
        return
    end
    table.insert(candidateAudios, {playerNameAudio})
    math.randomseed(tostring(os.time()):reverse():sub(1, 7))
    if math.random(3) == 1 then
        table.insert(candidateAudios, {playerNameAudio, "11_010"})
        table.insert(candidateAudios, {playerNameAudio, "11_011"})
        table.insert(candidateAudios, {playerNameAudio, "11_012"})
    end
    if type(self.lastAction) == 'table' and self.lastAction.PassType == 'High' then
        candidateAudios = {}
        table.insert(candidateAudios, {playerNameAudio, "11_067"})
        self.lastAction.PassType = ""
    end

    seq = self:RandomItem(candidateAudios)
    self:InsertAudioSequence(seq, CommentaryConstants.AudioPriority.DRIBBLE)
end

--- 播放射门音频(射门前出脚)
function CommentaryManager:PlayShootAudio(id, shootAction, keyframe)
    if self.isDemoMatch then
        return
    end
    local playerNameAudio = self:GetPlayerNormalNameAudio(id)
    if self.nowMatchEvent == CommentaryConstants.MatchEventType.NORMAL_PLAYON and keyframe.isStartOnNormalPlayOn then
        self.eventPlayerId = id
        -- 犯规任意球（直接打门）
        if self.lastMatchEvent == CommentaryConstants.MatchEventType.CNETER_DIRECT_FREEKICK then
            self:PlayCenterDirectFreeKickAudioWithShoot()
        end

        -- 准备罚点球
        if self.lastMatchEvent == CommentaryConstants.MatchEventType.PENALTY_KICK then
            self:PlayPenaltyKickAudioWithShoot()
        end
        return
    end
    self.shootAction = shootAction
    self.shootPlayerId = id
end

--- 获取射门音频
function CommentaryManager:GetShootAudio()
    local playerNameAudio = self:GetPlayerNormalNameAudio(self.shootPlayerId)
    local seq = {}
    local candidateAudios = {}
    -- 玩家射门
    if self.shootPlayerId < self.opponentStartId then
        -- 头球射门
        if self.shootAction.shootAnimationType == CommentaryConstants.ShootAnimationType.Header then
            if playerNameAudio then
                table.insert(candidateAudios, {playerNameAudio, "11_118"})
                table.insert(candidateAudios, {playerNameAudio, "11_119"})
            else
                table.insert(candidateAudios, {"11_118"})
                table.insert(candidateAudios, {"11_119"})
            end
        -- 凌空抽射
        elseif self.shootAction.shootAnimationType == CommentaryConstants.ShootAnimationType.VolleyShoot then
            if playerNameAudio then
                table.insert(candidateAudios, {playerNameAudio, "12_042"})
                table.insert(candidateAudios, {playerNameAudio, "12_043"})
                table.insert(candidateAudios, {playerNameAudio, "12_044"})
            else
                table.insert(candidateAudios, {"12_042"})
                table.insert(candidateAudios, {"12_043"})
                table.insert(candidateAudios, {"12_044"})
            end
        -- 其它射门
        else
            if playerNameAudio then
                table.insert(candidateAudios, {playerNameAudio, "11_115"})
                table.insert(candidateAudios, {playerNameAudio, "11_116"})
                table.insert(candidateAudios, {playerNameAudio, "11_117"})
            else
                table.insert(candidateAudios, {"11_115"})
                table.insert(candidateAudios, {"11_116"})
                table.insert(candidateAudios, {"11_117"})
            end
        end
    else
        -- 电脑射门
        if playerNameAudio then
            table.insert(candidateAudios, {playerNameAudio, "11_205"})
        else
            table.insert(candidateAudios, {"11_205"})
        end
    end
    seq = self:RandomItem(candidateAudios)
    return seq
end

--- 播放截球音频
function CommentaryManager:PlayInterceptAudio(id, interceptAction, keyframe)
    local playerNameAudio = self:GetPlayerNormalNameAudio(id)
    local seq = {}
    local candidateAudios = {}
    table.insert(candidateAudios, {playerNameAudio, "11_046"})
    table.insert(candidateAudios, {playerNameAudio, "11_047"})
    local nowPosition = self:GetPlayerPositon(id, keyframe.actionStartFrame.GetPosition())
    if nowPosition[5] == true then
        candidateAudios = {}
        table.insert(candidateAudios, {"11_063"})
        table.insert(candidateAudios, {playerNameAudio, "11_071"})
    end
    seq = self:RandomItem(candidateAudios)
    self:InsertAudioSequence(seq, CommentaryConstants.AudioPriority.INTERCEPT)
    EventSystem.SendEvent("AudienceAudioManager.OnEvent", AudienceAudioConstants.EventType.INTERCEPT, interceptAction, nil, id, keyframe)
end

--- 播放守门音频
function CommentaryManager:PlaySaveAudio(id, saveAction, keyframe)
    local playerNameAudio1 = self:GetPlayerNormalNameAudio(id)
    local playerNameAudio2 = self:GetPlayerNormalNameAudio(id, true, true)
    local shootPlayerNameAudio1 = self:GetPlayerNormalNameAudio(saveAction.shooterAthleteId)
    local shootPlayerNameAudio2 = self:GetPlayerNormalNameAudio(saveAction.shooterAthleteId, true, false)
    local seq = {}
    local candidateAudios = {}
    local MissType = self:getShootMissType(saveAction.shootEndPosition)
    if self.playCenterDirectFreeKickAudioWithShoot then
        -- 没收射球
        if saveAction.shootResult == ShootResult.Catched then
            table.insert(candidateAudios, {playerNameAudio2, "11_048"})
            table.insert(candidateAudios, {playerNameAudio2, "11_049"})
            table.insert(candidateAudios, {playerNameAudio2, "11_050"})
            table.insert(candidateAudios, {playerNameAudio2, "11_167"})
            table.insert(candidateAudios, {playerNameAudio2, "11_171"})
            EventSystem.SendEvent("AudienceAudioManager.OnEvent", AudienceAudioConstants.EventType.MISS, saveAction)
            seq = self:RandomItem(candidateAudios)
        -- 扑出射门（目前扑出的球都会出底线）
        elseif saveAction.shootResult == ShootResult.Bounced then
            table.insert(candidateAudios, {playerNameAudio2, "11_168"})
            table.insert(candidateAudios, {playerNameAudio2, "11_169"})
            table.insert(candidateAudios, {playerNameAudio2, "11_170"})
            if saveAction.ikGoal == SaveIKGoal.LeftFoot or saveAction.ikGoal == SaveIKGoal.RightFoot then
                candidateAudios = {}
                table.insert(candidateAudios, {playerNameAudio2, "11_172"})
            end
            if saveAction.ikGoal == SaveIKGoal.None then
                candidateAudios = {}
                table.insert(candidateAudios, {playerNameAudio2, "11_173"})
            end
            table.insert(candidateAudios, {"11_210", playerNameAudio2})
            EventSystem.SendEvent("AudienceAudioManager.OnEvent", AudienceAudioConstants.EventType.MISS, saveAction)
            seq = self:RandomItem(candidateAudios)
        -- 不在门框范围内
        elseif saveAction.shootResult == ShootResult.Miss then
            table.insert(candidateAudios, {"11_194"})
            -- 射高了
            if MissType == 'lowHeight' then
                table.insert(candidateAudios, {"11_131"})
                table.insert(candidateAudios, {"11_132"})
                table.insert(candidateAudios, {"11_134"})
            elseif MissType == 'middleHeight' then
                table.insert(candidateAudios, {"11_127"})
                table.insert(candidateAudios, {"11_130"})
                table.insert(candidateAudios, {shootPlayerNameAudio1, "11_128"})
            elseif MissType == 'highHeight' then
                table.insert(candidateAudios, {"11_126"})
                table.insert(candidateAudios, {"11_133"})
            -- 射偏了
            elseif MissType == 'cloWide' then
                table.insert(candidateAudios, {"11_134"})
                table.insert(candidateAudios, {"11_131"})
                table.insert(candidateAudios, {"11_114"})
                table.insert(candidateAudios, {"11_135"})
            elseif MissType == 'middleWide' then
                table.insert(candidateAudios, {"11_112"})
                table.insert(candidateAudios, {shootPlayerNameAudio1, "11_166"})
            elseif MissType == 'farWide' then
                table.insert(candidateAudios, {"11_126"})
                table.insert(candidateAudios, {"11_113"})
            end
            EventSystem.SendEvent("AudienceAudioManager.OnEvent", AudienceAudioConstants.EventType.MISS, saveAction)
            seq = self:RandomItem(candidateAudios)
        -- 进球
        elseif saveAction.shootResult == ShootResult.Goal then
            table.insert(candidateAudios, {"11_189"})
            table.insert(candidateAudios, {"11_190"})
            table.insert(candidateAudios, {"11_192"})
            table.insert(candidateAudios, {"11_207"})
            table.insert(candidateAudios, {"16_042"})
            table.insert(candidateAudios, {"16_043"})
            EventSystem.SendEvent("AudienceAudioManager.OnEvent", AudienceAudioConstants.EventType.GOAL, saveAction)

            seq = self:RandomItem(candidateAudios)
            candidateAudios = self:PlayScoreAudioWithShootSuccess(saveAction.shooterAthleteId, shootPlayerNameAudio2)
            table.imerge(seq, self:RandomItem(candidateAudios))
        end
        self:InsertAudioSequence(seq, CommentaryConstants.AudioPriority.SAVE, true)
        self.playCenterDirectFreeKickAudioWithShoot = nil
        return
    end

    if self.playPenaltyKickAudioWithShoot then
        if saveAction.shootResult == ShootResult.Miss then
            table.insert(candidateAudios, {shootPlayerNameAudio2, "11_139"})
            EventSystem.SendEvent("AudienceAudioManager.OnEvent", AudienceAudioConstants.EventType.MISS, saveAction)
        elseif saveAction.shootResult == ShootResult.Bounced then
            table.insert(candidateAudios, {playerNameAudio1, "11_143"})
            table.insert(candidateAudios, {"11_144"})
            EventSystem.SendEvent("AudienceAudioManager.OnEvent", AudienceAudioConstants.EventType.MISS, saveAction)
        elseif saveAction.shootResult == ShootResult.Goal then
            table.insert(candidateAudios, {shootPlayerNameAudio2, "11_140"})
            table.insert(candidateAudios, {shootPlayerNameAudio2, "11_141"})
            table.insert(candidateAudios, {shootPlayerNameAudio2, "11_142"})
            EventSystem.SendEvent("AudienceAudioManager.OnEvent", AudienceAudioConstants.EventType.GOAL, saveAction)
        end
        seq = self:RandomItem(candidateAudios)
        self:InsertAudioSequence(seq, CommentaryConstants.AudioPriority.SAVE, true)
        self.playPenaltyKickAudioWithShoot = nil
        return
    end

    -- 没进球播放扑救录音
    -- 没收射球
    if saveAction.shootResult == ShootResult.Catched then
        table.insert(candidateAudios, {playerNameAudio2, "11_050"})
        table.insert(candidateAudios, {playerNameAudio2, "11_167"})
        table.insert(candidateAudios, {playerNameAudio2, "11_171"})
        EventSystem.SendEvent("AudienceAudioManager.OnEvent", AudienceAudioConstants.EventType.MISS, saveAction)
        seq = self:RandomItem(candidateAudios)
    -- 扑出射门（目前扑出的球都会出底线）
    elseif saveAction.shootResult == ShootResult.Bounced then
        table.insert(candidateAudios, {playerNameAudio2, "11_168"})
        table.insert(candidateAudios, {playerNameAudio2, "11_169"})
        table.insert(candidateAudios, {playerNameAudio2, "11_170"})
        if saveAction.ikGoal == SaveIKGoal.LeftFoot or saveAction.ikGoal == SaveIKGoal.RightFoot then
            candidateAudios = {}
            table.insert(candidateAudios, {playerNameAudio2, "11_172"})
        end
        if saveAction.ikGoal == SaveIKGoal.None then
            candidateAudios = {}
            table.insert(candidateAudios, {playerNameAudio2, "11_173"})
        end
        table.insert(candidateAudios, {"11_210", playerNameAudio2})
        EventSystem.SendEvent("AudienceAudioManager.OnEvent", AudienceAudioConstants.EventType.MISS, saveAction)
        seq = self:RandomItem(candidateAudios)
    -- 不在门框范围内
    elseif saveAction.shootResult == ShootResult.Miss then
        table.insert(candidateAudios, {"11_194"})
        table.insert(candidateAudios, {"11_195"})
        table.insert(candidateAudios, {"11_164"})
        table.insert(candidateAudios, {"11_165"})
        -- 射高了，复制三遍 扩大概率
        if MissType == 'lowHeight' then
            for i = 1, 3 do
                table.insert(candidateAudios, {"11_131"})
                table.insert(candidateAudios, {"11_132"})
                table.insert(candidateAudios, {"11_134"})
            end
        elseif MissType == 'middleHeight' then
            for i = 1, 3 do
                table.insert(candidateAudios, {"11_127"})
                table.insert(candidateAudios, {"11_130"})
                table.insert(candidateAudios, {shootPlayerNameAudio1, "11_128"})
                table.insert(candidateAudios, {shootPlayerNameAudio1, "11_166"})
            end
        elseif MissType == 'highHeight' then
            for i = 1, 3 do
                table.insert(candidateAudios, {"11_126"})
                table.insert(candidateAudios, {"11_133"})
            end
        -- 射偏了，复制三遍 扩大概率
        elseif MissType == 'cloWide' then
            for i = 1, 3 do
                table.insert(candidateAudios, {"11_134"})
                table.insert(candidateAudios, {"11_131"})
                table.insert(candidateAudios, {"11_114"})
                table.insert(candidateAudios, {"11_135"})
            end
        elseif MissType == 'middleWide' then
            for i = 1, 3 do
                table.insert(candidateAudios, {"11_112"})
                table.insert(candidateAudios, {shootPlayerNameAudio1, "11_166"})
            end
        elseif MissType == 'farWide' then
            for i = 1, 3 do
                table.insert(candidateAudios, {"11_126"})
                table.insert(candidateAudios, {"11_113"})
            end
        end
        EventSystem.SendEvent("AudienceAudioManager.OnEvent", AudienceAudioConstants.EventType.MISS, saveAction)
        seq = self:RandomItem(candidateAudios)
    -- 进球
    elseif saveAction.shootResult == ShootResult.Goal then
        table.insert(candidateAudios, {"11_189"})
        table.insert(candidateAudios, {"11_190"})
        table.insert(candidateAudios, {"11_192"})
        table.insert(candidateAudios, {"11_207"})
        table.insert(candidateAudios, {"16_042"})
        table.insert(candidateAudios, {"16_043"})
        EventSystem.SendEvent("AudienceAudioManager.OnEvent", AudienceAudioConstants.EventType.GOAL, saveAction)

        seq = self:RandomItem(candidateAudios)
        candidateAudios = self:PlayScoreAudioWithShootSuccess(saveAction.shooterAthleteId, shootPlayerNameAudio2)
        table.imerge(seq, self:RandomItem(candidateAudios))
    end
    self:InsertAudioSequence(seq, CommentaryConstants.AudioPriority.SAVE, true)

    -- 点球大战中不会播放“球门球”或者“角球”
    if not ___matchUI.inPenaltyShootOut then
        if saveAction.shootResult == ShootResult.Miss then
            -- 球门球
            self:PlayGoalKickAudio(CommentaryConstants.AudioPriority.SAVE)
        elseif saveAction.shootResult == ShootResult.Bounced then
            -- 角球
            self:PlayCornerKickAudio(CommentaryConstants.AudioPriority.SAVE)
        end
    end
end

function CommentaryManager:getShootMissType(shootEndPosition)
    local startPosition = Vector3(0, self.goalHeight, 0)
    local distanceWide = math.abs((shootEndPosition.x - startPosition.x)) - self.goalWide / 2
    local distanceHeight = shootEndPosition.y - startPosition.y
    local miss = {
        low = 0.2 * self.goalHeight,
        high = 0.6 * self.goalHeight,
        clo = 0.2 * self.goalWide,
        far = 0.5 * self.goalWide,
    }
    if distanceHeight > 0 and distanceWide < 0 then
        -- 射高了
        if distanceHeight <= miss.low then
            return 'lowHeight'
        elseif distanceHeight >= miss.high then
            return 'highHeight'
        else
            return 'middleHeight'
        end
    elseif distanceWide > 0 then
        -- 射偏了
        if distanceWide <= miss.clo then
            return 'cloWide'
        elseif distanceWide >= miss.far then
            return 'farWide'
        else
            return 'middleWide'
        end
    elseif distanceHeight == 0 then
        -- 横梁
        return 'goalBeam'
    elseif distanceWide == 0 then
        -- 门柱
        return 'goalPost'
    end
    return 'None'
end

function CommentaryManager:PlayScoreAudioWithShootSuccess(shooterAthleteId, shootPlayerNameAudio)
    --- 此处会在比分修改通知之后执行到，所以把比分自动加1
    if self:IsPlayer(shooterAthleteId) then
        self.playerScore = self.playerScore + 1
    else
        self.opponentScore = self.opponentScore + 1
    end

    local candidateAudios = {}
    table.insert(candidateAudios, {"16_048"})
    --- 领先3球以上
    if self.playerScore - self.opponentScore > 2 or self.opponentScore - self.playerScore > 2 then
        --- 本方领先3球
        if self.playerScore - self.opponentScore > 2 then
            --- 本方球员进球
            if self:IsPlayer(shooterAthleteId) then
                table.insert(candidateAudios, {"16_050"})
                table.insert(candidateAudios, {"16_051"})
                table.insert(candidateAudios, {shootPlayerNameAudio, "11_145"})
            --- 对方球员进球
            else
                table.insert(candidateAudios, {"11_158"})
                table.insert(candidateAudios, {"11_159"})
                table.insert(candidateAudios, {shootPlayerNameAudio, "11_160"})
            end
        --- 对方领先3球
        elseif self.opponentScore - self.playerScore > 2 then
            --- 本方球员进球
            if self:IsPlayer(shooterAthleteId) then
                table.insert(candidateAudios, {"11_158"})
                table.insert(candidateAudios, {"11_159"})
                table.insert(candidateAudios, {shootPlayerNameAudio, "11_160"})
            --- 对方球员进球
            else
                table.insert(candidateAudios, {"16_050"})
                table.insert(candidateAudios, {"16_051"})
                table.insert(candidateAudios, {shootPlayerNameAudio, "11_145"})
            end
        end
    --- 比分打平
    elseif self.playerScore == self.opponentScore then
        if self.isInEndThreeMinute then
            table.insert(candidateAudios, {shootPlayerNameAudio, "11_153"})
            table.insert(candidateAudios, {shootPlayerNameAudio, "11_154"})
        else
            table.insert(candidateAudios, {shootPlayerNameAudio, "11_151"})
            table.insert(candidateAudios, {"11_157"})
        end
    --- 比分差距在2球之内
    else
        table.insert(candidateAudios, {"11_146"})
        table.insert(candidateAudios, {"11_157"})
        --- 本方领先2球之内
        if self.playerScore - self.opponentScore > 0 and self.playerScore - self.opponentScore <= 2 then
            --- 对方球员进球
            if not self:IsPlayer(shooterAthleteId) then
                if self.isInEndThreeMinute then
                    table.insert(candidateAudios, {shootPlayerNameAudio, "11_156", "16_049"})
                    table.insert(candidateAudios, {"11_158"})
                else
                    table.insert(candidateAudios, {shootPlayerNameAudio, "11_155"})
                    table.insert(candidateAudios, {shootPlayerNameAudio, "11_156"})
                end
            end
        --- 对方领先2球之内
        elseif self.opponentScore - self.playerScore > 0 and self.opponentScore - self.playerScore <= 2 then
            --- 本方球员进球
            if self:IsPlayer(shooterAthleteId) then
                if self.isInEndThreeMinute then
                    table.insert(candidateAudios, {shootPlayerNameAudio, "11_156", "16_049"})
                    table.insert(candidateAudios, {"11_158"})
                else
                    table.insert(candidateAudios, {shootPlayerNameAudio, "11_155"})
                    table.insert(candidateAudios, {shootPlayerNameAudio, "11_156"})
                end
            end
        end
    end
    return candidateAudios
end

--- 当比分改变时
function CommentaryManager:OnMatchScoreChange(playerScore, opponentScore)
    self.playerScore = playerScore
    self.opponentScore = opponentScore
    self.isScoreSame = playerScore == opponentScore
end

-- 最后三分钟通知
function CommentaryManager:InEndThreeMinute(isInEndThreeMinute)
    self.isInEndThreeMinute = isInEndThreeMinute
end

function CommentaryManager:GetPlayerPositon(id, position)
    -- TODO: 后期有时间重构
    if position then
        local xposition
        local yposition
        local IsOppHalf
        local IsOppPenalty
        local IsSide
        local xdiv = 4
        local ydiv = 5
        local sdiv = 2.5
        if (self.isPlayerOnLeft and id < self.opponentStartId) or(not self.isPlayerOnLeft and id >= self.opponentStartId) then
            if position.x > self.pitx / xdiv then
                xposition = 'Left'
            elseif position.x < -(self.pitx / xdiv) then
                xposition = 'Right'
            else
                xposition = 'Middle'
            end

            if position.y > self.pity / ydiv then
                yposition = 'Back'
            elseif position.y < -(self.pity / ydiv) then
                yposition = 'Forward'
            else
                yposition = 'Middle'
            end
            if position.y < -1 then
                IsOppHalf = true
            else
                IsOppHalf = false
            end
            if position.y < -33.5 and position.y > -50 and position.x > -20 and position.x < 20 then
                IsOppPenalty = true
            else
                IsOppPenalty = false
            end
        else
            if position.x > self.pitx / xdiv then
                xposition = 'Right'
            elseif position.x < -(self.pitx / xdiv) then
                xposition = 'Left'
            else
                xposition = 'Middle'
            end

            if position.y > self.pity / ydiv then
                yposition = 'Forward'
            elseif position.y < -(self.pity / ydiv) then
                yposition = 'Back'
            else
                yposition = 'Middle'
            end
            if position.y > 1 then
                IsOppHalf = true
            else
                IsOppHalf = false
            end
            if position.y < 50 and position.y > 33.5 and position.x > -20 and position.x < 20 then
                IsOppPenalty = true
            else
                IsOppPenalty = false
            end
        end
        if position.x > self.pitx / sdiv or position.x < -(self.pitx / sdiv) then
            IsSide = true
        else
            IsSide = false
        end
        local xyposition = yposition .. xposition
        return { xposition, yposition, xyposition, IsOppHalf, IsOppPenalty, IsSide }
    end
end

function CommentaryManager:GetPlayerRotation(id, rotation)
    -- TODO: 后期有时间重构
    if rotation then
        local yrotation
        if (self.isPlayerOnLeft and id < self.opponentStartId) or(not self.isPlayerOnLeft and id >= self.opponentStartId) then
            if rotation.y > 135 and rotation.y < 225 then
                yrotation = 'Attack'
            elseif rotation.y > 225 and rotation.y < 315 then
                yrotation = 'AttackRight'
            elseif rotation.y > 45 and rotation.y < 135 then
                yrotation = 'AttackLeft'
            elseif rotation.y > 315 and rotation.y < 45 then
                yrotation = 'Retreat'
            end
        else
            if rotation.y > 135 and rotation.y < 225 then
                yrotation = 'Retreat'
            elseif rotation.y > 225 and rotation.y < 315 then
                yrotation = 'AttackLeft'
            elseif rotation.y > 45 and rotation.y < 135 then
                yrotation = 'AttackRight'
            elseif rotation.y > 315 and rotation.y < 45 then
                yrotation = 'Attack'
            end
        end
        return yrotation
    end
end

function CommentaryManager:Vector2toVector3(v2)
    return Vector3(v2.x, 0, v2.y)
end

-- 播放射门前的音频
function CommentaryManager:PlayShootBeforeAudio(id, shootAction, keyframe)
    if self.isDemoMatch then
        return
    end
    if ___matchUI.inPenaltyShootOut then
        return
    end

    if self.nowMatchEvent == CommentaryConstants.MatchEventType.NORMAL_PLAYON and keyframe.isStartOnNormalPlayOn then
        -- 犯规任意球（直接打门）/点球
        if self.lastMatchEvent == CommentaryConstants.MatchEventType.CNETER_DIRECT_FREEKICK or self.lastMatchEvent == CommentaryConstants.MatchEventType.PENALTY_KICK then
            return
        end
    end

    local playerNameAudio = self:GetPlayerNormalNameAudio(id)
    local seq = {}
    local candidateAudios = {}
    -- 玩家射门
    if id < self.opponentStartId then
        -- 头球射门
        if shootAction.isHeader then
            table.insert(candidateAudios, {playerNameAudio, "11_044"})
            table.insert(candidateAudios, {playerNameAudio, "11_045"})
        -- 其它射门
        else
            --table.insert(candidateAudios, {playerNameAudio, "11_007"})
            table.insert(candidateAudios, {playerNameAudio, "11_008"})
            table.insert(candidateAudios, {"11_205"})
            table.insert(candidateAudios, {"11_206"})
        end
    else
        -- 电脑射门
        table.insert(candidateAudios, {"11_205"})
        table.insert(candidateAudios, {"11_206"})
    end
    seq = self:RandomItem(candidateAudios)
    self:InsertAudioSequence(seq, CommentaryConstants.AudioPriority.SAVE)
end

function CommentaryManager:InitSkillAudioMap()
    self.skillAudioMap = 
    {
        --- 大力头槌
        D03 = function(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) 
                self:PlayDltcSkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) end,
        --- 凌空抽射
        D04 = function(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) 
                self:PlayLkcsSkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) end,
        --- 重炮手
        D07 = function(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) 
                self:PlayZpsSkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) end,
        --- 冷静推射
        D01 = function(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) 
                self:PlayLjtsSkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) end,
        --- 禁区之狐
        D02 = function(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) 
                self:PlayJqzhSkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) end,
        --- 冲击波
        D05 = function(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) 
                self:PlayCjbSkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) end,
        --- 猛虎射门
        D06 = function(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) 
                self:PlayMhcmSkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) end,
        --- 手控球
        D06 = function(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) 
                self:PlaySkqSkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) end,
        --- 零失误
        D06 = function(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) 
                self:PlayLswSkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) end,
        --- 门神下凡
        D06 = function(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) 
                self:PlayMsxfSkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) end,
        --- 神级反应
        D06 = function(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) 
                self:PlaySjfySkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) end,
        --- 节拍器
        B03 = function(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) 
                self:PlayJpqSkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) end,
        --- 带球突破
        B01 = function(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) 
                self:PlayDqtpSkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) end,
        --- 小动作
        A02 = function(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) 
                self:PlayXdzSkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) end,
        --- 跳水
        B02 = function(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) 
                self:PlayTsSkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) end,
        --- 盯人
        --- A08 = function(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) 
        ---        self:PlayDrSkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) end,
        --- 手术刀直塞
        C01 = function(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) 
                self:PlaySsdzsSkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) end,
        --- 组织核心
        C04 = function(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) 
                self:PlayZzhxSkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) end,
        --- 封堵
        A06 = function(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) 
                self:PlayFdSkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) end,
        --- 防空塔
        A05 = function(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) 
                self:PlayFktSkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) end,
        --- 精准预判
        A04 = function(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) 
                self:PlayJzypSkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) end,
        --- 飞铲
        A01 = function(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) 
                self:PlayFcSkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) end,
        --- 制空者
        E06 = function(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) 
                self:PlayZkzSkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) end,
        --- 偷猎者
        A03 = function(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) 
                self:PlayTlzSkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) end,
        --- 冲锋号角
        --- G02 = function(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) 
        ---        self:PlayCfhjSkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) end,
        --- 众志成城
        --- G03 = function(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) 
        ---        self:PlayZzccSkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) end,
        --- 永动机
        G01 = function(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) 
                self:PlayYdjSkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) end,
        --- 链式防守
        A07 = function(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) 
                self:PlayLsfsSkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) end,
        --- 过顶球
        C02 = function(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) 
                self:PlayGdqSkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) end,
        --- 下底传中
        C03 = function(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) 
                self:PlayXdczSkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) end,
        --- 大力水手
        F05 = function(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) 
                self:PlayDlssSkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) end,
        --- 角球大师
        F04 = function(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) 
                self:PlayJqdsSkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) end,
        --- 指挥人墙
        E08 = function(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) 
                self:PlayZhrqSkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) end,
        --- 点球大师
        F03 = function(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) 
                self:PlayDqdsSkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) end,
        --- 点球杀手
        E07 = function(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) 
                self:PlayDqssSkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio) end
    }
end

--- 播放只需要普通名字的技能音频
function CommentaryManager:PlaySkillAudioWithNormalName(candidateAudios)
    local seq = self:RandomItem(candidateAudios)
    self:InsertAudioSequence(seq, CommentaryConstants.AudioPriority.SKILL)
    return true
end

--- 播放需要普通名字和激情名字的技能音频
function CommentaryManager:PlaySkillAudioWithNormalNameAndPassionName(playerNamePassionAudio, candidateAudios)
    local seq = {}
    if playerNamePassionAudio ~= "" then
        seq = {playerNamePassionAudio}
    else
        seq = self:RandomItem(candidateAudios)
    end
    self:InsertAudioSequence(seq, CommentaryConstants.AudioPriority.SAVE)
    return true
end

--- 播放大力头槌技能音频
function CommentaryManager:PlayDltcSkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio)
    local candidateAudios = {{playerNameNormalAudioWithNotMust, "12_041"}, {playerNameNormalAudioWithNotMust, "16_037"}}
    return self:PlaySkillAudioWithNormalNameAndPassionName(playerNamePassionAudio, candidateAudios)
end

--- 播放凌空抽射技能音频
function CommentaryManager:PlayLkcsSkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio)
    local candidateAudios = {{playerNameNormalAudioWithNotMust, "12_042"}, {playerNameNormalAudioWithNotMust, "12_043"}, {playerNameNormalAudioWithNotMust, "12_044"}}
    return self:PlaySkillAudioWithNormalNameAndPassionName(playerNamePassionAudio, candidateAudios)
end

--- 播放重炮手技能音频
function CommentaryManager:PlayZpsSkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio)
    local candidateAudios = {{playerNameNormalAudioWithNotMust, "12_045"}, {playerNameNormalAudioWithNotMust, "12_046"}, {playerNameNormalAudioWithNotMust, "12_047"}}
    return self:PlaySkillAudioWithNormalNameAndPassionName(playerNamePassionAudio, candidateAudios)
end

--- 播放冷静推射技能音频
function CommentaryManager:PlayLjtsSkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio)
    local candidateAudios = {{"16_038"}, {playerNameNormalAudioWithNotMust, "12_049"}, {playerNameNormalAudioWithNotMust, "12_063"}}
    return self:PlaySkillAudioWithNormalNameAndPassionName(playerNamePassionAudio, candidateAudios)
end

--- 播放禁区之狐技能音频
function CommentaryManager:PlayJqzhSkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio)
    local candidateAudios = {{playerNameNormalAudioWithNotMust, "11_122"}, {"16_039"}}
    return self:PlaySkillAudioWithNormalNameAndPassionName(playerNamePassionAudio, candidateAudios)
end

--- 播放冲击波技能音频
function CommentaryManager:PlayCjbSkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio)
    local candidateAudios = {{playerNameNormalAudioWithNotMust, "16_040"}}
    return self:PlaySkillAudioWithNormalNameAndPassionName(playerNamePassionAudio, candidateAudios)
end

--- 播放猛虎射门技能音频
function CommentaryManager:PlayMhcmSkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio)
    local candidateAudios = {{playerNameNormalAudioWithNotMust, "16_041"}}
    return self:PlaySkillAudioWithNormalNameAndPassionName(playerNamePassionAudio, candidateAudios)
end

--- 播放手控球技能音频
function CommentaryManager:PlaySkqSkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio)
    local candidateAudios = {{playerNameNormalAudioWithMustAndGk, "12_052"}, {playerNameNormalAudioWithMustAndGk, "16_044"}}
    return self:PlaySkillAudioWithNormalName(candidateAudios)
end

--- 播放零失误技能音频
function CommentaryManager:PlayLswSkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio)
    local candidateAudios = {{playerNameNormalAudioWithMustAndGk, "12_052"}, {playerNameNormalAudioWithMustAndGk, "16_044"}}
    return self:PlaySkillAudioWithNormalName(candidateAudios)
end

--- 播放门神下凡技能音频
function CommentaryManager:PlayMsxfSkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio)
    local candidateAudios = {{playerNameNormalAudioWithMustAndGk, "16_045"}, {playerNameNormalAudioWithMustAndGk, "16_046"}, {playerNameNormalAudioWithMustAndGk, "16_047"}}
    return self:PlaySkillAudioWithNormalName(candidateAudios)
end

--- 播放神级反应技能音频
function CommentaryManager:PlaySjfySkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio)
    local candidateAudios = {{playerNameNormalAudioWithMustAndGk, "16_045"}, {playerNameNormalAudioWithMustAndGk, "16_046"}, {playerNameNormalAudioWithMustAndGk, "16_047"}}
    return self:PlaySkillAudioWithNormalName(candidateAudios)
end

--- 播放节拍器技能音频
function CommentaryManager:PlayJpqSkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio)
    local candidateAudios = {{playerNameNormalAudioWithMustAndNotGk, "12_061"}, {playerNameNormalAudioWithMustAndNotGk, "16_059"}}
    return self:PlaySkillAudioWithNormalName(candidateAudios)
end

--- 播放带球突破技能音频
function CommentaryManager:PlayDqtpSkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio)
    local candidateAudios = {{playerNameNormalAudioWithNotMust, "12_001"}, {playerNameNormalAudioWithNotMust, "12_002"}, {playerNameNormalAudioWithNotMust, "12_003"}, {playerNameNormalAudioWithNotMust, "12_004"}, {playerNameNormalAudioWithNotMust, "12_005"}, {playerNameNormalAudioWithNotMust, "12_006"}}
    return self:PlaySkillAudioWithNormalName(candidateAudios)
end

--- 播放小动作技能音频
function CommentaryManager:PlayXdzSkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio)
    local candidateAudios = {{playerNameNormalAudioWithNotMust, "16_060"}, {playerNameNormalAudioWithNotMust, "16_061"}}
    return self:PlaySkillAudioWithNormalName(candidateAudios)
end

--- 播放跳水技能音频
function CommentaryManager:PlayTsSkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio)
    local candidateAudios = {{playerNameNormalAudioWithNotMust, "16_062"}}
    return self:PlaySkillAudioWithNormalName(candidateAudios)
end

--- 播放盯人技能音频（以后添加被释放技能球员解说）
function CommentaryManager:PlayDrSkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio)
    local candidateAudios = {{playerNameNormalAudioWithNotMust, "16_064"}, {playerNameNormalAudioWithNotMust, "16_065"}, {playerNameNormalAudioWithNotMust, "16_066"}}
    return self:PlaySkillAudioWithNormalName(candidateAudios)
end

--- 播放手术刀直塞技能音频
function CommentaryManager:PlaySsdzsSkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio)
    local candidateAudios = {{playerNameNormalAudioWithNotMust, "16_067"}, {playerNameNormalAudioWithNotMust, "12_025"}, {playerNameNormalAudioWithNotMust, "16_068"}}
    return self:PlaySkillAudioWithNormalName(candidateAudios)
end

--- 播放组织核心技能音频
function CommentaryManager:PlayZzhxSkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio)
    local candidateAudios = {{playerNameNormalAudioWithNotMust, "16_069"}, {playerNameNormalAudioWithNotMust, "16_070"}}
    return self:PlaySkillAudioWithNormalName(candidateAudios)
end

--- 播放封堵技能音频
function CommentaryManager:PlayFdSkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio)
    local candidateAudios = {{playerNameNormalAudioWithMustAndNotGk, "16_071"}, {playerNameNormalAudioWithMustAndNotGk, "16_072"}}
    return self:PlaySkillAudioWithNormalName(candidateAudios)
end

--- 播放防空塔技能音频
function CommentaryManager:PlayFktSkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio)
    local candidateAudios = {{playerNameNormalAudioWithNotMust, "11_070"}, {playerNameNormalAudioWithNotMust, "12_031"}, {playerNameNormalAudioWithNotMust, "12_062"}}
    return self:PlaySkillAudioWithNormalName(candidateAudios)
end

--- 播放精准预判技能音频
function CommentaryManager:PlayJzypSkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio)
    local candidateAudios = {{playerNameNormalAudioWithNotMust, "12_011"}, {playerNameNormalAudioWithNotMust, "12_012"}, {playerNameNormalAudioWithNotMust, "12_013"}, {playerNameNormalAudioWithNotMust, "12_014"}, {playerNameNormalAudioWithNotMust, "12_015"}}
    return self:PlaySkillAudioWithNormalName(candidateAudios)
end

--- 播放飞铲技能音频
function CommentaryManager:PlayFcSkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio)
    local candidateAudios = {{playerNameNormalAudioWithNotMust, "12_016"}, {playerNameNormalAudioWithNotMust, "12_017"}, {playerNameNormalAudioWithNotMust, "12_018"}}
    return self:PlaySkillAudioWithNormalName(candidateAudios)
end

--- 播放制空者技能音频
function CommentaryManager:PlayZkzSkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio)
    local candidateAudios = {{playerNameNormalAudioWithMustAndGk, "12_051"}}
    return self:PlaySkillAudioWithNormalName(candidateAudios)
end

--- 播放偷猎者技能音频
function CommentaryManager:PlayTlzSkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio)
    local candidateAudios = {{playerNameNormalAudioWithNotMust, "16_073"}, {playerNameNormalAudioWithNotMust, "16_074"}}
    return self:PlaySkillAudioWithNormalName(candidateAudios)
end

--- 播放冲锋号角技能音频
function CommentaryManager:PlayCfhjSkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio)
    local candidateAudios = {{playerNameNormalAudioWithNotMust, "16_075"}}
    return self:PlaySkillAudioWithNormalName(candidateAudios)
end

--- 播放众志成城技能音频
function CommentaryManager:PlayZzccSkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio)
    local candidateAudios = {{playerNameNormalAudioWithNotMust, "16_076"}}
    return self:PlaySkillAudioWithNormalName(candidateAudios)
end

--- 播放永动机技能音频
function CommentaryManager:PlayYdjSkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio)
    local candidateAudios = {{playerNameNormalAudioWithMustAndNotGk, "16_077"}, {playerNameNormalAudioWithMustAndNotGk, "16_078"}, {playerNameNormalAudioWithMustAndNotGk, "16_079"}}
    return self:PlaySkillAudioWithNormalName(candidateAudios)
end

--- 播放链式防守技能音频
function CommentaryManager:PlayLsfsSkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio)
    math.randomseed(tostring(os.time()):reverse():sub(1, 7))
    if math.random(5) == 1 then
        local candidateAudios = {{"16_080"}}
        return self:PlaySkillAudioWithNormalName(candidateAudios)
    end
end

--- 播放过顶球技能音频
function CommentaryManager:PlayGdqSkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio)
    local candidateAudios = {{playerNameNormalAudioWithNotMust, "12_022"}, {playerNameNormalAudioWithNotMust, "16_081"}}
    return self:PlaySkillAudioWithNormalName(candidateAudios)
end

--- 播放下底传中技能音频
function CommentaryManager:PlayXdczSkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio)
    local candidateAudios = {{playerNameNormalAudioWithNotMust, "16_082"}, {playerNameNormalAudioWithNotMust, "16_083"}, {playerNameNormalAudioWithNotMust, "16_084"}}
    return self:PlaySkillAudioWithNormalName(candidateAudios)
end

--- 播放大力水手技能音频
function CommentaryManager:PlayDlssSkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio)
    local candidateAudios = {{playerNameNormalAudioWithMustAndNotGk, "12_032"}}
    return self:PlaySkillAudioWithNormalName(candidateAudios)
end

--- 播放角球大师技能音频
function CommentaryManager:PlayJqdsSkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio)
    local candidateAudios = {{playerNameNormalAudioWithNotMust, "12_036"}, {playerNameNormalAudioWithNotMust, "16_085"}, {"16_086"}}
    return self:PlaySkillAudioWithNormalName(candidateAudios)
end

--- 播放指挥人墙技能音频
function CommentaryManager:PlayZhrqSkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio)
    local candidateAudios = {{playerNameNormalAudioWithMustAndGk, "12_068"}}
    return self:PlaySkillAudioWithNormalName(candidateAudios)
end

--- 播放点球大师技能音频
function CommentaryManager:PlayDqdsSkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio)
    local candidateAudios = {{playerNameNormalAudioWithMustAndNotGk, "12_034"}, {playerNameNormalAudioWithMustAndNotGk, "12_035"}}
    return self:PlaySkillAudioWithNormalName(candidateAudios)
end

--- 播放点球杀手技能音频
function CommentaryManager:PlayDqssSkillAudio(playerNameNormalAudioWithNotMust, playerNameNormalAudioWithMustAndNotGk, playerNameNormalAudioWithMustAndGk, playerNamePassionAudio)
    local candidateAudios = {{playerNameNormalAudioWithMustAndNotGk, "12_067"}}
    return self:PlaySkillAudioWithNormalName(candidateAudios)
end

function CommentaryManager:PlayDemoMatchCommentary(audioName)
    local audioFilePath = "Assets/CapstonesRes/Game/Audio/Commentary/DemoMatch/" .. audioName .. ".mp3"
    if not self.nowAudioPlayer then
        self.nowAudioPlayer = AudioManager.GetPlayer("commentary")
    end
    if self.inDemoMatchFadeOut then
        DOTween.Kill(self.nowAudioPlayer, false)
    end
    self.nowAudioPlayer.PlayAudio(audioFilePath, 1)
end

function CommentaryManager:IsAudioPlayingInDemoMatch()
    return self.nowAudioPlayer.isPlaying
end

function CommentaryManager:StopDemoMatchCommentary()
    self.nowAudioPlayer.Stop()
end

function CommentaryManager:FadeOutDemoMatchCommentary(duration)
    duration = duration or 1
    local fadeOutTweener = ShortcutExtensions.DOFade(self.nowAudioPlayer, 0, duration)
    self.inDemoMatchFadeOut = true
end

function CommentaryManager:onDestroy()
    self:RemoveEvent()
end

return CommentaryManager