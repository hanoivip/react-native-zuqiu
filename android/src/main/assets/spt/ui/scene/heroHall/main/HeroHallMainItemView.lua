local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Color = UnityEngine.Color
local Vector3 = UnityEngine.Vector3
local GameObjectHelper = require("ui.common.GameObjectHelper")
local AssetFinder = require("ui.common.AssetFinder")

local HeroHallMainItemView = class(unity.base, "HeroHallMainItemView")

function HeroHallMainItemView:ctor()
    self.lockedObj = self.___ex.lockedObj
    self.unlockObj = self.___ex.unlockObj
    self.nameTxt = self.___ex.name
    self.desc = self.___ex.desc
    self.icon = self.___ex.icon
    self.score = self.___ex.score
    self.scoreRef = self.___ex.scoreRef
    self.attribute = self.___ex.attribute
    self.openCondition = self.___ex.openCondition
    self.click = self.___ex.click
    self.lockAnimator = self.___ex.lockAnimator
    self.unlockAnimator = self.___ex.unlockAnimator
    -- 解锁动画重新设置参数所需变量
    self.imgBgLocked = self.___ex.imgBgLocked
    self.imgLock = self.___ex.imgLock
    self.txtUnlockTitle = self.___ex.txtUnlockTitle
    self.cgAttri = self.___ex.canvasGroupAttri
    self.imgBgNormal = self.___ex.imgBgNormal
    self.imgCircle = self.___ex.imgCircle
    self.rctIcon = self.___ex.rctIcon
    self.imgLine_1 = self.___ex.imgLine_1
    self.imgLine_2 = self.___ex.imgLine_2
    self.txtScoreTitle = self.___ex.txtScoreTitle

    self.canItemClick = true
    self.heroHallMainView = nil
end

function HeroHallMainItemView:start()
    self:RegBtnEvent()
end

function HeroHallMainItemView:InitView(itemData, onItemClick, heroHallMainView)
    self.id = itemData.id

    GameObjectHelper.FastSetActive(self.lockedObj, itemData.activate ~= 1)
    GameObjectHelper.FastSetActive(self.unlockObj, itemData.activate == 1)

    self.nameTxt.text = tostring(itemData.name)
    self.desc.text = tostring(itemData.desc)

    self.lockAnimator:Rebind()  --Lua assist checked flag
    if itemData.activate == -1 then        -- 未激活
        self.openCondition.text = tostring(itemData.openDesc)
    elseif itemData.activate == 0 then     -- 待激活
        self.openCondition.text = tostring(itemData.openDesc) .. "\n\n" .. lang.transstr("hero_hall_main_can_unlock")
        self.lockAnimator:SetBool("canUnlock", true)  --Lua assist checked flag
    elseif itemData.activate == 1 then     -- 已激活
        self.icon.overrideSprite = AssetFinder.GetHeroHallIcon(itemData.hallPicRes)
        self:SetScoreTxt(itemData.score)
    else
        dump("wrong data activate, please check the server")
    end

    self:InitAttributeView(itemData)

    self.onItemClick = onItemClick
    self.heroHallMainView = heroHallMainView

    self.unlockAnimator:Rebind()  --Lua assist checked flag
    self.unlockAnimator:SetBool("UnlockAnimation", false)  --Lua assist checked flag
    self.unlockAnimator:SetBool("isUnlock", itemData.activate == 1)  --Lua assist checked flag
end

function HeroHallMainItemView:InitAttributeView(itemData)
    for k, v in pairs(self.attribute) do
        GameObjectHelper.FastSetActive(v.gameObject, false)
    end

    local totalAttribute = 0
    local hlvl = 0
    for k, statueData in pairs(itemData.list) do
        totalAttribute = totalAttribute + statueData.fixAttribute
        hlvl = hlvl + statueData.hlvl
    end
    if #itemData.attributeType == 10 then       -- 全属性
        GameObjectHelper.FastSetActive(self.attribute["1"].gameObject, true)
        self.attribute["1"].text = lang.transstr("hero_hall_main_all_attribute") .. " +" .. totalAttribute
        if hlvl > 0 then
            GameObjectHelper.FastSetActive(self.attribute["2"].gameObject, true)
            self.attribute["2"].text = lang.trans("hero_hall_skill_all_add")
        end
    else
        for k, attributeName in pairs(itemData.attributeType) do
            GameObjectHelper.FastSetActive(self.attribute[tostring(k)].gameObject, true)
            self.attribute[tostring(k)].text = lang.transstr(attributeName) .. " +" .. totalAttribute
        end
        if hlvl > 0 then
            local attributeNum = table.nums(itemData.attributeType)
            local index = tostring(attributeNum + 1)
            GameObjectHelper.FastSetActive(self.attribute[index].gameObject, true)
            self.attribute[index].text = lang.trans("hero_hall_skill_all_add")
        end
    end
end

function HeroHallMainItemView:SetScoreTxt(score)
    self.score.text = tostring(score)
    self.scoreRef.text = tostring(score)
end

function HeroHallMainItemView:RegBtnEvent()
    self.click:regOnButtonClick(function()
        if self.onItemClick and self.canItemClick then
            self.onItemClick(self.id)
        end
    end)
end

function HeroHallMainItemView:ActivateHall(itemData)
    self.canItemClick = false
    self:RefreshStaticUI(itemData)
    self.lockAnimator:SetBool("canUnlock", false)  --Lua assist checked flag
    self.unlockAnimator:SetBool("UnlockAnimation", true)  --Lua assist checked flag
end

function HeroHallMainItemView:RefreshStaticUI(itemData)
    self.icon.overrideSprite = AssetFinder.GetHeroHallIcon(itemData.hallPicRes)
    self:SetScoreTxt(itemData.score)
    self:InitAttributeView(itemData)
end

-- 暂时无用
function HeroHallMainItemView:ResetUIStatus(itemData)
    self.imgBgLocked.color = Color.white
    self.imgLine_1.color = Color.white
    self.imgLock.color = Color.white
    self.openCondition.color = Color.white
    self.txtUnlockTitle.color = Color(1, 1, 1, 0.4)
    self.cgAttri.alpha = 1
    self.imgBgNormal.color = Color.white
    self.imgCircle.color = Color.white
    self.rctIcon.localScale = Vector3.one;
    self.icon.color = Color.white
    self.imgLine_2.color = Color.white
    self.scoreRef.color = Color(218 / 255, 224 / 255, 239 / 255, 1)
    self.txtScoreTitle.color = Color(1, 1, 1, 102 / 255)
    self.score.color = Color(1, 1, 1, 1)
end

-- 设置激活，动画事件
function HeroHallMainItemView:ActivateUnlockObj()
    GameObjectHelper.FastSetActive(self.unlockObj, true)
end

-- 结束解锁动画，动画事件
function HeroHallMainItemView:EndUnlockAnim()
    self.canItemClick = true
    self.unlockAnimator:SetBool("UnlockAnimation", false)  --Lua assist checked flag

    self.heroHallMainView:EndUnlockAnim()
end

function HeroHallMainItemView:RebindAllAnimator()
    self.lockAnimator:Rebind()  --Lua assist checked flag
    self.unlockAnimator:Rebind()  --Lua assist checked flag
end

return HeroHallMainItemView
