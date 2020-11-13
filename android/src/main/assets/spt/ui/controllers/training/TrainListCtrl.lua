local TrainType = require("training.TrainType")
local TrainData = require("training.TrainData")
local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
local PlayerCardModel = require("ui.models.cardDetail.PlayerCardModel")
local PlayerTeamsModel = require("ui.models.PlayerTeamsModel")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local DialogManager = require("ui.control.manager.DialogManager")
local SweepResultCtrl = require("ui.controllers.training.SweepResultCtrl")
local TargetPlayerChooseModel = require("ui.models.store.TargetPlayerChooseModel")
local CardIndexViewModel = require("ui.models.cardIndex.CardIndexViewModel")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local TrainListCtrl = class(BaseCtrl, "TrainListCtrl")

TrainListCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Training/PlayerChoose.prefab"

local trainPositionMap = {
    [TrainType.SHOOT] = {
        FL = 1,
        FC = 1,
        FR = 1,
    },
    [TrainType.DRIBBLE] = {
        ML = 1,
        MC = 1,
        MR = 1,
        AMC = 1,
        DMC = 1,
    },
    [TrainType.DEFEND] = {
        DL = 1,
        DC = 1,
        DR = 1,
    },
    [TrainType.GK] = {
        GK = 1,
    },
    [TrainType.BRAIN] = {
        FL = 1,
        FC = 1,
        FR = 1,
        ML = 1,
        MC = 1,
        MR = 1,
        AMC = 1,
        DMC = 1,
        DL = 1,
        DC = 1,
        DR = 1,
        GK = 1,
    },
}

local playerTeamsModel = nil

-- 排序函数
local function StartOrderComp(aModel, bModel)
    if not playerTeamsModel then
        playerTeamsModel = PlayerTeamsModel.new()
    end

    local aPriority = 0
    local bPriority = 0
    if playerTeamsModel:IsPlayerInInitTeam(aModel:GetPcid()) then
        aPriority = 2
    elseif playerTeamsModel:IsPlayerInReplaceTeam(aModel:GetPcid()) then
        aPriority = 1
    end
    if playerTeamsModel:IsPlayerInInitTeam(bModel:GetPcid()) then
        bPriority = 2
    elseif playerTeamsModel:IsPlayerInReplaceTeam(bModel:GetPcid()) then
        bPriority = 1
    end

    local aPower = tonumber(aModel:GetPower())
    local bPower = tonumber(bModel:GetPower())
    if aPriority == bPriority then
        return aPower > bPower
    else
        return aPriority > bPriority
    end
end

function TrainListCtrl:Init(trainType, gameID, parentCtrl, residualTime)
    self.trainType = trainType
    self.gameID = gameID
    self.residualTime = residualTime
    self.parentCtrl = parentCtrl
    self.view.clickStart = function()
        if self.choosePcid and self.residualTime > 0 and not PlayerCardModel.new(self.choosePcid):IsSkillLevelMax() then
            TrainData.trainType = self.trainType
            TrainData.pcid = self.choosePcid
            TrainData.gameID = gameID
            if self.trainType == TrainType.BRAIN then  -- 脑力训练不切换场景
                self:Close()
                res.PushScene("ui.controllers.training.brain.BrainTrainingCtrl", TrainData.new())
            else
                -- 防止在恢复场景时没有弹板但是有模糊效果
                res.curSceneInfo.blur = nil
                self.residualTime = self.residualTime - 1
                res.ChangeScene("ui.controllers.training.TrainSceneCtrl")
            end
        elseif PlayerCardModel.new(self.choosePcid):IsSkillLevelMax() then
            DialogManager.ShowToast(lang.trans("skillMaxTip"))
        else
            DialogManager.ShowToast(lang.trans("training_tips1"))
        end
    end

    self.view.sweepCallback = function ()
        local level = PlayerInfoModel.new():GetLevel()
        if level < 16 then
            self:LevelTips()
        else
            self:SweepSuccess()
        end
    end

    self.view.onScrollCreateItem = function(scrollSelf, index)
        local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Training/CardFrame.prefab")
        scrollSelf:resetItem(spt, index)
        return obj
    end
    self.view.onScrollResetItem = function(scrollSelf, spt, index)
        local itemData = scrollSelf.itemDatas[index]  -- PlayerCardModel
        spt:InitView(itemData)
        if index ~= self.selectIndex then
            spt:OnCancel()
        else
            spt:OnChoose()
        end
        spt.clickCard = function()
            if self.selectIndex then
                local selectSpt = scrollSelf:getItem(self.selectIndex)
                if selectSpt then
                    selectSpt:OnCancel()
                end
            end
            self.selectIndex = index
            spt:OnChoose()
            self:OnCardClick(itemData:GetPcid()) 
        end
        scrollSelf:updateItemIndex(spt, index)
    end
    self.view.sortMenuView.clickSort = function(index) self:OnSortClick(index) end
    self.view.clickSearch = function() self:OnSearchClick() end
    self.cardsMapModel = PlayerCardsMapModel.new()
