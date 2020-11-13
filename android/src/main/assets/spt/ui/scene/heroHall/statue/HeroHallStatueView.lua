local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector2 = UnityEngine.Vector2
local GameObjectHelper = require("ui.common.GameObjectHelper")
local AssetFinder = require("ui.common.AssetFinder")

local HeroHallStatueView = class(unity.base, "HeroHallStatueView")

function HeroHallStatueView:ctor()
    self.infoBarDynParent = self.___ex.infoBarDynParent
    self.btnLeft = self.___ex.btnLeft
    self.btnRight = self.___ex.btnRight
    self.showArea = self.___ex.showArea
    self.showAreaCanvasGroup = self.___ex.showAreaCanvasGroup
    self.txtCorner = self.___ex.txtCorner
    self.txtCardName = self.___ex.txtCardName
    self.txtTitle = self.___ex.txtTitle
    self.txtDesc = self.___ex.txtDesc
    self.attribute = self.___ex.attribute
    self.attributeExtra = self.___ex.attributeExtra
    self.btnUpgrade = self.___ex.btnUpgrade
    self.buttonUpgrade = self.___ex.buttonUpgrade
    self.txtUpgrade = self.___ex.txtUpgrade
    self.cardArea = self.___ex.cardArea
    self.imgIcon = self.___ex.imgIcon
    self.btnIntro = self.___ex.btnIntro
    -- upgrade efx
    self.efxUpgradeCtrl = self.___ex.efxUpgradeCtrl
    self.efxClickMask = self.___ex.efxClickMask
    self.efxAnimator = self.___ex.efxAnimator
    self.efxIcon = self.___ex.efxIcon
    self.efxIconRct = self.___ex.efxIconRct
    self.animView = self.___ex.animView
    -- 背景特效
    self.bgAnimator = self.___ex.bgAnimator


    self.onClickBtnLeft = nil
    self.onClickBtnRight = nil
    self.onClickBtnUpgrade = nil
    self.onClickBtnIntro = nil
    self.onClickEfxMask = nil
end

function HeroHallStatueView:start()
    self:RegBtnEvent()
end

function HeroHallStatueView:InitView(heroHallStatueModel)
    self.model = heroHallStatueModel
    self.animView:InitView(self)
    self:UpdateStatueView()
end

function HeroHallStatueView:UpdateStatueView()
    local currStatueData = self.model:GetCurrStatue()
    -- 左上角序号
    self.txtCorner.text = self.model:GetIndexString()
    -- 殿堂名称
    self.txtTitle.text = self.model:GetTitle()
    -- 球员名字
    if currStatueData.cardValid then
        if currStatueData.activate == 1 then
            self.txtCardName.text = currStatueData.statueQualityDesc .. lang.transstr("hero_hall_statue") .. " · " .. currStatueData.cardName
        else
            self.txtCardName.text = currStatueData.cardName
        end
    else
        self.txtCardName.text = lang.trans("hero_hall_statue_secret")
    end
    -- 殿堂效果描述
    if currStatueData.cardValid then
        self.txtDesc.text = tostring(self.model:GetDesc())
    else
        self.txtDesc.text = lang.trans("commingSoon")
    end
    -- 雕像等级icon
    local iconRes = AssetFinder.GetHeroHallIcon(currStatueData.hallPicRes)
    self.imgIcon.overrideSprite = iconRes
    self.efxIcon.overrideSprite = iconRes

    self:InitCardArea(currStatueData)

    -- 基础属性显示
    for k, v in pairs(self.attribute) do
        GameObjectHelper.FastSetActive(v.gameObject, false)
    end
    if currStatueData.cardValid then
        local attributes, fixAttribute, basicAttribute, multiAttribute = self.model:GetCurrStatueAttributes()

        local hasMuliti = true
        if multiAttribute <= 0 then
            hasMuliti = false
        end

        local strAttribute = tostring(basicAttribute)
        local strMultiAttribute = "+" .. string.format("%.2f", multiAttribute * 100) .. "%"
        if table.nums(attributes) == 10 then     -- 全属性
            GameObjectHelper.FastSetActive(self.attribute["1"].gameObject, true)
            if hasMuliti then strAttribute = strAttribute .. " <color=#86BE0E>" .. strMultiAttribute .. "</color>" end
            self.attribute["1"].text = lang.transstr("hero_hall_main_all_attribute") .. ": " .. strAttribute
            if currStatueData.hlvl > 0 then
                GameObjectHelper.FastSetActive(self.attribute["2"].gameObject, true)
                self.attribute["2"].text = lang.trans("hero_hall_skill_all_add_para", currStatueData.hlvlCondition, currStatueData.hlvl)
            end
        else
            local index = 1
            for attributeName, attributeValue in pairs(attributes) do
                GameObjectHelper.FastSetActive(self.attribute[tostring(index)].gameObject, true)
                strAttribute = tostring(basicAttribute)
                if hasMuliti then strAttribute = strAttribute .. " <color=#86BE0E>" .. strMultiAttribute .. "</color>" end
                self.attribute[tostring(index)].text = lang.transstr(attributeName) .. ": " .. strAttribute
                index = index + 1
            end
            if currStatueData.hlvl > 0 then
                GameObjectHelper.FastSetActive(self.attribute[tostring(index)].gameObject, true)
                self.attribute[tostring(index)].text = lang.trans("hero_hall_skill_all_add_para", currStatueData.hlvlCondition, currStatueData.hlvl)
            end
        end
    end

    -- 额外属性显示
    for k, v in pairs(self.attributeExtra) do
        GameObjectHelper.FastSetActive(v.gameObject, false)
    end
    if currStatueData.cardValid then
        if currStatueData.activate ~= 1 then        -- 未激活雕像显示
            GameObjectHelper.FastSetActive(self.attributeExtra["1"].gameObject, true)
            GameObjectHelper.FastSetActive(self.attributeExtra["2"].gameObject, true)
            self.attributeExtra["1"].text = lang.trans("playerMail_noHave")
            self.attributeExtra["2"].text = lang.trans("hero_hall_statue_unlock_condition")
        else
            local improveDesc = self.model:GetCurrStatueImproveDesc()
            local index = 1
            for improveName, v in pairs(improveDesc) do
                GameObjectHelper.FastSetActive(self.attributeExtra[tostring(index)].gameObject, true)
                self.attributeExtra[tostring(index)].text = v.desc
                index = index + 1
            end
        end
    else
        GameObjectHelper.FastSetActive(self.attributeExtra["1"].gameObject, true)
        self.attributeExtra["1"].text = lang.trans("nonactivated")
    end

    -- 升级按钮
    self.buttonUpgrade.interactable = currStatueData.activate == 1
    self.txtUpgrade.text = lang.trans("hero_hall_statue_upgrade")
    if self.model:IsCurrStatueMaxLevel() then
        self.txtUpgrade.text = lang.trans("hero_hall_upgrade_max_level")
        self.buttonUpgrade.interactable = false
    end
