local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector3 = clr.UnityEngine.Vector3
local Timer = require('ui.common.Timer')
local DialogManager = require("ui.control.manager.DialogManager")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local ActivityListModel = require("ui.models.activity.ActivityListModel")
local PasterListCtrl = require("ui.controllers.activity.content.pasterSplit.PasterListCtrl")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local StoreModel = require("ui.models.store.StoreModel")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local EventSystem = require("EventSystem")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local ActivityContentBaseCtrl = require("ui.controllers.activity.content.ActivityContentBaseCtrl")
local PasterSplitModel = require("ui.models.activity.PasterSplitModel")

local PasterSplitCtrl = class(ActivityContentBaseCtrl)

function PasterSplitCtrl:InitWithProtocol()
    self.view = self.contentPrefab:GetComponent(clr.CapsUnityLuaBehav)
    self.view.clickPlusSymbol = function() self:OnBtnPlusSymbol() end
    self.view.clickBtnSplit = function(tag) self:OnBtnSplit(tag) end
    self.view.resetCousume = function (func) self:ResetCousume(func) end
    self.playerInfoModel = PlayerInfoModel.new()
    self.isActivityActive = true
    self.selectedPasterModel = {}
    self.pasterSplitModel = self.activityModel
    self:CheckActivityEnd()
    self:InitActTimeTip()
    
    self:InitView(false)
    self:RefreshContent(false)
end

function PasterSplitCtrl:InitView()
    self.view:InitView(self.activityModel)
end

function PasterSplitCtrl:OnBtnPlusSymbol()
    local pasterListCtrl = PasterListCtrl.new()
end

function PasterSplitCtrl:InitActTimeTip()
    local actTime = lang.trans("visit_endInfo")
    self.isActivityActive = self.pasterSplitModel:GetActivityState()
    if self.isActivityActive then
        actTime = lang.trans("cumulative_pay_time", string.convertSecondToMonth(self.pasterSplitModel:GetStartTime()), 
                            string.convertSecondToMonth(self.pasterSplitModel:GetActivityEndTime()))
        self:CheckActivityEnd()
    else
        self:DoIfActivityEnd()
    end
    self.view.residualTime.text = actTime
end

function PasterSplitCtrl:DoIfActivityEnd()
    self:RefreshContent(false)
    self.OnBtnPlusSymbol = function()
        DialogManager.ShowToast(lang.trans("visit_endInfo"))
    end
end

function PasterSplitCtrl:CheckActivityEnd()
    if not self.isActivityActive then return end
    
    local deltaTimeValue = cache.getServerDeltaTimeValue()
    local serverTimeNow = tonumber(os.time()) + tonumber(deltaTimeValue)
    local beforeEndInterval = tonumber(self.pasterSplitModel:GetActivityEndTime()) - serverTimeNow
    if beforeEndInterval <= 0 then
        self.isActivityActive = false
        self:InitActTimeTip()
        return
    end

    if self.countDownTimer ~= nil then self.countDownTimer:Destroy() end
    self.countDownTimer = Timer.new(beforeEndInterval, function(time)
        if time <= 0 then
            self.isActivityActive = false
            self:InitActTimeTip()
        end
    end)
end

function PasterSplitCtrl:OnBtnSplit(tag)
    if not tag then 
        dump("error    tag = nil!!!")
        return
    end

    local residualTime = self.pasterSplitModel:GetResidualTime()
    if tonumber(residualTime) <= 0 then
        DialogManager.ShowToast(lang.trans("pasterSplit_activity_desc4"))
        return
    end

    local selectedCardPasterModel = self.selectedPasterModel.cardPasterModel
    local ptid = selectedCardPasterModel:GetId()
    local pasterWeekOrMonth = self:GetSelectedPasterType(self.selectedPasterModel)
    local splitInfo = self:GetPasterSplitInfo(tag)
    if splitInfo and next(splitInfo) then
        self:RegBtnSplitFunc(tag, splitInfo, ptid, pasterWeekOrMonth)
    else
        self:RegBtnSplitFuncIfDataNotFound(tag)
    end
end

function PasterSplitCtrl:RegBtnSplitFunc(tag, splitInfo, ptid, pasterWeekOrMonth)
    if tag == self.view.splitType.Money then
        self:OnMoneySplit(splitInfo.needCount, splitInfo.pieceNum, ptid, pasterWeekOrMonth)
    elseif tag == self.view.splitType.Diamond then
        self:OnDiamondSplit(splitInfo.needCount, splitInfo.pieceNum, ptid, pasterWeekOrMonth)
    elseif tag == self.view.splitType.BlackDiamond then
        self:OnBlackDiamondSplit(splitInfo.needCount, splitInfo.pieceNum, ptid, pasterWeekOrMonth)
    end