end

function TrainListCtrl:Refresh(trainType, gameID, parentCtrl, residualTime)
    TrainListCtrl.super.Refresh(self)
    self.trainType = trainType
    self.gameID = gameID
    self.residualTime = residualTime
    self.parentCtrl = parentCtrl
    self:InitView()
end

function TrainListCtrl:InitView()
    local cardModelList = self:GetCardModelList()
    self:RefreshScrollView(cardModelList)
    self.view:InitView(self.trainType)
end

function TrainListCtrl:Close()
    if type(self.view.closeDialog) == "function" then
        self.view.closeDialog()
    end
end

function TrainListCtrl:LevelTips()
    local content = lang.trans("sweep_tip")
    DialogManager.ShowAlertPop(lang.trans("tips"), content)
end

function TrainListCtrl:SweepSuccess()
    local playercardModel = PlayerCardModel.new(self.choosePcid)
    if self.residualTime > 0 and self.choosePcid and not playercardModel:IsSkillLevelMax() then
        clr.coroutine(function ()
            local response = req.littleGameSweep(self.gameID, self.choosePcid)
            if api.success(response) then
                local data = response.val
                local resultDummy, dummyComp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/Training/TrainSweepResultDummy.prefab", "camera", true)
                -- 进入结算页面
                local coreResultCtrl = SweepResultCtrl.new(data.maxTimes, data.times, resultDummy.transform)
                coreResultCtrl:InitView(PlayerCardModel.new(data.cardInfo.pcid), data.reward, data.score)

                self.residualTime = self.residualTime - 1
                self.cardsMapModel:ResetCardData(data.cardInfo.pcid, data.cardInfo)
                if self.gameID == "501" then
                    EventSystem.SendEvent("Refresh_Brain_Time")
                else
                    EventSystem.SendEvent("Refresh_Skill_Time", self.residualTime)
                end
            end
        end)
    elseif playercardModel:IsSkillLevelMax() then
        DialogManager.ShowToast(lang.trans("skillMaxTip"))
    else
        DialogManager.ShowToast(lang.trans("training_tips1"))
    end
end

function TrainListCtrl:GetCardModelList()
    local cardList = self.cardsMapModel:GetCardList()
    local cardModelList = {}
    for i, pcid in ipairs(cardList) do
        local cardModel = PlayerCardModel.new(pcid)
        -- 1，需要过滤掉品质为1的卡牌，因为这种卡永远不会参加训练
        -- 2，过滤没有进阶的卡牌，因为这种卡还没有开启技能
        -- 3, 过滤无技能可升级的球员 (可拥有最大技能点数为0)
        cardModel:InitEquipsAndSkills()
        if cardModel:GetCardQuality() ~= 1 and cardModel:GetUpgrade() >= 2 and cardModel:HasSkillLevelUp() then
            -- 根据训练类型过滤对应位置的球员
            local positions = cardModel:GetPosition()
            for j, pos in ipairs(positions) do
                if trainPositionMap[self.trainType][pos] then
                    table.insert(cardModelList, cardModel)
                    break
                end
            end
        end
    end
    -- 排序（出场顺序，战力)
    table.sort(cardModelList, StartOrderComp)

    self.targetPlayerChooseModel = TargetPlayerChooseModel.new(cardModelList)
    if not self.cardIndexViewModel then
        self.cardIndexViewModel = CardIndexViewModel.new()
    end
    return cardModelList
