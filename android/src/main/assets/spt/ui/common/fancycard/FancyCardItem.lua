local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local Vector3 = UnityEngine.Vector3
local AssetFinder = require("ui.common.AssetFinder")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local Helper = require("ui.scene.formation.Helper")
local FancyCardItem = class(unity.base)

function FancyCardItem:ctor()
    self.bg = self.___ex.bg
    self.fancy = self.___ex.fancy
    self.starLowText = self.___ex.starLowText
    self.starHighText = self.___ex.starHighText
    self.starHigh = self.___ex.starHigh
    self.starLow = self.___ex.starLow
    self.bgside = self.___ex.bgside
    self.fancyMask = self.___ex.fancyMask
    self.head = self.___ex.head
    self.group = self.___ex.group
    self.fancyName = self.___ex.fancyName
    self.quality = self.___ex.quality
    self.cardName = self.___ex.cardName
    self.fancyName1 = self.___ex.fancyName1
    self.sideMask = self.___ex.sideMask
    self.starIcon = self.___ex.starIcon
    self.btn = self.___ex.btn
    self.starBg = self.___ex.starBg
    self.bottomName = self.___ex.bottomName
    self.bottomNameObj = self.___ex.bottomNameObj
    self.newTip = self.___ex.newTip
    self.addNumText = self.___ex.addNumText
    self.addNum = self.___ex.addNum
    self.starMask = self.___ex.starMask
    self.shadow = self.___ex.shadow
    self.starHighAni = self.___ex.starHighAni
    self.starLowAni = self.___ex.starLowAni
    self.upSide = self.___ex.upSide
end

function FancyCardItem:start()
    self:ResetAddNumSize()
    if self.btn then
        self.btn:regOnButtonClick(function ()
            self:BtnClick()
        end)
    end
end

function FancyCardItem:SetResourceCache(resourceCache)
    self.resourceCache = resourceCache
end

-- param =
-- {
--     isShowName = false,
--     nameColor = Color(1, 1, 1),
--     nameSize = 18,
--     dontShowHaveCard = false,
--     isShowNew = false,
--     showStar = false,
--     count = nil,
--     scale = 1,
--     isShowCount = false
-- }
function FancyCardItem:InitView(fancyCard, param)
    self.fancyCard = fancyCard
    if param then
        local scale = param.scale
        if param.isShowName then
            self.bottomName.text = fancyCard:GetName()
            self.bottomName.color = param.nameColor or Color(1, 1, 1)
            self.bottomName.fontSize = param.nameSize or 18
            GameObjectHelper.FastSetActive(self.bottomNameObj, true)
        end
        if param.isShowCount then
            self.addNumText.text = 'x' .. param.count
            if scale then
                self.addNumText.transform.localScale = Vector3(1/scale, 1/scale, 1)
            end
        end
        GameObjectHelper.FastSetActive(self.addNum, param.isShowCount or false)
        if param.shadow then
            GameObjectHelper.FastSetActive(self.shadow, true)
        end
        self.dontShowHaveCard = param.dontShowHaveCard
        self.isShowNew = param.isShowNew
        if scale then
            self.gameObject.transform.localScale = Vector3(scale, scale, 1)
            self.bottomName.transform.localScale = Vector3(1/scale, 1/scale, 1)
        end
    end
    self.showStar = param and param.showStar or false
    self.isBig = not not self.cardName
    
    self:SetBg()
    self:SetFancyGroupBg()
    self:SetBgSide()
    self:SetMask()
    self:SetHead()
    self:SetGroupIcon()
    self:SetQualityIcon()
    self:RefreshStar()

    local groupNameColor, groupNameShadow = fancyCard:GetFancyNameColor(self.isBig)
    if groupNameShadow and groupNameShadow ~= "" then
        self.fancyName.text = "<color=" .. groupNameShadow .. ">" .. fancyCard:GetFancyName() .. "</color>"
    else
        self.fancyName.text = ""
    end
    self.fancyName1.text = "<color=" .. groupNameColor .. ">" .. fancyCard:GetFancyName() .. "</color>"
    if self.isBig then
        --大卡多一個名字顯示
        self.cardName.text = "<color=" .. fancyCard:GetNameColor() .. ">" .. fancyCard:GetName() .. "</color>"
        self:SetSideMask()
    end
    self:RefreshNewTip()
end

function FancyCardItem:ResetAddNumSize()
    if self.cardName then
        --只有小卡匹配
        return
    end
    self:coroutine(function ()
        unity.waitForEndOfFrame()
        local boxRect = self.transform.rect
        local width = self.cardName and 195 or 200
        local scaleFactor = 1
        if boxRect.width ~= width then
            scaleFactor = boxRect.width / width
        end
        local scale = Vector3(scaleFactor, scaleFactor, 1)
        self.fancyName.transform.localScale = scale
    end)
end

