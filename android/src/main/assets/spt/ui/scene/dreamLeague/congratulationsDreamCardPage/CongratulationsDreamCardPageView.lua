local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local DreamLeagueCardHelper = require("ui.scene.dreamLeague.DreamLeagueCardHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CongratulationsDreamCardPageView = class(unity.base)
function CongratulationsDreamCardPageView:ctor()
    self.scrollParent = self.___ex.scrollParent
    self.sellBtn = self.___ex.sellBtn
    self.close = self.___ex.close
end

function CongratulationsDreamCardPageView:InitView(congratulationsDreamCardPageModel)
    self.model = congratulationsDreamCardPageModel
    self.sellBtn:regOnButtonClick(function()
        self:OnBtnSell()
    end)
    self.close:regOnButtonClick(function()
        self:Close()
    end)
    self:InitScroll()
    DialogAnimation.Appear(self.transform)
end

function CongratulationsDreamCardPageView:Close()
    DialogAnimation.Disappear(self.transform, nil, function()
        if type(self.closeDialog) == "function" then
            self.closeDialog()
        end
    end)
end

function CongratulationsDreamCardPageView:OnBtnSell()
    if self.clickSell then
        self.clickSell()
    end
end

function CongratulationsDreamCardPageView:InitScroll()
    res.ClearChildren(self.scrollParent)
    local allCards = self.model:GetAllCards()
    local cardNum = #allCards
    if cardNum > 0 then
        local path = "Assets/CapstonesRes/Game/UI/Scene/DreamLeague/CongratulationsDreamCardPage/CongratulateCard.prefab"
        for i,v in ipairs(allCards) do
            local prefab, spt = res.Instantiate(path)
            prefab.transform:SetParent(self.scrollParent, false)
            spt:InitView(v, self.clickSelect)
        end
    else
        self:Close()
    end
end

return CongratulationsDreamCardPageView
