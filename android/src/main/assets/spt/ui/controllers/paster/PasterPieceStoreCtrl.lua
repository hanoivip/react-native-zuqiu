local PasterPieceStoreModel = require("ui.models.paster.PasterPieceStoreModel")
local DialogManager = require("ui.control.manager.DialogManager")
local StoreModel = require("ui.models.store.StoreModel")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local PasterPieceStoreCtrl = class(nil, "PasterPieceStoreCtrl")

function PasterPieceStoreCtrl:ctor(content)
    self:Init(content)
    self.pasterPieceStoreModel = PasterPieceStoreModel.new()
    self.view.pasterClick = function(pasterModel) self:OnPasterClick(pasterModel) end
    self.view.exchangePaster = function(pasterModel) self:OnExchangePaster(pasterModel) end
end

function PasterPieceStoreCtrl:Init(content)
    local object, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Paster/PasterStore.prefab")
    object.transform:SetParent(content, false)
    self.view = spt
end

function PasterPieceStoreCtrl:InitView()
    local cacheScrollPos = StoreModel.GetPlayerPasterCacheScrollPos()
    clr.coroutine(function()
        local respone = req.getPasterPieceStore(nil, nil, true)
        if api.success(respone) then 
            local data = respone.val
            self.pasterPieceStoreModel:InitWithProtocol(data)
            local pasterType = StoreModel.GetShowPasterType()
            self.view:InitView(self.pasterPieceStoreModel, cacheScrollPos, pasterType)
            StoreModel.SetPlayerPasterCacheScrollPos(nil)
        end
    end)
end

function PasterPieceStoreCtrl:EnterScene()
end

function PasterPieceStoreCtrl:OnPasterClick(pasterModel)
    StoreModel.SetPlayerPasterCacheScrollPos(self.view.scrollView:getScrollNormalizedPos())
    res.PushDialog("ui.controllers.paster.PasterDetailCtrl", pasterModel)
end

function PasterPieceStoreCtrl:OnExchangePaster(pasterModel)
    local selectPasterId = pasterModel:GetPasterId()
    local composePieceNeed = pasterModel:GetComposePieceNeed() 
    local pasterType = pasterModel:GetPasterType() 
    local pieceNum = self.pasterPieceStoreModel:GetPieceNum(pasterType)
    if pieceNum >= composePieceNeed then
        local callback = function()
            clr.coroutine(function()
                local respone = req.pasterIncorporate(selectPasterId)
                if api.success(respone) then 
                    local data = respone.val
                    if next(data) then 
                        local pasterPiece = data.cost.pasterPiece
                        local typeId = pasterPiece.type
                        local newNum = pasterPiece.num
                        self.pasterPieceStoreModel:ResetPieceNum(typeId, newNum, pasterPiece)
                        self.view:UpdatePieceNum(self.pasterPieceStoreModel)
                        CongratulationsPageCtrl.new(data.contents)
                        EventSystem.SendEvent("PasterPieceExchange", selectPasterId)
                    end
                end
            end)
        end
        local tipTitle = lang.trans("paster_exchange_title")
        local name = pasterModel:GetName()
        local isWeekPaster = pasterModel:IsWeekPaster()
        local typeStr = isWeekPaster and lang.transstr("paster_piece_week") or lang.transstr("paster_piece_month")
        local tipContent = lang.trans("paster_exchange_content", composePieceNeed, typeStr, name)
        self:OnMessageBox(tipTitle, tipContent, callback) 
    else
        DialogManager.ShowToast(lang.trans("paster_piece_not_enough"))
    end
end

function PasterPieceStoreCtrl:OnMessageBox(titleText, contentText, callback) 
    local content = { }
    content.title = titleText
    content.content = contentText
    content.button1Text = lang.trans("cancel")
    content.button2Text = lang.trans("confirm")
    content.onButton2Clicked = function()
        callback()
    end
    local resDlg, dialogcomp = res.ShowDialog('Assets/CapstonesRes/Game/UI/Control/Dialog/MessageBox.prefab', 'overlay', true, true, nil, nil, 10000)
    dialogcomp.contentcomp:initData(content)
end

function PasterPieceStoreCtrl:ShowPageVisible(isShow)
    self.view:ShowPageVisible(isShow)
end

return PasterPieceStoreCtrl