end

-- 初始化球员卡牌
function HeroHallStatueView:InitCardArea(currStatueData)
    if currStatueData == nil then currStatueData = self.model:GetCurrStatue() end

    res.ClearChildren(self.cardArea.transform)
    local cardObject, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Card/Prefab/Card.prefab")
    cardObject.transform:SetParent(self.cardArea.transform, false)
    spt:InitView(self.model:GetCurrCardModel())
    spt:IsShowName(false)
end

-- 初始化动画
function HeroHallStatueView:InitUpgradeEffect()
    self.efxIcon.overrideSprite = AssetFinder.GetHeroHallIcon(self.model:GetPreLevelStatueIcon())
    self.efxIconRct.anchoredPosition = Vector2(0, 0)
    -- 开始动画
    self.model:SetIsInEfx(true)
    GameObjectHelper.FastSetActive(self.efxUpgradeCtrl, true)
    self.efxAnimator:SetBool("isStart", true)  --Lua assist checked flag
end

-- 动画中换icon
function HeroHallStatueView:ChangeEfxIcon()
    self.efxIcon.overrideSprite = AssetFinder.GetHeroHallIcon(self.model:GetCurrLevelStatueIcon())
end

-- 升级雕像后动画结束
function HeroHallStatueView:FinishUpgradeEffect()
    if self.model:GetIsInEfx() then
        self.model:SetIsInEfx(false)
        GameObjectHelper.FastSetActive(self.efxUpgradeCtrl, false)
        self.efxAnimator:SetBool("isStart", false)  --Lua assist checked flag
        self:UpdateAfterUpgrade(self.model)
    end
end

-- 升级雕像后更新界面，关闭动画
function HeroHallStatueView:UpdateAfterUpgrade(heroHallStatueModel)
    self:InitView(heroHallStatueModel)
end

function HeroHallStatueView:RegBtnEvent()
    self.btnLeft:regOnButtonClick(function()
        if self.onClickBtnLeft then
            self.onClickBtnLeft()
        end
    end)

    self.btnRight:regOnButtonClick(function()
        if self.onClickBtnRight then
            self.onClickBtnRight()
        end
    end)

    self.btnUpgrade:regOnButtonClick(function()
        if self.onClickBtnUpgrade then
            self.onClickBtnUpgrade()
        end
    end)

    self.btnIntro:regOnButtonClick(function()
        if self.onClickBtnIntro then
            self.onClickBtnIntro()
        end
    end)

    self.efxClickMask:regOnButtonClick(function()
        if self.onClickEfxMask then
            self.onClickEfxMask()
        end
    end)
end

function HeroHallStatueView:RegOnDynamicLoad(func)
    self.infoBarDynParent:RegOnDynamicLoad(func)
end

return HeroHallStatueView
