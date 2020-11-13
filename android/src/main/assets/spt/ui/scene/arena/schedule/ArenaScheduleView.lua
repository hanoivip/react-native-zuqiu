local ArenaIndexType = require("ui.scene.arena.ArenaIndexType")
local MatchScheduleType = require("ui.scene.arena.schedule.MatchScheduleType")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local ArenaScheduleView = class(unity.base)

function ArenaScheduleView:ctor()
    self.infoBarDynParent = self.___ex.infoBarDynParent
    self.arenaTitle = self.___ex.arenaTitle
    self.arenaTitleIcon = self.___ex.arenaTitleIcon
    self.btnRule = self.___ex.btnRule
    self.btnReward = self.___ex.btnReward
    self.btnSchedule = self.___ex.btnSchedule
    self.btnMyFormation = self.___ex.btnMyFormation
    self.btnOtherFormation = self.___ex.btnOtherFormation
    self.btnCourt = self.___ex.btnCourt
    self.homeTeamView = self.___ex.homeTeamView
    self.visitTeamView = self.___ex.visitTeamView
    self.matchTitle = self.___ex.matchTitle
    self.matchTime = self.___ex.matchTime
    self.showArea = self.___ex.showArea
    self.isMatchGoonArea = self.___ex.isMatchGoonArea
    self.btnCourtTechnology = self.___ex.btnCourtTechnology
    self.animator = self.___ex.animator

    self.teamArea = self.___ex.teamArea
    self.rewardArea = self.___ex.rewardArea
    self.rewardView = self.___ex.rewardView
    self.rewardView.clickReward = function(isRecieved) self:OnClickScheduleReward(isRecieved) end
end

function ArenaScheduleView:OnClickScheduleReward(isRecieved)
    if self.clickScheduleReward then 
        self.clickScheduleReward(isRecieved)
    end
end

function ArenaScheduleView:EnterScene()
    self.rewardView:EnterScene()
end

function ArenaScheduleView:ExitScene()
    self.rewardView:ExitScene()
end

function ArenaScheduleView:start()
    self.btnRule:regOnButtonClick(function()
        self:OnBtnRule()
    end)
    self.btnReward:regOnButtonClick(function()
        self:OnBtnReward()
    end)
    self.btnSchedule:regOnButtonClick(function()
        self:OnBtnSchedule()
    end)
    self.btnMyFormation:regOnButtonClick(function()
        self:OnBtnMyFormation()
    end)
    self.btnOtherFormation:regOnButtonClick(function()
        self:OnBtnOtherFormation()
    end)
    self.btnCourt:regOnButtonClick(function()
        self:OnBtnCourt()
    end)
    self.btnCourtTechnology:regOnButtonClick(function()
        self:OnBtnCourtTechnology()
    end)
end

function ArenaScheduleView:OnBtnMyFormation()
    if self.clickMyFormation then 
        self.clickMyFormation()
    end
end

function ArenaScheduleView:OnBtnOtherFormation()
    if self.clickOtherFormation then 
        self.clickOtherFormation()
    end
end

function ArenaScheduleView:OnBtnCourtTechnology()
    if self.clickCourtTechnology then 
        self.clickCourtTechnology()
    end 
end

function ArenaScheduleView:OnBtnCourt()
    if self.clickCourt then 
        self.clickCourt()
    end
end

function ArenaScheduleView:OnBtnRule()
    if self.clickRule then 
        self.clickRule()
    end
end

function ArenaScheduleView:OnBtnReward()
    if self.clickReward then 
        self.clickReward()
    end
end

function ArenaScheduleView:OnBtnSchedule()
    if self.clickSchedule then 
        self.clickSchedule()
    end
end

function ArenaScheduleView:OnBtnBack()
    if self.clickBack then 
        self.clickBack()
    end
end

function ArenaScheduleView:OnClickBackAnimation()
    if self.hasMatchGoon then 
        self.animator:Play("ArenaScheduleTeamLeaveAnimation", 0, 0)
    elseif self.isMatch then 
        self.animator:Play("ArenaScheduleTeamLeaveAnimation", 0, 0)
    else
        self.animator:Play("ArenaScheduleRewardLeaveAnimation", 0, 0)
    end
end

function ArenaScheduleView:OnAnimationLeave()
    self:OnBtnBack()
end

function ArenaScheduleView:ShowDisplayArea(isShow)
    GameObjectHelper.FastSetActive(self.showArea, isShow)
end

function ArenaScheduleView:InitView(arenaModel, arenaNextMatchModel, arenaType)
    self:ShowDisplayArea(true)
    local title = arenaType .. "_arena"
    self.arenaTitle.text = lang.trans(title)
    local arenaIndex = ArenaIndexType[arenaType]
    self.arenaTitleIcon.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Arena/Images/Arena/Arena" .. arenaIndex .. ".png")
    GameObjectHelper.FastSetActive(self.arenaTitleIcon.gameObject, true);
    local isMatch = false
    local hasMatchGoon = arenaNextMatchModel and arenaNextMatchModel:HasMatchGoon() or false

    if not hasMatchGoon then -- 在等待服务器数据的时候显示一个提示信息
        if arenaNextMatchModel then 
            isMatch = true
            self.homeTeamView:InitView(arenaModel, arenaNextMatchModel, arenaType, true)
            self.visitTeamView:InitView(arenaModel, arenaNextMatchModel, arenaType, false)
            local group = arenaNextMatchModel:GetTeamGroup()
            local matchDesc = arenaNextMatchModel:GetGroupDesc()
            local stageRound = arenaNextMatchModel:GetStageRound() + 1
            if group and group ~= "" then 
                self.matchTitle.text = lang.trans("next_match_title", group, lang.transstr(matchDesc), stageRound)
            elseif matchDesc == MatchScheduleType.Final then
                self.matchTitle.text = lang.trans(matchDesc)
            else
                self.matchTitle.text = lang.trans("next_match_title2", lang.transstr(matchDesc), stageRound)
            end
            local time = arenaNextMatchModel:GetTime()
            local convertTime = os.date(lang.transstr("calendar_time3"), time) 
            self.matchTime.text = lang.trans("match_time", convertTime)
        else
            self.rewardView:InitView(arenaModel, arenaType)
        end
    end

    GameObjectHelper.FastSetActive(self.teamArea, isMatch)
    GameObjectHelper.FastSetActive(self.rewardArea, not hasMatchGoon and not isMatch)
    GameObjectHelper.FastSetActive(self.isMatchGoonArea, hasMatchGoon)

    self:ShowAnimation(hasMatchGoon, isMatch)
end

function ArenaScheduleView:ShowAnimation(hasMatchGoon, isMatch)
    self.hasMatchGoon = hasMatchGoon
    self.isMatch = isMatch
    if hasMatchGoon then 
        self.animator:Play("ArenaScheduleTeamMatchingEntryAnimation", 0, 0)
    elseif isMatch then 
        self.animator:Play("ArenaScheduleTeamEntryAnimation", 0, 0)
    else
        self.animator:Play("ArenaScheduleRewardEntryAnimation", 0, 0)
    end
end

function ArenaScheduleView:RegOnDynamicLoad(func)
    self.infoBarDynParent:RegOnDynamicLoad(func)
end

return ArenaScheduleView
