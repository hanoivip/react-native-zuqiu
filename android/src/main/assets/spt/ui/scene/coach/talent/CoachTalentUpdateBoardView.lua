local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector2 = UnityEngine.Vector2
local Mathf = UnityEngine.Mathf
local Color = UnityEngine.Color
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CurrencyImagePath = require("ui.scene.itemList.CurrencyImagePath")
local AssetFinder = require("ui.common.AssetFinder")

local CoachTalentUpdateItemView = class(unity.base, "CoachTalentUpdateItemView")

-- 进度条最大宽度
local PROGRESS_MAX_WIDTH = 484

-- 升级/解锁按钮颜色
local Btn_update_disable_COLOR = Color(206/255, 209/255, 210/255)
local Btn_update_enable_COLOR = Color(65/255, 65/255, 65/255)

function CoachTalentUpdateItemView:ctor()
    -- 图标
    self.imgIcon = self.___ex.imgIcon
    -- 技能名称
    self.txtChooseTitle = self.___ex.txtChooseTitle
    -- 描述
    self.txtChooseContent = self.___ex.txtChooseContent
    -- round名称
    self.txtChooseType = self.___ex.txtChooseType
    -- 等级描述
    self.txtLevel = self.___ex.txtLevel
    -- 进度条
    self.imgProgress = self.___ex.imgProgress
    self.rctProgress = self.___ex.rctProgress
    -- 左边
    self.txtLeftTitle = self.___ex.txtLeftTitle
    self.txtLeftProp = self.___ex.txtLeftProp
    self.txtLeftPropNum = self.___ex.txtLeftPropNum
    -- 右边
    self.txtRightTitle = self.___ex.txtRightTitle
    self.txtRightProp = self.___ex.txtRightProp
    self.txtRightPropNum = self.___ex.txtRightPropNum
    -- 升级消耗
    self.txtNeedCurrency = self.___ex.txtNeedCurrency
    -- 满级货币处提示
    self.txtMaxLvlHint = self.___ex.txtMaxLvlHint
    -- 第一个货币
    self.objCurrencyItem_1 = self.___ex.objCurrencyItem_1
    self.imgCurrencyIcon_1 = self.___ex.imgCurrencyIcon_1
    self.txtCurrencyNum_1 = self.___ex.txtCurrencyNum_1
    -- 第二个货币
    self.objCurrencyItem_2 = self.___ex.objCurrencyItem_2
    self.imgCurrencyIcon_2 = self.___ex.imgCurrencyIcon_2
    self.txtCurrencyNum_2 = self.___ex.txtCurrencyNum_2
    -- 第三个货币
    self.objCurrencyItem_3 = self.___ex.objCurrencyItem_3
    self.imgCurrencyIcon_3 = self.___ex.imgCurrencyIcon_3
    self.txtCurrencyNum_3 = self.___ex.txtCurrencyNum_3
    -- 升级按钮
    self.btnUpdate = self.___ex.btnUpdate
    self.buttonUpdate = self.___ex.buttonUpdate
    self.txtUpdate = self.___ex.txtUpdate
    -- 升级向右箭头
    self.imgRightArrow = self.___ex.imgRightArrow
end

function CoachTalentUpdateItemView:start()
    self:RegBtnEvent()
end

function CoachTalentUpdateItemView:InitView(data)
    self.data = data

    self:InitTopView(data)
    self:InitMiddleView(data)
    self:InitBottomView(data)
end

-- 升级面板为阵型的初始化
function CoachTalentUpdateItemView:InitTopView(data)
    self.imgIcon.overrideSprite = AssetFinder.GetCoachTalentSkill(data.picIndex)
    -- 技能名字
    self.txtChooseTitle.text = tostring(data.talentName or "")
    -- 技能描述
    self.txtChooseContent.text = tostring(data.desc or "")
    -- 等级
    self.txtLevel.text = lang.trans("friends_manager_item_level", data.lvl .. "/" .. data.maxLvl)
    -- 进度条
    self.rctProgress.sizeDelta = Vector2(Mathf.Clamp01(tonumber(data.lvl) / tonumber(data.maxLvl)) * PROGRESS_MAX_WIDTH, self.rctProgress.sizeDelta.y)
end

