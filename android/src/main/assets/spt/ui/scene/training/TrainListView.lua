local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local ButtonColorConfig = require("ui.common.ButtonColorConfig")
local TrainType = require("training.TrainType")
local PlayerCardModel = require("ui.models.cardDetail.PlayerCardModel")
local TrainListView = class(unity.base)

function TrainListView:ctor()
    self.close = self.___ex.close
    self.train = self.___ex.train
    self.trainButton = self.___ex.trainButton
    self.sweep = self.___ex.sweep
    self.sweepButton = self.___ex.sweepButton
    self.scroll = self.___ex.scroll
    self.trainPlayerFrame = self.___ex.trainPlayerFrame
    self.maxSkillHint = self.___ex.maxSkillHint
    self.grayText = self.___ex.grayText
    self.goldText = self.___ex.goldText
    self.trainPlayerImage = self.___ex.trainPlayerImage
    self.trainTitle = self.___ex.trainTitle
    self.hintText = self.___ex.hintText
    self.trainDesc = self.___ex.trainDesc
    self.board = self.___ex.board
    self.sortMenuView = self.___ex.sortMenuView
    self.posText = self.___ex.posText
    self.btnSearch = self.___ex.btnSearch
    self.posDescTxt = self.___ex.posDescTxt

    -- scrollRectSameSize 的注册方法需要提前执行
    self.scroll:regOnCreateItem(function(scrollSelf, index)
        if type(self.onScrollCreateItem) == "function" then
            return self.onScrollCreateItem(scrollSelf, index)
        end
    end)
    self.scroll:regOnResetItem(function(scrollSelf, spt, index)
        if type(self.onScrollResetItem) == "function" then
            return self.onScrollResetItem(scrollSelf, spt, index)
        end
    end)
end

function TrainListView:start()
    self.trainButton.interactable = false
    self.sweepButton.interactable = false
    GameObjectHelper.FastSetActive(self.grayText.gameObject, true)
    GameObjectHelper.FastSetActive(self.goldText.gameObject, false)

    self.sweep:onPointEventHandle(false)
    self.train:onPointEventHandle(false)
    GameObjectHelper.FastSetActive(self.maxSkillHint.gameObject, false)

    self.close:regOnButtonClick(function()
        DialogAnimation.Disappear(self.transform, self.canvasGroup, function()
            if type(self.closeDialog) == "function" then
                self.closeDialog()
            end
        end)
    end)
    self.train:regOnButtonClick(function()
        if type(self.clickStart) == "function" then
            self.clickStart()
        end
    end)
    self.sweep:regOnButtonClick(function ()
        if type(self.sweepCallback) == "function" then
            self.sweepCallback()
        end
    end)
    self.btnSearch:regOnButtonClick(function()
        self:OnBtnSearch()
    end)
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function TrainListView:InitView(trainType)
    local trainTypeGo = self.trainPlayerImage:Find(tostring(trainType)).gameObject
    GameObjectHelper.FastSetActive(trainTypeGo, true)

    if #self.scroll.itemDatas == 0 then
        GameObjectHelper.FastSetActive(self.hintText, true)
    else
        GameObjectHelper.FastSetActive(self.hintText, false)
    end
    if trainType == TrainType.SHOOT then
        self.posDescTxt.text = lang.trans("training_shooter")
        self.trainDesc.text = lang.trans("training_desc", clr.unwrap(lang.trans("training_shooter")))
    elseif trainType == TrainType.DRIBBLE then
        self.posDescTxt.text = lang.trans("training_dribble")
        self.trainDesc.text = lang.trans("training_desc", clr.unwrap(lang.trans("training_dribble")))
    elseif trainType == TrainType.DEFEND then
        self.posDescTxt.text = lang.trans("training_defend")
        self.trainDesc.text = lang.trans("training_desc", clr.unwrap(lang.trans("training_defend")))
    elseif trainType == TrainType.GK then
        self.posDescTxt.text = lang.trans("training_gk")
        self.trainDesc.text = lang.trans("training_desc", clr.unwrap(lang.trans("training_gk")))
    elseif trainType == TrainType.BRAIN then
        self.posDescTxt.text = ""
        self.trainDesc.text = lang.trans("training_desc", "")
    end
end

function TrainListView:SetTrainPlayer(cardModel, pcid)
    GameObjectHelper.FastSetActive(self.trainPlayerImage.gameObject, false)
    GameObjectHelper.FastSetActive(self.trainPlayerFrame.gameObject, true)
    if not self.trainPlayer then
        local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Training/CardFrame.prefab")
        obj.transform:SetParent(self.trainPlayerFrame.transform, false)
        self.trainPlayer = spt
    end
    self.trainPlayer:InitView(PlayerCardModel.new(pcid), true)
    if cardModel:IsSkillLevelMax() then
        self.trainButton.interactable = false
        GameObjectHelper.FastSetActive(self.maxSkillHint.gameObject, true)
    else
        self.trainButton.interactable = true
        GameObjectHelper.FastSetActive(self.maxSkillHint.gameObject, false)
    end
    self.sweepButton.interactable = true
    GameObjectHelper.FastSetActive(self.grayText.gameObject, false)
    GameObjectHelper.FastSetActive(self.goldText.gameObject, true)

    self.train:onPointEventHandle(true)
    self.sweep:onPointEventHandle(true)
end

function TrainListView:OnBtnSearch()
    if self.clickSearch then
        self.clickSearch()
    end
end

function TrainListView:ClearChoosePlayer()
    GameObjectHelper.FastSetActive(self.grayText.gameObject, true)
    GameObjectHelper.FastSetActive(self.trainPlayerImage.gameObject, false)
    GameObjectHelper.FastSetActive(self.trainPlayerFrame.gameObject, false)
end

function TrainListView:SetSortTxt(isSelected)
    self.posText.text = isSelected and lang.trans("pos_be_selected_title") or lang.trans("cardIndex_select")
end

return TrainListView
