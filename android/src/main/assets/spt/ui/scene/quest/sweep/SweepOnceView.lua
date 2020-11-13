local UnityEngine = clr.UnityEngine
local WaitForSeconds = UnityEngine.WaitForSeconds

local SweepBarCtrl = require("ui.controllers.quest.sweep.SweepBarCtrl")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local ItemDetailModel = require("ui.models.itemDetail.ItemDetailModel")
local AssetFinder = require("ui.common.AssetFinder")
local SweepOnceView = class(unity.base)

function SweepOnceView:ctor()
    self.sweepContent = self.___ex.sweepContent
    self.confirmButton = self.___ex.confirmButton
    self.expNum = self.___ex.expNum
    self.debrisObj = self.___ex.debrisObj
    self.nameTxt = self.___ex.nameTxt
    self.countTxt = self.___ex.countTxt
    self.debrisImg = self.___ex.debrisImg
end

local WaitTime = 0.5
function SweepOnceView:InitView(sweepListModel)
    self.sweepListModel = sweepListModel
    self:coroutine(function()
        local sweepBarRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Quest/SweepBar.prefab")
        local sweepListData = sweepListModel:GetListData()
        for index, sweepData in ipairs(sweepListData) do
            SweepBarCtrl.new(nil, sweepData, sweepBarRes, self.sweepContent, WaitTime)
        end
        local sweepTotalData = sweepListModel:GetTotalData()
        self.expNum.text = sweepTotalData.exp and tostring(sweepTotalData.exp.addExp) or "0"
        self:InitDebrisDate()
    end)
end

function SweepOnceView:start()
    self.confirmButton:regOnButtonClick(function()
        self:Close()
    end)
    
end

function SweepOnceView:Close()
    if type(self.closeDialog) == "function" then
        self.closeDialog()
    end
end
    
function SweepOnceView:InitDebrisDate()
    local id = cache.getRequiredEquipId()
    local itemModel = nil
    if id then
        itemModel = ItemDetailModel.new(id)
    else
        return
    end
    local isHasCurrItem = self.sweepListModel:IsHasCurrItem(id)
    if not isHasCurrItem then return end

    self.debrisObj:SetActive(true)
    local need_num = itemModel:GetCompositePieceNum()
    local name = itemModel:GetName()
    local curr_num = itemModel:GetEquipPieceNum()
    self.nameTxt.text = itemModel:GetName()
    self.debrisImg.overrideSprite = AssetFinder.GetEquipIcon(id)

    if tonumber(need_num) == 1 then
        self.countTxt.text = lang.trans("sweepEqsCanWear")
        return
    end
    if need_num <= curr_num then
        self.countTxt.text = lang.trans("sweepEqsCanWear_1")
    else
        self.countTxt.text = lang.trans("sweepDebris", tostring(curr_num), tostring(need_num))
    end
end

function SweepOnceView:onDestroy()
    local playerInfoModel = PlayerInfoModel.new()
    playerInfoModel:UnlockLevelUp()
end

return SweepOnceView
