local GameObjectHelper = require("ui.common.GameObjectHelper")
local MistEditorMapView = class(unity.base, "MistEditorMapView")

function MistEditorMapView:ctor()
--------Start_Auto_Generate--------
    self.editorMapSpt = self.___ex.editorMapSpt
    self.periodTxt = self.___ex.periodTxt
    self.rewardContentTxt = self.___ex.rewardContentTxt
    self.levelTxt = self.___ex.levelTxt
    self.scoreTxt = self.___ex.scoreTxt
    self.downTipTxt = self.___ex.downTipTxt
    self.detailBtn = self.___ex.detailBtn
    self.txtTxt = self.___ex.txtTxt
    self.remainTimeTxt = self.___ex.remainTimeTxt
    self.registerBtn = self.___ex.registerBtn
    self.registerStateTxt = self.___ex.registerStateTxt
    self.buffStoreBtn = self.___ex.buffStoreBtn
    self.backBtn = self.___ex.backBtn
--------End_Auto_Generate----------
end

function MistEditorMapView:start()
    self:RegBtnEvent()
end

function MistEditorMapView:RegBtnEvent()
    self.backBtn:regOnButtonClick(function()
        EventSystem.SendEvent("GuildWarMist_EditorMap", false)
    end)
    self.buffStoreBtn:regOnButtonClick(function()
        self:OnBtnBuffStoreClick()
    end)
end

function MistEditorMapView:InitView(guildMistWarMainModel, mistMapModel)
    self.model = guildMistWarMainModel
    self.mistMapModel = mistMapModel
    local period = self.model:GetPeriod()
    local mistLevel = self.model:GetFightMinLevel()
    local score = self.model:GetTotalScore()
    local round = self.mistMapModel:GetRound()
    local periodStr = lang.transstr("guildwar_period2", period)
    local roundStr = periodStr .. lang.transstr("round_num", round)
    local openMaxLevel = self.model:GetOpenMaxLevel()

    self.periodTxt.text = roundStr
    self.levelTxt.text = tostring(mistLevel)
    self.scoreTxt.text = tostring(score)
    self.downTipTxt.text = lang.trans("guild_mist_down_tip", openMaxLevel)
    EventSystem.SendEvent("GuildWarMist_SetMapPos", true)
end

-- buff商店
function MistEditorMapView:OnBtnBuffStoreClick()
    local round = self.mistMapModel:GetRound()
    local storePath = "ui.controllers.guild.guildMistWar.GuildMistWarBuffStoreCtrl"
    res.PushDialog(storePath, self.model, round)
end

function MistEditorMapView:OnEnterScene()
    self:RegEvent()
end

function MistEditorMapView:OnExitScene()
    GameObjectHelper.FastSetActive(self.gameObject, false)
    self:UnRegEvent()
end

function MistEditorMapView:RegEvent()

end

function MistEditorMapView:UnRegEvent()
    
end

return MistEditorMapView
