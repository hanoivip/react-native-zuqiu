local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local Object = UnityEngine.Object
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CardConfig = require("ui.common.card.CardConfig")
local PasterMainType = require("ui.scene.paster.PasterMainType")
local AssetFinder = require("ui.common.AssetFinder")
local CardColorConfig = require("ui.common.card.CardColorConfig")
local PlayersCardItem = class(unity.base)

local MaxStar = 3
local StarPos = 
{
    [1] = 
    {
       [1] ={ x = 0, y = 0}
    },
    [2] = 
    {
       [1] ={ x = 0, y = 0},
       [2] ={ x = 0, y = -20},
    },
    [3] = 
    {
       [1] ={ x = 0, y = 0},
       [2] ={ x = 20, y = 0},
       [3] ={ x = 10, y = -20},
    },
}

local function GetStarPos(index, upgrade)
    return StarPos[upgrade][index]
end

function PlayersCardItem:ctor()
    self.backside = self.___ex.backside
    self.quality = self.___ex.quality
    self.playerIcon = self.___ex.playerIcon
    self.ribbon = self.___ex.ribbon
    self.playerName = self.___ex.playerName
    self.playerNameShadow = self.___ex.playerNameShadow
    self.playerLevel = self.___ex.playerLevel
    self.levelColorComponent = self.___ex.levelColorComponent
    self.starArea = self.___ex.starArea
    self.starMap = self.___ex.starMap
    self.upgradeLevel = self.___ex.upgradeLevel
    self.ascendArea = self.___ex.ascendArea
    self.ascendIcon = self.___ex.ascendIcon
    self.backImg = self.___ex.backImg
    self.nation = self.___ex.nation
    self.nameGradient = self.___ex.nameGradient
    self.pos = self.___ex.pos
    self.posGradient = self.___ex.posGradient
    self.cname = self.___ex.cname
    self.decorate = self.___ex.decorate
    self.isShowName = true
    self.cardEffect = nil -- 卡牌特效（传奇卡）
end

function PlayersCardItem:start()
end

-- 卡牌资源缓存记录
function PlayersCardItem:SetCardResourceCache(resourceCache)
    self.resourceCache = resourceCache
end

-- 有些界面不需要显示名字
function PlayersCardItem:IsShowName(isShow)
    self.isShowName = isShow
    self:ShowCardChinaName()
end

function PlayersCardItem:ShowCardChinaName()
    local name = self.isShowName and tostring(self.cardModel:GetName()) or ""
    self.cname.text = name
end

function PlayersCardItem:InitView(cardModel)
    self.cardModel = cardModel
    local quality = cardModel:GetCardQuality()
    -- 品质
    local fixQuality = cardModel:GetCardFixQuality()
    self:SetQualityCard(fixQuality)
    -- 头像
    self:SetCardAvatar(cardModel:GetAvatar())

    self.playerName.text = tostring(cardModel:GetNameByEnglish())
    self.playerLevel.text = tostring(cardModel:GetLevel())
    self:ShowCardChinaName()

    local posTable = cardModel:GetPosByChina()
    local posstr = ""
    for i, pos in ipairs(posTable) do
        local symbol = ""
        if i < #posTable then 
            symbol = "\n"
        end
        posstr = posstr .. pos .. symbol
    end
    self.pos.text = posstr
    
    -- 颜色
    local nameGradientColor = CardColorConfig.GetNameColor(fixQuality)
    self.nameGradient:ResetPointColors(table.nums(nameGradientColor))
    for i, v in ipairs(nameGradientColor) do
        self.nameGradient:AddPointColors(v.percent, v.color)
    end

    local levelGradientColor = CardColorConfig.GetLevelGradientColor(fixQuality)
    self.levelColorComponent:ResetPointColors(table.nums(levelGradientColor))
    for i, v in ipairs(levelGradientColor) do
        self.levelColorComponent:AddPointColors(v.percent, v.color)
    end

    local posGradientColor = CardColorConfig.GetPosColor(fixQuality)
    self.posGradient:ResetPointColors(table.nums(posGradientColor))
    for i, v in ipairs(posGradientColor) do
        self.posGradient:AddPointColors(v.percent, v.color)
    end
    
    self:ShowUpgrade(cardModel)
    self:ShowAscend(cardModel)
    self:SetNation(cardModel)

    -- 贴纸
    local hasPaster = cardModel:HasPaster()
    GameObjectHelper.FastSetActive(self.decorate.gameObject, hasPaster)
    if hasPaster then 
        local mainType = cardModel:GetPasterMainType()
        self:PasterShowOnType(fixQuality, mainType)
    end

    self:ShowEffect(cardModel)
end

