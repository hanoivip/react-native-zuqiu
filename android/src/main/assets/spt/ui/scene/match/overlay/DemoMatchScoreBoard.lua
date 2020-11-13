local UnityEngine = clr.UnityEngine
local WaitForSeconds = UnityEngine.WaitForSeconds
local Vector2 = UnityEngine.Vector2
local CommentaryManager = require("ui.control.manager.CommentaryManager")
local CommonConstants = require("ui.common.CommonConstants")
local DemoMatchConfig = require("coregame.DemoMatchConfig")
local DialogType = DemoMatchConfig.DialogType

local DemoMatchScoreBoard = class(unity.base)

local PreScoreResetPositionY = 2.5
local NewScoreResetPositionY = -72

function DemoMatchScoreBoard:ctor()
    self.homeTeam = self.___ex.homeTeam
    self.awayTeam = self.___ex.awayTeam
    self.time = self.___ex.time
    self.homePreScore = self.___ex.homePreScore
    self.homeNewScore = self.___ex.homeNewScore
    self.awayPreScore = self.___ex.awayPreScore
    self.awayNewScore = self.___ex.awayNewScore
    self.homePreScoreRect = self.___ex.homePreScoreRect
    self.homeNewScoreRect = self.___ex.homeNewScoreRect
    self.awayPreScoreRect = self.___ex.awayPreScoreRect
    self.awayNewScoreRect = self.___ex.awayNewScoreRect
    self.boardAnim = self.___ex.boardAnim
    self.homeScoreAnim = self.___ex.homeScoreAnim
    self.awayScoreAnim = self.___ex.awayScoreAnim

    self.dialogId = 0
    self.items = nil
    self.dialogType = nil
end

function DemoMatchScoreBoard:ShowDialog(dialog)
    self.dialogId = dialog.dialogId
    self.items = dialog.items
    self.audioOnShow = dialog.audioOnShow
    self.gameObject:SetActive(true)
    self:SetText()
    self:MoveIn()
end

function DemoMatchScoreBoard:DismissDialog()
    self.homePreScoreRect.anchoredPosition = Vector2(self.homePreScoreRect.anchoredPosition.x, PreScoreResetPositionY)
    self.homeNewScoreRect.anchoredPosition = Vector2(self.homeNewScoreRect.anchoredPosition.x, NewScoreResetPositionY)
    self.awayPreScoreRect.anchoredPosition = Vector2(self.awayPreScoreRect.anchoredPosition.x, PreScoreResetPositionY)
    self.awayNewScoreRect.anchoredPosition = Vector2(self.awayNewScoreRect.anchoredPosition.x, NewScoreResetPositionY)
    ___demoManager:OnDemoMatchDialogDismiss(self.dialogId)
    self.gameObject:SetActive(false)
    self.items = nil
    self.audioOnShow = nil
end

function DemoMatchScoreBoard:SetText()
    local params = string.split(lang.transstr(self.items[1]), ',')
    self.homeTeam.text = params[1]
    self.awayTeam.text = params[2]
    self.time.text = params[3]
    self.homePreScore.text = params[4]
    self.awayPreScore.text = params[5]
    self.homeNewScore.text = params[6]
    self.awayNewScore.text = params[7]
    self.isHomeScoreChanged = params[4] ~= params[6]
    self.isAwayScoreChanged = params[5] ~= params[7]
end

function DemoMatchScoreBoard:MoveIn()
    self.boardAnim:Play("Base Layer.MoveIn", 0)
    if #self.audioOnShow > 0 then
        CommentaryManager.GetInstance():PlayDemoMatchCommentary(self.audioOnShow[1])
    end
end

function DemoMatchScoreBoard:OnAnimEnd(animMoveType)
    if animMoveType == CommonConstants.UIAnimMoveType.MOVE_IN then
        if self.isHomeScoreChanged then
            self.homeScoreAnim:Play("Base Layer.ChangeScore", 0)
        end
        if self.isAwayScoreChanged then
            self.awayScoreAnim:Play("Base Layer.ChangeScore", 0)
        end
    elseif animMoveType == CommonConstants.UIAnimMoveType.MOVE_OUT then
        self:DismissDialog()
    end
end

function DemoMatchScoreBoard:OnChangeScoreEnd()
    self.boardAnim:Play("Base Layer.MoveOut", 0)
end

return DemoMatchScoreBoard
