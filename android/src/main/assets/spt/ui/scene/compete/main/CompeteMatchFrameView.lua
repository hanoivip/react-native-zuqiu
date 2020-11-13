local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local Color = UnityEngine.Color

local ColorConversionHelper = require("ui.common.ColorConversionHelper")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local WorldTournamentName = require("data.WorldTournamentName")
local CompeteMatchType = require("ui.scene.compete.main.CompeteMatchType")
local CompeteSignConvert = require("ui.scene.compete.main.CompeteSignConvert")
local AssetFinder = require("ui.common.AssetFinder")

local CompeteMatchFrameView = class(unity.base)

function CompeteMatchFrameView:ctor()
    self.bottomSlot = self.___ex.bottomSlot
    self.progress = self.___ex.progress
    self.bottom = self.___ex.bottom
    self.sign = self.___ex.sign
    self.nameTxt = self.___ex.name
    self.matchInfo = self.___ex.matchInfo
    self.startInfo = self.___ex.startInfo
    self.checkInfo = self.___ex.checkInfo
    self.score1 = self.___ex.score1
    self.score2 = self.___ex.score2
    self.time = self.___ex.time
    self.round = self.___ex.round
    self.btnStart = self.___ex.btnStart
    self.btnCheck = self.___ex.btnCheck
    self.waitDesc = self.___ex.waitDesc
    -- 争霸赛标识
    self.competeSign = self.___ex.competeSign
    self.rctName = self.___ex.rctName
end

-- @param params
local OverWidth = 254 -- 进度条充满宽度
local HalfWidth = 110 -- 进度条半场宽度
local OriginWidth = 0 -- 未开始比赛宽度
local OriginHeight = 9 -- 初始高度
function CompeteMatchFrameView:InitView(competeModel, index, competeMainModel)
    local progress = competeMainModel:GetProgress()
    local bottomTrans = self.bottomSlot.transform
    local bottomAnchorMin, bottomAnchorMax, bottomAnchoredPosition, bottomSizeDelta, bottomPivot
    local progressAnchorMin, progressAnchorMax, progressAnchoredPosition, progressSizeDelta
    local bottomSlotPath, progressPath
    local isFirst, isMid, isFinal = false, false, false
    local basePath = "Assets/CapstonesRes/Game/UI/Scene/Compete/Main/Images"

    local isNotOpenMatch = competeModel:IsNotOpenMatch()
    local isMatchOver = competeModel:IsMatchOver()
    local isMatching = competeModel:IsMatching()
    local isWaitMatch = competeModel:IsWaitMatch()
    
    -- 最左边和最右边根据进度条表现状态设置不同形状和不同进度
    if competeMainModel:IsFirstFrame(index) then 
        isFirst = true
        bottomAnchorMin = Vector2(0, 0)
        bottomAnchorMax = Vector2(0, 0)
        bottomAnchoredPosition = Vector2(-5.5, 12)
        bottomSizeDelta = Vector2(261, 51)
        bottomPivot = Vector2(0, 0)
        bottomSlotPath = basePath .. "/BottomSlot1.png"
        progressAnchorMin = Vector2(0, 0.5)
        progressAnchorMax = Vector2(0, 0.5)
        progressAnchoredPosition = Vector2(10, -1) 

        if index < progress then 
            progressPath = basePath .. "/Progress3.png"
            OverWidth = 251
        else
            progressPath = basePath .. "/Progress1.png"
            OverWidth = 248
        end
    elseif competeMainModel:IsMidFrame(index) then 
        isMid = true
        bottomAnchorMin = Vector2(0, 0)
        bottomAnchorMax = Vector2(0, 0)
        bottomAnchoredPosition = Vector2(1.5, 12)
        bottomSizeDelta = Vector2(254, 51)
        bottomPivot = Vector2(0, 0)
        bottomSlotPath = basePath .. "/BottomSlot2.png"

        progressAnchorMin = Vector2(0, 0.5)
        progressAnchorMax = Vector2(0, 0.5)
        progressAnchoredPosition = Vector2(0, -1)

        if index < progress then 
            progressPath = basePath .. "/Progress4.png"
            OverWidth = 254
        else
            progressPath = basePath .. "/Progress2.png"
            OverWidth = 251
        end
    elseif competeMainModel:IsFinalFrame(index) then 
        isFinal = true
        bottomAnchorMin = Vector2(1, 0)
        bottomAnchorMax = Vector2(1, 0)
        bottomAnchoredPosition = Vector2(-11.5, 12)
        bottomSizeDelta = Vector2(257, 51)
        bottomPivot = Vector2(1, 0)
        bottomSlotPath = basePath .. "/BottomSlot3.png"

        progressAnchorMin = Vector2(0, 0.5)
        progressAnchorMax = Vector2(0, 0.5)
        progressAnchoredPosition = Vector2(0, -1)
        progressPath = basePath .. "/Progress2.png"
        OverWidth = 248
    end

    bottomTrans.anchorMin = bottomAnchorMin
    bottomTrans.anchorMax = bottomAnchorMax
    bottomTrans.anchoredPosition = bottomAnchoredPosition
    bottomTrans.sizeDelta = bottomSizeDelta
    bottomTrans.pivot = bottomPivot

    local progressTrans = self.progress.transform
    progressTrans.anchorMin = progressAnchorMin
    progressTrans.anchorMax = progressAnchorMax
    progressTrans.anchoredPosition = progressAnchoredPosition
    
    -- 进度条表现根据当前比赛进度曾现不一样的图片
    if isMatching or isWaitMatch then
        progressSizeDelta = Vector2(HalfWidth, OriginHeight)
    elseif isMatchOver then
        progressSizeDelta = Vector2(OverWidth, OriginHeight)
    else
        progressSizeDelta = Vector2(OriginWidth, OriginHeight)
    end
    progressTrans.sizeDelta = progressSizeDelta

    local isServerCross = competeModel:IsServerCross()
    local bottomPath = isServerCross and basePath .. "/Frame2.png" or basePath .. "/Frame1.png"

    self.bottomSlot.overrideSprite = res.LoadRes(bottomSlotPath)
    self.progress.overrideSprite = res.LoadRes(progressPath)
    self.bottom.overrideSprite = res.LoadRes(bottomPath)

    self:InitFrameInfo(competeModel)

    GameObjectHelper.FastSetActive(self.matchInfo, not isMatching and not isNotOpenMatch)
    GameObjectHelper.FastSetActive(self.startInfo, isMatching)
    GameObjectHelper.FastSetActive(self.checkInfo, isNotOpenMatch)

    self:InitCompeteSign(competeModel)
