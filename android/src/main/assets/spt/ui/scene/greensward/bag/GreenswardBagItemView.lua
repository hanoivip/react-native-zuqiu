local UnityEngine = clr.UnityEngine
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local GreenswardBagItemView = class(unity.base, "GreenswardBagItemView")

local itemPath = "Assets/CapstonesRes/Game/UI/Common/Part/AdventureItemBox.prefab"

function GreenswardBagItemView:ctor()
    -- 物品容器
    self.rct = self.___ex.rct
    -- 点击
    self.click = self.___ex.click
    -- 选中
    self.imgSelect = self.___ex.imgSelect

    self.itemSpt = nil
end

function GreenswardBagItemView:start()
end

function GreenswardBagItemView:InitView(greenswardItemModel)
    if self.itemSpt == nil then
        res.ClearChildren(self.rct.transform)
        local obj, spt = res.Instantiate(itemPath)
        if obj and spt then
            obj.transform:SetParent(self.rct.transform, false)
            self.itemSpt = spt
        end
    end
    local id = greenswardItemModel:GetId()
    self.itemSpt:InitView(greenswardItemModel, id, true, true, false)
    GameObjectHelper.FastSetActive(self.imgSelect.gameObject, greenswardItemModel:GetSelected())
end

return GreenswardBagItemView
