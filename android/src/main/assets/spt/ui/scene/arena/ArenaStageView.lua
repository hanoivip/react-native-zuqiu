local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local Color = UnityEngine.Color
local Time = UnityEngine.Time
local GameObjectHelper = require("ui.common.GameObjectHelper")
local ArenaStateType = require("ui.scene.arena.ArenaStateType")
local ArenaType = require("ui.scene.arena.ArenaType")
local ArenaHelper = require("ui.scene.arena.ArenaHelper")
local MatchScheduleType = require("ui.scene.arena.schedule.MatchScheduleType")
local ArenaScheduleIndex = require("data.ArenaScheduleIndex")
local ArenaIndexType = require("ui.scene.arena.ArenaIndexType")
local ReqEventModel = require("ui.models.event.ReqEventModel")
local ArenaStageView = class(unity.base)

function ArenaStageView:ctor()
    self.btnStage = self.___ex.btnStage
    self.board = self.___ex.board
    self.btnFormation = self.___ex.btnFormation
    self.btnState = self.___ex.btnState
    self.stateText = self.___ex.stateText
    self.stateImage = self.___ex.stateImage
    self.stateGradient = self.___ex.stateGradient
    self.minStage = self.___ex.minStage
    self.stateButton = self.___ex.stateButton
    self.matchSign = self.___ex.matchSign
    self.allotSign = self.___ex.allotSign
    self.allotTime = self.___ex.allotTime
    self.lvlObj = self.___ex.lvlObj
    self.teamIcon = self.___ex.teamIcon
    self.starMap = self.___ex.starMap
    self.animator = self.___ex.animator
    self.arenaName = self.___ex.arenaName
    self.matchText = self.___ex.matchText
    self.redPoint = self.___ex.redPoint
    self.state = ArenaStateType.DefaultType
end

function ArenaStageView:start()
    self.btnStage:regOnButtonClick(function()
        self:OnBtnStage()
    end)
    self.btnFormation:regOnButtonClick(function()
        self:OnBtnFormation()
    end)
    self.btnState:regOnButtonClick(function()
        self:OnBtnState()
    end)
end

function ArenaStageView:InitView(arenaModel, arenaType)
    self.arenaType = arenaType

    local stage, star, openStar, minStage = arenaModel:GetAreaState(arenaModel:GetAreaScore(arenaType))
    for k, v in pairs(self.starMap) do
        local index = tonumber(string.sub(k, 2))
        local starData = ArenaHelper.GetStarPos[tostring(openStar)]
        local isOpen = starData and tobool(index <= openStar)
        if isOpen then 
            local pos = starData[index]
            v.gameObject.transform.anchoredPosition = Vector2(pos.x, pos.y)
            local isShow = tobool(index <= star)
            v.interactable = isShow
        end
        GameObjectHelper.FastSetActive(v.gameObject, isOpen)
    end
    local minStageNum, minStageDesc = "", ""
    if stage then 
        self.teamIcon.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Arena/Images/Main/Team" .. stage .. ".png")
        self.teamIcon:SetNativeSize()
        local minStagePos = ArenaHelper.GetMinStagePos[tostring(stage)]
        if minStagePos then 
            self.minStage.transform.anchoredPosition = Vector2(minStagePos.x, minStagePos.y)
            minStageNum = tostring(minStage)
            if stage < ArenaHelper.StageType.StoryStage then 
                minStageDesc = lang.transstr("reduce_num", minStage) 
            else
                minStageDesc = lang.transstr("star_num", minStage) 
            end
        end
    end
    self.minStage.text = minStageNum
    self.arenaName.text = arenaModel:GetGradeName(stage) .. " " .. minStageDesc

    GameObjectHelper.FastSetActive(self.redPoint, arenaModel:IsShowRedPoint(arenaType))
end

-- 设置竞技场状态（报名，取消报名，分配， 参赛）
function ArenaStageView:SetState(arenaType, arenaModel)
    self.stateButton.interactable = true
    local isMatch = arenaModel:IsMatch(arenaType)
    if isMatch then 
        local isSelectArea = arenaModel:IsSelectArea(arenaType)
        if isSelectArea then 
            self.stateText.text = lang.trans("enter")
            self.state = ArenaStateType.MatchType
            self:SetMatchTime(arenaModel)
        else
            self.stateText.text = lang.trans("regist")
            self.stateButton.interactable = false
            self.state = ArenaStateType.OccupyType
        end
    else
        local isSign = arenaModel:IsSign(arenaType)
        if isSign then 
            local isAllotArea = arenaModel:IsAllotArea(arenaType)
            if isAllotArea then 
                self.stateText.text = lang.trans("regist_cancel")
                self.state = ArenaStateType.AllotType
                self:SetTime(arenaModel)
            else
                self.stateText.text = lang.trans("regist")
                self.stateButton.interactable = false
                self.state = ArenaStateType.OccupyType
            end
        else
            self.stateText.text = lang.trans("regist")
            self.state = ArenaStateType.RegistType
        end
    end

    local isOccupy = tobool(self.state == ArenaStateType.OccupyType)
    self.stateText.color = isOccupy and Color(152 / 255, 152 / 255, 152 / 255) or Color(1, 1, 1)
    self.stateImage.color = isOccupy and Color(0, 1, 1) or Color(1, 1, 1)

    GameObjectHelper.FastSetActive(self.matchSign, self.state == ArenaStateType.MatchType)
    GameObjectHelper.FastSetActive(self.allotSign, self.state == ArenaStateType.AllotType)

    local isSign = tobool(self.state == ArenaStateType.AllotType) or tobool(self.state == ArenaStateType.MatchType)
    self:ShowBoard(isSign)
