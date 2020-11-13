local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CardPasterModel = require("ui.models.cardDetail.CardPasterModel")

local PasterUpgradeResultBoardView = class(unity.base)

function PasterUpgradeResultBoardView:ctor()
    self.btnConfirm = self.___ex.btnConfirm
    self.currentIcon = self.___ex.currentIcon
    self.currentStrengthin = self.___ex.currentStrengthin
    self.name = self.___ex.name
    self.typeName = self.___ex.typeName
    self.titleIcon = self.___ex.titleIcon
    self.ribbon = self.___ex.ribbon
    self.success = self.___ex.success
    self.fail = self.___ex.fail
    self.pasterOriginTrans = self.___ex.pasterOriginTrans
    self.pasterNewTrans = self.___ex.pasterNewTrans
end

function PasterUpgradeResultBoardView:start()
    self.btnConfirm:regOnButtonClick(function()
        self:onBtnConfirm()
    end)
end

function PasterUpgradeResultBoardView:onBtnConfirm()
    self:Close()
end

function PasterUpgradeResultBoardView:Close()
    DialogAnimation.Disappear(self.transform, nil, function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end)
end

function PasterUpgradeResultBoardView:InitView(upgradeResult, originPasterModel, cardResourceCache)
    self.upgradeResult = upgradeResult
    self.originPasterModel = originPasterModel


    local isSuccess = tobool(self.upgradeResult.success)
    if isSuccess then 
        self.titleIcon.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/CardDetail/Images/TrueColor/SkillIcon.png")
        self.ribbon.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Images/CommonTrueColor/Ribbon_1.png")
    else
        self.titleIcon.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/CardDetail/Images/TrueColor/Title_Icon.png")
        self.ribbon.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Images/CommonTrueColor/Ribbon_2.png")
    end
    GameObjectHelper.FastSetActive(self.success, isSuccess)
    GameObjectHelper.FastSetActive(self.fail, not isSuccess)

    local originPasterSpt = self:InstantiatePaster(self.pasterOriginTrans)
    local pasterRes = self:GetPasterRes()
    originPasterSpt:InitView(originPasterModel, cardResourceCache, pasterRes)
    local content = upgradeResult.content
    if type(content) == "table" and next(content) then
        local newPasterModel = CardPasterModel.new()
        local newPasterSpt = self:InstantiatePaster(self.pasterNewTrans)
        newPasterModel:InitWithCache(upgradeResult.content)
        newPasterSpt:InitView(newPasterModel, cardResourceCache, pasterRes)
    end
end

function PasterUpgradeResultBoardView:InstantiatePaster(parentTrans)
    local obj = Object.Instantiate(self:GetPasterCardRes())
    obj.transform:SetParent(parentTrans, false)
    local spt = res.GetLuaScript(obj)
    return spt
end

function PasterUpgradeResultBoardView:GetPasterCardRes()
    if not self.pasterCardRes then 
        self.pasterCardRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Paster/PasterCard.prefab")
    end
    return self.pasterCardRes
end

function PasterUpgradeResultBoardView:GetPasterRes()
    if not self.pasterRes then 
        self.pasterRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Paster/Paster.prefab")
    end
    return self.pasterRes
end


return PasterUpgradeResultBoardView