function FancyCardItem:RefreshStar(bUp)
    local star = self.fancyCard:GetStar()
    self.starLowText.text = tostring(star)
    self.starHighText.text = tostring(star)

    local haveCard = star >= 0
    local bCanShowStar = star > 0
    local bHigh = star > 4
    local bShowStar = self.showStar and bCanShowStar
    GameObjectHelper.FastSetActive(self.starHigh, bShowStar and bHigh)
    GameObjectHelper.FastSetActive(self.starLow, bShowStar and not bHigh)
    GameObjectHelper.FastSetActive(self.starBg.gameObject, bShowStar)
    if bUp then
        --只有升星界面刷新大卡才会调用到这里
        if bHigh then
            self.starHighAni.enabled = true
            self.starHighAni.Rebind()
        else
            self.starLowAni.enabled = true
            self.starLowAni.Rebind()
        end
    end
    local isBig = self.cardName and true or false
    if not isBig then
        self:SetStarMask()
        local bTrue = haveCard or self.dontShowHaveCard
        local color
        if self.resourceCache then
            color = self.resourceCache:GetColor(bTrue)
        else
            color = bTrue and Color(1,1,1) or Color(0.5, 0.5, 0.5)
        end
        self.bg.color = color
        self.fancy.color = color
        self.bgside.color = color
        self.head.color = color
        self.quality.color = color
        self.group.color = color
        self.upSide.color = color
    end
end

function FancyCardItem:RefreshNewTip()
    if self.newTip then
        GameObjectHelper.FastSetActive(self.newTip, self.isShowNew and self.fancyCard:IsNew())
    end
end

function FancyCardItem:SetPos(numberPos, formationId, courtSize)
    local posCoords = Helper.GetPos(numberPos, formationId, false, true)
    self.transform.localPosition = Vector3(posCoords.x * courtSize.x, posCoords.y * courtSize.y, 0)
end

function FancyCardItem:BtnClick()
    if self.OnBtnClick then
        self.OnBtnClick()
    end
end

function FancyCardItem:SetBg()
    local bgIcon = self.fancyCard:GetBg(self.isBig)
    if self.resourceCache then
        self.bg.overrideSprite = self.resourceCache:GetBg(bgIcon)
    else
        local bgRes = AssetFinder.GetFancyCardIcon(bgIcon)
        self.bg.overrideSprite = bgRes
    end
end

function FancyCardItem:SetFancyGroupBg()
    local groupBg = self.fancyCard:GetFancyBg()
    if self.resourceCache then
        self.fancy.overrideSprite = self.resourceCache:GetFancyGroupBg(groupBg)
    else
        local groupBgRes = AssetFinder.GetFancyCardIcon("GroupBg/" .. groupBg)
        self.fancy.overrideSprite = groupBgRes
    end
end

function FancyCardItem:SetBgSide()
    local bgSide = self.fancyCard:GetBgSide(self.isBig)
    if self.resourceCache then
        self.bgside.overrideSprite = self.resourceCache:GetBgSide(bgSide)
    else
        local bgSideRes = AssetFinder.GetFancyCardIcon(bgSide)
        self.bgside.overrideSprite = bgSideRes
    end
end

function FancyCardItem:SetMask()
    local mask = self.fancyCard:GetMask(self.isBig)
    if self.resourceCache then
        self.fancyMask.overrideSprite = self.resourceCache:GetMask(mask)
    else
        local maskRes = AssetFinder.GetFancyCardIcon(mask)
        self.fancyMask.overrideSprite = maskRes
    end
end

function FancyCardItem:SetHead()
    local head = self.fancyCard:GetHead()
    if self.resourceCache then
        self.head.overrideSprite = self.resourceCache:GetHead(head)
    else
        local headRes
        if head == nil or head == '' then
            headRes = AssetFinder.GetFancyCardIcon("Common/head")
        else
            headRes = AssetFinder.GetPlayerIcon(head)
        end
        self.head.overrideSprite = headRes
    end
end

function FancyCardItem:SetGroupIcon()
    local groupIcon = self.fancyCard:GetGroupIcon(self.isBig)
    if self.resourceCache then
        self.group.overrideSprite = self.resourceCache:GetFancyGroupIcon(groupIcon)
    else
        local groupIconRes = AssetFinder.GetFancyCardIcon(groupIcon)
        self.group.overrideSprite = groupIconRes
    end
end

function FancyCardItem:SetQualityIcon()
    local quality = self.fancyCard:GetQualityIcon()
    if self.resourceCache then
        self.quality.overrideSprite = self.resourceCache:getQualityIcon(quality)
    else
        local qualityRes = AssetFinder.GetFancyCardIcon("Common/" .. quality)
        self.quality.overrideSprite = qualityRes
    end
end

function FancyCardItem:SetSideMask()
    local mask = self.fancyCard:GetSideMask()
    if self.resourceCache then
        self.sideMask.overrideSprite = self.resourceCache:GetSideMask(mask)
    else
        local maskRes = AssetFinder.GetFancyCardIcon(mask)
        self.sideMask.overrideSprite = maskRes
    end
end

function FancyCardItem:SetStarMask()
    local mask = self.fancyCard:GetMask(false)
    if self.resourceCache then
        self.starMask.overrideSprite = self.resourceCache:GetMask(mask)
    else
        local maskRes = AssetFinder.GetFancyCardIcon(mask)
        self.starMask.overrideSprite = maskRes
    end
end

return FancyCardItem