end

function TrainListCtrl:RefreshScrollView(cardModelList)
    self.view.scroll:clearData()
    self.view.scroll.itemDatas = cardModelList
    self.view.scroll:refresh()
end

function TrainListCtrl:OnCardClick(pcid)
    local cardModel = PlayerCardModel.new(pcid)

    self.choosePcid = pcid
    self.view:SetTrainPlayer(cardModel, pcid)
end

function TrainListCtrl:OnSortClick(selectTypeIndex)
    self.cacheScrollPos = 1
    local typeIndex = self.targetPlayerChooseModel:GetSelectTypeIndex()
    if typeIndex == selectTypeIndex then return end
    local selectPos = self.targetPlayerChooseModel:GetSelectPos()
    local selectQuality = self.targetPlayerChooseModel:GetSelectQuality()
    local selectNationality = self.targetPlayerChooseModel:GetSeletNationality()
    local selectName = self.targetPlayerChooseModel:GetSeletName()
    local selectSkill = self.targetPlayerChooseModel:GetSeletSkill()
    self.targetPlayerChooseModel:SortCardList(selectTypeIndex, selectPos, selectQuality, selectNationality, selectName, selectSkill)
end

function TrainListCtrl:EventSortCardList()
    self:SetSelectDetail(self.targetPlayerChooseModel)
    self:SortCardListCallBack()
end

function TrainListCtrl:SortCardListCallBack()
    -- 创建卡牌列表
    local sortCardList = self.targetPlayerChooseModel:GetSortCardList()
    self.selectTypeIndex = self.targetPlayerChooseModel:GetSelectTypeIndex()
    self.selectPos = self.targetPlayerChooseModel:GetSelectPos()
    self.selectQuality = self.targetPlayerChooseModel:GetSelectQuality()
    self.selectName = self.targetPlayerChooseModel:GetSeletName()
    self.selectNationality = self.targetPlayerChooseModel:GetSeletNationality()
    self.selectSkill = self.targetPlayerChooseModel:GetSeletSkill()
    local cardsArray = {}
    for i, pcid in ipairs(sortCardList) do
        local cardModel = self.targetPlayerChooseModel:GetCardModel(pcid)
        table.insert(cardsArray, cardModel)
    end
    self.view:ClearChoosePlayer()
    self.choosePcid = nil
    self.selectIndex = nil
    self:RefreshScrollView(cardsArray)
end

function TrainListCtrl:SetSelectDetail(targetPlayerChooseModel)
    local isSelected = false
    if targetPlayerChooseModel then
        local selectPos = targetPlayerChooseModel:GetSelectPos()
        local selectQuality = targetPlayerChooseModel:GetSelectQuality()
        local selectName = targetPlayerChooseModel:GetSeletName()
        local selectNationality = targetPlayerChooseModel:GetSeletNationality()
        local selectSkill = targetPlayerChooseModel:GetSeletSkill()

        if selectPos and next(selectPos) then
            isSelected = true
        end
        if selectQuality and next(selectQuality) then
            isSelected = true
        end
        if selectSkill and next(selectSkill) then
            isSelected = true
        end
        if selectName ~= "" or selectNationality ~= "" then
            isSelected = true
        end
        self.view:SetSortTxt(isSelected)
    end
end

function TrainListCtrl:GetStatusData()
    return self.trainType, self.gameID, self.parentCtrl, self.residualTime
end

function TrainListCtrl:OnSearchClick()
    res.PushDialog("ui.controllers.playerList.PlayerSearchCtrl", self.targetPlayerChooseModel, self.cardIndexViewModel)
end

function TrainListCtrl:OnEnterScene()
    EventSystem.AddEvent("PlayerListModel_SortCardList", self, self.EventSortCardList)
end

function TrainListCtrl:OnExitScene()
    EventSystem.RemoveEvent("PlayerListModel_SortCardList", self, self.EventSortCardList)
end

return TrainListCtrl
