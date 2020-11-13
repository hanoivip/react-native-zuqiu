local GameObjectHelper = require("ui.common.GameObjectHelper")
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local CompeteSignConvert = require("ui.scene.compete.main.CompeteSignConvert")
local CompeteGuessSchedule = require("ui.models.compete.guess.CompeteGuessSchedule")

local CompeteGuessMyItemView = class(unity.base, "CompeteGuessMyItemView")

function CompeteGuessMyItemView:ctor()
    -- 玩家信息
    self.objHead = self.___ex.objHead
    -- 标题
    self.txtTitleBigEar = self.___ex.txtTitleBigEar
    self.txtTitleRefBigEar = self.___ex.txtTitleRefBigEar
    self.txtTitleSmallEar = self.___ex.txtTitleSmallEar
    self.txtTitleRefSmallEar = self.___ex.txtTitleRefSmallEar
    -- 竞猜成功
    self.imgSuccess = self.___ex.imgSuccess
    -- 竞猜失败
    self.imgFailed = self.___ex.imgFailed
    -- 左侧玩家
    self.left_ImgPlayerLogo = self.___ex.left_ImgPlayerLogo
    self.left_TxtPlayerName = self.___ex.left_TxtPlayerName
    self.left_ImgCompeteSign = self.___ex.left_ImgCompeteSign
    self.left_TxtSupportNum = self.___ex.left_TxtSupportNum
    -- 右侧玩家
    self.right_ImgPlayerLogo = self.___ex.right_ImgPlayerLogo
    self.right_TxtPlayerName = self.___ex.right_TxtPlayerName
    self.right_ImgCompeteSign = self.___ex.right_ImgCompeteSign
    self.right_TxtSupportNum = self.___ex.right_TxtSupportNum
    -- 胜负
    self.txtInfo = self.___ex.txtInfo
    -- 比分
    self.txtScore = self.___ex.txtScore
    -- 小场比分
    self.txtScores = self.___ex.txtScores
    -- 录像按钮
    self.btnReplay = self.___ex.btnReplay

    -- 数据
    self.data = nil
    -- 比赛数据
    self.matchData = nil
    -- 翻盘奖励数据
    self.reverseReward = nil
end

function CompeteGuessMyItemView:start()
    self:RegBtnEvent()
end

function CompeteGuessMyItemView:SetJudgeStage(minStage, maxStage)
    self.minStage = minStage
    self.maxStage = maxStage
end

function CompeteGuessMyItemView:InitView(data, competeGuessModel)
    self.data = data
    self.matchData = data.match
    self.competeGuessModel = competeGuessModel
    -- 标题
    if data.matchType == "bigEar" then
        GameObjectHelper.FastSetActive(self.txtTitleBigEar.gameObject, true)
        GameObjectHelper.FastSetActive(self.txtTitleSmallEar.gameObject, false)
        local txt = lang.transstr("compete_cup2") .. lang.transstr("knockout") .. lang.transstr(CompeteGuessSchedule.RoundNameMap[tonumber(data.round)])
        self.txtTitleBigEar.text = txt
        self.txtTitleRefBigEar.text = txt
    elseif data.matchType == "smallEar" then
        GameObjectHelper.FastSetActive(self.txtTitleBigEar.gameObject, false)
        GameObjectHelper.FastSetActive(self.txtTitleSmallEar.gameObject, true)
        local txt = lang.transstr("compete_cup1") .. lang.transstr("knockout") .. lang.transstr(CompeteGuessSchedule.RoundNameMap[tonumber(data.round)])
        self.txtTitleSmallEar.text = txt
        self.txtTitleRefSmallEar.text = txt
    else
        GameObjectHelper.FastSetActive(self.txtTitleBigEar.gameObject, false)
        GameObjectHelper.FastSetActive(self.txtTitleSmallEar.gameObject, false)
        dump("wrong match type!")
    end

    -- 左侧玩家
    self:InitPlayerInfo(self.left_ImgPlayerLogo, self.left_TxtPlayerName, self.left_ImgCompeteSign, self.left_TxtSupportNum, self.matchData.player1)
    -- 右侧玩家
    self:InitPlayerInfo(self.right_ImgPlayerLogo, self.right_TxtPlayerName, self.right_ImgCompeteSign, self.right_TxtSupportNum, self.matchData.player2)

    -- 比分
    self.txtScore.text = "<color=#FFEB04FF>" .. self.matchData.player1.score .. "</color>:" .. self.matchData.player2.score
    self.txtInfo.text = self.matchData.player1.score > self.matchData.player2.score and lang.transstr("win") .. "/" .. lang.transstr("lose") or lang.transstr("lose") .. "/" .. lang.transstr("win")
    -- 小比分
    local player1_scores = self.matchData.player1.scores
    local player2_scores = self.matchData.player2.scores
    local count = 0
    if #player1_scores == #player2_scores then
        count = #player1_scores
    end
    self.txtScores.text = self:JoinScroes(player1_scores, player2_scores, count)
    GameObjectHelper.FastSetActive(self.imgSuccess.gameObject, false)
    GameObjectHelper.FastSetActive(self.imgFailed.gameObject, true)
