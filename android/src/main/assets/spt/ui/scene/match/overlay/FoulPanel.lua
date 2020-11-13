local UnityEngine = clr.UnityEngine
local WaitForSeconds = UnityEngine.WaitForSeconds

local MatchConstants = require("ui.scene.match.MatchConstants")
local CommonConstants = require("ui.common.CommonConstants")
local MatchInfoModel = require("ui.models.MatchInfoModel")
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")

local FoulPanel = class(unity.base)

function FoulPanel:ctor()
    self.rectTrans = self.___ex.rectTrans
    self.nameTxt = self.___ex.name
    self.number = self.___ex.number
    self.time = self.___ex.time
    self.foulTypeText = self.___ex.foulTypeText
    self.stayTime = self.___ex.stayTime
    self.homeTeamLogoBox = self.___ex.homeTeamLogoBox
    self.homeTeamLogo = self.___ex.homeTeamLogo
    self.awayTeamLogoBox = self.___ex.awayTeamLogoBox
    self.awayTeamLogo = self.___ex.awayTeamLogo
    -- 动画管理器
    self.animator = self.___ex.animator
end

function FoulPanel:start()
    local matchInfoModel = MatchInfoModel.GetInstance()
    local playerTeamData = matchInfoModel:GetPlayerTeamData()
    local opponentTeamData = matchInfoModel:GetOpponentTeamData()
    TeamLogoCtrl.BuildTeamLogo(self.homeTeamLogo, playerTeamData.logo)
    TeamLogoCtrl.BuildTeamLogo(self.awayTeamLogo, opponentTeamData.logo)
end

function FoulPanel:Display(isPlayer, number, name, time, foulType)
    self.nameTxt.text = name
    self.number.text = tostring(number)
    self.time.text = tostring(time)
    if isPlayer then
        self.homeTeamLogoBox:SetActive(true)
        self.awayTeamLogoBox:SetActive(false)
    else
        self.homeTeamLogoBox:SetActive(false)
        self.awayTeamLogoBox:SetActive(true)
    end

    if foulType == MatchConstants.FoulType.FOUL then
        self.foulTypeText.text = lang.trans("match_foul")
    elseif foulType == MatchConstants.FoulType.OFFSIDE then
        self.foulTypeText.text = lang.trans("match_offside")
    elseif foulType == MatchConstants.FoulType.YELLOW_CARD then
        self.foulTypeText.text = lang.trans("match_yellowCard")
    elseif foulType == MatchConstants.FoulType.RED_CARD then
        self.foulTypeText.text = lang.trans("match_redCard")
    end

    self:PlayMoveInAnim()
end

function FoulPanel:PlayMoveInAnim()
    self.animator:Play("Base Layer.MoveIn", 0)
end

function FoulPanel:PlayMoveOutAnim()
    coroutine.yield(WaitForSeconds(self.stayTime))
    self.animator:Play("Base Layer.MoveOut", 0)
end

function FoulPanel:EndAnimation()
    self.gameObject:SetActive(false)
end

function FoulPanel:OnAnimEnd(animMoveType)
    if animMoveType == CommonConstants.UIAnimMoveType.MOVE_IN then
        self:coroutine(function ()
            self:PlayMoveOutAnim()
        end)
    elseif animMoveType == CommonConstants.UIAnimMoveType.MOVE_OUT then
        self:EndAnimation()
    end
end

return FoulPanel
