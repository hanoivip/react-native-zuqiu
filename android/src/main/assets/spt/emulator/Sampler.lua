if jit then jit.off(true, true) end

local Actions = import("./actions/Actions")
local Match = import("./Match")
local Field = import("./Field")
local MatchStates = import("./matchStates/MatchStates")
local vector2 = import("./libs/vector")

local Sampler = class()

function Sampler:ctor(callbackObj, callbackFunctions)
    self.callbackObj = callbackObj
    self.needStopCallback = callbackFunctions.needStopCallback
    self.pauseCallback = callbackFunctions.pauseCallback
    self.pauseOnPreShootCallback = callbackFunctions.pauseOnPreShootCallback
    self.pauseOnManualOperateCallback = callbackFunctions.pauseOnManualOperateCallback
    self.outputMovementFrameCallback = callbackFunctions.outputMovementFrameCallback
    self.outputBallFrameCallback = callbackFunctions.outputBallFrameCallback
    self.outputPlayerKeyFrameCallback = callbackFunctions.outputPlayerKeyFrameCallback
    self.outputOpponentKeyFrameCallback = callbackFunctions.outputOpponentKeyFrameCallback
    self.outputPlayerCoachSkillFrameCallback = callbackFunctions.outputPlayerCoachSkillFrameCallback
    self.outputOpponentCoachSkillFrameCallback = callbackFunctions.outputOpponentCoachSkillFrameCallback
    self.outputPlayerTeamFrameCallback = callbackFunctions.outputPlayerTeamFrameCallback
    self.outputOpponentTeamFrameCallback = callbackFunctions.outputOpponentTeamFrameCallback
    self.outputMatchKeyFrameCallback = callbackFunctions.outputMatchKeyFrameCallback
    self.outputAthleteEffectCallback = callbackFunctions.outputAthleteEffectCallback
    self.outputLatestTimeCallback = callbackFunctions.outputLatestTimeCallback
    self.outputPenaltyShootOutSequenceCallBack = callbackFunctions.outputPenaltyShootOutSequenceCallBack
    self.outputAthleteBuffCallback = callbackFunctions.outputAthleteBuffCallback
    self.outputAthleteSkillCallback = callbackFunctions.outputAthleteSkillCallback
    self.operationCallback = callbackFunctions.operationCallback
    self.sleepCallback = callbackFunctions.sleepCallback
    self.outputDeployedEventCallback = callbackFunctions.outputDeployedEventCallback
    self.outputDebugInfoCallback = callbackFunctions.outputDebugInfoCallback

    self.match = Match.new()
    self.field = Field

    self.lastMatchEventName = nil

    log.info("Sampler ctor done")
end

function Sampler:init(initializer)
    self.match:init(initializer)
end

function Sampler:nextKeyFrame()
    self.match:nextKeyFrame()
end

local function isAtheleteKeyFrame(athlete, time)
    if (athlete.currentAnimation ~= nil and athlete.currentAnimation.startTime ~= nil and math.cmpf(athlete.currentAnimation.startTime, time) == 0) or
        (athlete.outputActionStatus and athlete.outputActionStatus.name == "ManualOperate") or
        (athlete.outputActionStatus and athlete.outputActionStatus.name == "Shoot") then
        return true
    else
        return false
    end
end