end

function PasterSplitCtrl:RegBtnSplitFuncIfDataNotFound(tag)
    self.view:coroutine(function()
        local tLPasterSplitMaxId = self.pasterSplitModel:GetStaticTableMaxId()
        local staticTableName = self.pasterSplitModel:GetStaticTableName()
        local response = req.getNewDataByTableName(staticTableName, tLPasterSplitMaxId)
        if api.success(response) then
            local staticTable = self.pasterSplitModel:GetStaticTableData()
            local newData = response.val.jsonUpdate[staticTableName]
            for id, v in pairs(newData) do
                staticTable[id] = v
            end

            local selectedCardPasterModel = self.selectedPasterModel.cardPasterModel
            local ptid = selectedCardPasterModel:GetId()
            local pasterWeekOrMonth = self:GetSelectedPasterType(self.selectedPasterModel)
            local splitInfo = self:GetPasterSplitInfo(tag)

            self:RegBtnSplitFunc(tag, splitInfo, ptid, pasterWeekOrMonth)
        end
    end)
end

function PasterSplitCtrl:OnMoneySplit(needCount, pieceNum, ptid, pasterWeekOrMonth)
    local title = lang.trans("tips")
    local titleText = lang.transstr("split_paster")
    local callback = function()
        clr.coroutine(function()
            local respone = req.pasterSplitActivity(ptid, self.view.splitType.Money)
            if api.success(respone) then
                local data = respone.val
                local paster = data.cost.paster

                self:RemovePasterPtidInList(ptid)

                self.pasterSplitModel:ResetPermittedTime(data.p_data)
                self.view:SetTimeAdmtText()
                self.playerInfoModel:SetMoney(self.playerInfoModel:GetMoney() - needCount)
                CongratulationsPageCtrl.new(data.contents)
            end
        end)
    end
    local checkQualificationCallback = function()
        if PlayerInfoModel.new():GetMoney() < needCount then
            self:NotEnoughEuroMessageBox()
            return
        else
            callback()
        end
    end
    local contentText = lang.transstr("pasterSplit_activity_Split", tostring(self:ConvertNumberShow(needCount)), lang.transstr("goldCoin"), pasterWeekOrMonth, tostring(pieceNum))
    DialogManager.ShowConfirmPop(titleText, contentText, checkQualificationCallback)
end

function PasterSplitCtrl:OnDiamondSplit(needCount, pieceNum, ptid, pasterWeekOrMonth)
    local title = lang.trans("tips")
    local titleText = lang.transstr("split_paster")
    local callback = function()
        clr.coroutine(function()
            local respone = req.pasterSplitActivity(ptid, self.view.splitType.Diamond)
            if api.success(respone) then
                local data = respone.val
                local paster = data.cost.paster

                self:RemovePasterPtidInList(ptid)

                self.pasterSplitModel:ResetPermittedTime(data.p_data)
                self.view:SetTimeAdmtText()
                self.playerInfoModel:SetDiamond(self.playerInfoModel:GetDiamond() - needCount)
                CongratulationsPageCtrl.new(data.contents)
            end
        end)
    end
    local checkQualificationCallback = function()
        if PlayerInfoModel.new():GetDiamond() < needCount then            
            local content = lang.trans("store_gacha_tip_1")
            DialogManager.ShowConfirmPop(title, content, function ()
                res.PushDialog("ui.controllers.charge.ChargeAndVIPCtrl")
            end)
            return
        else
            callback()
        end
    end       
    local contentText = lang.transstr("pasterSplit_activity_Split", tostring(self:ConvertNumberShow(needCount)), lang.transstr("diamond"), pasterWeekOrMonth, tostring(pieceNum))
    DialogManager.ShowConfirmPop(titleText, contentText, checkQualificationCallback)
end

