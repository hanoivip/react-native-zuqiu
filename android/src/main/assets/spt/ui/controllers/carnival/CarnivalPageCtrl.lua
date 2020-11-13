local CarnivalModel = require("ui.models.carnival.CarnivalModel")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local DialogManager = require("ui.control.manager.DialogManager")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local CourtBgMusicCtrl = require("ui.controllers.court.CourtBgMusicCtrl")
local FriendsMenuType = require("ui.models.friends.MenuType")
local LevelLimit = require("data.LevelLimit")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local CarnivalPageCtrl = class(BaseCtrl)
CarnivalPageCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Carnival/Prefabs/CarnivalBoard.prefab"

CarnivalPageCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}
local TaskState = {
    Lock2 = -3,
    Lock = -2,
    Unlock = -1,
    Finish = 0,
    GetReward = 1,
}
local JumpId = {
    FB = 1,
    Level = 2,
    Friends = 3,
    PowerTarget = 4,
    PlayerManager = 5,
    Transfer = 6,
    Training = 7,
    Ladder = 8,
    Guild = 9,
    PlayerLetter = 10,
    Reincarnation = 11,
    Court = 12,
    Vitamin = 13,
    Gacha = 14,
}
local DefaultTaskIndex = 1

function CarnivalPageCtrl:GetStatusData()
    return self.carnivalModel
end

function CarnivalPageCtrl:AheadRequest()
    local response = req.beginnerCarnivalInfo(nil, nil, true)
    if api.success(response) then
        local data = response.val
        local list = data and data.list
        if not self.carnivalModel then
            self.carnivalModel = CarnivalModel.new()
        end
        self.carnivalModel:InitWithProtocol(list)
    end
end

function CarnivalPageCtrl:Init()
    if not self.playerInfoModel then
        self.playerInfoModel = PlayerInfoModel.new()
    end
    self.currentDayIndex = self.carnivalModel:GetTodayIndex()
    self.currentTabIndex = 1
end

function CarnivalPageCtrl:Refresh()
    CarnivalPageCtrl.super.Refresh(self)
    self:CreateDetailItemList()
    self:CreateLabelsItemList()
    self:CreateProgressItemList()
    self:InitView()
end

function CarnivalPageCtrl:InitView()
    self.view.onCloseClick = function()
        self:Close()
    end
    self.view.onTab1Click = function()
        self:ClickTab(1)
    end
    self.view.onTab2Click = function()
        self:ClickTab(2)
    end
    self.view:InitView(self.carnivalModel)
end

function CarnivalPageCtrl:UpdateRedPointState()
    if self.refreshRedPoint then
        self.carnivalModel:SetSelectLabel(self.currentDayIndex)
        self:RefreshLabelsScrollView()
        self:RefreshDetailItemList()
        self.view:InitView(self.carnivalModel)
        self:InitTabsView(self.currentDayIndex, true)
        self.refreshRedPoint = false
    end
end

