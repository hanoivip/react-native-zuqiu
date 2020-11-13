local UnityEngine = clr.UnityEngine
local UI = UnityEngine.UI
local Image = UI.Image
local Sprite = UnityEngine.Sprite
local Canvas = UnityEngine.Canvas
local Object = UnityEngine.Object

local AssetFinder = require("ui.common.AssetFinder")
local PrefabCache = require("ui.scene.match.overlay.PrefabCache")
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local MatchInfoModel = require("ui.models.MatchInfoModel")
local SkillItemModel = require("ui.models.common.SkillItemModel")

local PlayerNameSkillIconView = class(unity.base)

function PlayerNameSkillIconView:ctor()
    self.icon = self.___ex.icon
    self.nameTxt = self.___ex.name
    self.markedIcon = self.___ex.markedIcon
end

function PlayerNameSkillIconView:InitView(skillID, skillIcon, isMarked)
    if skillIcon == nil then
        skillIcon = AssetFinder.GetMatchSkillIcon(skillID)
    end
    if skillIcon == nil or skillIcon == clr.null then
        self:SetActive(false)
    else
        local skillItemModel = SkillItemModel.new()
        skillItemModel:InitByID(skillID)
        self.icon.overrideSprite = skillIcon
        self.nameTxt.text = skillItemModel:GetName()
        self:SetActive(true)

        self.markedIcon:SetActive(isMarked)
    end
end

function PlayerNameSkillIconView:SetActive(isActive)
    self.gameObject:SetActive(isActive)
end

return PlayerNameSkillIconView
