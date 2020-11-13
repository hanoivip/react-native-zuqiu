local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local MedalSplitBoardView = class(unity.base)

function MedalSplitBoardView:ctor()
    self.btnConfirm = self.___ex.btnConfirm
    self.close = self.___ex.close
    self.qualityArea = self.___ex.qualityArea
    self.qualityMedalMap = {}
    self.selectQuality = {}
end

function MedalSplitBoardView:start()
    self.btnConfirm:regOnButtonClick(function()
        self:OnBtnConfirm()
    end)

    self.close:regOnButtonClick(function()
        self:Close()
    end)

    DialogAnimation.Appear(self.transform)
end

function MedalSplitBoardView:Close()
    DialogAnimation.Disappear(self.transform, nil, function()
        if type(self.closeDialog) == "function" then
            self.closeDialog()
        end
    end)
end

function MedalSplitBoardView:OnBtnConfirm()
    self:ClickConfirm()
end

function MedalSplitBoardView:ClickConfirm()
    if self.clickConfirm then
        self.clickConfirm(self.selectQuality)
    end
end

function MedalSplitBoardView:ClickMedalQuality(quality)
    local currentItemBar = self.qualityMedalMap[tostring(quality)]
    if self.selectQuality[tostring(quality)] then 
        self.selectQuality[tostring(quality)] = nil
        currentItemBar:ChangeState(false)
    else
        self.selectQuality[tostring(quality)] = true
        currentItemBar:ChangeState(true)
    end
end

function MedalSplitBoardView:InitView(medalListModel)
    local medalPrefab = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Medal/Prefab/MedalQualityBar.prefab")
    local splitQualityMap = medalListModel:GetSplitQuality()
    for i, quality in ipairs(splitQualityMap) do
        local medalQualityObject = Object.Instantiate(medalPrefab)
        local spt = res.GetLuaScript(medalQualityObject)
        medalQualityObject.transform:SetParent(self.qualityArea, false)
        local qualitySymbol = medalListModel:GetQualityDesc(quality)
        local desc = lang.transstr("medal_quality", qualitySymbol)
        spt:InitView(desc, true)
        spt.clickMedal = function() self:ClickMedalQuality(quality) end
        self.qualityMedalMap[tostring(quality)] = spt
    end
end

return MedalSplitBoardView
