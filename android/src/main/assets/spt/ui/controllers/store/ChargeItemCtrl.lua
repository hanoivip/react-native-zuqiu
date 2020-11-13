local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object

local DialogManager = require("ui.control.manager.DialogManager")
local EventSystem = require("EventSystem")
local ChargeItemModel = require("ui.models.store.ChargeItemModel")
local CustomEvent = require("ui.common.CustomEvent")

local ChargeItemCtrl = class()

function ChargeItemCtrl:ctor(data)
    if type(data) == "table" then
        self.model = ChargeItemModel.new(data)

        local prefab = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Store/ChargeItemBoard.prefab")
        local item = Object.Instantiate(prefab)
        local spt = item:GetComponent(clr.CapsUnityLuaBehav)
        spt:InitView(self.model)
        spt:regOnButtonClick(function (eventData)
            DialogManager.ShowToastByLang("functionNotOpen")
            -- local dialog, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/Store/ChargeConfirm.prefab", "camera", true, true)
            -- dialogcomp.contentcomp:Init(self.model)
        end)
        self.view = spt
    end
end

return ChargeItemCtrl