function CoachTalentUpdateItemView:InitMiddleView(data)
    local effectTalentType = tonumber(data.effectTalentType)
    -- -- 升级左侧信息
    if data.isLocked then
        self.txtLeftTitle.text = lang.trans("not_unlock")
        self.txtLeftProp.text = lang.trans("not_unlock")
    else
        self.txtLeftTitle.text = lang.trans("current_level_num", lang.transstr("friends_manager_item_level", data.lvl)) -- 当前等级Lv.X
        local prop = data.effectTalent1 + (tonumber(data.lvl) - 1) * data.effectTalentLevelUp
        if effectTalentType == 2 then
            prop = tostring(prop / 10) .. "%%"
        end
        self.txtLeftProp.text = string.gsub(data.desc2, "[%%]d", tostring(prop), 1)
    end
    -- 升级右侧信息
    if data.isMaxLvl then
        self.txtRightTitle.text = lang.trans("hero_hall_upgrade_max_level") -- 已满级
        self.txtRightProp.text = lang.trans("hero_hall_upgrade_max_level")
    else
        local nextLvl = tonumber(data.lvl) + 1
        self.txtRightTitle.text = lang.trans("next_level_num", lang.transstr("friends_manager_item_level", nextLvl)) -- 下一等级Lv.X
        local nextProp = data.effectTalent1 + (nextLvl - 1) * data.effectTalentLevelUp
        if effectTalentType == 2 then
            nextProp = tostring(nextProp / 10) .. "%%"
        end
        self.txtRightProp.text = string.gsub(data.desc2, "[%%]d", tostring(nextProp), 1)
    end
    -- 向右箭头
    GameObjectHelper.FastSetActive(self.imgRightArrow.gameObject, not data.isMaxLvl and not data.isLocked)
end

function CoachTalentUpdateItemView:InitBottomView(data)
    if data.isMaxLvl then
        GameObjectHelper.FastSetActive(self.txtNeedCurrency.gameObject, false)
        GameObjectHelper.FastSetActive(self.txtMaxLvlHint.gameObject, true)
        GameObjectHelper.FastSetActive(self.objCurrencyItem_1.gameObject, false)
        GameObjectHelper.FastSetActive(self.objCurrencyItem_2.gameObject, false)
        GameObjectHelper.FastSetActive(self.objCurrencyItem_3.gameObject, false)
        self.buttonUpdate.interactable = false
        self.txtUpdate.text = lang.trans("hero_hall_upgrade_max_level")
        return
    end
    GameObjectHelper.FastSetActive(self.txtNeedCurrency.gameObject, true)
    GameObjectHelper.FastSetActive(self.txtMaxLvlHint.gameObject, false)
    self.buttonUpdate.interactable = true
    self.txtNeedCurrency.text = lang.trans("update_need") -- 升级消耗
    self.txtUpdate.text = lang.trans("levelUp") -- 升级

    if data.isLocked then
        self.buttonUpdate.interactable = data.canUnlock
        self.txtNeedCurrency.text = lang.trans("unlock_need")  -- 解锁消耗
        if data.canUnlock then
            self.txtUpdate.text = lang.trans("unlock") -- 解锁
        else
            self.txtUpdate.text = lang.transstr("unable") .. lang.transstr("unlock") -- 不可解锁
        end
    end

    -- 消耗天赋点
    local ctp = tonumber(data.talentPoint[tonumber(data.lvl) + 1])
    if ctp ~= nil and ctp > 0 then
        GameObjectHelper.FastSetActive(self.objCurrencyItem_1.gameObject, true)
        self.imgCurrencyIcon_1.overrideSprite = res.LoadRes(CurrencyImagePath.ctp)
        self.txtCurrencyNum_1.text = "X" .. string.formatNumWithUnit(ctp)
    else
        GameObjectHelper.FastSetActive(self.objCurrencyItem_1.gameObject, false)
    end
    -- 消耗的欧元
    local m = tonumber(data.priceTalent) + tonumber(data.lvl) * tonumber(data.priceTalentLevelUp)
    if m ~= nil and m > 0 then
        GameObjectHelper.FastSetActive(self.objCurrencyItem_2.gameObject, true)
        self.imgCurrencyIcon_2.overrideSprite = res.LoadRes(CurrencyImagePath.m)
        self.txtCurrencyNum_2.text = "X" .. string.formatNumWithUnit(m)
    else
        GameObjectHelper.FastSetActive(self.objCurrencyItem_2.gameObject, false)
    end

    GameObjectHelper.FastSetActive(self.objCurrencyItem_3.gameObject, false)
end

function CoachTalentUpdateItemView:OnEnterScene()
end

function CoachTalentUpdateItemView:OnExitScene()
end

function CoachTalentUpdateItemView:RegBtnEvent()
    self.btnUpdate:regOnButtonClick(function()
        EventSystem.SendEvent("CoachTalentUpdateSkill", self.data)
    end)
end

return CoachTalentUpdateItemView
