local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CurrencyImagePath = require("ui.scene.itemList.CurrencyImagePath")

local AssistantCoachUpdateBoardView = class(unity.base, "AssistantCoachUpdateBoardView")

local AssistantCoachSkillPath = "Assets/CapstonesRes/Game/UI/Scene/Coach/AssistantSystem/Prefabs/AssistantCoachSkillItem.prefab"

local ATTR_Y = 470
local SKILL_Y = 580

function AssistantCoachUpdateBoardView:ctor()
    -- 左边
    self.txtLeftTitle = self.___ex.txtLeftTitle
    self.sptLeftAttrs = self.___ex.sptLeftAttrs
    self.rctLeftSkill = self.___ex.rctLeftSkill
    -- 右边
    self.txtRightTitle = self.___ex.txtRightTitle
    self.sptRightAttrs = self.___ex.sptRightAttrs
    self.rctRightSkill = self.___ex.rctRightSkill
    self.txtFull = self.___ex.txtFull
    self.objRightAttr = self.___ex.objRightAttr
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
    self.objNewSkill = self.___ex.objNewSkill
    self.txtNewSkillName = self.___ex.txtNewSkillName
end

function AssistantCoachUpdateBoardView:start()
    self:RegBtnEvent()
end

function AssistantCoachUpdateBoardView:InitView(acModel, sptParent)
    self.acModel = acModel
    self.sptParent = sptParent

    self:InitMiddleView(acModel)
    self:InitBottomView(acModel)
end

function AssistantCoachUpdateBoardView:InitMiddleView(acModel)
    local lvl = acModel:GetLvl()
    local nextLvl = lvl + 1
    -- 升级左侧信息
    local attrs = acModel:GetAttrs()
    self.txtLeftTitle.text = lang.trans("current_level_num", lang.transstr("friends_manager_item_level", lvl)) -- 当前等级Lv.X
    self.sptLeftAttrs:InitView(attrs)

    -- 升级右侧信息
    local isMax = acModel:IsMax()
    GameObjectHelper.FastSetActive(self.txtFull.gameObject, isMax)
    if isMax then
        self.txtRightTitle.text = lang.trans("hero_hall_upgrade_max_level") -- 已满级
        self.sptRightAttrs:InitView({})
    else
        self.txtRightTitle.text = lang.trans("next_level_num", lang.transstr("friends_manager_item_level", nextLvl)) -- 下一等级Lv.X
        self.sptRightAttrs:InitView(attrs, true)
    end

    -- 是否解锁技能
    local needShowSkill = false
    self:DisplaySkill(false)
    local skills = acModel:GetSkills()
    res.ClearChildren(self.rctLeftSkill)
    res.ClearChildren(self.rctRightSkill)
    for k, skill in pairs(skills) do
        if not skill.isOpen and nextLvl >= skill.unlockLvl then
            needShowSkill = true
            self:DisplaySkill(true)
            local objSkill, sptSkill = res.Instantiate(AssistantCoachSkillPath)
            objSkill.transform:SetParent(self.rctLeftSkill, false)
            sptSkill:InitView(skill, false, true, false)
            sptSkill:SetOpenState(false)

            objSkill, sptSkill = res.Instantiate(AssistantCoachSkillPath)
            objSkill.transform:SetParent(self.rctRightSkill, false)
            sptSkill:InitView(skill, false, true, false)
            sptSkill:SetOpenState(true)

            self.txtNewSkillName.text = skill.name
            break
        end
    end

    if needShowSkill then
        self.sptParent:SetBoardSize(SKILL_Y)
    else
        self.sptParent:SetBoardSize(ATTR_Y)
    end
end

function AssistantCoachUpdateBoardView:DisplaySkill(isShow)
    GameObjectHelper.FastSetActive(self.rctLeftSkill.gameObject, isShow)
    GameObjectHelper.FastSetActive(self.rctRightSkill.gameObject, isShow)
    GameObjectHelper.FastSetActive(self.objNewSkill.gameObject, isShow)
end

function AssistantCoachUpdateBoardView:InitBottomView(acModel)
    local isMax = acModel:IsMax()
    self:DisplayCurrency(isMax)
    GameObjectHelper.FastSetActive(self.objCurrencyItem_2.gameObject, false)
    GameObjectHelper.FastSetActive(self.objCurrencyItem_3.gameObject, false)
    if not isMax then
        -- 消耗助理教练经验书
        local ace = tonumber(acModel:GetUpdateAce())
        if ace ~= nil and ace > 0 then
            GameObjectHelper.FastSetActive(self.objCurrencyItem_1.gameObject, true)
            self.imgCurrencyIcon_1.overrideSprite = res.LoadRes(CurrencyImagePath.ace)
            self.txtCurrencyNum_1.text = "X" .. string.formatNumWithUnit(ace)
        else
            GameObjectHelper.FastSetActive(self.objCurrencyItem_1.gameObject, false)
        end
    end

    self.buttonUpdate.interactable = not isMax
end

function AssistantCoachUpdateBoardView:DisplayCurrency(isMax)
    GameObjectHelper.FastSetActive(self.objCurrencyItem_1.gameObject, not isMax)
    GameObjectHelper.FastSetActive(self.objCurrencyItem_2.gameObject, not isMax)
    GameObjectHelper.FastSetActive(self.objCurrencyItem_3.gameObject, not isMax)
    GameObjectHelper.FastSetActive(self.txtNeedCurrency.gameObject, not isMax)
    GameObjectHelper.FastSetActive(self.txtMaxLvlHint.gameObject, isMax)
end

function AssistantCoachUpdateBoardView:OnEnterScene()
end

function AssistantCoachUpdateBoardView:OnExitScene()
end

function AssistantCoachUpdateBoardView:RegBtnEvent()
    self.btnUpdate:regOnButtonClick(function()
        self:OnClickBtnUpdate()
    end)
end

function AssistantCoachUpdateBoardView:OnClickBtnUpdate()
    if self.onBtnUpdateClick and type(self.onBtnUpdateClick) == "function" then
        self.onBtnUpdateClick()
    end
end

return AssistantCoachUpdateBoardView