function PasterSplitCtrl:OnBlackDiamondSplit(needCount, pieceNum, ptid, pasterWeekOrMonth)
    local title = lang.trans("tips")
    local titleText = lang.transstr("split_paster")
    local callback = function()
        clr.coroutine(function()
            local respone = req.pasterSplitActivity(ptid, self.view.splitType.BlackDiamond)
            if api.success(respone) then
                local data = respone.val
                local paster = data.cost.paster

                self:RemovePasterPtidInList(ptid)

                self.pasterSplitModel:ResetPermittedTime(data.p_data)
                self.view:SetTimeAdmtText()
                self.playerInfoModel:SetBlackDiamond(self.playerInfoModel:GetBlackDiamond() - needCount)
                CongratulationsPageCtrl.new(data.contents)
            end
        end)
    end
    local checkQualificationCallback = function()
        if PlayerInfoModel.new():GetBlackDiamond() < needCount then
            local content = lang.trans("store_gacha_tip_3")
            DialogManager.ShowConfirmPop(title, content, function ()
                res.PushDialog("ui.controllers.charge.ChargeAndVIPCtrl", nil, nil, true)
            end)
            return
        else
            callback()
        end
    end
    local contentText = lang.transstr("pasterSplit_activity_Split", tostring(self:ConvertNumberShow(needCount)), lang.transstr("pasterSplit_activity_coin"), pasterWeekOrMonth, tostring(pieceNum))
    DialogManager.ShowConfirmPop(titleText, contentText, checkQualificationCallback)
end

function PasterSplitCtrl:NotEnoughEuroMessageBox()
    local content = { }
    content.title = lang.trans("tips") 
    content.content = lang.trans("transfer_market_euro") 
    content.button1Text = lang.trans("goto")
    content.onButton1Clicked = function()
        res.PushScene("ui.controllers.store.StoreCtrl", require("ui.models.store.StoreModel").MenuTags.ITEM)   
    end
    local resDlg, dialogcomp = res.ShowDialog('Assets/CapstonesRes/Game/UI/Control/Dialog/GeneralBox.prefab',"camera", true, true)
    dialogcomp.contentcomp:initData(content)   
end

function PasterSplitCtrl:RemovePasterPtidInList(ptid)
    local pastersMap = cache.getPlayerPastersMap()
    local newPastersMap = {}
    local index = nil
    if pastersMap and type(pastersMap) == "table" then
        for k, v in pairs(pastersMap) do
            if tostring(v.ptid) ~= tostring(ptid) then
                newPastersMap[k] = v
            end
        end
        cache.setPlayerPastersMap(newPastersMap)
        EventSystem.SendEvent("PasterSplit_ChangeView", false, nil)
    end
end

function PasterSplitCtrl:EventChangeView(isChange, selectedPasterModel)
    if not self.isActivityActive then
        self:RefreshContent(false)
        return
    end
    self.selectedPasterModel = selectedPasterModel
    self:RefreshContent(isChange, selectedPasterModel)
end

function PasterSplitCtrl:RefreshContent(isChange, selectedPasterModel)
    GameObjectHelper.FastSetActive(self.view.beforeSelect, not isChange)
    GameObjectHelper.FastSetActive(self.view.afterSelect, isChange)
    if isChange then self:DoAfterSelectChange(selectedPasterModel) end
end

function PasterSplitCtrl:DoAfterSelectChange(selectedPasterModel)
    local selectedCardPasterModel = selectedPasterModel.cardPasterModel
    local isMonthPaster = selectedCardPasterModel:IsMonthPaster()
    GameObjectHelper.FastSetActive(self.view.monthPiece, isMonthPaster)
    GameObjectHelper.FastSetActive(self.view.weekPiece, not isMonthPaster)

    self.view.paterPieceView:InitView(selectedCardPasterModel)

    self:InstantiateSelectedPaster(selectedPasterModel)

    self:InitASTextArea(selectedPasterModel)
end

function PasterSplitCtrl:InitASTextArea(selectedPasterModel)
    local selectedCardPasterModel = selectedPasterModel.cardPasterModel
    self.view.pasterNameText.text = selectedCardPasterModel:GetName()

    local splitInfo = self:GetPasterSplitInfo(self.view.splitType.Money)
    if splitInfo and next(splitInfo) then
        self:InitBtnSplitTip(selectedPasterModel)
    else
        self:InitBtnSplitTipIfDataNotFound()
    end
end

function PasterSplitCtrl:InitBtnSplitTip(selectedPasterModel, deadLoop)
    local pasterWeekOrMonth = self:GetSelectedPasterType(selectedPasterModel)
    local pasterPieceName = pasterWeekOrMonth
    self.view.pasterPieceNameText.text = pasterPieceName
    for k, v in pairs(self.view.splitType) do
        local splitInfo = self:GetPasterSplitInfo(v)
        if not splitInfo then
            dump("error:  data obtaining fail!!!!")
            if not deadLoop then
                self:DealWithUnexpected(selectedPasterModel)
            end
            break
        end
        self.view["btnTip" .. v .."Text"].text = pasterPieceName .. lang.transstr("pasterSplit_activity_desc2", splitInfo.pieceNum)
        self.view[v .. "BtnText"].text = "X" .. tostring(self:ConvertNumberShow(splitInfo.needCount))
    end
