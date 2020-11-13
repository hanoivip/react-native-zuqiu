local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local LuaButton = require("ui.control.button.LuaButton")
local EventSystem = require ("EventSystem")
local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local PlayerDollRewardSelectView = class(LuaButton)

function PlayerDollRewardSelectView:ctor()
    PlayerDollRewardSelectView.super.ctor(self)
--------Start_Auto_Generate--------
    self.rewardContentTrans = self.___ex.rewardContentTrans
    self.btnGroupSpt = self.___ex.btnGroupSpt
    self.gradeTagContentTrans = self.___ex.gradeTagContentTrans
    self.scrollViewSpt = self.___ex.scrollViewSpt
    self.confirmBtn = self.___ex.confirmBtn
    self.closeBtn = self.___ex.closeBtn
--------End_Auto_Generate----------
    self.confirmChange = false
    DialogAnimation.Appear(self.transform, nil)
end

function PlayerDollRewardSelectView:start()
    self:RegBtnEvent()
    self:RegEvent()
end

function PlayerDollRewardSelectView:InitView(playerDollModel)
    self.playerDollModel = playerDollModel
    self.originData = {}
    self:SaveOriginData()
    self:InitTab()
    self:ShowRewards()
end

function PlayerDollRewardSelectView:SaveOriginData()
    local rewardList = self.playerDollModel:GetRewardList()
    for id, reward in pairs(rewardList) do
        self.originData[id] = reward.select
    end
end

function PlayerDollRewardSelectView:SetOriginData()
    for id, isSelected in pairs(self.originData) do
        self.playerDollModel:SetWantedReward(id, isSelected)
    end
end

function PlayerDollRewardSelectView:CompareOriginData()
    for id, isSelected in pairs(self.originData) do
        if self.playerDollModel:IsRewardWanted(id) ~= isSelected then
            return false
        end
    end
    return true
end

-- 按钮触发事件注册
function PlayerDollRewardSelectView:RegBtnEvent()
    self.confirmBtn:regOnButtonClick(function()
        self:OnBtnConfirm()
    end)
    self.closeBtn:regOnButtonClick(function()
        self:OnBtnClose()
    end)
end

function PlayerDollRewardSelectView:OnBtnConfirm()
    if self.onBtnConfirm and type(self.onBtnConfirm) == "function" then
        self.onBtnConfirm()
    end
end

function PlayerDollRewardSelectView:OnBtnClose()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function()
            self.closeDialog()
        end)
    end
end

function PlayerDollRewardSelectView:InitTab()
    self.tabList = {}
    if not self.btnGroupSpt.menu then
        self.btnGroupSpt.menu = {}
    end
    local resPrefab = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Activties/PlayerDoll/ScrollItem/PlayerDollGroupLabel.prefab")
    local choseRewardGrades = {}
    local choseReward = self.playerDollModel:GetChoseRewardCount()
    for grade, count in pairs(choseReward) do
        table.insert(choseRewardGrades, {grade = grade, count = count})
    end
    table.sort(choseRewardGrades, function (a, b) return a.grade < b.grade end)
    for i, v in pairs(choseRewardGrades) do
        if not self.btnGroupSpt.menu[i] then
            local obj = Object.Instantiate(resPrefab)
            obj.transform:SetParent(self.gradeTagContentTrans, false)
            local objScript = obj:GetComponent("CapsUnityLuaBehav")
            self.tabList[i] = objScript
            self.btnGroupSpt.menu[i] = objScript
        end
        self.btnGroupSpt:BindMenuItem(i, function() self:OnTabClick(i) end)
        self.btnGroupSpt.menu[i]:InitView(self.playerDollModel, i)
    end
    local defaultGrade = self.playerDollModel:GetCurGrade()
    self.btnGroupSpt:selectMenuItem(defaultGrade)
    self:OnTabClick(defaultGrade)
end

function PlayerDollRewardSelectView:OnTabClick(tag)
    local modeTag = tonumber(tag)
    self.playerDollModel:SetCurGrade(modeTag)
    for i, tab in pairs(self.btnGroupSpt.menu) do
        tab:SetIcon(tostring(tag))
    end
    self:InitReward()
end

function PlayerDollRewardSelectView:InitReward()
    res.ClearChildren(self.rewardContentTrans)
    local resPrefab = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Activties/PlayerDoll/ScrollItem/PlayerDollRewardSelectItem.prefab")
    local tag = self.playerDollModel:GetCurGrade()
    local rewardItemList = self.playerDollModel:GetGradeRewardList(tag)
    local sortedList = {}
    for id, reward in pairs(rewardItemList) do
        table.insert(sortedList, {id = id, reward = reward})
    end 
    table.sort(sortedList, function (a, b) return a.reward.order < b.reward.order end)
    for index, detail in pairs(sortedList) do
        local obj = Object.Instantiate(resPrefab)
        obj.transform:SetParent(self.rewardContentTrans, false)
        local objScript = obj:GetComponent("CapsUnityLuaBehav")
        objScript:InitView(detail, self.playerDollModel, true)
    end
end

function PlayerDollRewardSelectView:ShowRewards()
    local itemDatas = self.playerDollModel:GetSortedRewardList()
    self.scrollViewSpt:InitView(itemDatas, self.playerDollModel)
end

function PlayerDollRewardSelectView:RegEvent()
    EventSystem.AddEvent("PlayerDoll_RewardSelect", self, self.ShowRewards)
end

function PlayerDollRewardSelectView:OnExitScene()
    EventSystem.RemoveEvent("PlayerDoll_RewardSelect", self, self.ShowRewards)
    if self.confirmChange then return end
    self:SetOriginData()
end

return PlayerDollRewardSelectView
