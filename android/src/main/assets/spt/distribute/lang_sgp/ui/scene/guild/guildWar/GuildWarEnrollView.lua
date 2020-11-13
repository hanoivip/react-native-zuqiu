local UnityEngine = clr.UnityEngine
local UI = UnityEngine.UI
local Text = UI.Text
local Vector3 = UnityEngine.Vector3
local Color = UnityEngine.Color
local GUILD_MEMBERTYPE = require("ui.controllers.guild.GUILD_MEMBERTYPE")
local GUILDWAR_STATE = require("ui.controllers.guild.guildWar.GUILDWAR_STATE")
local GuildWar = require("data.GuildWar")

local GuildWarEnrollView = class(unity.base)

function GuildWarEnrollView:ctor()
   self.infoBarDynParent = self.___ex.infoBar
   self.leftButton = self.___ex.leftButton
   self.leftButtonIcon = self.___ex.leftButtonIcon
   self.rightButton = self.___ex.rightButton
   self.rightButtonIcon = self.___ex.rightButtonIcon
   self.level = self.___ex.level
   self.btnEnroll = self.___ex.btnEnroll
   self.btnEnrollText = self.___ex.btnEnrollText
   self.guardPosition = self.___ex.guardPosition
   self.conditionTxt = self.___ex.conditionTxt
   self.conditionObj = self.___ex.conditionObj
   self.tipText = self.___ex.tipText
   self.btnInstruction = self.___ex.btnInstruction
   self.btnHistory = self.___ex.btnHistory
   self.btnSchedule = self.___ex.btnSchedule
   self.btnMyData = self.___ex.btnMyData
   self.periodText = self.___ex.periodText
end

function GuildWarEnrollView:start()
    self.btnEnroll:regOnButtonClick(function()
        if type(self.OnBtnEnrollClick) == "function" then
            local state = self.model:GetState()
            if state == GUILDWAR_STATE.NOTSIGN or state == GUILDWAR_STATE.PREFINISH then
                self.OnBtnEnrollClick()
            end
        end
    end)

    self.btnInstruction:regOnButtonClick(function()
        if type(self.OnBtnInstructionClick) == "function" then
            self.OnBtnInstructionClick()
        end
    end)

    self.btnHistory:regOnButtonClick(function()
        if type(self.OnBtnHistoryClick) == "function" then
            self.OnBtnHistoryClick()
        end
    end)

    self.btnSchedule:regOnButtonClick(function()
        if type(self.OnBtnScheduleClick) == "function" then
            self.OnBtnScheduleClick()
        end
    end)

    self.btnMyData:regOnButtonClick(function()
        if type(self.OnBtnMyDataClick) == "function" then
            self.OnBtnMyDataClick()
        end
    end)

    local pressAddData = {
        acceleration = 1,
        clickCallback = function()
            self:AddLevel()
        end,
        durationCallback = function(count)
            self:AddLevel()
        end,
    }

    local pressMinusData = {
        acceleration = 1,
        clickCallback = function()
            self:MinusLevel()
        end,
        durationCallback = function(count)
            self:MinusLevel()
        end,
    }

    self.leftButton:regOnButtonPressing(pressMinusData)
    self.rightButton:regOnButtonPressing(pressAddData)
    -- 小热更先脚本先适配
    self.conditionObj.transform.localPosition = Vector3(545, -117.9, 0)
end

function GuildWarEnrollView:InitView(model)
    self.model = model
    local authority = model:GetSelfAuthority()
    local state = model:GetState()
    local time = model:GetLeftTime()
    local timeTab = string.convertSecondToTimeTable(time)
    local day = timeTab.day
    local hour = timeTab.hour
    local period = model:GetPeriod()

    self.periodText.text = lang.transstr("guildwar_period", period)
    if state == GUILDWAR_STATE.NOTSIGN or state == GUILDWAR_STATE.PREFINISH then
        if authority == GUILD_MEMBERTYPE.ADMIN or authority == GUILD_MEMBERTYPE.VP then
            self.tipText.text = lang.transstr("guildwar_enrollTip1", day, hour)
        else
            self.tipText.text = lang.transstr("guildwar_enrollTip2")
        end
        self.btnEnrollText.text = lang.transstr("guildwar_enrollBtn1")
    elseif state == GUILDWAR_STATE.SIGNED then
        self.tipText.text = lang.transstr("guildwar_enrollTip3", day, hour)
        self.btnEnrollText.text = lang.transstr("guildwar_enrollBtn2")
    elseif state == GUILDWAR_STATE.GROUPING then
        self.tipText.text = lang.transstr("guildwar_enrollTip4")
        self.btnEnrollText.text = lang.transstr("guildwar_enrollBtn3")
    elseif state == GUILDWAR_STATE.PREPARE then
        self.tipText.text = lang.transstr("guildwar_enrollTip5", day, hour)
        self.btnEnrollText.text = lang.transstr("guildwar_enrollBtn4")
    end

    self:SetHistoryButtonState(state ~= GUILDWAR_STATE.PREPARE)
end

function GuildWarEnrollView:SetHistoryButtonState(state)
    local isFirst = self.model:GetIsFirst()
    if isFirst == true then
        self.btnHistory.gameObject:SetActive(false)
        self.btnSchedule.gameObject:SetActive(true)
    else
        self.btnHistory.gameObject:SetActive(state)
        self.btnSchedule.gameObject:SetActive(not state)
    end
end

function GuildWarEnrollView:SetLeftButtonIcon(isgrey)
    self:SetButtonIcon(self.leftButtonIcon, isgrey)
end

function GuildWarEnrollView:SetRightButtonIcon(isgrey)
    self:SetButtonIcon(self.rightButtonIcon, isgrey)
end

function GuildWarEnrollView:SetButtonIcon(btnIcon, isgrey)
    if isgrey then
        btnIcon.color = Color(100/255.0, 100/255.0, 100/255.0)
    else
        btnIcon.color = Color(1, 1, 1)
    end
end

function GuildWarEnrollView:SetLevelText(level, openMaxLevel)
    if tonumber(level) <= openMaxLevel then
        self.conditionObj:SetActive(false)
    else
        self.conditionObj:SetActive(true)
        local num = self.model:GetLastFirstInfo(level - 1)

        self.conditionTxt.text = format(GuildWar[tostring(level)].conditionDesc, num)
    end
    self.level.text = lang.transstr("guildwar_level", level)
    self.level.color = Color(1, 1, 1, 200.0 / 255)

    local state = self.model:GetState()
    local signLevel = self.model:GetSignLevel()
    if state ~= GUILDWAR_STATE.NOTSIGN and state ~= GUILDWAR_STATE.PREFINISH then
        if level == signLevel then
            self.level.color = Color(182.0 / 255, 255.0 / 255, 51.0 / 255)
        end
    end
end

function GuildWarEnrollView:RegOnDynamicLoad(func)
    self.infoBarDynParent:RegOnDynamicLoad(func)
end

return GuildWarEnrollView
