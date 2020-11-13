local AssetFinder = require("ui.common.AssetFinder")
local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local FancyCardResourceCache = class()

function FancyCardResourceCache:ctor()
    self.fancyGroupBg = {} --组图
    self.fancyGroupIcon = {} --卡片中间组图
    self.fancyBg = {} --卡片背景
    self.bgSide = {} --卡片边框
    self.bgMask = {} --卡片遮罩
    self.sideMask = {} --边框遮罩
    self.head = {}
    self.qualityIcon = {}
    self.starIcon = {}
end

function FancyCardResourceCache:Clear()
    self:ctor()
end

function FancyCardResourceCache:GetFancyGroupBg(icon)
    if not self.fancyGroupBg[icon] then
        self.fancyGroupBg[icon] =  AssetFinder.GetFancyCardIcon("GroupBg/" .. icon)
    end
    return self.fancyGroupBg[icon]
end

function FancyCardResourceCache:GetFancyGroupIcon(icon)
    if not self.fancyGroupIcon[icon] then
        self.fancyGroupIcon[icon] = AssetFinder.GetFancyCardIcon(icon)
    end
    return self.fancyGroupIcon[icon]
end

function FancyCardResourceCache:GetBg(icon)
    if not self.fancyBg[icon] then
        self.fancyBg[icon] = AssetFinder.GetFancyCardIcon(icon)
    end
    return self.fancyBg[icon]
end

function FancyCardResourceCache:GetBgSide(icon)
    if not self.bgSide[icon] then
        self.bgSide[icon] = AssetFinder.GetFancyCardIcon(icon)
    end
    return self.bgSide[icon]
end

function FancyCardResourceCache:GetMask(icon)
    if not self.bgMask[icon] then
        self.bgMask[icon] = AssetFinder.GetFancyCardIcon(icon)
    end
    return self.bgMask[icon]
end

function FancyCardResourceCache:GetSideMask(icon)
    if not self.sideMask[icon] then
        self.sideMask[icon] = AssetFinder.GetFancyCardIcon(icon)
    end
    return self.sideMask[icon]
end

function FancyCardResourceCache:GetHead(icon)
    if icon == nil or icon == "" then
        icon = 'null'
    end
    if not self.head[icon] then
        if icon == 'null' then
            self.head[icon] = AssetFinder.GetFancyCardIcon("Common/head")
        else
            self.head[icon] = AssetFinder.GetPlayerIcon(icon)
        end
    end
    return self.head[icon]
end

function FancyCardResourceCache:getQualityIcon(quality)
    if not self.qualityIcon[quality] then
        self.qualityIcon[quality] = AssetFinder.GetFancyCardIcon("Common/" .. quality)
    end
    return self.qualityIcon[quality]
end

function FancyCardResourceCache:GetStarIcon(star)
    if not self.starIcon[star] then
        self.starIcon[star] = AssetFinder.GetFancyCardIcon(star > 3 and "Common/StarHigh" or "Common/starLow")
    end
    return self.starIcon[star]
end

local trueColor = Color(1,1,1)
local falseColor = Color(0.5, 0.5, 0.5)

function FancyCardResourceCache:GetColor(bTrue)
    return bTrue and trueColor or falseColor
end

return FancyCardResourceCache
