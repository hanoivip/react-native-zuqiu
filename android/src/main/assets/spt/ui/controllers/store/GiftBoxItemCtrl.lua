local Object = clr.UnityEngine.Object

local GiftBoxModel = require("ui.models.store.GiftBoxModel")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local GiftBoxItemCtrl = class(BaseCtrl, "GiftBoxItemCtrl")

function GiftBoxItemCtrl:ctor(data, isBufeng, isClickShow)
    if type(data) == "table" then
        self.model = GiftBoxModel.new()
        self.model:Init(data)
        local prefab = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Store/GiftBoxItem.prefab")
        local item = Object.Instantiate(prefab)
        local spt = item:GetComponent(clr.CapsUnityLuaBehav)
        spt:InitView(self.model, isBufeng, isClickShow)
        self.view = spt
    end
end

return GiftBoxItemCtrl
