local EventSystem = require ("EventSystem")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local LuaButton = require("ui.control.button.LuaButton")
local PlayerDollGroupLabelView = class(LuaButton)

function PlayerDollGroupLabelView:ctor()
    PlayerDollGroupLabelView.super.ctor(self)
--------Start_Auto_Generate--------
    self.maskBtn = self.___ex.maskBtn
    self.titleNormalTxt = self.___ex.titleNormalTxt
    self.selectNumNormalTxt = self.___ex.selectNumNormalTxt
    self.titleHLTxt = self.___ex.titleHLTxt
    self.selectNumHLlTxt = self.___ex.selectNumHLlTxt
--------End_Auto_Generate----------
    self.normal = self.___ex.normal
    self.mySelect = self.___ex.mySelect
    self.index = nil
end

function PlayerDollGroupLabelView:InitView(playerDollModel, index)
    self.playerDollModel = playerDollModel
    self.index = index
    local curIndex = self.playerDollModel:GetCurGrade()
    self:SetTitle()
    self:SetNum(true)
    self:RegEvent()
end

function PlayerDollGroupLabelView:SetTitle()
    local grade = lang.transstr("number_" .. self.index)
    local gradTitle = lang.trans("timeLimit_player_doll_grade", grade)
    self.titleNormalTxt.text = gradTitle
    self.titleHLTxt.text = gradTitle
end

function PlayerDollGroupLabelView:SetIcon(curIndex)
    GameObjectHelper.FastSetActive(self.mySelect.Icon1st, self.index == 1)
    GameObjectHelper.FastSetActive(self.mySelect.Icon2nd, self.index == 2)
    GameObjectHelper.FastSetActive(self.mySelect.Icon3rd, self.index == 3)
    GameObjectHelper.FastSetActive(self.normal.Icon1st, self.index == 1)
    GameObjectHelper.FastSetActive(self.normal.Icon2nd, self.index == 2)
    GameObjectHelper.FastSetActive(self.normal.Icon3rd, self.index == 3)
    GameObjectHelper.FastSetActive(self.mySelect.Go, self.index == tonumber(curIndex))
    GameObjectHelper.FastSetActive(self.normal.Go, self.index ~= tonumber(curIndex))
end

function PlayerDollGroupLabelView:SetNum(isInit)
    local curIndex = self.playerDollModel:GetCurGrade()
    local init = isInit or false
    if tonumber(curIndex) ~= self.index and not init then 
        return 
    end
    local numInNeed = self.playerDollModel:GetChoseRewardCountByGrade(tostring(self.index))
    local selectItems = self.playerDollModel:GetGradeRewardsSelected(tonumber(self.index))
    local selectNum = 0
    for id, reward in pairs(selectItems) do
        selectNum = selectNum + 1
    end
    local numTxt = {}
    if selectNum == tonumber(numInNeed) then
        numTxt = lang.trans("timeLimit_player_doll_numSelect_green", selectNum, numInNeed)
    else
        numTxt = lang.trans("timeLimit_player_doll_numSelect_red", selectNum, numInNeed)
    end
    self.selectNumNormalTxt.text = numTxt
    self.selectNumHLlTxt.text = numTxt
end

function PlayerDollGroupLabelView:RegEvent()
    EventSystem.AddEvent("PlayerDoll_RewardSelect", self, self.SetNum)
end

function PlayerDollGroupLabelView:onDestroy()
    EventSystem.RemoveEvent("PlayerDoll_RewardSelect", self, self.SetNum)
end

return PlayerDollGroupLabelView
