local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Image = UnityEngine.UI.Image
local TeamLogoModel = require("ui.models.common.TeamLogoModel")
local AssetFinder = require("ui.common.AssetFinder")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local TeamLogoCtrl = class()

function TeamLogoCtrl:ctor(view, parent)
    if view then
        self.view = view
    else
        self:CreateView(parent)
    end
end

function TeamLogoCtrl:CreateView(parent)
    local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Team/Prefab/TeamLogo.prefab")
    if parent then 
        obj.transform:SetParent(parent.transform, false)
    end
    self.view = spt
end

function TeamLogoCtrl:Init(data, isShowBase)
    self.model = TeamLogoModel.new(data)
    self.view:InitView(self.model, isShowBase)
end

function TeamLogoCtrl:PlayAppearAnimationWithImageOnly()
    self.view:PlayAppearAnimationWithImageOnly()
end

function TeamLogoCtrl:PlayAppearAnimation()
    self.view:PlayAppearAnimation()
end

function TeamLogoCtrl:PlayDisappearAnimation()
    self.view:PlayDisappearAnimation()
end

function TeamLogoCtrl:IsUserDefined()
    return self.model:IsUserDefined()
end

function TeamLogoCtrl:SetBoardId(id)
    if not self:IsUserDefined() then return end
    self.model:SetBoardId(id)
    self.view:SetBoard(id)
end

function TeamLogoCtrl:SetBorderId(id)
    if not self:IsUserDefined() then return end
    self.model:SetBorderId(id)
    self.view:SetBorder(id)
end

function TeamLogoCtrl:SetIconId(id)
    if not self:IsUserDefined() then return end
    self.model:SetIconId(id)
    self.view:SetIcon(id)
end

function TeamLogoCtrl:SetRibbonId(id)
    if not self:IsUserDefined() then return end
    self.model:SetRibbonId(id)
    self.view:SetRibbon(id)
end

function TeamLogoCtrl:SetBoardColorId(id)
    if not self:IsUserDefined() then return end
    self.model:SetBoardColorId(id)
    self.view:SetBoardColor(self.model:GetBoardColorRed(), self.model:GetBoardColorGreen(), self.model:GetBoardColorBlue())
end

function TeamLogoCtrl.BuildTeamLogo(teamLogo, logoData)
    local teamLogoTrans = teamLogo.transform

    res.ClearChildren(teamLogoTrans)
    if type(logoData) == "table" then
        teamLogo.enabled = false
        local teamLogoCtrl = TeamLogoCtrl.new(nil, teamLogoTrans)
        teamLogoCtrl:Init(PlayerInfoModel.TransTeamLogoData(logoData))
    else
        teamLogo.enabled = true
        teamLogo.overrideSprite = AssetFinder.GetTeamIcon(logoData)
    end
end

return TeamLogoCtrl
