local GameObjectHelper = require("ui.common.GameObjectHelper")
local CompeteGuessSchedule = require("ui.models.compete.guess.CompeteGuessSchedule")

local CompeteGuessMatchItemView = class(unity.base, "CompeteGuessMatchItemView")

function CompeteGuessMatchItemView:ctor()
    -- 标题
    self.txtTitleBigEar = self.___ex.txtTitleBigEar
    self.txtTitleRefBigEar = self.___ex.txtTitleRefBigEar
    self.txtTitleSmallEar = self.___ex.txtTitleSmallEar
    self.txtTitleRefSmallEar = self.___ex.txtTitleRefSmallEar
    -- 纹理背景
    self.objTex = self.___ex.objTex
    -- 录像按钮
    self.btnReplay = self.___ex.btnReplay
    -- 翻盘奖励详情按钮
    self.btnReverseReward = self.___ex.btnReverseReward
    -- 左侧玩家信息
    self.sptLeftPlayer = self.___ex.sptLeftPlayer
    self.objLeftPlayer = self.___ex.objLeftPlayer
    self.left_BtnSupport = self.___ex.left_BtnSupport
    -- 右侧玩家信息
    self.sptRightPlayer = self.___ex.sptRightPlayer
    self.objRightPlayer = self.___ex.objRightPlayer
    self.right_ImgCompeteSign = self.___ex.right_ImgCompeteSign
    self.right_BtnSupport = self.___ex.right_BtnSupport
    -- 中间信息
    self.objMiddle = self.___ex.objMiddle
    -- 倒计时的文本
    self.txtTitleCountDown = self.___ex.txtTitleCountDown
    -- 倒计时
    self.txtCountdown = self.___ex.txtCountdown
    -- 绿色六边形
    self.imgHexagonGreen = self.___ex.imgHexagonGreen
    -- VS图片
    self.imgVS = self.___ex.imgVS
    -- 比赛结果
    self.txtResult = self.___ex.txtResult
    -- 结算中
    self.txtAccounting = self.___ex.txtAccounting
    -- 小场比分
    self.txtScores = self.___ex.txtScores
    -- 当前倍率
    self.txtMultiple = self.___ex.txtMultiple
    -- 获胜失败信息
    self.txtInfo = self.___ex.txtInfo
end

function CompeteGuessMatchItemView:start()
end

function CompeteGuessMatchItemView:update()
    if self.data and self.competeGuessModel then
        local countdown = self.competeGuessModel:GetCountdown()
        if self.data.schedule == CompeteGuessSchedule.guessing and countdown > 0 then
            -- 更新倒计时
            self.txtCountdown.text = string.convertSecondToTime(countdown)
            self.imgHexagonGreen.fillAmount = countdown / CompeteGuessSchedule.Countdown
        end
    end
end

function CompeteGuessMatchItemView:RegBtnEvent()
end

function CompeteGuessMatchItemView:InitView(data, competeGuessModel)
    self.data = data
    self.competeGuessModel = competeGuessModel
    -- 标题
    if data.matchType == "bigEar" then
        GameObjectHelper.FastSetActive(self.txtTitleBigEar.gameObject, true)
        GameObjectHelper.FastSetActive(self.txtTitleSmallEar.gameObject, false)
        local txt = lang.transstr("compete_cup2") .. " " .. lang.transstr("knockout") .. " " .. lang.transstr(CompeteGuessSchedule.RoundNameMap[tonumber(data.round)])
        self.txtTitleBigEar.text = txt
        self.txtTitleRefBigEar.text = txt
    elseif data.matchType == "smallEar" then
        GameObjectHelper.FastSetActive(self.txtTitleBigEar.gameObject, false)
        GameObjectHelper.FastSetActive(self.txtTitleSmallEar.gameObject, true)
        local txt = lang.transstr("compete_cup1") .. " " .. lang.transstr("knockout") .. " " .. lang.transstr(CompeteGuessSchedule.RoundNameMap[tonumber(data.round)])
        self.txtTitleSmallEar.text = txt
        self.txtTitleRefSmallEar.text = txt
    else
        GameObjectHelper.FastSetActive(self.txtTitleBigEar.gameObject, false)
        GameObjectHelper.FastSetActive(self.txtTitleSmallEar.gameObject, false)
        dump("wrong match type!")
    end

    -- 初始化中间部分信息
    self:InitMiddleInfo(data)

    -- 左侧玩家信息
    self.sptLeftPlayer:InitView(data.player1, data, competeGuessModel)
    -- 右侧玩家
    self.sptRightPlayer:InitView(data.player2, data, competeGuessModel)
end

