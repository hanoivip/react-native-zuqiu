local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local GameObjectHelper = require("ui.common.GameObjectHelper")
local AssetFinder = require("ui.common.AssetFinder")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local GreenswardCycleDetailView = class(unity.base, "GreenswardCycleDetailView")

local skill_item_path = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Dialog/CycleDetail/GreenswardCycleDetailSkillItem.prefab"

function GreenswardCycleDetailView:ctor()
    -- 标题
    self.txtTitle = self.___ex.txtTitle
    -- 关闭按钮
    self.btnClose = self.___ex.btnClose
    -- canvasGroup
    self.canvasGroup = self.___ex.canvasGroup
    -- 面板的Rect Transform
    self.rctBoard = self.___ex.rctBoard
    -- 当前周期
    self.txtCurrCycle = self.___ex.txtCurrCycle
    -- 剩余回合
    self.txtCurrLeftRound = self.___ex.txtCurrLeftRound

    -- 当前天气图标
    self.imgWeaIcon = self.___ex.imgWeaIcon
    -- 当前天气名称
    self.txtWeaName = self.___ex.txtWeaName
    -- 技能容器
    self.rctSkills = self.___ex.rctSkills
    -- 有效果
    self.objHasEffect = self.___ex.objHasEffect
    -- 无效果
    self.txtNone = self.___ex.txtNone
    -- 降低等级
    self.txtLvl = self.___ex.txtLvl

    -- 当前星象图标
    self.imgStarIcon = self.___ex.imgStarIcon
    -- 当前星象名称
    self.txtStarName = self.___ex.txtStarName
    -- 当前星象描述
    self.txtStarDesc = self.___ex.txtStarDesc
    -- 星象图鉴按钮
    self.btnStarLib = self.___ex.btnStarLib
end

function GreenswardCycleDetailView:start()
    self:RegBtnEvent()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function GreenswardCycleDetailView:InitView(greenswardCycleDetailModel)
    self.model = greenswardCycleDetailModel
end

function GreenswardCycleDetailView:RefreshView()
    local currCycle = tostring(self.model:GetCurrCycle())
    self.txtTitle.text = lang.transstr("cycle") .. currCycle
    self.txtCurrCycle.text = currCycle
    self.txtCurrLeftRound.text = tostring(self.model:GetCurrLeftRound())
    -- 天气
    self.imgWeaIcon.overrideSprite = self.model:GetCurrWeaIconRes()
    self.txtWeaName.text = tostring(self.model:GetCurrWeaName())
    res.ClearChildren(self.rctSkills)
    local skillDatas = self.model:GetSkillAffectDatas()
    if skillDatas then
        GameObjectHelper.FastSetActive(self.objHasEffect.gameObject, true)
        GameObjectHelper.FastSetActive(self.txtNone.gameObject, false)
        for k, skillData in ipairs(skillDatas) do
            local obj, spt = res.Instantiate(skill_item_path)
            if obj and spt then
                obj.transform:SetParent(self.rctSkills.transform, false)
                spt:InitView(skillData)
            end
        end
        self.txtLvl.text = lang.trans("reduce_num", self.model:GetSkillAffectLvl())
    else
        GameObjectHelper.FastSetActive(self.objHasEffect.gameObject, false)
        GameObjectHelper.FastSetActive(self.txtNone.gameObject, true)
    end
    -- 星象
    self.imgStarIcon.overrideSprite = AssetFinder.GetGreenswardStarIcon(self.model:GetCurrStarIconIndex())
    self.txtStarName.text = tostring(self.model:GetCurrStarName())
    self.txtStarDesc.text = tostring(self.model:GetCurrStarDesc())
end

function GreenswardCycleDetailView:RegBtnEvent()
    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)
    self.btnStarLib:regOnButtonClick(function()
        self:OnBtnStarLibClick()
    end)
end

function GreenswardCycleDetailView:Close()
    local callback = function()
        if type(self.closeDialog) == "function" then
            self.closeDialog()
        end
    end
    DialogAnimation.Disappear(self.transform, nil, callback)
end

-- 点击星象图鉴按钮
function GreenswardCycleDetailView:OnBtnStarLibClick()
    if self.onBtnStarLibClick ~= nil and type(self.onBtnStarLibClick) == "function" then
        self.onBtnStarLibClick()
    end
end

return GreenswardCycleDetailView
