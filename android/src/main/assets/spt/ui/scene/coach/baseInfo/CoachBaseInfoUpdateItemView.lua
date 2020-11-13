local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector2 = UnityEngine.Vector2
local Mathf = UnityEngine.Mathf
local GameObjectHelper = require("ui.common.GameObjectHelper")
local UpdateBoardType = require("ui.models.coach.baseInfo.CoachBaseInfoUpdateBoardType")
local FormationConstants = require("ui.scene.formation.FormationConstants")
local CurrencyImagePath = require("ui.scene.itemList.CurrencyImagePath")
local CurrencyNameMap = require("ui.models.itemList.CurrencyNameMap")
local CoachItemMapModel = require("ui.models.coach.common.CoachItemMapModel")
local AssetFinder = require("ui.common.AssetFinder")

local CoachBaseInfoUpdateItemView = class(unity.base, "CoachBaseInfoUpdateItemView")

-- 进度条最大宽度
local PROGRESS_MAX_WIDTH = 453

function CoachBaseInfoUpdateItemView:ctor()
    -- 图标
    self.imgIcon = self.___ex.imgIcon
    -- 战术或者阵容的名称
    self.txtChooseTitle = self.___ex.txtChooseTitle
    -- 描述
    self.txtChooseContent = self.___ex.txtChooseContent
    -- 战术中的类别（如进攻偏好）或阵容
    self.txtChooseType = self.___ex.txtChooseType
    -- 更改战术或阵容
    self.btnChange = self.___ex.btnChange
    self.txtChange = self.___ex.txtChange
    -- 等级描述
    self.txtLevel = self.___ex.txtLevel
    -- 进度条
    self.imgProgress = self.___ex.imgProgress
    self.rctProgress = self.___ex.rctProgress
    -- 当前货币
    self.imgCurrCurrency = self.___ex.imgCurrCurrency
    self.txtCurrCurrency = self.___ex.txtCurrCurrency
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
    self.txtCurrencyName_1 = self.___ex.txtCurrencyName_1
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
    -- 升级向右箭头
    self.imgRightArrow = self.___ex.imgRightArrow
end

function CoachBaseInfoUpdateItemView:start()
    self:RegBtnEvent()
end

function CoachBaseInfoUpdateItemView:InitView(data)
    self.data = data

    -- 初始化item的类型
    if data.boardType == UpdateBoardType.Formation then
        self:InitFormationView(data)
    elseif data.boardType == UpdateBoardType.Tactics then
        self:InitTacticView(data)
    else
        GameObjectHelper.FastSetActive(self.btnChange.gameObject, false)
        self.txtChange.text = lang.transstr("switch")
        self.txtChooseTitle.text = ""
        self.txtChooseType.text = ""
        GameObjectHelper.FastSetActive(self.imgIcon.gameObject, false)
        dump("wrong board type!")
    end
end

-- 升级面板为阵型的初始化
function CoachBaseInfoUpdateItemView:InitFormationView(data)
    -- 切换按钮
    GameObjectHelper.FastSetActive(self.btnChange.gameObject, true)
    self.txtChange.text = lang.transstr("switch") .. lang.transstr("menu_formation") -- 切换阵型
    -- 阵型名字
    self.txtChooseTitle.text = tostring(data.formationName)
    -- 描述
    local currProp = "<color=#8ad53aff>" .. data.currProp .. "</color>"
    self.txtChooseContent.text = lang.trans("coach_baseInfo_update_desc", data.formationName, lang.transstr("match_skill_all") .. lang.transstr("card_training_rule_allAttr", currProp))
    -- 偏好阵型
    self.txtChooseType.text = data.formationStr or ""
    -- 等级
    self.txtLevel.text = lang.trans("friends_manager_item_level", data.lvl .. "/" .. data.maxLvl)
    -- 进度条
    self.rctProgress.sizeDelta = Vector2(Mathf.Clamp01(tonumber(data.lvl) / tonumber(data.maxLvl)) * PROGRESS_MAX_WIDTH, self.rctProgress.sizeDelta.y)
    -- 图标
    self.imgIcon.overrideSprite = AssetFinder.GetCoachBaseInfoItemIcon(data.boardType)
    -- 当前货币
    self:InitCurrCurrency(data)

    self:InitMiddleView(data)
    self:InitBottomView(data)
end

--升级面板为战术的初始化
function CoachBaseInfoUpdateItemView:InitTacticView(data)
    -- 切换按钮
    GameObjectHelper.FastSetActive(self.btnChange.gameObject, false)
    self.txtChange.text = lang.transstr("switch") .. lang.transstr("match_tactics") -- 切换战术
    -- 战术名字
    self.txtChooseTitle.text = data.tacticName
    -- 描述
    local currProp = "<color=#8ad53aff>" .. data.currProp .. "</color>"
    self.txtChooseContent.text = lang.trans("coach_baseInfo_update_desc", data.tacticName, lang.transstr("match_skill_all") .. lang.transstr("card_training_rule_allAttr", currProp))
    -- 战术类别
    self.txtChooseType.text = data.tacticsStr or ""
    -- 等级
    self.txtLevel.text = lang.trans("friends_manager_item_level", data.lvl .. "/" .. data.maxLvl)
    -- 进度条
    self.rctProgress.sizeDelta = Vector2(Mathf.Clamp01(tonumber(data.lvl) / tonumber(data.maxLvl)) * PROGRESS_MAX_WIDTH, self.rctProgress.sizeDelta.y)
    -- 图标
    self.imgIcon.overrideSprite = AssetFinder.GetCoachBaseInfoItemIcon(data.boardType .. "_" .. data.tacticsType)
    -- 当前货币
    self:InitCurrCurrency(data)

    self:InitMiddleView(data)
    self:InitBottomView(data)
