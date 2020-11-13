local GuildAuthority = require("data.GuildAuthority")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GuildWarType = require("ui.models.guild.guildMistWar.GuildWarType")
local RegisterState = require("ui.models.guild.guildMistWar.GuildWarRegisterState")

local GuildWarTypeSelectView = class(unity.base, "GuildWarTypeSelectView")

function GuildWarTypeSelectView:ctor()
--------Start_Auto_Generate--------
    self.commonBtn = self.___ex.commonBtn
    self.mistBtn = self.___ex.mistBtn
    self.commonDisableGo = self.___ex.commonDisableGo
    self.commonLockTxt = self.___ex.commonLockTxt
    self.mistDisableGo = self.___ex.mistDisableGo
    self.mistLockTxt = self.___ex.mistLockTxt
    self.commonFloorTxt = self.___ex.commonFloorTxt
    self.commonFloorTitleGo = self.___ex.commonFloorTitleGo
    self.commonRegisterTxt = self.___ex.commonRegisterTxt
    self.mistFloorTxt = self.___ex.mistFloorTxt
    self.mistFloorTitleGo = self.___ex.mistFloorTitleGo
    self.mistRegisterTxt = self.___ex.mistRegisterTxt
    self.downTipGo = self.___ex.downTipGo
--------End_Auto_Generate----------
    self.canvasGroup = self.___ex.canvasGroup
end

function GuildWarTypeSelectView:start()
    self:RegBtnEvent()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function GuildWarTypeSelectView:RegBtnEvent()
    self.commonBtn:regOnButtonClick(function()
        self:OnBtnNormalClick()
    end)
    self.mistBtn:regOnButtonClick(function()
        self:OnBtnMistClick()
    end)
end

function GuildWarTypeSelectView:InitView(guildWarTypeSelectModel)
    self.model = guildWarTypeSelectModel
    local mistRegisterState = self.model:GetMistRegisterState()
    local commonRegisterState = self.model:GetCommonRegisterState()
    local showTips = self.model:GetShowTips()

    local mistOpenState = mistRegisterState == RegisterState.CanRegister or mistRegisterState == RegisterState.Registered
    local commonOpenState = commonRegisterState == RegisterState.CanRegister or commonRegisterState == RegisterState.Registered
    GameObjectHelper.FastSetActive(self.mistBtn.gameObject, mistOpenState)
    GameObjectHelper.FastSetActive(self.mistDisableGo, not mistOpenState)
    GameObjectHelper.FastSetActive(self.commonBtn.gameObject, commonOpenState)
    GameObjectHelper.FastSetActive(self.commonDisableGo, not commonOpenState)

    local guildInfo = self.model:GetGuildInfo()
    local authority = tostring(guildInfo.authority)
    local authorityState = GuildAuthority[authority].signWarRight == 1

    -- 普通公会战文字状态
    local commonFloorTitleState = false
    if commonRegisterState == RegisterState.Lock then
        self.commonLockTxt.text = lang.trans("not_unlock")
    elseif commonRegisterState == RegisterState.CanRegister then
        if authorityState then
            self.commonRegisterTxt.text = lang.trans("guild_can_regist")
        else
            self.commonRegisterTxt.text = lang.trans("guild_not_regist")
        end
    elseif commonRegisterState == RegisterState.Registered then
        local registerMinLevel = self.model:GetRegisterMinLevel()
        self.commonFloorTxt.text = lang.trans("guild_normal_level", registerMinLevel)
        self.commonRegisterTxt.text = ""
        commonFloorTitleState = true
    elseif commonRegisterState == RegisterState.NoneRegister then
        self.commonRegisterTxt.text = lang.trans("guild_not_regist")
    end
    GameObjectHelper.FastSetActive(self.commonFloorTitleGo, commonFloorTitleState)
    -- 迷雾战场文字状态
    local mistFloorTitleState = false
    if mistRegisterState == RegisterState.Lock then
        local lockAddition = self.model:GetAdditionByWarType(GuildWarType.Mist)
        self.mistLockTxt.text = lang.trans("guild_mist_open_tip", lockAddition)
    elseif mistRegisterState == RegisterState.CanRegister then
        if authorityState then
            self.mistRegisterTxt.text = lang.trans("guild_can_regist")
        else
            self.mistRegisterTxt.text = lang.trans("guild_not_regist")
        end
    elseif mistRegisterState == RegisterState.Registered then
        local registerMinLevel = self.model:GetRegisterMinLevel()
        self.mistFloorTxt.text = lang.trans("guild_mist_level", registerMinLevel)
        self.mistRegisterTxt.text = ""
        mistFloorTitleState = true
    elseif mistRegisterState == RegisterState.NoneRegister then
        self.mistRegisterTxt.text = lang.trans("guild_not_regist")
    end
    GameObjectHelper.FastSetActive(self.mistFloorTitleGo, mistFloorTitleState)
    GameObjectHelper.FastSetActive(self.downTipGo, showTips)
end

function GuildWarTypeSelectView:RefreshView()

end

function GuildWarTypeSelectView:Close()
    local callback = function()
        if type(self.closeDialog) == "function" then
            self.closeDialog()
        end
    end
    DialogAnimation.Disappear(self.transform, nil, callback)
end

-- 点击标准战场
function GuildWarTypeSelectView:OnBtnNormalClick()
    if self.onBtnNormalClick ~= nil and type(self.onBtnNormalClick) == "function" then
        self.onBtnNormalClick()
    end
end

-- 点击迷雾战场
function GuildWarTypeSelectView:OnBtnMistClick()
    if self.onBtnMistClick ~= nil and type(self.onBtnMistClick) == "function" then
        self.onBtnMistClick()
    end
end

return GuildWarTypeSelectView
