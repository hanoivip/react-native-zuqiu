local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local FreeShoppingCartRewardReviewView = class()

function FreeShoppingCartRewardReviewView:ctor()
--------Start_Auto_Generate--------
    self.closeBtn = self.___ex.closeBtn
    self.contentTrans = self.___ex.contentTrans
--------End_Auto_Generate----------
    self.itemPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/FreeShoppingCart/FreeShoppingCartRewardReviewItem.prefab"
end

function FreeShoppingCartRewardReviewView:start()
    self.closeBtn:regOnButtonClick(function()
        self.closeDialog()
    end)
end

function FreeShoppingCartRewardReviewView:InitView(reviewData)
    local itemRes = res.LoadRes(self.itemPath)
    for i, v in pairs(reviewData) do
        local obj = Object.Instantiate(itemRes)
        obj.transform:SetParent(self.contentTrans, false)
        local spt = obj:GetComponent("CapsUnityLuaBehav")
        spt:InitView(v)
    end
end

return FreeShoppingCartRewardReviewView