function PlayersCardItem:ShowEffect(cardModel)
    local isShowEffect = cardModel:IsShowEffect()
    if self.cardEffect then 
        GameObjectHelper.FastSetActive(self.cardEffect, false)
    end
    if isShowEffect then 
        if self.cardEffect then 
            GameObjectHelper.FastSetActive(self.cardEffect, true)
        else
            local prefab = "Assets/CapstonesRes/Game/UI/Common/Card/Prefab/Effect/Effect.prefab"
            local obj, spt = res.Instantiate(prefab)
            obj.transform:SetParent(self.transform, false)
            self.cardEffect = obj
        end
    end
end

function PlayersCardItem:InitViewOnlyBack(cardModel)
    self:SetBackImg("CardBack_Quality" .. cardModel:GetCardQuality())
end

function PlayersCardItem:ShowUpgrade(cardModel)
    local upgrade = cardModel:GetUpgrade()
    local isOpenUpgrade = tobool(upgrade > 0)
    if isOpenUpgrade then 
        local matchUpgrade = upgrade 
        if upgrade > MaxStar then 
            matchUpgrade = 1
            self.upgradeLevel.text = tostring(upgrade)
            GameObjectHelper.FastSetActive(self.upgradeLevel.gameObject, true)
        else
            GameObjectHelper.FastSetActive(self.upgradeLevel.gameObject, false)
        end
        for k, v in pairs(self.starMap) do
            local index = tonumber(string.sub(k, 2))
            if index <= matchUpgrade then 
                local pos = GetStarPos(index, matchUpgrade)
                v.anchoredPosition = Vector2(pos.x, pos.y)
                GameObjectHelper.FastSetActive(v.gameObject, true)
            else
                GameObjectHelper.FastSetActive(v.gameObject, false)
            end
        end
    end
    GameObjectHelper.FastSetActive(self.starArea, isOpenUpgrade)
end

function PlayersCardItem:ShowAscend(cardModel)
    local ascend = cardModel:GetAscend()
    local isOpenAscend = tobool(ascend > 0)
    if isOpenAscend then 
        if self.resourceCache then 
            self.ascendIcon.overrideSprite = self.resourceCache:GetAscendRes(ascend)
        else
            local ascendRes = AssetFinder.GetCardAscendSign(ascend)
            self.ascendIcon.overrideSprite = ascendRes
        end
    end
    GameObjectHelper.FastSetActive(self.ascendArea, isOpenAscend)
end

-- 设置卡牌品质框
function PlayersCardItem:SetQualityCard(quality)
    if self.resourceCache then 
        self.backside.overrideSprite = self.resourceCache:GetQualityRes(quality)
        self.ribbon.overrideSprite = self.resourceCache:GetRibbonRes(quality)
    else
        local backsideRes = AssetFinder.GetCardBox(quality)
        self.backside.overrideSprite = backsideRes
        local ribbonRes = AssetFinder.GetCardRibbon(quality)
        self.ribbon.overrideSprite = ribbonRes
    end
end

function PlayersCardItem:PasterHonorShow(quality)
    if self.resourceCache then 
        self.decorate.overrideSprite = self.resourceCache:GetPasterHonorDecorateRes(quality)
    else
        local decorateRes = AssetFinder.GetPasterHonorDecorate(quality)
        self.decorate.overrideSprite = decorateRes
    end
end

function PlayersCardItem:PasterShowOnType(quality, pasterMainType)
    -- 争霸贴纸不显示效果
    if pasterMainType == PasterMainType.Compete then
        GameObjectHelper.FastSetActive(self.decorate.gameObject, false)
        return
    end

    if self.resourceCache then 
        self.decorate.overrideSprite = self.resourceCache:GetPasterDecorateOnTypeRes(quality, pasterMainType)
    else
        local decorateRes = AssetFinder.GetPasterDecorateOnType(quality, pasterMainType)
        self.decorate.overrideSprite = decorateRes
    end
end

-- 设置球员头像
function PlayersCardItem:SetCardAvatar(avatar)
    if self.resourceCache then 
        self.playerIcon.overrideSprite = self.resourceCache:GetAvatarRes(avatar)
    else
        local avatarRes = AssetFinder.GetPlayerIcon(avatar)
        self.playerIcon.overrideSprite = avatarRes
    end
end

-- 设置国籍
function PlayersCardItem:SetNation(cardModel)
    if cardModel:GetValid() == 1 then
        if self.resourceCache then 
            self.nation.overrideSprite = self.resourceCache:GetNationRes(cardModel:GetNation())
        else
            local nationRes = AssetFinder.GetNationIcon(cardModel:GetNation())
            self.nation.overrideSprite = nationRes
        end
    else
        GameObjectHelper.FastSetActive(self.nation.gameObject, false)
    end
end

function PlayersCardItem:SetBackImg(backName)
    local imgPath = "Assets/CapstonesRes/Game/UI/Common/Images/CardQuality/"
    if self.backImg then
        self.backImg.overrideSprite = res.LoadRes(imgPath .. backName .. ".png")
    end
end

return PlayersCardItem