function CompeteGuessMatchItemView:InitMiddleInfo(cacheData)
    local guessRatio = tonumber(string.format("%.2f", cacheData.guessRatio or 0))
    if cacheData.schedule == CompeteGuessSchedule.guessing then -- 可竞猜阶段
        self:DisplayMiddleObj(true, true, true, true, false, false, false, true, false, false)
    elseif cacheData.schedule == CompeteGuessSchedule.accounting then -- 比赛结算阶段
        self:DisplayMiddleObj(false, false, false, false, false, false, true, true, false, false)
        self.txtAccounting.text = lang.transstr("lottery_history_settling") .. "..." -- 结算中...
    elseif cacheData.schedule == CompeteGuessSchedule.resulting then -- 比赛已经出结果
        if cacheData.isMatchOver then
            self:DisplayMiddleObj(false, false, false, false, true, true, false, true, true, true)
            self.txtResult.text = "<size=40><color=#FFEB04FF>" .. cacheData.player1.score .. "</color>:" .. cacheData.player2.score .. "</size>"
            if cacheData.myGuess then -- 参与过竞猜
                if cacheData.myGuess.guessPlayer == cacheData.winner then -- 猜中
                    self.txtInfo.text = lang.transstr("compete_guess_desc9")
                else
                    self.txtInfo.text = lang.trans("compete_guess_desc10")
                end
            else -- 未竞猜
                GameObjectHelper.FastSetActive(self.txtInfo.gameObject, false)
            end
            -- 小比分
            local player1_scores = cacheData.player1.scores
            local player2_scores = cacheData.player2.scores
            local count = 0
            if #player1_scores == #player2_scores then
                count = #player1_scores
            end
            self.txtScores.text = self:JoinScroes(player1_scores, player2_scores, count)
        else -- 时间已过但服务器未出结果
            self:DisplayMiddleObj(false, false, false, false, false, false, true, true, false, false)
            self.txtAccounting.text = lang.transstr("lottery_history_settling") .. "..." -- 结算中..
        end
    else
        dump("wrong schedule data!")
    end
    -- 倍率
    GameObjectHelper.FastSetActive(self.txtMultiple.gameObject, guessRatio > 1)
    self.txtMultiple.text = lang.trans("compete_guess_desc4", guessRatio)
end

-- 主:客/主:客显示，CompeteGuessModel已处理好
-- 特殊颜色表示这是左侧玩家的分数
function CompeteGuessMatchItemView:JoinScroes(player1_scores, player2_scores, count)
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
        scores_str = scores_str .. self:ColorScore(p1_2.score) .. ":" .. p2_2.score .. ")"
    elseif not p1_2.isMark and p2_2.isMark then
        scores_str = scores_str .. p1_2.score .. ":" .. self:ColorScore(p2_2.score) .. ")"
    else
        scores_str = scores_str .. p1_2.score .. ":" .. p2_2.score .. ")"
    end
    if count == 3 then
        local p1_3 = player1_scores[3]
        local p2_3 = player2_scores[3]
        if p1_3.isMark and not p2_3.isMark then
            scores_str = scores_str .. "\n(" .. self:ColorScore(p1_3.score) .. ":" .. p2_3.score .. ")"
        elseif not p1_3.isMark and p2_3.isMark then
            scores_str = scores_str .. "\n(" .. p1_3.score .. ":" .. self:ColorScore(p2_3.score) .. ")"
        else
            scores_str = scores_str .. "\n(" .. p1_3.score .. ":" .. p2_3.score .. ")"
        end
    end
    return scores_str
end

function CompeteGuessMatchItemView:ColorScore(score)
    return "<color=#FFEB04FF>" .. tostring(score) .. "</color>"
end

function CompeteGuessMatchItemView:DisplayMiddleObj(isCountdown, isTxtCountdown, isImgHexGreen, isImgVS, isTxtResult, isTxtScores, isTxtAccounting, isTxtMultiple, isTxtInfo, isBtnReplay)
    -- 倒计时
    GameObjectHelper.FastSetActive(self.txtTitleCountDown.gameObject, isCountdown)
    GameObjectHelper.FastSetActive(self.txtCountdown.gameObject, isTxtCountdown)
    -- 绿色六边形
    GameObjectHelper.FastSetActive(self.imgHexagonGreen.gameObject, isImgHexGreen)
    -- vs图片
    GameObjectHelper.FastSetActive(self.imgVS.gameObject, isImgVS)
    -- 结算中&比赛结果
    GameObjectHelper.FastSetActive(self.txtResult.gameObject, isTxtResult)
    -- 小场比分
    GameObjectHelper.FastSetActive(self.txtScores.gameObject, isTxtScores)
    -- 结算中
    GameObjectHelper.FastSetActive(self.txtAccounting.gameObject, isTxtAccounting)
    -- 倍率
    GameObjectHelper.FastSetActive(self.txtMultiple.gameObject, isTxtMultiple)
    -- 获胜信息
    GameObjectHelper.FastSetActive(self.txtInfo.gameObject, isTxtInfo)
    -- 回放按钮
    GameObjectHelper.FastSetActive(self.btnReplay.gameObject, isBtnReplay)
end

return CompeteGuessMatchItemView
