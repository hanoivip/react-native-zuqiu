local UnityEngine = clr.UnityEngine
local UI = UnityEngine.UI
local Text = UI.Text
local Vector3 = UnityEngine.Vector3
local Vector2 = UnityEngine.Vector2
local Color = UnityEngine.Color
local Object = UnityEngine.Object
local EquipItemModel = require("ui.models.cardDetail.EquipItemModel")
local ItemOriginType = require("ui.controllers.itemList.ItemOriginType")
local ItemModel = require("ui.models.cardDetail.ItemModel")

local GuildChallengeEnterView = class(unity.base)

function GuildChallengeEnterView:ctor()
    self.infoBarDynParent = self.___ex.infoBarDynParent
    self.menuButtonGroup = self.___ex.menuButtonGroup
    self.themeImage = self.___ex.themeImage
    self.rewardScrollerContent = self.___ex.rewardScrollerContent
    self.btnSweep = self.___ex.btnSweep
    self.btnSweepText = self.___ex.btnSweepText
    self.btnSweepObj = self.___ex.btnSweepObj
    self.btnStart = self.___ex.btnStart
    self.btnStartTrans = self.___ex.btnStartTrans
    self.glowEffect1 = self.___ex.glowEffect1
    self.glowEffect2 = self.___ex.glowEffect2
    self.glowEffect3 = self.___ex.glowEffect3
    self.glowEffect4 = self.___ex.glowEffect4
    self.glowEffect5 = self.___ex.glowEffect5
    self.effectGroup = {self.glowEffect1, self.glowEffect2, self.glowEffect3, self.glowEffect4, self.glowEffect5}
    self.star1 = self.___ex.star1
    self.star2 = self.___ex.star2
    self.star3 = self.___ex.star3
    self.starGroup = {self.star1, self.star2, self.star3}
    self.vipObj = self.___ex.vipObj
    self.vipText = self.___ex.vipText
    self.leftCount = self.___ex.leftCount
    self.nameTxt = self.___ex.name
    self.power = self.___ex.power
    self.title = self.___ex.title
end

local function IsNeedShowUseSymbol(playerData, equipID)
    local CardBuilder = require("ui.common.card.CardBuilder")
    for k, pcid in pairs(playerData) do
        local playerModel = CardBuilder.GetStarterModel(pcid)
        playerModel:InitEquipsAndSkills()
        if playerModel:HasNeedEquip(equipID) then
            return true
        end
    end
end

function GuildChallengeEnterView:start()
    local menu = self.menuButtonGroup.menu
    for k, v in pairs(menu) do
        local i = tonumber(string.sub(k, 5, 5))
        v:regOnButtonClick(function()
            self:OnMenuTypeClick(i)
        end)
    end
    self.btnStart:regOnButtonClick(function()
        if type(self.onBtnStartClick) == "function" then
            self.onBtnStartClick()
        end
    end)
    self.btnSweep:regOnButtonClick(function()
        if type(self.onBtnSweepClick) == "function" then
            self.onBtnSweepClick()
        end
    end)
end

function GuildChallengeEnterView:OnMenuTypeClick(index)
    if type(self.onMenuItemClick) == "function" then
        self.onMenuItemClick(index)
    end
end

function GuildChallengeEnterView:SwitchMenu(index)
    self.menuButtonGroup:selectMenuItem("diff" .. index)
end

function GuildChallengeEnterView:InitView(model)
    local index = model:GetCurrentDiff()
    self.nameTxt.text = lang.transstr("guildChallenge_name" .. model:GetCurrentLevelIndex())
    self.themeImage.sprite = model:GetImgSprite()
    self.title.text = model:GetTitle()
    self:SetGlowEffect(model:GetCurrentLevelIndex())
    self:SetSelectButtons(7)
    self:SwitchMenu(index)
    self:SetDiffStarView(model:GetSingleDiffStar(index))
    self:SetVipAddition(model:GetVipAddition())
    self:SetSweepButtonState(model, index)
    self:SetLeftCount(model)
    self:SetDoubleLevel(model)
    self:SetPower(model, index)
end

function GuildChallengeEnterView:SetLeftCount(model)
    local count = model:GetLeftCount()
    self.leftCount.text = lang.transstr("challenge_leftCount", count)
end

function GuildChallengeEnterView:SetSweepButtonState(model, index)
    local star = model:GetSingleDiffStar(index)
    local sweep = model:GetSweepInfo()
    if sweep == true then
        self.btnSweep.gameObject:SetActive(true)
        self.btnStartTrans.anchoredPosition = Vector2(375, -260)
        if star < 3 then
            self.btnSweepObj.interactable = false
            self.btnSweepText.enabled = false
        else
            self.btnSweepObj.interactable = true
            self.btnSweepText.enabled = true
        end
    else
        self.btnSweep.gameObject:SetActive(false)
        self.btnStartTrans.anchoredPosition = Vector2(375, -220)
    end
end