function CarnivalPageCtrl:ClickItemButton(itemData)
    if not cache.getIsOpenBeginnerCarnival() then
        DialogManager.ShowToast(lang.trans("carnival_close"))
        return
    end
    local jumpId = itemData.type
    local taskState = itemData.taskState
    if taskState == TaskState.Unlock then
        local level = tonumber(self.playerInfoModel:GetLevel())
        if jumpId == JumpId.FB or jumpId == JumpId.Level then
            res.PushScene("ui.controllers.quest.QuestPageCtrl", nil, nil, nil, true)
        elseif jumpId == JumpId.Friends then
            res.PushScene("ui.controllers.friends.FriendsMainCtrl", FriendsMenuType.MESSAGES)
        elseif jumpId == JumpId.PlayerManager or jumpId == JumpId.PowerTarget or jumpId == JumpId.Reincarnation or jumpId == JumpId.Vitamin then
            res.PushScene("ui.controllers.playerList.PlayerListMainCtrl", nil, nil, nil, nil, true)
        elseif jumpId == JumpId.Transfer then
            local unlockLevel = LevelLimit["transfer"] and LevelLimit["transfer"].playerLevel
            if level >= tonumber(unlockLevel) then
                res.PushScene("ui.controllers.transferMarket.TransferMarketCtrl", {})
            else
                DialogManager.ShowToast(lang.trans("unlock_tips", clr.unwrap(lang.trans("transfer")), unlockLevel))
            end
        elseif jumpId == JumpId.Training then
            local unlockLevel = LevelLimit["littleGame"] and LevelLimit["littleGame"].playerLevel
            if level >= tonumber(unlockLevel) then
                res.PushScene("ui.controllers.training.TrainCtrl")
            else
                DialogManager.ShowToast(lang.trans("unlock_tips", clr.unwrap(lang.trans("training")), unlockLevel))
            end
        elseif jumpId == JumpId.Ladder then
            local unlockLevel = LevelLimit["ladder"] and LevelLimit["ladder"].playerLevel
            if level >= tonumber(unlockLevel) then
                res.PushScene("ui.controllers.ladder.LadderMainCtrl")
            else
                DialogManager.ShowToast(lang.trans("unlock_tips", clr.unwrap(lang.trans("pd_ladder_txt")), unlockLevel))
            end
        elseif jumpId == JumpId.Guild then
            local unlockLevel = LevelLimit["guild"] and LevelLimit["guild"].playerLevel
            if level >= tonumber(unlockLevel) then
                clr.coroutine(function()
                    local respone = req.guildIndex()
                    if api.success(respone) then
                        local data = respone.val
                        if data.base.isExsit == true then
                            res.PushScene("ui.controllers.guild.GuildHomeCtrl", data) 
                        else
                            res.PushScene("ui.controllers.guild.GuildJoinCtrl")
                        end
                    end
                end)
            else
                DialogManager.ShowToast(lang.trans("unlock_tips", clr.unwrap(lang.trans("guild")), unlockLevel))
            end
        elseif jumpId == JumpId.PlayerLetter then
            res.PushScene("ui.controllers.quest.QuestPageCtrl", nil, nil, nil, true)
            res.PushDialog("ui.controllers.playerLetter.PlayerLetterCtrl")
        elseif jumpId == JumpId.Court then
            local unlockLevel = LevelLimit["building"] and LevelLimit["building"].playerLevel
            if level >= tonumber(unlockLevel) then 
                CourtBgMusicCtrl.StartPlayBgm()
                res.PushScene("ui.controllers.court.CourtMainCtrl")
            else
                DialogManager.ShowToast(lang.trans("unlock_tips", clr.unwrap(lang.trans("court")), unlockLevel))
            end
        elseif jumpId == JumpId.Gacha then
            res.PushScene("ui.controllers.store.StoreCtrl", require("ui.models.store.StoreModel").MenuTags.GACHA)
        end
    elseif taskState == TaskState.Finish then
        clr.coroutine(function ()
            local response = req.activityReceive(self.carnivalModel:GetActivityType(), itemData.rewardId, nil, nil, true)
            if api.success(response) then
                local data = response.val
                if data.contents ~= nil then  
                    CongratulationsPageCtrl.new(data.contents)
                    self.refreshRedPoint = true
                    self:AheadRequest()
                end
            end
        end)
    end
end

function CarnivalPageCtrl:CreateDetailItemList()
    self.view.detailScrollView.onScrollCreateItem = function(index)
        local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Carnival/Prefabs/CarnivalItem.prefab")
        return obj, spt
    end
    self.view.detailScrollView.onScrollResetItem = function(spt, index)
        local data = self.view.detailScrollView.itemDatas[index]
        spt.clickButton = function() self:ClickItemButton(spt.data) end
        spt:InitView(data, self.view.itemParentScrollRect)
        self.view.detailScrollView:updateItemIndex(spt, index)
    end
    self:RefreshDetailItemList()
end

function CarnivalPageCtrl:RefreshDetailItemList()
    local data = self.carnivalModel:GetCurrentDetailData(self.currentDayIndex, self.currentTabIndex)
    self.view.detailScrollView:clearData()
    for i = 1, #data do
        table.insert(self.view.detailScrollView.itemDatas, data[i])
    end
    self.view.detailScrollView:refresh()
end

-- Task Index
function CarnivalPageCtrl:ClickTab(index)
    self.currentTabIndex = index
    self:RefreshDetailItemList()
end

function CarnivalPageCtrl:CreateLabelsItemList()
    self.view.labelScrollView.onScrollCreateItem = function(index)
        local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Carnival/Prefabs/CarnivalLabel.prefab")
        return obj, spt
    end
    self.view.labelScrollView.onScrollResetItem = function(spt, index)
        local data = self.view.labelScrollView.itemDatas[index]
        spt.clickButton = function() self:ClickLabel(spt.data.dayIndex) end
        spt:InitView(data)
        spt:ChangeButtonState(data.isSelect)
        self.view.labelScrollView:updateItemIndex(spt, index)
    end
    -- default : today
    self:ClickLabel(self.carnivalModel:GetTodayIndex())
    self:RefreshLabelsScrollView()