end

-- 主:客/主:客显示，CompeteGuessModel已处理好
-- 特殊颜色表示这是左侧玩家的分数
function CompeteGuessMyItemView:JoinScroes(player1_scores, player2_scores, count)
    if count <= 0 then return "" end

    local scores_str = "("
    local p1_1 = player1_scores[1]
    local p2_1 = player2_scores[1]
    if p1_1.isMark and not p2_1.isMark then -- 左边主场分数是界面左侧玩家的，标颜色
        scores_str = scores_str .. self:ColorScore(p1_1.score) .. ":" .. p2_1.score .. "/"
    elseif not p1_1.isMark and p2_1.isMark then -- 右边客场分数是界面左侧玩家的，标颜色
        scores_str = scores_str .. p1_1.score .. ":" .. self:ColorScore(p2_1.score) .. "/"
    else
        scores_str = scores_str .. p1_1.score .. ":" .. p2_1.score .. "/"
    end
    local p1_2 = player1_scores[2]
    local p2_2 = player2_scores[2]
    if p1_2.isMark and not p2_2.isMark then
        scores_str = scores_str .. self:ColorScore(p1_2.score) .. ":" .. p2_2.score
    elseif not p1_2.isMark and p2_2.isMark then
        scores_str = scores_str .. p1_2.score .. ":" .. self:ColorScore(p2_2.score)
    else
        scores_str = scores_str .. p1_2.score .. ":" .. p2_2.score
    end
    if count == 3 then
        local p1_3 = player1_scores[3]
        local p2_3 = player2_scores[3]
        if p1_3.isMark and not p2_3.isMark then
            scores_str = scores_str .. "/" .. self:ColorScore(p1_3.score) .. ":" .. p2_3.score .. ")"
        elseif not p1_3.isMark and p2_3.isMark then
            scores_str = scores_str .. "/" .. p1_3.score .. ":" .. self:ColorScore(p2_3.score) .. ")"
        else
            scores_str = scores_str .. p1_3.score .. ":" .. p2_3.score .. ")"
        end
    else
        scores_str = scores_str .. ")"
    end
    return scores_str
end

function CompeteGuessMyItemView:ColorScore(score)
    return "<color=#FFEB04FF>" .. tostring(score) .. "</color>"
end

function CompeteGuessMyItemView:InitPlayerInfo(imgLogo, txtName, imgCompeteSign, txtSupportNum, playerData)
    -- 球队logo
    self:InitTeamLogo(imgLogo, playerData.logo)
    -- 争霸赛标识
    self:InitCompeteSign(imgCompeteSign, playerData.worldTournamentLevel)
    -- 球队名字
    txtName.text = playerData.name .. "  " .. playerData.serverName
    -- 支持人数
    txtSupportNum.text = lang.trans("compete_guess_desc15", playerData.guessCount)
end

-- 球队logo
function CompeteGuessMyItemView:InitTeamLogo(logoRct, logoData)
    TeamLogoCtrl.BuildTeamLogo(logoRct, logoData)
end

-- 争霸赛标识
function CompeteGuessMyItemView:InitCompeteSign(imgCompeteSign, competeSign)
    local hasCompeteSign = false
    if competeSign then
        local signData = CompeteSignConvert[tostring(competeSign)]
        if signData then
            imgCompeteSign.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Compete/Common/Images/" .. signData.path .. ".png")
            hasCompeteSign = true
        end
    end
    GameObjectHelper.FastSetActive(imgCompeteSign.gameObject, hasCompeteSign)
end

-- 注册按钮事件
function CompeteGuessMyItemView:RegBtnEvent()
    self.btnReplay:regOnButtonClick(function()
        self:OnClickBtnReplay()
    end)
end

-- 点击录像
function CompeteGuessMyItemView:OnClickBtnReplay()
    if self.onClickBtnReplay then
        self.onClickBtnReplay(self.matchData)
    end
end

return CompeteGuessMyItemView
