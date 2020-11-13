local ItemsMapModel = require("ui.models.ItemsMapModel")
local UnsavedCardModel = require("ui.models.cardDetail.UnsavedCardModel")
local DialogManager = require("ui.control.manager.DialogManager")
local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
local CardPowerCtrl = require("ui.controllers.cardDetail.CardPowerCtrl")
local TrainPageCtrl = class(nil, "TrainPageCtrl")

local function ShowTipDialog(title, text)
    DialogManager.ShowAlertPopByLang(title, text, function() end)
end

function TrainPageCtrl:ctor(view, content)
    self:Init(content)
end

function TrainPageCtrl:EnterScene()
end

function TrainPageCtrl:ExitScene()
end

function TrainPageCtrl:Init(content)
    local pageObject, pageSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/CardDetail/TrainPage.prefab")
    pageObject.transform:SetParent(content, false)
    self.pageView = pageSpt
    self.itemsMapModel = ItemsMapModel.new()
    self.playerCardsMapModel = PlayerCardsMapModel.new()
    self.isTrain = false

    self.pageView.clickBreak = function()
        if self.isTrain or not self.cardModel:IsOperable() then 
            return
        elseif not self.cardModel:IsTrainOpen() then 
            DialogManager.ShowToast(lang.trans("trainFailTip"))
        else
            if self.itemsMapModel:GetItemNum(1) > 0 then
                clr.coroutine(function()
                    local response = req.cardAdvance(self.cardModel:GetPcid())
                    if api.success(response) then
                        local data = response.val
                        if data.cost then
                            self.itemsMapModel:ResetItemNum(data.cost.id, data.cost.num)
                        end
                        local unsavedCardModel = UnsavedCardModel.new(data.card)

                        self.pageView:UpdateUnsavedAdvanceResult(unsavedCardModel, self.itemsMapModel, self.cardModel)
                        self.isTrain = true
                    end
                end)
            else
                DialogManager.ShowToast(lang.trans("no_train_item"))
            end
        end
    end
    self.pageView.clickSave = function()
        clr.coroutine(function()
            local response = req.cardAdvanceConfirm(self.cardModel:GetPcid())
            if api.success(response) then
                local data = response.val
                self.playerCardsMapModel:ResetCardData(data.card.pcid, data.card)
            end
        end)
    end
    self.pageView.clickCancel = function()
        self:InitView(self.cardDetailModel)
    end
    self.pageView.clickIntellect = function()
        local cardModel = self.cardDetailModel:GetCardModel()
        if not cardModel:IsOperable() then 
            return 
        end
        res.PushDialog("ui.controllers.cardDetail.TrainIntellectCtrl", self.cardDetailModel, self.itemsMapModel)
    end
end

function TrainPageCtrl:InitView(cardDetailModel)
    self.cardDetailModel = cardDetailModel
    self.cardModel = cardDetailModel:GetCardModel()
    self.pageView:InitView(cardDetailModel, self.itemsMapModel)
    self.isTrain = false
end

function TrainPageCtrl:ShowPageVisible(isVisible)
    self.pageView:ShowPageVisible(isVisible)
end

return TrainPageCtrl