function GuildChallengeEnterView:SetVipAddition(vipAddition)
    if vipAddition <= 0 then 
        self.vipObj:SetActive(false)
    else
        self.vipObj:SetActive(true)
        self.vipText.text = "+" .. vipAddition .. "%"
    end 
end

function GuildChallengeEnterView:SetPower(model, index)
    self.power.text = lang.transstr("guildChall_power", model:GetPower(index))
end

function GuildChallengeEnterView:SetDiffStarView(starNum)
    for i = 1, #self.starGroup do
        if i <= starNum then
            self.starGroup[i]:SetActive(true)
        else
            self.starGroup[i]:SetActive(false)
        end
    end
end

function GuildChallengeEnterView:SetGlowEffect(index)
    for i = 1, #self.effectGroup do
        if i == index then
            self.effectGroup[i]:SetActive(true)
        else
            self.effectGroup[i]:SetActive(false)
        end
    end
end

function GuildChallengeEnterView:SetDoubleLevel(model)
    local level = 0
    local war = model:GetWar()
    local isDouble = model:GetIsDouble()
    if isDouble == false then return end

    if war ~= nil then
        level = tonumber(war.level)
    end

    local menu = self.menuButtonGroup.menu
    for k, v in pairs(menu) do
        local i = tonumber(string.sub(k, 5, 5))
        if i <= tonumber(level) then
             v.___ex.double:SetActive(true)
        else
            v.___ex.double:SetActive(false)
        end
    end

end

function GuildChallengeEnterView:SetSelectButtons(maxDiff)
    local menu = self.menuButtonGroup.menu
    for k, v in pairs(menu) do
        local i = tonumber(string.sub(k, 5, 5))
        if i <= tonumber(maxDiff) then
            v.___ex.up1Text:SetActive(false)
            v.___ex.up2Text:SetActive(true)
            v.___ex.down1Text:SetActive(false)
            v.___ex.down2Text:SetActive(true)
        else
            v.___ex.up1Text:SetActive(true)
            v.___ex.up2Text:SetActive(false)
            v.___ex.down1Text:SetActive(true)
            v.___ex.down2Text:SetActive(false)
        end
    end
end

function GuildChallengeEnterView:RegOnDynamicLoad(func)
    self.infoBarDynParent:RegOnDynamicLoad(func)
end

function GuildChallengeEnterView:InitRewardView(diamond, money, itemList, eqsList)
    res.ClearChildren(self.rewardScrollerContent)
    self.rewardSptMap = {}

    if diamond > 0 then
        local diamondItemModel = ItemModel.new()
        diamondItemModel:InitWithDiamondAddNum(diamond)
        self:InstantiateItemBox(diamondItemModel)
    end

    if money > 0 then
        local moneyItemModel = ItemModel.new()
        moneyItemModel:InitWithMoneyAddNum(money)
        self:InstantiateItemBox(moneyItemModel)
    end

    for key, value in pairs(itemList) do
        local itemModel = ItemModel.new()
        local newItemData = {id = key, add = tonumber(value)}
        itemModel:InitWithCache(newItemData)
        self:InstantiateItemBox(itemModel)
    end

    local equipBoxPrefab = res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Part/EquipBox.prefab")
    for i = 1, #eqsList do
        self:BuildEquipBox(eqsList[i], equipBoxPrefab, true)
    end

    self:RefreshRewardContent()
end

function GuildChallengeEnterView:BuildEquipBox(equipId, equipBoxPrefab, isShowPiece)
    local equipItemModel = EquipItemModel.new()
    equipItemModel:InitWithStaticId(equipId)
    local obj = Object.Instantiate(equipBoxPrefab)
    obj.transform:SetParent(self.rewardScrollerContent, false)
    local objScript = obj:GetComponent(clr.CapsUnityLuaBehav)
    objScript:InitView(equipItemModel, equipId, false, false, isShowPiece, true, ItemOriginType.OTHER)
    self.rewardSptMap[tostring(equipId)] = objScript
end

function GuildChallengeEnterView:InstantiateItemBox(itemModel)
    local itemBoxObj, itemBoxView = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Part/ItemBox.prefab")
    itemBoxObj.transform:SetParent(self.rewardScrollerContent, false)
    itemBoxView:InitView(itemModel, itemModel:GetID(), false, true, true, ItemOriginType.OTHER)
end

function GuildChallengeEnterView:RefreshRewardContent()
    if not self.rewardSptMap then return end

    local PlayerTeamsModel = require("ui.models.PlayerTeamsModel")
    local playerTeamsModel = PlayerTeamsModel.new()
    playerTeamsModel:Init()
    local initPlayerData = playerTeamsModel:GetInitPlayersData(playerTeamsModel:GetNowTeamId())

    for equipID, spt in pairs(self.rewardSptMap) do
        if spt and spt ~= clr.null then
            local isShowUseSymbol = IsNeedShowUseSymbol(initPlayerData, equipID)
            spt:SetEquipUseSymbol(isShowUseSymbol)
        end
    end
end

function GuildChallengeEnterView:onDestroy()
    self.rewardSptMap = nil
end

return GuildChallengeEnterView
