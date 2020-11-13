local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector3 = UnityEngine.Vector3
local Vector2 = UnityEngine.Vector2
local GameObjectHelper = require("ui.common.GameObjectHelper")

local AssistantCoachSystemBookLView = class(unity.base, "AssistantCoachSystemBookLView")

-- 助理教练教练头像prefab
local PortraitPath = "Assets/CapstonesRes/Game/UI/Scene/Coach/Common/Prefabs/AssistantCoachPortrait.prefab"

function AssistantCoachSystemBookLView:ctor()
    -- 教练头像
    self.rctPortrait = self.___ex.rctPortrait
    -- 教练名字
    self.txtName = self.___ex.txtName
    -- 教练等级
    self.txtLvl = self.___ex.txtLvl
    -- 教练星级
    self.sptStars = self.___ex.sptStars
    -- 更换团队
    self.btnSwitch = self.___ex.btnSwitch
    -- 升级
    self.btnUpdate = self.___ex.btnUpdate
    self.buttonUpdate = self.___ex.buttonUpdate
    self.txtUpdateNum = self.___ex.txtUpdateNum
    self.txtUpdateFull = self.___ex.txtUpdateFull
    self.objUpdateNotFull = self.___ex.objUpdateNotFull
    -- 助理教练上阵
    self.btnSelect = self.___ex.btnSelect
    -- 招募助理教练
    self.btnHire = self.___ex.btnHire
    -- 未上阵助教
    self.infoNone = self.___ex.infoNone

    -- 助理教练Model
    self.acModel = nil
    -- 父界面使用Model，AssistantCoachSystemModel
    self.parentModel = nil
    -- 是否上阵助教
    self.hasAC = false
end

function AssistantCoachSystemBookLView:start()
    self:RegBtnEvent()
end

function AssistantCoachSystemBookLView:RegBtnEvent()
    -- 更换团队
    self.btnSwitch:regOnButtonClick(function()
        if self.onBtnSwitchTeam and type(self.onBtnSwitchTeam) == "function" then
            self.onBtnSwitchTeam()
        end
    end)
    -- 助理教练升级
    self.btnUpdate:regOnButtonClick(function()
        if self.onBtnUpdateClick and type(self.onBtnUpdateClick) == "function" then
            self.onBtnUpdateClick()
        end
    end)
    -- 助理教练上阵
    self.btnSelect:regOnButtonClick(function()
        if self.onBtnSelect and type(self.onBtnSelect) == "function" then
            self.onBtnSelect()
        end
    end)
    -- 雇佣助理教练
    self.btnHire:regOnButtonClick(function()
        if self.onBtnHire and type(self.onBtnHire) == "function" then
            self.onBtnHire()
        end
    end)
end

function AssistantCoachSystemBookLView:InitView(assistantCoachModel, assistantCoachSystemModel, isReadOnly)
    self.acModel = assistantCoachModel
    self.parentModel = assistantCoachSystemModel
    self.hasAC = tobool(self.acModel ~= nil)
    self.isReadOnly = isReadOnly

    self:DisplayArea(self.hasAC)
    self:RefreshView()
end

function AssistantCoachSystemBookLView:RefreshView()
    -- 头像
    self:InitPortrait(self.acModel)
    self:UpdatePortrait(self.acModel)
    if self.hasAC then
        -- 名字
        self.txtName.text = tostring(self.acModel:GetName())
        -- 等级
        self.txtLvl.text = tostring(self.acModel:GetLvl())
        -- 星级
        self.sptStars:InitView(self.acModel:GetQuality())
        -- 升级按钮
        self:InitUpdateBtn(self.acModel)
    else
        self.txtName.text = ""
        self.txtLvl.text = ""
        self.sptStars:InitView(0)
    end
end

function AssistantCoachSystemBookLView:DisplayArea(hasAC)
    GameObjectHelper.FastSetActive(self.txtName.gameObject, hasAC)
    GameObjectHelper.FastSetActive(self.txtLvl.gameObject, hasAC)
    GameObjectHelper.FastSetActive(self.sptStars.gameObject, hasAC)
    for k, v in pairs(self.infoNone) do
        GameObjectHelper.FastSetActive(v.gameObject, not hasAC)
    end
    GameObjectHelper.FastSetActive(self.btnSwitch.gameObject, not self.isReadOnly and hasAC)
    GameObjectHelper.FastSetActive(self.btnUpdate.gameObject, not self.isReadOnly and hasAC)
    GameObjectHelper.FastSetActive(self.btnSelect.gameObject, not self.isReadOnly and not hasAC)
    GameObjectHelper.FastSetActive(self.btnHire.gameObject, not self.isReadOnly and not hasAC)
end

-- 助理教练头像
function AssistantCoachSystemBookLView:InitPortrait(acModel)
    if self.portraitSpt ~= nil then
        self:UpdatePortrait(acModel)
    else
        res.ClearChildren(self.rctPortrait)
        local portraitObj, portraitSpt = res.Instantiate(PortraitPath)
        if portraitObj ~= nil and portraitSpt ~= nil then
            self.portraitSpt = portraitSpt
            portraitObj.transform:SetParent(self.rctPortrait.transform, false)
            portraitObj.transform.localScale = Vector3.one
            portraitObj.transform.localPosition = Vector3.zero
            self:UpdatePortrait(acModel)
        end
    end
end

-- 更新助理教练教练头像显示
function AssistantCoachSystemBookLView:UpdatePortrait(acModel)
    if self.portraitSpt ~= nil then
        self.portraitSpt:InitView(acModel, false, true, false, false, false)
    end
end

-- 升级按钮
function AssistantCoachSystemBookLView:InitUpdateBtn(acModel)
    local isMax = acModel:IsMax()
    local isCoachMax = acModel:IsMax()
    if (isCoachMax and not isMax) or (not isCoachMax and not isMax) then
        -- 教练控制满级 or 未满级
        GameObjectHelper.FastSetActive(self.objUpdateNotFull.gameObject, true)
        GameObjectHelper.FastSetActive(self.txtUpdateFull.gameObject, false)
        self.buttonUpdate.interactable = true
        self.txtUpdateNum.text = "x" .. acModel:GetUpdateAce()
    else
        GameObjectHelper.FastSetActive(self.objUpdateNotFull.gameObject, false)
        GameObjectHelper.FastSetActive(self.txtUpdateFull.gameObject, true)
        self.buttonUpdate.interactable = false
    end
end

function AssistantCoachSystemBookLView:GetTeamIdx()
    return self.hasAC and self.acModel:GetTeamIdx() or 0
end

return AssistantCoachSystemBookLView