end

function CarnivalPageCtrl:RefreshLabelsScrollView()
    local dataList = self.carnivalModel:GetLabelsLockState()
    self.view.labelScrollView:clearData()
    for i = 1, #dataList do
        table.insert(self.view.labelScrollView.itemDatas, dataList[i])
    end
    self.view.labelScrollView:refresh()
end

-- Day Index
function CarnivalPageCtrl:ClickLabel(index)
    if index > self.carnivalModel:GetUnlockIndex() then
        return
    end
    self.currentDayIndex = index
    local dataList = self.carnivalModel:GetLabelsLockState()
    for i, v in ipairs(dataList) do
        if i == index and v.isUnlock then -- 解锁才可点击
            v.isSelect = true
            self:ClickTab(DefaultTaskIndex)
            self:InitTabsView(index, false)
        else
            v.isSelect = false
        end
        local spt = self.view.labelScrollView:getItem(i)
        if spt then
            spt:ChangeButtonState(v.isSelect)
        end
    end
end

function CarnivalPageCtrl:InitTabsView(dayIndex, isGetReward)
    local tab1, tab2 = self.carnivalModel:GetCurrentTabs(dayIndex)
    self.view:InitTabsView(tab1, tab2)
    EventSystem.SendEvent("CarnivalPageView.InitTabsState", isGetReward)
end

function CarnivalPageCtrl:CreateProgressItemList()
    self.view.progressScrollView.onScrollCreateItem = function(index)
        local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Carnival/Prefabs/CarnivalProgressItem.prefab")
        return obj, spt
    end
    self.view.progressScrollView.onScrollResetItem = function(spt, index)
        local data = self.view.progressScrollView.itemDatas[index]
        spt.onItemClick = function() self:ClickPregressItem(spt.model) end
        spt.onItemGetRewardClick = function() self:ClickProgressGetReward(spt.model) end
        spt:InitView(data, self.carnivalModel:GetCurrentProgressNumber())
        self.view.progressScrollView:updateItemIndex(spt, index)
    end
    self:RefreshProgressItemList()
end

function CarnivalPageCtrl:RefreshProgressItemList()
    local dataList = self.carnivalModel:GetProgressList()
    self.view.progressScrollView:clearData()
    for i = 1, #dataList do
        table.insert(self.view.progressScrollView.itemDatas, dataList[i])
    end
    self.view.progressScrollView:refresh()
end

function CarnivalPageCtrl:ClickPregressItem(itemModel)
    if not cache.getIsOpenBeginnerCarnival() then
        DialogManager.ShowToast(lang.trans("carnival_close"))
        return
    end
    res.PushDialog("ui.controllers.carnival.CarnivalPopBoardCtrl", itemModel)
end

function CarnivalPageCtrl:ClickProgressGetReward(itemModel)
    if not cache.getIsOpenBeginnerCarnival() then
        DialogManager.ShowToast(lang.trans("carnival_close"))
        return
    end
    clr.coroutine(function()
        local response = req.beginnerCarnivalProgressInfo(self.carnivalModel:GetActivityType(), itemModel.ID, nil, nil, true)
        if api.success(response) then
            local data = response.val
            if data.contents ~= nil then
                CongratulationsPageCtrl.new(data.contents)
                -- TODO:任务进度奖励的红点服务器逻辑未完成
                -- self.refreshRedPoint = true
                -- self:AheadRequest()
                itemModel.status = 1
                EventSystem.SendEvent("CarnivalProgressItem.UpdateState")
            end
        end
    end)
end

function CarnivalPageCtrl:OnEnterScene()
    EventSystem.AddEvent("CarnivalReward_UpdateRedPointState", self, self.UpdateRedPointState)
end

function CarnivalPageCtrl:OnExitScene()
    EventSystem.RemoveEvent("CarnivalReward_UpdateRedPointState", self, self.UpdateRedPointState)
end

function CarnivalPageCtrl:Close()
    self.view:Close()
    EventSystem.SendEvent("CarnivalRedPoint_RefreshHomeEvent")
end

return CarnivalPageCtrl