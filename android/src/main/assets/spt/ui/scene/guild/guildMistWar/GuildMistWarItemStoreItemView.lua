local GameObjectHelper = require("ui.common.GameObjectHelper")
local GuildMistWarItemStoreItemView = class(unity.base)

function GuildMistWarItemStoreItemView:ctor()
--------Start_Auto_Generate--------
    self.nameTxt = self.___ex.nameTxt
    self.itemImg = self.___ex.itemImg
    self.buyBtn = self.___ex.buyBtn
    self.priceTxt = self.___ex.priceTxt
    self.buyDisableGo = self.___ex.buyDisableGo
    self.disableTxt = self.___ex.disableTxt
    self.boughtGo = self.___ex.boughtGo
    self.detailBtn = self.___ex.detailBtn
--------End_Auto_Generate----------
    self.imgPath = "Assets/CapstonesRes/Game/UI/Scene/Guild/Image/GuildMistWar/%s.png"
end

function GuildMistWarItemStoreItemView:start()
    EventSystem.AddEvent("GuildBuffStoreItem_RefreshBuy", self, self.ResetBuyState)
    self:RegOnButtonClick()
end

function GuildMistWarItemStoreItemView:RegOnButtonClick()
    self.buyBtn:regOnButtonClick(function ()
        if type(self.onBuyItemBtnClick) == "function" then
            self.onBuyItemBtnClick()
        end
    end)
    self.detailBtn:regOnButtonClick(function ()
        self:OnDetailBtnClick()
    end)
end

function GuildMistWarItemStoreItemView:InitView(staticData, serverData, guildMistWarBuffStoreModel)
    self.staticData = staticData
    self.serverData = serverData
    self.model = guildMistWarBuffStoreModel
    local mapid = tostring(staticData.mapId)
    local minLevel = self.model:GetMinLevel()
    local remainCount = self.model:GetItemStoreMapRemainCount(mapid)
    local remainStr = lang.transstr("guild_mist_map_remain", remainCount)
    local price = staticData.price[minLevel]
    self.itemImg.overrideSprite = res.LoadRes(format(self.imgPath, staticData.picIndex))
    self.priceTxt.text = lang.trans("guild_buff_store_consume", price)
    self.nameTxt.text = staticData.name .. " (" .. remainStr .. ")"
    self:InitBtnState(staticData)
end

function GuildMistWarItemStoreItemView:InitBtnState(staticData)
    local selfAuthority = self.model:GetSelfAuthority()
    local selectRound = self.model:GetSelectRound()
    if selfAuthority >= 3 then
        GameObjectHelper.FastSetActive(self.buyBtn.gameObject, false)
        GameObjectHelper.FastSetActive(self.buyDisableGo, true)
    end

end

function GuildMistWarItemStoreItemView:OnDetailBtnClick()
    local prefabPath = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildMistWar/MistMapStoreDetail.prefab"
    local dialog, dialogcomp = res.ShowDialog(prefabPath, "camera", true, true)
    local script = dialogcomp.contentcomp
    script:InitView(self.staticData)
end

function GuildMistWarItemStoreItemView:ResetBuyState(buffInfo)
    self:InitBtnState(self.model, self.data, buffInfo)
end

function GuildMistWarItemStoreItemView:onDestroy()
    EventSystem.RemoveEvent("GuildBuffStoreItem_RefreshBuy", self, self.ResetBuyState)
end

return GuildMistWarItemStoreItemView
