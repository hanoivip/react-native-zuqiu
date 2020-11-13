local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Color = UnityEngine.Color
local GameObjectHelper = require("ui.common.GameObjectHelper")
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local AdditionView = class(unity.base)

function AdditionView:ctor()
    self.match = self.___ex.match
    self.desc = self.___ex.desc
    self.descText = self.___ex.descText
    self.hTeam = self.___ex.hTeam
    self.vTeam = self.___ex.vTeam
    self.score = self.___ex.score
    self.mirror = self.___ex.mirror
    self.hName = self.___ex.hName
    self.hServer = self.___ex.hServer
    self.vName = self.___ex.vName
    self.vServer = self.___ex.vServer
    self.matchDesc = self.___ex.matchDesc
	self.opponent = self.___ex.opponent
	self.empty = self.___ex.empty
    self.matchProgressContent = self.___ex.matchProgressContent
	self.penaltyScore = self.___ex.penaltyScore
	self.additionSignMap = {}
	self.additionSymbol = nil
end

function AdditionView:InitView(matchModel, index)
	local isShowMatch = false
	if  matchModel:IsRiseInMatch() then
		self.descText.text = lang.trans("compete_addition_desc1")
	elseif matchModel:IsFailInMatch() then
		self.descText.text = lang.trans("compete_addition_desc2")
	elseif matchModel:IsMatching() then
		isShowMatch = true
		local player1Data = matchModel:GetPlayer1Data()
		local player2Data = matchModel:GetPlayer2Data()
		TeamLogoCtrl.BuildTeamLogo(self.hTeam, player1Data.logo)
		TeamLogoCtrl.BuildTeamLogo(self.vTeam, player2Data.logo)

		local attackData = matchModel:GetAttackData()
		local defenderData = matchModel:GetDefenderData()
		local aScore = attackData.score
		local dScore = defenderData.score
		local score = aScore .. " : " .. dScore
		local sid1 = player1Data.sid or ""
		local sid2 = player2Data.sid or ""

		self.hName.text = player1Data.name
		self.vName.text = player2Data.name
		self.hServer.text = sid1 .. lang.transstr("server")
		self.vServer.text = sid2 .. lang.transstr("server")
		local additionProgress = matchModel:GetAdditionProgress()
		local myProgress = matchModel:GetMyProgress()
		local isWin = matchModel:IsWin()
		local isMatchOver = matchModel:IsMatchOver()
		local additionSignRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Compete/Cross/Prefab/AdditionSign.prefab")
		for i = 1, additionProgress do
			if not self.additionSignMap[i] then 
				local obj = Object.Instantiate(additionSignRes)
				local spt = res.GetLuaScript(obj)
				obj.transform:SetParent(self.matchProgressContent, false)
				self.additionSignMap[i] = spt
			end
			self.additionSignMap[i]:InitView(i, additionProgress, myProgress, isWin, isMatchOver)
		end
		for extra = additionProgress + 1, table.nums(self.additionSignMap) do
			GameObjectHelper.FastSetActive(self.additionSignMap[extra].gameObject, false)
		end

		local isPass = tobool(additionProgress == myProgress)
		local isSuccess = isPass and isWin
		if not self.additionSymbol then 
			local symbolObj = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Compete/Cross/Prefab/AdditionSymbol.prefab")
			local symbolSpt = res.GetLuaScript(symbolObj)
			symbolObj.transform:SetParent(self.matchProgressContent, false)
			self.additionSymbol = symbolSpt
		end
		self.additionSymbol:InitView(isSuccess)
		
		local playerId = matchModel:GetPlayerRoleId()
		local player1Color = (playerId == player1Data.pid) and Color.yellow or Color.white
		local player2Color = (playerId == player2Data.pid) and Color.yellow or Color.white
		self.hName.color = player1Color
		self.vName.color = player2Color
		self.hServer.color = player1Color
		self.vServer.color = player2Color
		
		if isMatchOver then 
			self.score.text = score
			self.mirror.text = score
			if aScore == dScore then --（需要调整比分位置为  自身主场：对方客场/对方主场：自身客场）
				local roleAttackScore = attackData.attackScore
				local roleDefenderScore = attackData.defenderScore
				local opponentAttackScore = defenderData.attackScore
				local opponentDefenderScore = defenderData.defenderScore
				local scoreText = "(<color=#FFEB04FF>" .. roleDefenderScore .. "</color>" .. " : " .. opponentAttackScore .. " / " .. opponentDefenderScore .. " : " .. "<color=#FFEB04FF>" .. roleAttackScore .. "</color>" .. ")"
				if roleAttackScore == opponentAttackScore then 
					local rolePenaltyScore, opponentPenaltyScore = matchModel:GetPenaltyScore() 
					scoreText = scoreText .. "\n" .. "(<color=#FFEB04FF>" .. rolePenaltyScore .. "</color>" .. " : " .. opponentPenaltyScore .. ")"
				end
				self.penaltyScore.text = scoreText
			else
				self.penaltyScore.text = ""
			end
		else
			local defaultScoreShow = "- : -"
			self.score.text = defaultScoreShow
			self.mirror.text = defaultScoreShow
			self.penaltyScore.text = ""
		end

		if isSuccess then 
			self.matchDesc.text = lang.trans("compete_addition_desc4")
		else
			if not isMatchOver then
				self.matchDesc.text = lang.trans("compete_match_desc")
			elseif isWin then 
				self.matchDesc.text = lang.trans("compete_addition_desc3", additionProgress - myProgress)
			else
				self.matchDesc.text = lang.trans("compete_addition_desc5")
			end
		end

		local isEmpty = matchModel:IsEmpty()
		GameObjectHelper.FastSetActive(self.opponent, not isEmpty)
		GameObjectHelper.FastSetActive(self.empty, isEmpty)
	end
	GameObjectHelper.FastSetActive(self.match, isShowMatch)
	GameObjectHelper.FastSetActive(self.desc, not isShowMatch)
end

return AdditionView