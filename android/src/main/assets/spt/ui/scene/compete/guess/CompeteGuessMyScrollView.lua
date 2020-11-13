local ScrollRectEx = clr.UnityEngine.UI.ScrollRectEx
local LuaScrollRectEx = require("ui.control.scroll.LuaScrollRectEx")
local CompeteGuessMyScrollView = class(LuaScrollRectEx)

local itemPath = "Assets/CapstonesRes/Game/UI/Scene/Compete/Guess/CompeteGuessMyItem.prefab" -- 竞猜失败
local itemPathStage = "Assets/CapstonesRes/Game/UI/Scene/Compete/Guess/CompeteGuessMyItemStage.prefab" -- 竞猜正常奖励
local itemPathReverse = "Assets/CapstonesRes/Game/UI/Scene/Compete/Guess/CompeteGuessMyItemReverse.prefab" -- 竞猜正常奖励


local REVERSE_ITEM_SUFFIX = "Reverse"
local STAGE_ITEM_SUFFIX = "Stage"
local DEFAULT_ITEM_SUFFIX = "Default"

function  CompeteGuessMyScrollView:ctor()
    CompeteGuessMyScrollView.super.ctor(self)
    self.rctContent = self.___ex.rctContent
    self.cScrollRect = self.___ex.cScrollRect:GetComponent(ScrollRectEx)
end

function CompeteGuessMyScrollView:start()
end

function CompeteGuessMyScrollView:InitView(itemDatas, competeGuessModel)
    self.competeGuessModel = competeGuessModel
    self:refresh(itemDatas)
end

function CompeteGuessMyScrollView:getItemTag(index)
    local itemData = self.itemDatas[index]
    if not itemData then return DEFAULT_ITEM_SUFFIX end

    local matchData = itemData.match
    if not matchData then return DEFAULT_ITEM_SUFFIX end

    if matchData.isMatchOver then
        if matchData.winner == itemData.guessPlayer then -- 竞猜成功
            if matchData[matchData.winner].guessCount < matchData[matchData.notwinner].guessCount
                and tonumber(itemData.stage) >= self.minStage
                and tonumber(itemData.stage) <= self.maxStage then -- 翻盘奖励
                return REVERSE_ITEM_SUFFIX
            else -- 竞猜人数持平属于正常奖励
                return STAGE_ITEM_SUFFIX
            end
        else -- 竞猜失败
            return DEFAULT_ITEM_SUFFIX
        end
    end
end

-- 竞猜失败的item
function CompeteGuessMyScrollView:createItemByTagDefault(index)
    local obj = res.Instantiate(itemPath)
    obj.transform:SetParent(self.rctContent, false)
    return obj
end

function CompeteGuessMyScrollView:resetItemByTagDefault(spt, index)
    local data = self.itemDatas[index]
    data.idx = index
    spt:SetJudgeStage(self.minStage, self.maxStage)
    spt:InitView(data, self.competeGuessModel)
    spt.onClickBtnReplay = function(matchData) self:OnClickMyItemReplay(matchData) end
end

-- 正常奖励的item
function CompeteGuessMyScrollView:createItemByTagStage(index)
    local obj = res.Instantiate(itemPathStage)
    obj.transform:SetParent(self.rctContent, false)
    return obj
end

function CompeteGuessMyScrollView:resetItemByTagStage(spt, index)
    local data = self.itemDatas[index]
    data.idx = index
    spt:SetJudgeStage(self.minStage, self.maxStage)
    spt:InitView(data, self.competeGuessModel)
    spt.onRewardReceive = function(season, round, matchType, combatIndex, idx) self:OnRewardReceive(season, round, matchType, combatIndex, idx) end
    spt.onClickBtnReplay = function(matchData) self:OnClickMyItemReplay(matchData) end
end

-- 翻盘奖励的item
function CompeteGuessMyScrollView:createItemByTagReverse(index)
    local obj = res.Instantiate(itemPathReverse)
    obj.transform:SetParent(self.rctContent, false)
    return obj
end

function CompeteGuessMyScrollView:resetItemByTagReverse(spt, index)
    local data = self.itemDatas[index]
    data.idx = index
    spt:SetJudgeStage(self.minStage, self.maxStage)
    spt:InitView(data, self.competeGuessModel)
    spt.onRewardReceive = function(season, round, matchType, combatIndex, idx) self:OnRewardReceive(season, round, matchType, combatIndex, idx) end
    spt.onClickBtnReplay = function(matchData) self:OnClickMyItemReplay(matchData) end
end

function CompeteGuessMyScrollView:Clear()
    self.cScrollRect.ClearData()  --Lua assist checked flag
end

function CompeteGuessMyScrollView:OnRewardReceive(season, round, matchType, combatIndex, idx)
    if self.onRewardReceive then
        self.onRewardReceive(season, round, matchType, combatIndex, idx)
    end
end

function CompeteGuessMyScrollView:OnClickMyItemReplay(matchData)
    if self.onClickMyItemReplay then
        self.onClickMyItemReplay(matchData)
    end
end

function CompeteGuessMyScrollView:SetJudgeStage(minStage, maxStage)
    self.minStage = minStage
    self.maxStage = maxStage
end

return CompeteGuessMyScrollView
