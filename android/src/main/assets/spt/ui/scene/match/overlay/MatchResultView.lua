local CommonConstants = require("ui.common.CommonConstants")
local UISoundManager = require("ui.control.manager.UISoundManager")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local MatchConstants = require("ui.scene.match.MatchConstants")

local MatchResultView = class(unity.base)

function MatchResultView:ctor()
    -- 胜利图标
    self.winBox = self.___ex.winBox
    -- 平局图标
    self.drawBox = self.___ex.drawBox
    -- 失败图标
    self.loseBox = self.___ex.loseBox
    -- 动画管理器
    self.animator = self.___ex.animator
    -- 胜利左标题
    self.winLeftTitleImg = self.___ex.winLeftTitleImg
    -- 胜利右标题
    self.winRightTitleImg = self.___ex.winRightTitleImg
    -- 胜利的文字
    self.SEAText_Win = self.___ex.SEAText_Win
    -- 比赛关卡是否有特殊通关条件
    self.matchStageIsSpecial = false
    -- 比赛结果，1:胜利，0:平局，-1:失败
    -- 比赛图标
    self.winIcon = self.___ex.winIcon
    self.loseIcon = self.___ex.loseIcon
    self.resultStatus = nil
end

function MatchResultView:InitView(resultStatus, matchStageIsSpecial)
    self.resultStatus = resultStatus
    self.matchStageIsSpecial = matchStageIsSpecial
end

function MatchResultView:start()
    self:BuildPage()
    self:RegisterEvent()
end

function MatchResultView:BuildPage()
    local matchResultData = cache.getMatchResult()
    self.matchType = matchResultData.matchType

    if self.matchStageIsSpecial then
        self:BuildPageOnSpecial()
    else
        self:BuildPageOnCommon()
    end
end

function MatchResultView:IconConfig(isWin)
    local path = "Assets/CapstonesRes/Game/UI/Match/Overlay/Images/SettlementSystem/MatchIcon/"
    local icon = "Normal"
    local findMatchIcon = MatchConstants.MatchTypeIcon[self.matchType]
    if findMatchIcon then 
        icon = findMatchIcon
    end
    local symbol = isWin and "_Win" or "_Lose"
    local iconSprite = isWin and self.winIcon or self.loseIcon
    local iconDir = path .. icon .. symbol .. ".png"
    iconSprite.sprite = res.LoadRes(iconDir)
end

function MatchResultView:BuildPageOnCommon()
    local soundPath
    if self.resultStatus == 1 then
        self.winLeftTitleImg.sprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Match/Overlay/Images/SettlementSystem/MatchResult/Win_Title_1.png")
        self.winRightTitleImg.sprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Match/Overlay/Images/SettlementSystem/MatchResult/Win_Title_2.png")
        GameObjectHelper.FastSetActive(self.winBox, true)
        GameObjectHelper.FastSetActive(self.drawBox, false)
        GameObjectHelper.FastSetActive(self.loseBox, false)
        soundPath = "Match/matchWin"
        self.animator:Play("Base Layer.Win", 0)
        self:IconConfig(true)
    elseif self.resultStatus == 0 then
        GameObjectHelper.FastSetActive(self.winBox, false)
        GameObjectHelper.FastSetActive(self.drawBox, true)
        GameObjectHelper.FastSetActive(self.loseBox, false)
        soundPath = "Match/matchDraw"
        self.animator:Play("Base Layer.Draw", 0)
    elseif self.resultStatus == -1 then
        GameObjectHelper.FastSetActive(self.winBox, false)
        GameObjectHelper.FastSetActive(self.drawBox, false)
        GameObjectHelper.FastSetActive(self.loseBox, true)
        soundPath = "Match/matchLose"
        self.animator:Play("Base Layer.Lose", 0)
        self:IconConfig(false)
    end
    if self.matchType == MatchConstants.MatchType.LEAGUE then
        soundPath = "League/LeagueMatchResult"
    end
    UISoundManager.play(tostring(soundPath), 1)
end

function MatchResultView:BuildPageOnSpecial()
    if self.resultStatus == 1 then
        self.winLeftTitleImg.sprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Match/Overlay/Images/SettlementSystem/MatchResult/Success_Title_1.png")
        self.winRightTitleImg.sprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Match/Overlay/Images/SettlementSystem/MatchResult/Success_Title_2.png")
        GameObjectHelper.FastSetActive(self.winBox, true)
        GameObjectHelper.FastSetActive(self.drawBox, false)
        GameObjectHelper.FastSetActive(self.loseBox, false)
        UISoundManager.play('Match/matchWin', 1)
        self.animator:Play("Base Layer.Win", 0)

        self:TransformText()
        self:IconConfig(true)
    else
        GameObjectHelper.FastSetActive(self.winBox, false)
        GameObjectHelper.FastSetActive(self.drawBox, false)
        GameObjectHelper.FastSetActive(self.loseBox, true)
        UISoundManager.play('Match/matchLose', 1)
        self.animator:Play("Base Layer.Lose", 0)
        self:IconConfig(false)
    end
end

-- 在多版本中有成功和胜利两种表现形式切换
function MatchResultView:TransformText()
    if self.SEAText_Win then
        self.SEAText_Win.text = lang.trans("match_success")
    end
end

function MatchResultView:Destroy()
    if type(self.closeDialog) == "function" then
        self.closeDialog()
    end
end

function MatchResultView:PlayMoveOutAnim()
    if self.resultStatus == 1 then
        self.animator:Play("Base Layer.WinLeave", 0)
    elseif self.resultStatus == 0 then
        self.animator:Play("Base Layer.DrawLeave", 0)
    elseif self.resultStatus == -1 then
        self.animator:Play("Base Layer.LoseLeave", 0)
    end
end

function MatchResultView:OnAnimEnd(animMoveType)
    if animMoveType == CommonConstants.UIAnimMoveType.MOVE_IN then
        EventSystem.SendEvent("SettlementPageView.ShowMatchDataView")
    elseif animMoveType == CommonConstants.UIAnimMoveType.MOVE_OUT then
        EventSystem.SendEvent("MatchDataView.PlayMoveOutAnim")
    end
end

--- 注册事件
function MatchResultView:RegisterEvent()
    EventSystem.AddEvent("MatchResultView.PlayMoveOutAnim", self, self.PlayMoveOutAnim)
end

--- 移除事件
function MatchResultView:RemoveEvent()
    EventSystem.RemoveEvent("MatchResultView.PlayMoveOutAnim", self, self.PlayMoveOutAnim)
end

function MatchResultView:onDestroy()
    self:RemoveEvent()
end

return MatchResultView
