local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local DialogManager = require("ui.control.manager.DialogManager")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CommonConstants = require("ui.common.CommonConstants")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GuildBuffStoreType = require("ui/models/guild/guildMistWar/GuildBuffStoreType")

local GuildMistWarBuffStoreView = class(unity.base)

function GuildMistWarBuffStoreView:ctor()
--------Start_Auto_Generate--------
    self.buffShopGo = self.___ex.buffShopGo
    self.buffRoundTitleTxt = self.___ex.buffRoundTitleTxt
    self.arrowLeftBtn = self.___ex.arrowLeftBtn
    self.arrowRightBtn = self.___ex.arrowRightBtn
    self.attackTrans = self.___ex.attackTrans
    self.defendTrans = self.___ex.defendTrans
    self.itemShopGo = self.___ex.itemShopGo
    self.itemTrans = self.___ex.itemTrans
    self.donateNumTxt = self.___ex.donateNumTxt
--------End_Auto_Generate----------

    self.menuButtonGroup = self.___ex.menuButtonGroup
    self.itemShopScroll = self.___ex.itemShopScroll
    self.buffSptList = {}
    self.itemSptList = {}
end

function GuildMistWarBuffStoreView:start()
    DialogAnimation.Appear(self.transform, nil)
    self:RegOnBtn()
end

function GuildMistWarBuffStoreView:InitView(guildMistWarBuffStoreModel, tag)
    self.model = guildMistWarBuffStoreModel
    self.currentRound = self.model:GetSelectRound()
    self.menuButtonGroup:selectMenuItem(tag or GuildBuffStoreType.BuffTag)
    self:OnTagClick(tag or GuildBuffStoreType.BuffTag)
end

function GuildMistWarBuffStoreView:RegOnBtn()
    self.arrowLeftBtn:regOnButtonClick(function()
        self:NextRound()
    end)
    self.arrowRightBtn:regOnButtonClick(function()
        self:PreviewRound()
    end)
    for tag, v in pairs(self.menuButtonGroup.menu) do
        self.menuButtonGroup:BindMenuItem(tag, function()
            self:OnTagClick(tag)
        end)
    end
end

function GuildMistWarBuffStoreView:OnTagClick(tag)
    if tag == GuildBuffStoreType.BuffTag then
        self:InitBuff()
    else
        self:InitItem()
    end
    local cumulativeDay = self.model:GetCumulativeTotal()
    self.donateNumTxt.text = "x" .. cumulativeDay
end

function GuildMistWarBuffStoreView:InitBuff()
    local attackBuffData = self.model:GetAttackBuffData()
    local defendBuffData = self.model:GetDefendBuffData()
    self:InitBuffScroll(attackBuffData, self.attackTrans)
    self:InitBuffScroll(defendBuffData, self.defendTrans)
    self:RefreshBuffArrow()
    local period = self.model:GetPeriod()
    local roundStr = lang.transstr("round_num", self.currentRound)
    self.buffRoundTitleTxt.text = "[" .. tostring(period) .. "] " .. roundStr
    GameObjectHelper.FastSetActive(self.buffShopGo, true)
    GameObjectHelper.FastSetActive(self.itemShopGo, false)
end

function GuildMistWarBuffStoreView:InitBuffScroll(buffData, parentTrans)
    res.ClearChildren(parentTrans)
    local buffRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildMistWar/GuildMistBuffStoreItem.prefab")
    for i, v in ipairs(buffData.static) do
        local keyId = v.id
        local serverData = buffData.serverData or {}
        local tObj = Object.Instantiate(buffRes)
        tObj.transform:SetParent(parentTrans, false)
        local buffSpt = tObj:GetComponent("CapsUnityLuaBehav")
        buffSpt:InitView(v, serverData[keyId], self.model)
        buffSpt.onBuyBuffBtnClick = function() self:OnBuyBuffBtn(keyId) end
        self.buffSptList[keyId] = buffSpt
    end
end

function GuildMistWarBuffStoreView:OnBuyBuffBtn(keyId)
    if self.buyBuffClick then
        self.buyBuffClick(keyId)
    end
end

