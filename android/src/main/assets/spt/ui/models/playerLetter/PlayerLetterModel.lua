local Model = require("ui.models.Model")
local PlayerLetterConstants = require("ui.scene.playerLetter.PlayerLetterConstants")
local PlayerLetterItemModel = require("ui.models.playerLetter.PlayerLetterItemModel")

-- 球员信函模型
local PlayerLetterModel = class(Model, "PlayerLetterModel")

function PlayerLetterModel:ctor()
    -- 信函数据
    self.letterData = nil
    -- 未回信信函数据
    self.noReplyList = nil
    -- 已回信信函数据
    self.haveReplyList = nil
    self.super.ctor(self)
end

function PlayerLetterModel:Init(data)
    if not data then
        data = cache.getPlayerLetterInfo()
        if data == nil then
            data = {}
        end
    end
    self.letterData = data
end

function PlayerLetterModel:InitLetterData(data)
    self.letterData = data
    self.noReplyList = {}
    self.haveReplyList = {}
    local newLetterData = {}

    for i, itemData in ipairs(self.letterData) do
        local playerLetterItemModel = PlayerLetterItemModel.new(itemData)
        local letterState = playerLetterItemModel:GetState()
        local letterID = playerLetterItemModel:GetID()
        if letterState == PlayerLetterConstants.LetterState.HAVE_AWARD then
            table.insert(self.haveReplyList, playerLetterItemModel)
        else
            table.insert(self.noReplyList, playerLetterItemModel)
        end
        newLetterData[letterID] = playerLetterItemModel
    end

    self.letterData = newLetterData
    cache.setPlayerLetterInfo(self.letterData)
end

function PlayerLetterModel:InitWithProtocol(data)
    self:InitLetterData(data)
end

--- 获取未回信列表
-- @return table
function PlayerLetterModel:GetNoReplyList()
    return self.noReplyList
end

--- 获取已回信列表
-- @return table
function PlayerLetterModel:GetHaveReplyList()
    return self.haveReplyList
end

--- 获取单元信件数据
-- @param letterID 信件id
-- @return PlayerLetterItemModel
function PlayerLetterModel:GetLetterItemModelByID(letterID)
    return self.letterData[letterID]
end

--- 更新信件读取状态
-- @param letterID 信件ID
function PlayerLetterModel:UpdateLetterReadState(letterID)
    local playerLetterItemModel = self:GetLetterItemModelByID(letterID)
    playerLetterItemModel:SetReadState(PlayerLetterConstants.LetterReadState.READ)
end

--- 因为领奖而更新数据
-- @param letterId 信件id
function PlayerLetterModel:UpdateDataOnReceiveAward(letterID)
    local playerLetterItemModel = self:GetLetterItemModelByID(letterID)
    playerLetterItemModel:SetState(PlayerLetterConstants.LetterState.HAVE_AWARD)
    local letterID = playerLetterItemModel:GetID()
    for i, model in ipairs(self.noReplyList) do
        if model == playerLetterItemModel then
            table.remove(self.noReplyList, i)
            break
        end
    end
    table.insert(self.haveReplyList, playerLetterItemModel)
end

-- 获得未读或者完成信件的ID
function PlayerLetterModel:GetFirstNoReadOrFinishedLetterID()
    if self.noReplyList == nil then return nil end
    for i, v in ipairs(self.noReplyList) do
        if not v:GetShow() then
            if v:GetReadState() == 0 then
                return v:GetID()
            end
            if v:GetState() == 0 then
                return v:GetID()
            end
        end
    end
    return nil
end

return PlayerLetterModel