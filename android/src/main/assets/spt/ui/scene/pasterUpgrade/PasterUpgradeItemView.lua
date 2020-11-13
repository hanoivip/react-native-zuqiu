local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local DialogManager = require("ui.control.manager.DialogManager")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local PasterUpgradeItemView = class(unity.base)

function PasterUpgradeItemView:ctor()
    self.pasterParentTrans = self.___ex.pasterParentTrans
    self.selectGo = self.___ex.selectGo
    self.selectBtn = self.___ex.selectBtn
end

function PasterUpgradeItemView:start()
    EventSystem.AddEvent("PasterUpgrade_OnSelect", self, self.OnSelect)
    self.selectBtn:regOnButtonClick(function ()
        self:OnSelectClick()
    end)
end

function PasterUpgradeItemView:GetPasterCardRes()
    if not self.pasterCardRes then 
        self.pasterCardRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Paster/PasterCard.prefab")
    end
    return self.pasterCardRes
end

function PasterUpgradeItemView:GetPasterRes()
    if not self.pasterRes then 
        self.pasterRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Paster/Paster.prefab")
    end
    return self.pasterRes
end

function PasterUpgradeItemView:InstantiatePaster(cardPasterModel)
    if not self.pasterCardSpt then
        local obj = Object.Instantiate(self:GetPasterCardRes())
        obj.transform:SetParent(self.pasterParentTrans, false)
        self.pasterCardSpt = res.GetLuaScript(obj)
    end
    local pasterRes = self:GetPasterRes()
    self.pasterCardSpt:InitView(cardPasterModel, self.cardResourceCache, pasterRes)
end

function PasterUpgradeItemView:InitView(cardPasterModel, cardResourceCache, selectedMap)
    self.cardResourceCache = cardResourceCache
    self.cardPasterModel = cardPasterModel
    self.selectedMap = selectedMap
    self:InstantiatePaster(cardPasterModel)
    self:OnSelect(selectedMap)
end

function PasterUpgradeItemView:OnSelect(selectedMap)
    local isChoose = self:CheckIsChoose()
    GameObjectHelper.FastSetActive(self.selectGo, isChoose)
end

function PasterUpgradeItemView:OnSelectClick()
    local isChoose = self:CheckIsChoose()
    if isChoose then
        GameObjectHelper.FastSetActive(self.selectGo, false)
        EventSystem.SendEvent("PasterUpgrade_UnselectPaster", self.cardPasterModel)
    else
        local isHasEmpty = self:CheckIsHasEmpty()
        if isHasEmpty then
            EventSystem.SendEvent("PasterUpgrade_SelectPaster", self.cardPasterModel)
            GameObjectHelper.FastSetActive(self.selectGo, true)
        else
            DialogManager.ShowToastByLang("dream_select_full")
        end
    end
end

function PasterUpgradeItemView:CheckIsChoose()
    local ptid = self.cardPasterModel:GetId()
    for i,v in ipairs(self.selectedMap) do
        if v == ptid then
           return true
        end 
    end
    return false
end

function PasterUpgradeItemView:CheckIsHasEmpty()
    for i,v in ipairs(self.selectedMap) do
        if not v then
           return true
        end 
    end
    return false
end

function PasterUpgradeItemView:onDestroy()
    EventSystem.RemoveEvent("PasterUpgrade_OnSelect", self, self.OnSelect)
end

function PasterUpgradeItemView:UpdateItemIndex(index)

end

return PasterUpgradeItemView
