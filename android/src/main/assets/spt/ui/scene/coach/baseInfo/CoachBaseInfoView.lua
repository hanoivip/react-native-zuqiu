local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector3 = UnityEngine.Vector3
local Vector2 = UnityEngine.Vector2
local Mathf = UnityEngine.Mathf
local GameObjectHelper = require("ui.common.GameObjectHelper")

local CoachBaseInfoView = class(unity.base, "CoachBaseInfoView")

-- 教练头像prefab
local CoachPortraitPath = "Assets/CapstonesRes/Game/UI/Scene/Coach/Common/Prefabs/CoachPortrait.prefab"

-- 进度条最大宽度
local PROGRESS_MAX_WIDTH = 565

function CoachBaseInfoView:ctor()
    -- 资源框
    self.infoBarDynParent = self.___ex.infoBarDynParent
    -- 中间面板
    self.mainView = self.___ex.mainView
    -- 教练头像
    self.rctPortrait = self.___ex.rctPortrait
    -- 经验进度
    self.rctProgress = self.___ex.rctProgress
    -- 下一品质提示
    self.txtNextTip = self.___ex.txtNextTip
    -- 阵型框
    self.rctFormation = self.___ex.rctFormation
    -- 滑动框
    self.scrollView = self.___ex.scrollView
    -- 介绍
    self.btnIntro = self.___ex.btnIntro
    -- 阵型控制脚本
    self.sptFormation = self.___ex.sptFormation
    -- 升级按钮
    self.btnUpdate = self.___ex.btnUpdate
    self.buttonUpdate = self.___ex.buttonUpdate
    self.txtUpdateNum = self.___ex.txtUpdateNum
    -- 执教经验书货币
    self.btnPlus = self.___ex.btnPlus
    self.txtCredentialNum = self.___ex.txtCredentialNum

    self.notFull_Go = self.___ex.notFull_Go
    self.full_Go = self.___ex.full_Go

    -- 教练头像控制脚本
    self.coachPortraitSpt = nil
end

function CoachBaseInfoView:start()
    self:RegBtnEvent()
end

function CoachBaseInfoView:InitView(coachBaseInfoModel, playerTeamsModel, formationCacheDataModel)
    self.model = coachBaseInfoModel
    self.playerTeamsModel = playerTeamsModel
    self.formationCacheDataModel = formationCacheDataModel

    -- 教练头像
    self:InitCoachPortrait()
    -- 教练升级相关内容显示
    self:InitUpdateDisplay()
    -- 滑动框
    self.scrollView:RegOnItemButtonClick("btnBg", function(itemData) self:OnItemClick(itemData) end)
    self.scrollView:InitView(self.model:GetScrollData())
    -- 阵型
    self.sptFormation:InitView(0, self.model:GetCurrFormationId(), self.model:GetCurrFormationData())
end

-- 教练头像
function CoachBaseInfoView:InitCoachPortrait()
    res.ClearChildren(self.rctPortrait)
    local portraitObj, portraitSpt = res.Instantiate(CoachPortraitPath)
    if portraitObj ~= nil and portraitSpt ~= nil then
        self.coachPortraitSpt = portraitSpt
        portraitObj.transform:SetParent(self.rctPortrait.transform, false)
        portraitObj.transform.localScale = Vector3.one
        portraitObj.transform.localPosition = Vector3.zero
        self:UpdateCoachPortrait()
    end
end

-- 更新教练头像显示
function CoachBaseInfoView:UpdateCoachPortrait()
    if self.coachPortraitSpt ~= nil then
        self.coachPortraitSpt:InitView(self.model:GetCredentialLevel(), self.model:GetStarLevel(), true)
    end
end

-- 升级相关的显示
function CoachBaseInfoView:InitUpdateDisplay()
    -- 下一级品质提示
    local nextLevelName = self.model:GetNextCredentialLevelName()
    local isNotFull = tobool(nextLevelName)
    GameObjectHelper.FastSetActive(self.notFull_Go, isNotFull)
    GameObjectHelper.FastSetActive(self.full_Go, not isNotFull)

    if nextLevelName then
        self.txtNextTip.text = lang.trans("coach_baseInfo_next_tip", nextLevelName)
    else
        self.txtNextTip.text = lang.trans("hero_hall_upgrade_max_level") -- 已满级
    end
    local hadCENum = self.model:GetCurrCENum()
    local needCENum = self.model:GetUpdateNeedCENum()
    self.buttonUpdate.interactable = not self.model:IsCoachMaxLevel() or hadCENum >= needCENum
    if needCENum <= 0 then needCENum = 1 end
    self.txtUpdateNum.text = "x" .. tostring(needCENum)
    self.txtCredentialNum.text = string.formatNumWithUnit(hadCENum)
    -- 进度条
    self.rctProgress.sizeDelta = Vector2(Mathf.Clamp01(hadCENum / needCENum) * PROGRESS_MAX_WIDTH, self.rctProgress.sizeDelta.y)
end

function CoachBaseInfoView:OnEnterScene()
    EventSystem.AddEvent("CoachBaseInfoUpdate_UpdateAfterFormationUpgrade", self, self.UpdateAfterFormationUpgrade)
    EventSystem.AddEvent("CoachBaseInfoUpdate_UpdateAfterTacticUpgrade", self, self.UpdateAfterTacticUpgrade)
end

function CoachBaseInfoView:OnExitScene()
    EventSystem.RemoveEvent("CoachBaseInfoUpdate_UpdateAfterFormationUpgrade", self, self.UpdateAfterFormationUpgrade)
    EventSystem.RemoveEvent("CoachBaseInfoUpdate_UpdateAfterTacticUpgrade", self, self.UpdateAfterTacticUpgrade)
end

function CoachBaseInfoView:RegBtnEvent()
    self.btnIntro:regOnButtonClick(function()
        if self.onBtnIntroClick then
            self.onBtnIntroClick()
        end
    end)

    self.btnUpdate:regOnButtonClick(function()
        if self.onBtnUpdateClick then
            self.onBtnUpdateClick()
        end
    end)

    self.btnPlus:regOnButtonClick(function()
        if self.onBtnCurrencyPlusClick then
            self.onBtnCurrencyPlusClick()
        end
    end)
end

function CoachBaseInfoView:ShowDisplayArea(isShow)
    GameObjectHelper.FastSetActive(self.mainView.gameObject, isShow)
end

function CoachBaseInfoView:RegOnDynamicLoad(func)
    self.infoBarDynParent:RegOnDynamicLoad(func)
end

-- 点击阵型/战术，弹出升级面板
function CoachBaseInfoView:OnItemClick(itemData)
    if self.onItemClick then
        self.onItemClick(itemData)
    end
end

-- 阵型升级后更新
function CoachBaseInfoView:UpdateAfterFormationUpgrade(idx, formationId, newData)
    if self.updateAfterFormationUpgrade then
        self.updateAfterFormationUpgrade(idx, formationId, newData)
    end
end

-- 战术升级后更新
function CoachBaseInfoView:UpdateAfterTacticUpgrade(idx, tacticType, id, newData)
    if self.updateAfterTacticUpgrade then
        self.updateAfterTacticUpgrade(idx, tacticType, id, newData)
    end
end

return CoachBaseInfoView
