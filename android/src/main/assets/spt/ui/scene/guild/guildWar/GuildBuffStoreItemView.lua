local DialogManager = require("ui.control.manager.DialogManager")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local GuildBuffStoreItemView = class(unity.base)

function GuildBuffStoreItemView:ctor()
    self.BgImg = self.___ex.BgImg
    self.attributeImg = self.___ex.attributeImg
    self.consumeTxt = self.___ex.consumeTxt
    self.buyBtn = self.___ex.buyBtn
    self.buyDisableGo = self.___ex.buyDisableGo
    self.bought = self.___ex.bought
    self.animator = self.___ex.animator
    self.title = self.___ex.title
end

function GuildBuffStoreItemView:Init(data, model, nextRound, buffInfo)
    self.data = data
    self.model = model
    EventSystem.AddEvent("GuildBuffStoreItem_RefreshBuy", self, self.ResetBuyState)
    
    local path = "Assets/CapstonesRes/Game/UI/Scene/Guild/Image/GuildWar/%s.png"
    self.attributeImg.overrideSprite = res.LoadRes(format(path, data.effect))
    self.consumeTxt.text = lang.trans("guild_buff_store_consume", data["price" .. tostring(model:GetLevel())])

    if data.type == "atk" then
        self.BgImg.overrideSprite = res.LoadRes(format(path, "AttackItemBg"))
        self.title.text = lang.trans("guild_war_buff_atk")
    elseif data.type == "def" then
        self.BgImg.overrideSprite = res.LoadRes(format(path, "DefenceItemBg"))
        self.title.text = lang.trans("guild_war_buff_def")
    end

    self:RegOnButtonClick()
    self:InitBtnState(model, data, buffInfo)
end

function GuildBuffStoreItemView:InitBtnState(model, data, buffInfo)
    local isHasPermission = tonumber(model:GetSelfAuthority()) < 3
    if not isHasPermission then
        GameObjectHelper.FastSetActive(self.buyBtn.gameObject, false)
        GameObjectHelper.FastSetActive(self.buyDisableGo, true)
    end
    local maxOrder = -1
    local key = tostring(data.key)
    if data.type == "atk" then
        maxOrder = buffInfo.atkOrder
    end
    if data.type == "def" then
        maxOrder = buffInfo.defOrder
    end
    local order = data.order
    if tonumber(order) <= tonumber(maxOrder) then
        GameObjectHelper.FastSetActive(self.buyBtn.gameObject, false)
        GameObjectHelper.FastSetActive(self.buyDisableGo, false)
        GameObjectHelper.FastSetActive(self.bought, true)
    end
end

function GuildBuffStoreItemView:RegOnButtonClick()
    self.buyBtn:regOnButtonClick(function ()
        if type(self.onBuyBuffBtnClick) == "function" then
            self.onBuyBuffBtnClick()
        end
    end)
end

function GuildBuffStoreItemView:ResetBuyState(buffInfo)
    self:InitBtnState(self.model, self.data, buffInfo)
end

function GuildBuffStoreItemView:onDestroy()
    EventSystem.RemoveEvent("GuildBuffStoreItem_RefreshBuy", self, self.ResetBuyState)
end

return GuildBuffStoreItemView