function Sampler:main()
    print("Sampler main loop start")

    local match = self.match
    while not self.needStopCallback(self.callbackObj) do
        self.sleepCallback(self.callbackObj)
        self.operationCallback(self.callbackObj)

        self:nextKeyFrame()
        local currentTime = match.currentTime

        local isNormalPlayOnStart = false
        if match.state.name ~= self.lastMatchEventName and match.state.name == "NormalPlayOn" then
            isNormalPlayOnStart = true
        end

        self.outputMovementFrameCallback(self.callbackObj, match, isNormalPlayOnStart)

        if match.state.name ~= self.lastMatchEventName then
            self.outputMatchKeyFrameCallback(self.callbackObj, match)
            if match.state.name ~= "NormalPlayOn" or not match.ball.output then
                match.ball.output = "None"
            end
            if match.state.name == "PenaltyShootOutKick"
                and match.attackTeam.shootOutAttempts == 1
                and match.defenseTeam.shootOutAttempts == 0 then
                self.outputPenaltyShootOutSequenceCallBack(self.callbackObj, match)
            end
        end

        if match.playerTeam.isDeployed then
            self.outputDeployedEventCallback(self.callbackObj, currentTime)
            match.playerTeam.isDeployed = nil
        end

        if match.ball.output or match.ball.nextOutput then
            self.outputBallFrameCallback(self.callbackObj, currentTime, match.ball, isNormalPlayOnStart)
        end

        if match.playerTeam.lastCoachSkillId then
            self.outputPlayerCoachSkillFrameCallback(self.callbackObj, match, match.playerTeam)
        end
        if match.opponentTeam.lastCoachSkillId then
            self.outputOpponentCoachSkillFrameCallback(self.callbackObj, match, match.opponentTeam)
        end

        if match.playerTeam.outputIsManualOperateEnded then
            self.outputPlayerTeamFrameCallback(self.callbackObj, match, match.playerTeam)
        end
        if match.opponentTeam.outputIsManualOperateEnded then
            self.outputOpponentTeamFrameCallback(self.callbackObj, match, match.opponentTeam)
        end

        local isShootPause = false
        local isManualOperatePause = nil
        local manualOperateAthlete = nil

        for i, athlete in ipairs(match.playerTeam.athletes) do
            if athlete.outputActionStatus ~= nil and athlete.outputActionStatus.name == "PreShoot" then
                log.warning("PreShoot sampled !!!")
            end

            if athlete.outputActionStatus ~= nil and athlete.outputActionStatus.name == "ShootPause" then
                isShootPause = true
                preShootAthlete = athlete
            end

            if athlete.outputActionStatus ~= nil and athlete.outputActionStatus.name == "ManualOperate" then
                isManualOperatePause = true
                manualOperateAthlete = athlete
            end

            if isAtheleteKeyFrame(athlete, currentTime) then
                self.outputPlayerKeyFrameCallback(self.callbackObj, athlete, currentTime, isNormalPlayOnStart)
            end

            if athlete.interceptRate or athlete.stealRate or athlete.influenceRate or athlete.saveRate then
                self.outputAthleteEffectCallback(self.callbackObj, currentTime, athlete)
            end

            if #athlete.outputSkills > 0 then
                self.outputAthleteSkillCallback(self.callbackObj, currentTime, athlete)
            end

            if #athlete.outputStartBuffs > 0 or #athlete.outputEndBuffs > 0 then
                self.outputAthleteBuffCallback(self.callbackObj, currentTime, athlete)
            end

            --FOR DEBUG
            --[[
            if isManualOperatePause and athlete.currentAnimation and athlete.debugLines then
                local delta = 0
                delta = athlete.currentAnimation.animationInfo.time - athlete.currentAnimation.animationInfo.lastTouch * TIME_STEP
                self.outputDebugInfoCallback(self.callbackObj, currentTime - delta - 0.1, athlete)
            end
            ]]
            if DEBUG_INFO_OUTPUT and (athlete.debugLines or athlete.debugText) then
                self.outputDebugInfoCallback(self.callbackObj, currentTime, athlete)
            end
        end
        for i, athlete in ipairs(match.opponentTeam.athletes) do
            if athlete.outputActionStatus ~= nil and athlete.outputActionStatus.name == "PreShoot" then
                log.warning("PreShoot sampled !!!")
            end

            if athlete.outputActionStatus ~= nil and athlete.outputActionStatus.name == "ShootPause" then
                isShootPause = true
                preShootAthlete = athlete
            end

            if athlete.outputActionStatus ~= nil and athlete.outputActionStatus.name == "ManualOperate" then
                isManualOperatePause = true
                manualOperateAthlete = athlete
            end

            if isAtheleteKeyFrame(athlete, currentTime) then
                self.outputOpponentKeyFrameCallback(self.callbackObj, athlete, currentTime, isNormalPlayOnStart)
            end

            if athlete.interceptRate or athlete.stealRate or athlete.influenceRate or athlete.saveRate then
                self.outputAthleteEffectCallback(self.callbackObj, currentTime, athlete)
            end

            if #athlete.outputSkills > 0 then
                self.outputAthleteSkillCallback(self.callbackObj, currentTime, athlete)
            end

            if #athlete.outputStartBuffs > 0 or #athlete.outputEndBuffs > 0 then
                self.outputAthleteBuffCallback(self.callbackObj, currentTime, athlete)
            end

            if DEBUG_INFO_OUTPUT and (athlete.debugLines or athlete.debugText) then
                self.outputDebugInfoCallback(self.callbackObj, currentTime, athlete)
            end
        end

        if isManualOperatePause then
            self.pauseOnManualOperateCallback(self.callbackObj, manualOperateAthlete)
        end

        if isShootPause then
            log.warning("ShootPause sampled !!!")
            self.pauseOnPreShootCallback(self.callbackObj, preShootAthlete)
        end

        self.lastMatchEventName = match.state.name

        self.outputLatestTimeCallback(self.callbackObj, currentTime)

        -- Update flag before match event is written to queue
        -- Skip the first two frames because no pause need
        if math.cmpf(currentTime, 0.2) > 0 and match.state.name ~= "NormalPlayOn" then
            print("Emulator will be paused for " .. match.state.name .. " at " .. currentTime)
            self.pauseCallback(self.callbackObj)
        end

        if match.state.name == "GameOver" then
            break
        end
    end
end

return Sampler
