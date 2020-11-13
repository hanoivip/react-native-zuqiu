local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local SloganShopDialog = class(unity.base)

function SloganShopDialog:ctor()
--------Start_Auto_Generate--------
    self.titleTxt = self.___ex.titleTxt
    self.contentTrans = self.___ex.contentTrans
    self.closeBtnSpt = self.___ex.closeBtnSpt
--------End_Auto_Generate----------
    self.itemObjPath = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Dialog/Shop/AdventureStoreItem.prefab"
    self.itemSptMap = {}
end

function SloganShopDialog:start()
	DialogAnimation.Appear(self.transform)
    self.closeBtnSpt:regOnButtonClick(function()
        self:Close()
    end)
end

function SloganShopDialog:Close()
    DialogAnimation.Disappear(self.transform, nil, function() self.closeDialog() end)
end

function SloganShopDialog:InitView(eventModel)
    self.eventModel = eventModel
    self.titleTxt.text = eventModel:GetEventName()

    local storeList = eventModel:GetStoreList()
    local itemObj = res.LoadRes(self.itemObjPath)
    for index, itemData in ipairs(storeList) do
        local id = itemData.id
        local spt = self.itemSptMap[id]
        if not spt then
            local o = Object.Instantiate(itemObj)
            o.transform:SetParent(self.contentTrans, false)
            spt = res.GetLuaScript(o)
            self.itemSptMap[id] = spt
        end
        spt:InitView(itemData)
        spt.buyClick = function()
            if self.buyClick then
                self.buyClick(itemData)
            end
        end
    end
end

return SloganShopDialog