end

function ArenaStageView:SetTime(arenaModel)
    local time = arenaModel:GetAllotTime(self.arenaType)
    if time > 0 then
        if self.timer then
            self:StopCoroutine(self.timer)
            self.timer = nil
        end

        self.timer = self:coroutine(function()
            while time > 0 do
                self.allotTime.text = string.formatTimeClock(time, 3600)
                coroutine.yield()
                time = time - Time.unscaledDeltaTime
            end
            self:OnRefresh()
        end)
    end
end

function ArenaStageView:SetMatchTime(arenaModel)
    if arenaModel:IsMatchOverNotRecieve(self.arenaType) then 
        self.matchText.text = lang.trans("arena_match_tip1")
    elseif arenaModel:IsMatchOverRecieved(self.arenaType) then 
        self.matchText.text = lang.trans("arena_match_tip2")
    elseif arenaModel:IsMatchOngoing(self.arenaType) then 
        local gameOrder = arenaModel:GetGameOrder(self.arenaType)
        if gameOrder then 
            local matchDesc 
            local stageRound
            for i, v in ipairs(ArenaScheduleIndex) do
                if v.gameOrder == gameOrder then 
                    matchDesc = v.gameStage
                    stageRound = v.stageOrder + 1
                    break
                end
            end
            local matchInfo = ""
            if matchDesc == MatchScheduleType.Final then
                matchInfo = lang.transstr(matchDesc)
            else
                matchInfo = lang.transstr("next_match_title2", lang.transstr(matchDesc), stageRound)
            end
            local time = arenaModel:GetGameTime(self.arenaType)
            if time > 0 then
                if self.gameTimer then
                    self:StopCoroutine(self.gameTimer)
                    self.gameTimer = nil
                end

                self.gameTimer = self:coroutine(function()
                    while time > 0 do
                        self.matchText.text = matchInfo .. "\n" .. string.formatTimeClock(time, 3600)
                        coroutine.yield()
                        time = time - Time.unscaledDeltaTime
                    end
                end)
            else
                self.matchText.text = matchInfo
            end
        else
            self.matchText.text = lang.trans("arena_be_match")
        end
    else
        self.matchText.text = ""
    end
end

function ArenaStageView:OnRefresh()
    if self.refresh then 
        self.refresh()
    end
end

function ArenaStageView:ShowBoard(isShow)
    GameObjectHelper.FastSetActive(self.board, isShow)
    if isShow then 
        if self.arenaType == ArenaType.SilverStage or self.arenaType == ArenaType.BlackGoldStage or self.arenaType == ArenaType.RedGoldStage then 
            self.animator:Play("ArenaStageButtonClickAnimation2", 0, 0)
        else
            self.animator:Play("ArenaStageButtonClickAnimation", 0, 0)
        end
    end
end

function ArenaStageView:OnBtnState()
    if self.clickState then 
        self.clickState(self.arenaType, self.state)
    end
end

function ArenaStageView:OnBtnStage()
    if self.clickStage then 
        self.clickStage(self.arenaType)
    end
end

function ArenaStageView:OnBtnFormation()
    if self.clickFormation then 
        self.clickFormation(self.arenaType)
    end
end

function ArenaStageView:ArenaStageClick(arenaType)
    self:ShowBoard(tobool(self.arenaType == arenaType))
end

function ArenaStageView:ArenaStateChange(arenaModel)
    if not self.gameObject.activeSelf then
        return
    end

    self:StopTimer()
    self:SetState(self.arenaType, arenaModel)
end

function ArenaStageView:StopTimer()
    if self.timer then
        self:StopCoroutine(self.timer)
        self.timer = nil
    end
    if self.gameTimer then
        self:StopCoroutine(self.gameTimer)
        self.gameTimer = nil
    end
end

function ArenaStageView:CutPage(arenaModel, bShow)
    GameObjectHelper.FastSetActive(self.gameObject, bShow)
    self:StopTimer()
    if bShow then
        self:SetState(self.arenaType, arenaModel)
    end
end

function ArenaStageView:OnEnterScene()
    EventSystem.AddEvent("ArenaStageClick", self, self.ArenaStageClick)
    EventSystem.AddEvent("ArenaStateChange", self, self.ArenaStateChange)
end

function ArenaStageView:OnExitScene()
    EventSystem.RemoveEvent("ArenaStageClick", self, self.ArenaStageClick)
    EventSystem.RemoveEvent("ArenaStateChange", self, self.ArenaStateChange)
    self:ShowBoard(false)
end

return ArenaStageView