function GuildMistWarBuffStoreView:InitItem()
    local itemListStatic = self.model:GetItemStoreStaticList()
    local itemListServer = self.model:GetItemStoreServerList()
    res.ClearChildren(self.itemTrans)
    local itemRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildMistWar/GuildMistItemStoreItem.prefab")
    for i, v in ipairs(itemListStatic) do
        local keyId = v.id
        local tObj = Object.Instantiate(itemRes)
        tObj.transform:SetParent(self.itemTrans, false)
        local itemSpt = tObj:GetComponent("CapsUnityLuaBehav")
        itemSpt:InitView(v, itemListServer[keyId], self.model)
        itemSpt.onBuyItemBtnClick = function() self:OnBuyItemBtn(keyId) end
        self.itemSptList[keyId] = itemSpt
    end
    GameObjectHelper.FastSetActive(self.buffShopGo, false)
    GameObjectHelper.FastSetActive(self.itemShopGo, true)
end

function GuildMistWarBuffStoreView:OnBuyItemBtn(keyId)
    if self.buyItemClick then
        self.buyItemClick(keyId)
    end
end

function GuildMistWarBuffStoreView:NextRound()
    local maxRound = self.model:GetMaxRound()
    local arrowLefState = self.currentRound < maxRound
    if arrowLefState then
        self.currentRound = self.currentRound + 1
        self.model:SetSelectRound(self.currentRound)
        self:InitBuff()
    end
    self:RefreshBuffArrow()
end

function GuildMistWarBuffStoreView:PreviewRound()
    local arrowRightState = self.currentRound > 1
    if arrowRightState then
        self.currentRound = self.currentRound - 1
        self.model:SetSelectRound(self.currentRound)
        self:InitBuff()
    end
    self:RefreshBuffArrow()
end

function GuildMistWarBuffStoreView:RefreshBuffArrow()
    local maxRound = self.model:GetMaxRound()
    local arrowLefState = self.currentRound < maxRound
    local arrowRightState = self.currentRound > 1
    GameObjectHelper.FastSetActive(self.arrowLeftBtn.gameObject, arrowLefState)
    GameObjectHelper.FastSetActive(self.arrowRightBtn.gameObject, arrowRightState)
end

function GuildMistWarBuffStoreView:InitScrollView(model, isAttackPage, nextRound, buffInfo)
    local scrolItemData = model:GetBuffDatas()
    model:SetBuffInfo(buffInfo)
    local buffInfoOrder = model:ResetBuffInfoOrder()
    self.buffScrollRect:regOnCreateItem(function (scrollSelf, index)
        local prefab = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildBuffStoreItem.prefab"
        local obj, spt = res.Instantiate(prefab)
        scrollSelf:resetItem(spt, index)
        return obj
    end)

    self.buffScrollRect:regOnResetItem(function (scrollSelf, spt, index)
        local data = scrollSelf.itemDatas[index]
        spt:Init(data, model, nextRound, buffInfoOrder)
        spt.onBuyBuffBtnClick = function ()
            if isAttackPage and data.type == "def" then
                DialogManager.ShowToast(lang.trans("guild_buff_store"))
                return
            end

            if not isAttackPage and data.type == "atk" then
                DialogManager.ShowToast(lang.trans("guild_buff_store_1"))
                return
            end

            self:coroutine(function ()
                local response = req.guildWarBuyBuffMist(tonumber(nextRound or model:GetRound()), data.key)
                if api.success(response) then
                    local infoData = response.val
                    GameObjectHelper.FastSetActive(spt.bought, true)
                    spt.animator:Play("GuildBuffStoreItemBoughtAnimation")
                    -- 更新model里的数据
                    model:SetBuff(isAttackPage, infoData.defBuff or infoData.atkBuff)
                    model:SetCumulativeTotal(infoData.cumulativeDay)
                    self.contributeTxt.text = lang.trans("guild_contribute", model:GetCumulativeTotal())
                    local buyBuffInfoOrder = model:ResetBuffInfoOrder(infoData)
                    EventSystem.SendEvent("GuildBuffStoreItem_RefreshBuy", buyBuffInfoOrder)
                end
            end)
        end
        scrollSelf:updateItemIndex(spt, index)
    end)

    self.buffScrollRect:refresh(scrolItemData)
end

return GuildMistWarBuffStoreView
