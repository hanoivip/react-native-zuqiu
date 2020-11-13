local UnityEngine = clr.UnityEngine
local Vector3 = UnityEngine.Vector3
local GameObjectHelper = require("ui.common.GameObjectHelper")

local AssistantCoachLibraryItemView = class(unity.base, "AssistantCoachLibraryItemView")

local PortraitPath = "Assets/CapstonesRes/Game/UI/Scene/Coach/Common/Prefabs/AssistantCoachPortrait.prefab"

function AssistantCoachLibraryItemView:ctor()
    -- 头像
    self.rctPortrait = self.___ex.rctPortrait
    -- 点击蒙版
    self.btnClick = self.___ex.btnClick
    -- 是否已加入助理教练团队
    self.imgInTeam = self.___ex.imgInTeam

    -- 助理教练头像脚本
    self.portraitSpt = nil
end

function AssistantCoachLibraryItemView:start()
end

function AssistantCoachLibraryItemView:InitView(acModel, assistantCoachLibraryModel)
    self.acModel = acModel
    self.aclModel = assistantCoachLibraryModel
    self:InitPortrait(acModel)
    self:SetChosen(self.aclModel:GetChoosedAcid() == acModel:GetId())
    GameObjectHelper.FastSetActive(self.imgInTeam.gameObject, acModel:IsInTeam())
end

-- 初始化助理教练头像
function AssistantCoachLibraryItemView:InitPortrait(acModel)
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
function AssistantCoachLibraryItemView:UpdatePortrait(acModel)
    if self.portraitSpt ~= nil then
        self.portraitSpt:InitView(acModel)
    end
end

function AssistantCoachLibraryItemView:SetChosen(isChosen)
    if self.portraitSpt then
        self.portraitSpt:DisplayBg(isChosen)
    end
end

return AssistantCoachLibraryItemView
