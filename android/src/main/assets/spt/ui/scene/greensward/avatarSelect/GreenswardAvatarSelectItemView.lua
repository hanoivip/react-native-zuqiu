local UnityEngine = clr.UnityEngine
local Vector3 = UnityEngine.Vector3
local GameObjectHelper = require("ui.common.GameObjectHelper")
local GreenswardItemType = require("ui.models.greensward.item.configType.GreenswardItemType")

local GreenswardAvatarSelectItemView = class(unity.base, "GreenswardAvatarSelectItemView")

local avatarPath = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Avatar/GreenswardAvatar.prefab"

function GreenswardAvatarSelectItemView:ctor()
    self.rctAvatar = self.___ex.rctAvatar
    self.txtName = self.___ex.txtName
    self.imgSelected = self.___ex.imgSelected
    self.btnClick = self.___ex.btnClick

    self.avatarSpt = nil
end

function GreenswardAvatarSelectItemView:start()
end

function GreenswardAvatarSelectItemView:InitView(greenswardItemModel)
    self.itemModel = greenswardItemModel

    local itemType = self.itemModel:GetItemType()
    local logoId = nil
    local frameId = nil
    if itemType == GreenswardItemType.Logo then
        self.rctAvatar.localScale = Vector3(0.9, 0.9, 0.9)
        logoId = self.itemModel:GetPicIndex()
    elseif itemType == GreenswardItemType.Frame then
        self.rctAvatar.localScale = Vector3(0.7, 0.7, 0.7)
        frameId = self.itemModel:GetPicIndex()
    end
    -- 实例化头像
    if self.avatarSpt ~= nil then
        self.avatarSpt:InitView(logoId, frameId)
    else
        res.ClearChildren(self.rctAvatar.transform)
        local obj, spt = res.Instantiate(avatarPath)
        if obj ~= nil and spt ~= nil then
            obj.transform:SetParent(self.rctAvatar.transform, false)
            obj.transform.localScale = Vector3.one
            obj.transform.localPosition = Vector3.zero
            self.avatarSpt = spt
            self.avatarSpt:InitView(logoId, frameId)
        end
    end

    if itemType == GreenswardItemType.Logo then
        self.avatarSpt:SetLogoScale(1)
    elseif itemType == GreenswardItemType.Frame then
        self.avatarSpt:SetLogoScale()
    end

    self:SetSelected(self.itemModel:GetSelected())
    self:SetOwn(self.itemModel:GetOwnNum() > 0)
end

function GreenswardAvatarSelectItemView:SetOwn(flag)
    self.hasOwn = flag
    if self.avatarSpt then
        self.avatarSpt:SetOwn(self.hasOwn)
    end
end

function GreenswardAvatarSelectItemView:SetSelected(flag)
    self.isSelected = flag
    GameObjectHelper.FastSetActive(self.imgSelected.gameObject, flag)
end

return GreenswardAvatarSelectItemView
