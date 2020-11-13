local GuildAuthority = require("data.GuildAuthority")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local GuildMistWarBuffStoreItemView = class(unity.base)

function GuildMistWarBuffStoreItemView:ctor()
--------Start_Auto_Generate--------
    self.bgImg = self.___ex.bgImg
    self.titleTxt = self.___ex.titleTxt
    self.attributeImg = self.___ex.attributeImg
    self.buyDisableGo = self.___ex.buyDisableGo
    self.disableTxt = self.___ex.disableTxt
    self.buyBtn = self.___ex.buyBtn
    self.consumeTxt = self.___ex.consumeTxt
    self.boughtGo = self.___ex.boughtGo
--------End_Auto_Generate----------
end

function GuildMistWarBuffStoreItemView:start()
    EventSystem.AddEvent("GuildBuffStoreItem_RefreshBuy", self, self.ResetBuyState)
    self:RegOnButtonClick()
end

function GuildMistWarBuffStoreItemView:InitView(staticData, serverData, guildMistWarBuffStoreModel)
    self.staticData = staticData
    self.serverData = serverData
    self.model = guildMistWarBuffStoreModel
    local path = "Assets/CapstonesRes/Game/UI/Scene/Guild/Image/GuildWar/%s.png"
    local price = staticData["price" .. tostring(self.model:GetLevel())]
    self.attributeImg.overrideSprite = res.LoadRes(format(path, staticData.effect))
    self.consumeTxt.text = lang.trans("guild_buff_store_consume", price)

    if staticData.type == "atk" then
        self.bgImg.overrideSprite = res.LoadRes(format(path, "AttackItemBg"))
        self.titleTxt.text = lang.trans("guild_war_buff_atk")
    elseif staticData.type == "def" then
        self.bgImg.overrideSprite = res.LoadRes(format(path, "DefenceItemBg"))
        self.titleTxt.text = lang.trans("guild_war_buff_def")
    end

    self:InitBtnState(staticData)
end

function GuildMistWarBuffStoreItemView:InitBtnState(staticData)
    local selfAuthority = self.model:GetSelfAuthority()
    local selectRound = self.model:GetSelectRound()
    selfAuthority = tostring(selfAuthority)
    local authorityState = GuildAuthority[selfAuthority].buyBuff == 1
    local maxOrder = self.model:GetMaxOrderByType(staticData.type, selectRound)
    if not authorityState then
        GameObjectHelper.FastSetActive(self.buyBtn.gameObject, false)
        GameObjectHelper.FastSetActive(self.buyDisableGo, true)
    end
    local order = staticData.order
    if tonumber(order) <= tonumber(maxOrder) then
        GameObjectHelper.FastSetActive(self.buyBtn.gameObject, false)
        GameObjectHelper.FastSetActive(self.buyDisableGo, false)
        GameObjectHelper.FastSetActive(self.boughtGo, true)
    end
end

function GuildMistWarBuffStoreItemView:RegOnButtonClick()
    self.buyBtn:regOnButtonClick(function ()
        if type(self.onBuyBuffBtnClick) == "function" then
            self.onBuyBuffBtnClick()
        end
    end)
end

function GuildMistWarBuffStoreItemView:ResetBuyState(buffInfo)
    self:InitBtnState(self.model, self.data, buffInfo)
end

function GuildMistWarBuffStoreItemView:onDestroy()
    EventSystem.RemoveEvent("GuildBuffStoreItem_RefreshBuy", self, self.ResetBuyState)
end

return GuildMistWarBuffStoreItemView
