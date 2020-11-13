local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogManager = require("ui.control.manager.DialogManager")
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local ColorConversionHelper = require("ui.common.ColorConversionHelper")
local PeakChallengeBoardItemView = class(unity.base)

function PeakChallengeBoardItemView:ctor()
    self.nameTxt = self.___ex.name
    self.level = self.___ex.level
    self.teamLogo = self.___ex.teamLogo
    self.btnView = self.___ex.btnView
    self.fireBtn = self.___ex.fireBtn
    self.sweepBtn = self.___ex.sweepBtn
    self.sweepBtnComponent = self.___ex.sweepBtnComponent
    self.buttonSweepText = self.___ex.buttonSweepText
    self.server =self.___ex.server
    self.rank = self.___ex.rank
    self.powerGroup = self.___ex.powerGroup
end

function PeakChallengeBoardItemView:start()
    self:RegBtn()
end

function PeakChallengeBoardItemView:InitView(data)
    self:SetSweepButtonState(cache.getPeakSweepFlag())
    self.nameTxt.text = data.name
    self.level.text = "Lv" .. tostring(data.lvl)
    self:InitLogoData(self.teamLogo, data.logo)
    self.server.text = data.serverName
    self.rank.text = lang.trans("peak_rank", tostring(data.rank))
    self:SetPowerValue(data)
end
function PeakChallengeBoardItemView:SetPowerValue(data)
    local flag = nil
    local tempPower = nil
    for k, v in pairs(self.powerGroup) do
        local i = tonumber(k)
        flag = (data.peakTeam.teamShow[self:GetTeamShowKey(data.peakTeam.teamOrder, i)] == 1)
        tempPower = data.peakTeam.teamFlag[tostring(i)] and data.peakTeam.teamInfo[tostring(i)].power or 0
        v.text = lang.transstr("formation") .. i ..lang.transstr("guildWar_pb_power") .. ":  " .. (flag and (tempPower == 0 and lang.transstr("peak_nil_team") or tempPower) or lang.transstr("pd_peak_locked"))
    end
end

function PeakChallengeBoardItemView:GetTeamShowKey(data, index)
    for k, v in pairs(data) do
        if v == index then
            return k
        end
    end
    return nil
end

function PeakChallengeBoardItemView:RegBtn()
    self.btnView:regOnButtonClick(function ()
        if self.onViewDetail then
            self.onViewDetail(function(data)
                self:ResetPower(data)
            end)
        end
    end)
    self.fireBtn:regOnButtonClick(function ()
        if self.onChallengeOpponent then
            self.onChallengeOpponent(false)
        end
    end)
    self.sweepBtn:regOnButtonClick(function ()
        if self.onChallengeOpponent then
            self.onChallengeOpponent(true)
        end
    end)
end

function PeakChallengeBoardItemView:SetSweepButtonState(isOpen)
    self.sweepBtn:onPointEventHandle(isOpen)
    self.sweepBtnComponent.interactable = isOpen
    local r, g, b 
    if isOpen then 
        r, g, b = 145, 125, 86
    else
        r, g, b = 125, 125, 125
    end
    local color = ColorConversionHelper.ConversionColor(r, g, b)
    self.buttonSweepText.color = color
end

function PeakChallengeBoardItemView:ResetPower(data)
    self:SetPowerValue(data)
end
   
function PeakChallengeBoardItemView:InitLogoData(teamLogo, logoData)
    TeamLogoCtrl.BuildTeamLogo(teamLogo, logoData)
end

return PeakChallengeBoardItemView