end

function CompeteMatchFrameView:InitFrameInfo(competeModel)
    self.nameTxt.text = competeModel:GetShowName()
    local beginTime = competeModel:GetBeginTime() or 0
    local endTime = competeModel:GetEndTime() or 0
    local convertTime = os.date(lang.transstr("calendar_time4"), tonumber(beginTime))
    convertTime = convertTime .. " — " .. os.date(lang.transstr("calendar_time4"), tonumber(endTime))
    self.time.text = tostring(convertTime)

    local matchType = competeModel:GetMatchType()
    local matchRound = competeModel:GetMatchRound()
    local matchText = WorldTournamentName[tostring(matchType)].name
    self.round.text = lang.trans("next_match_title2", matchText, matchRound) 

    local roleData, opponentData = competeModel:GetMatchScoreStatistics()
    local roleScore = roleData.score
    local opponentScore = opponentData.score

    local isWin = false
    local sign = 1
    local isMatchOver = competeModel:IsMatchOver()
    local isWaitMatch = competeModel:IsWaitMatch()
    local isDraw = false
    if isMatchOver then
		local roleTotalScore = tonumber(roleScore)
		local opponentTotalScore = tonumber(opponentScore)

        self.score1.text = roleTotalScore .. " : " .. opponentTotalScore
		local roleAttackScore = roleData.attackScore
		local roleDefenderScore = roleData.defenderScore
		local opponentAttackScore = opponentData.attackScore
		local opponentDefenderScore = opponentData.defenderScore
		local scoreStatistics = "(<color=#FFEB04FF>" .. roleDefenderScore .. "</color>" .. " : " .. opponentAttackScore .. " / " .. opponentDefenderScore .. " : " .. "<color=#FFEB04FF>" .. roleAttackScore .. "</color>" .. ")"
		if roleTotalScore == opponentTotalScore then
			local rolePenaltyScore, opponentPenaltyScore = competeModel:GetPenaltyScore()
			if competeModel:IsKnockout() then -- 淘汰赛比分相同时要比较主客场
				if roleAttackScore == opponentAttackScore then
					isWin = tobool(rolePenaltyScore > opponentPenaltyScore)
					scoreStatistics = scoreStatistics .. "\n" .. "(<color=#FFEB04FF>" .. rolePenaltyScore .. "</color>" .. " : " .. opponentPenaltyScore .. ")"
				else
					isWin = tobool(roleAttackScore > opponentAttackScore)
				end
				sign = isWin and 3 or 2
			else
				sign = 4
				isDraw = true
				isWin = false
			end
		else
			isWin = roleTotalScore > opponentTotalScore
			sign = isWin and 3 or 2
		end	   
        self.score2.text = scoreStatistics

        local green = ColorConversionHelper.ConversionColor(137, 255, 105, 255)
        local red = ColorConversionHelper.ConversionColor(239, 63, 63, 255)
        local blue = ColorConversionHelper.ConversionColor(64, 180, 228, 255)
        self.score1.color = isWin and green or (isDraw and blue or red)
        self.waitDesc.text = ""
    elseif isWaitMatch then 
        self.waitDesc.text = lang.trans("compete_wait_opponent")
        self.score1.text = ""
        self.score2.text = ""
        sign = 1
    else
        sign = 1
    end
    self.sign.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Compete/Main/Images/Sign" .. sign .. ".png")
end

function CompeteMatchFrameView:InitCompeteSign(competeModel)
    local worldTournamentLevel = competeModel:GetCompeteSign()
    local posX = -9
    if worldTournamentLevel ~= nil then
        local signData = CompeteSignConvert[tostring(worldTournamentLevel)]
        if signData then
            GameObjectHelper.FastSetActive(self.competeSign.gameObject, true)
            self.competeSign.overrideSprite = AssetFinder.GetCompeteSign(signData.path)
            posX = 0
        else
            GameObjectHelper.FastSetActive(self.competeSign.gameObject, false)
        end
    else
        GameObjectHelper.FastSetActive(self.competeSign.gameObject, false)
    end
    self.rctName.anchoredPosition = Vector2(posX, self.rctName.anchoredPosition.y)
end

return CompeteMatchFrameView