end

function  PasterSplitCtrl:DealWithUnexpected(selectedPasterModel)
    self.view:coroutine(function()
        local tLPasterSplitMaxId = self.pasterSplitModel:GetStaticTableMaxId()
        local staticTableName = self.pasterSplitModel:GetStaticTableName()
        local response = req.getNewDataByTableName(staticTableName, tLPasterSplitMaxId)
        if api.success(response) then
            local staticTable = self.pasterSplitModel:GetStaticTableData()
            local newData = response.val.jsonUpdate[staticTableName]
            for id, v in pairs(newData) do
                staticTable[id] = v
            end
            
            self:InitBtnSplitTip(selectedPasterModel, true)
        end
    end)
end

function PasterSplitCtrl:ConvertNumberShow(needCount)
    local count = tonumber(needCount)
    return string.formatNumWithUnit(count)
end

function PasterSplitCtrl:InitBtnSplitTipIfDataNotFound()
    self.view:coroutine(function()
        local tLPasterSplitMaxId = self.pasterSplitModel:GetStaticTableMaxId()
        local staticTableName = self.pasterSplitModel:GetStaticTableName()
        local response = req.getNewDataByTableName(staticTableName, tLPasterSplitMaxId)
        if api.success(response) then
            local staticTable = self.pasterSplitModel:GetStaticTableData()
            local newData = response.val.jsonUpdate[staticTableName]
            for id, v in pairs(newData) do
                staticTable[id] = v
            end
            self:InitBtnSplitTip(self.selectedPasterModel)
        end
    end)
end

function PasterSplitCtrl:GetSelectedPasterType(selectedPasterModel)
    local selectedCardPasterModel = selectedPasterModel.cardPasterModel
    local pasterWeekOrMonth = lang.transstr(selectedCardPasterModel:IsMonthPaster() and "paster_piece_month" or "paster_piece_week")
    return pasterWeekOrMonth
end

function PasterSplitCtrl:GetPasterSplitInfo(tag)
    local splitInfo = {}
    local selectedCardPasterModel = self.selectedPasterModel.cardPasterModel
    local pasterType = tonumber(selectedCardPasterModel:GetPasterType())
    local pasterQuality = pasterType == 1 and selectedCardPasterModel:GetPasterQuality() or 0
    local splitPriceList = self.pasterSplitModel:GetSplitPriceList()
    if splitPriceList and next(splitPriceList) then
        local splitTable = splitPriceList[tostring(pasterQuality)]
        if not splitTable then
            dump("cannot find paster quality in table!")
            return
        end

        splitInfo ={
            pieceNum = splitTable[tag .. "Count"],
            needCount = splitTable[tag .. "Price"],
        }
        return splitInfo
    else
        return false
    end
end

function PasterSplitCtrl:InstantiateSelectedPaster(selectedPasterModel)
    local parentTrans = self.view.pasterContainer.transform
    res.ClearChildren(parentTrans)
    local pasterCardRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Activties/PasterSplit/PasterCard.prefab")
    local obj = Object.Instantiate(pasterCardRes)
    obj.transform.localScale = Vector3(1.8, 1.8, 1)
    obj.transform.localPosition = Vector3(5.66, 44.83, 0)
    obj.transform:SetParent(parentTrans, false)
    local spt = res.GetLuaScript(obj)
    spt:SetImgeObjActive(false)
    spt.clickCardPaster = function() self:OnClickCardPaster() end
    local pasterRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Paster/Paster.prefab")
    spt:InitView(selectedPasterModel.cardPasterModel, selectedPasterModel.cardResourceCache, pasterRes)
end

function PasterSplitCtrl:OnClickCardPaster()
    self:OnBtnPlusSymbol()
end

function PasterSplitCtrl:OnEnterScene()
    EventSystem.AddEvent("PasterSplit_ChangeView", self, self.EventChangeView)
    self.view:OnEnterScene()
end

function PasterSplitCtrl:OnExitScene()
    EventSystem.RemoveEvent("PasterSplit_ChangeView", self, self.EventChangeView)
    if self.countDownTimer ~= nil then self.countDownTimer:Destroy() end
    self.view:OnExitScene()
end

return PasterSplitCtrl