end

function CoachBaseInfoUpdateItemView:InitCurrCurrency(data)
    self.imgCurrCurrency.overrideSprite = AssetFinder.GetCtiIcon(data.ctiConfig.picIndex)
    self.txtCurrCurrency.text = "X" .. string.formatNumWithUnit(data.currCurrencyNum)
end

function CoachBaseInfoUpdateItemView:InitMiddleView(data)
    -- 升级左侧信息
    self.txtLeftTitle.text = lang.trans("current_level_num", lang.transstr("friends_manager_item_level", data.lvl)) -- 当前等级
    self.txtLeftProp.text = lang.transstr("match_skill_all") .. lang.transstr("card_training_rule_allAttr", ":")
    self.txtLeftPropNum.text = tostring(data.currProp)
    -- 升级右侧信息
    if data.isMaxLvl and data.isCoachMaxLvl then
        self.txtRightTitle.text = lang.trans("hero_hall_upgrade_max_level") -- 已满级
        self.txtRightProp.text = lang.trans("hero_hall_upgrade_max_level")
    elseif not data.isMaxLvl and data.isCoachMaxLvl then
        self.txtRightTitle.text = lang.trans("next_level_num", lang.transstr("friends_manager_item_level", tonumber(data.lvl) + 1)) -- 下一等级
        self.txtRightProp.text = lang.trans("coach_baseInfo_update_to_lock") -- 升级教练
    else
        self.txtRightTitle.text = lang.trans("next_level_num", lang.transstr("friends_manager_item_level", tonumber(data.lvl) + 1)) -- 下一等级
        self.txtRightProp.text = lang.transstr("match_skill_all") .. lang.transstr("card_training_rule_allAttr", ":") -- 全队全属性提升
    end
    GameObjectHelper.FastSetActive(self.txtRightPropNum.gameObject, not data.isMaxLvl)
    self.txtRightPropNum.text = tostring(data.nextProp)
    -- 向右箭头
    GameObjectHelper.FastSetActive(self.imgRightArrow.gameObject, not (data.isMaxLvl or data.isCoachMaxLvl))
end

function CoachBaseInfoUpdateItemView:InitBottomView(data)
    -- 升级按钮状态
    self.buttonUpdate.interactable = not (data.isMaxLvl or data.isCoachMaxLvl)
    if data.isMaxLvl and data.isCoachMaxLvl then
        GameObjectHelper.FastSetActive(self.txtNeedCurrency.gameObject, false)
        GameObjectHelper.FastSetActive(self.txtMaxLvlHint.gameObject, true)
        GameObjectHelper.FastSetActive(self.objCurrencyItem_1.gameObject, false)
        GameObjectHelper.FastSetActive(self.objCurrencyItem_2.gameObject, false)
        GameObjectHelper.FastSetActive(self.objCurrencyItem_3.gameObject, false)
        self.txtMaxLvlHint.text = lang.trans("hero_hall_upgrade_max_level")
        return
    end

    GameObjectHelper.FastSetActive(self.txtNeedCurrency.gameObject, true)
    GameObjectHelper.FastSetActive(self.txtMaxLvlHint.gameObject, false)
    -- 消耗货币
    if data.ctiAmount ~= nil and data.ctiAmount > 0 then
        GameObjectHelper.FastSetActive(self.objCurrencyItem_1.gameObject, true)
        self.txtCurrencyName_1.text = tostring(data.ctiConfig.name)
        self.imgCurrencyIcon_1.overrideSprite = AssetFinder.GetCtiIcon(data.ctiConfig.picIndex)
        self.txtCurrencyNum_1.text = "X" .. string.formatNumWithUnit(data.ctiAmount)
    else
        GameObjectHelper.FastSetActive(self.objCurrencyItem_1.gameObject, false)
    end
    if data.m ~= nil and data.m > 0 then
        GameObjectHelper.FastSetActive(self.objCurrencyItem_2.gameObject, true)
        self.imgCurrencyIcon_2.overrideSprite = res.LoadRes(CurrencyImagePath.m)
        self.txtCurrencyNum_2.text = "X" .. string.formatNumWithUnit(data.m)
    else
        GameObjectHelper.FastSetActive(self.objCurrencyItem_2.gameObject, false)
    end
    if data.d ~= nil and data.d > 0 then
        GameObjectHelper.FastSetActive(self.objCurrencyItem_3.gameObject, true)
        self.imgCurrencyIcon_3.overrideSprite = res.LoadRes(CurrencyImagePath.d)
        self.txtCurrencyNum_3.text = "X" .. string.formatNumWithUnit(data.d)
    else
        GameObjectHelper.FastSetActive(self.objCurrencyItem_3.gameObject, false)
    end
end

function CoachBaseInfoUpdateItemView:OnEnterScene()
end

function CoachBaseInfoUpdateItemView:OnExitScene()
end

function CoachBaseInfoUpdateItemView:RegBtnEvent()
end

return CoachBaseInfoUpdateItemView
