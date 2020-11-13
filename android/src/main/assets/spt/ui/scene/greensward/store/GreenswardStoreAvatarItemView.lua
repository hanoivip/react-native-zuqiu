local UnityEngine = clr.UnityEngine
local Vector3 = UnityEngine.Vector3
local GameObjectHelper = require("ui.common.GameObjectHelper")
local GreenswardItemModel = require("ui.models.greensward.item.GreenswardItemModel")
local GreenswardItemType = require("ui.models.greensward.item.configType.GreenswardItemType")

local GreenswardStoreAvatarItemView = class(unity.base, "GreenswardStoreAvatarItemView")

local avatarPath = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Avatar/GreenswardAvatar.prefab"

function GreenswardStoreAvatarItemView:ctor()
    self.rctAvatar = self.___ex.rctAvatar
    self.txtName = self.___ex.txtName
    self.imgPurchased = self.___ex.imgPurchased
    self.imgSelected = self.___ex.imgSelected
    self.btnClick = self.___ex.btnClick

    self.avatarSpt = nil
end

function GreenswardStoreAvatarItemView:start()
end

function GreenswardStoreAvatarItemView:InitView(greenswardStoreItemModel, currAvatar)
    self.storeItemModel = greenswardStoreItemModel or {}
    local contents = self.storeItemModel:GetContents()
    if table.isEmpty(contents) or table.isEmpty(contents.advItem) then return end

    local advItem = contents.advItem
    for k, v in ipairs(advItem) do
        self.itemModel = GreenswardItemModel.new(v.id, v.num)
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

        self.txtName.text = tostring(self.itemModel:GetName())
        self:SetSelected(self.storeItemModel:GetSelected())
        self.storeItemModel:SetCorrelationItemModel(self.itemModel)
        break
    end
    self:SetPurchased(self.storeItemModel:GetBought() > 0)
end

function GreenswardStoreAvatarItemView:SetPurchased(flag)
    self.isPurchased = flag
    GameObjectHelper.FastSetActive(self.imgPurchased.gameObject, flag)
end

function GreenswardStoreAvatarItemView:SetSelected(flag)
    self.isSelected = flag
    GameObjectHelper.FastSetActive(self.imgSelected.gameObject, flag)
end

return GreenswardStoreAvatarItemView
