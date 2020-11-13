local UnityEngine = clr.UnityEngine
local UI = UnityEngine.UI
local Text = UI.Text
local Vector2 = UnityEngine.Vector2
local AssetFinder = require("ui.common.AssetFinder")
local GameObjectHelper = require("ui.common.GameObjectHelper")

local GuildWarDefenceView = class(unity.base)

function GuildWarDefenceView:ctor()
    self.infoBarDynParent = self.___ex.infoBar
    self.guardPosition = self.___ex.guardPosition
    self.btnSchedule = self.___ex.btnSchedule
    self.btnInstruction = self.___ex.btnInstruction
    self.btnShop = self.___ex.btnShop
    self.btnMyData = self.___ex.btnMyData
    self.btnArrow = self.___ex.btnArrow
    self.btnLogo = self.___ex.btnLogo
    self.levelRoundText = self.___ex.levelRoundText
    self.periodText = self.___ex.periodText
    self.guildLogo = self.___ex.guildLogo
    self.guildName = self.___ex.guildName
    self.leftTime = self.___ex.leftTime
    self.captureCount = self.___ex.captureCount
    self.seizeCount = self.___ex.seizeCount
    self.atkBuffTxt = self.___ex.atkBuffTxt
    self.defBuffTxt = self.___ex.defBuffTxt
    self.loseAnim = self.___ex.loseAnim
end

function GuildWarDefenceView:start()
    self.btnInstruction:regOnButtonClick(function()
        if type(self.OnBtnInstructionClick) == "function" then
            self.OnBtnInstructionClick()
        end
    end)

    self.btnSchedule:regOnButtonClick(function()
        if type(self.OnBtnScheduleClick) == "function" then
            self.OnBtnScheduleClick()
        end
    end)

    self.btnShop:regOnButtonClick(function()
        if type(self.OnBtnShopClick) == "function" then
            self.OnBtnShopClick()
        end
    end)

    self.btnMyData:regOnButtonClick(function()
        if type(self.OnBtnMyDataClick) == "function" then
            self.OnBtnMyDataClick()
        end
    end)

    self.btnArrow:regOnButtonClick(function()
        if type(self.OnBtnArrowClick) == "function" then
            self.OnBtnArrowClick()
        end
    end)

    self.btnLogo:regOnButtonClick(function ()
        if type(self.OnBtnLogoClick) == "function" then
          self.OnBtnLogoClick()
        end
    end)
end

function GuildWarDefenceView:InitView(model)
    self.model = model
    local level = model:GetLevel()
    local round = model:GetRound()
    local period = model:GetPeriod()
    local guildData = model:GetGuildInfo()
    local time = model:GetLeftTime()
    local timeTable = string.convertSecondToTimeTable(time)
    local seizeCount = model:GetSeizeCount()
    local captureCount = model:GetCaptureCount()

    self.levelRoundText.text = lang.transstr("guildwar_round2", lang.transstr("number_" .. level), lang.transstr("number_" .. round))
    self.periodText.text = lang.transstr("guildwar_period", period)
    self.guildLogo.overrideSprite = AssetFinder.GetGuildIcon("GuildLogo" .. guildData.eid)
    self.guildName.text = guildData.name
    self.leftTime.text = timeTable.hour .. ":" .. timeTable.minute
    self.seizeCount.text = tostring(seizeCount)
    self.captureCount.text = tostring(captureCount)

    local atkBuff = self.model:GetEnemyBuffTxt()
    if atkBuff then
      GameObjectHelper.FastSetActive(self.atkBuffTxt.transform.parent.gameObject, true)
      self.atkBuffTxt.text = atkBuff
    end

    local defBuff = self.model:GetMyBuffTxt()
    if defBuff then
      GameObjectHelper.FastSetActive(self.defBuffTxt.transform.parent.gameObject, true)
      self.defBuffTxt.text = defBuff
    end

    if tonumber(captureCount) >= 7 then
        self.loseAnim:Play("GuildWarDefencePosition")
    end
end

function GuildWarDefenceView:onAnimationLeave()
end

function GuildWarDefenceView:RegOnDynamicLoad(func)
    self.infoBarDynParent:RegOnDynamicLoad(func)
end

return GuildWarDefenceView
