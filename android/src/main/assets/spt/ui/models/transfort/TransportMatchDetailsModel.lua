local Model = require("ui.models.Model")
local TransportMatchDetailsModel = class(Model)

function TransportMatchDetailsModel:ctor()
    TransportMatchDetailsModel.super.ctor(self)
end

function TransportMatchDetailsModel:InitWithParentProtocol(data)
    assert(data)
    self.data = data
    local mTeams = cache.getPlayerTeams()
    self.mTid = tonumber(mTeams.currTid) + 1
end

function TransportMatchDetailsModel:GetMatchResultDataList()
    local resultRawList = {}
    local resultList = {}
    --检出实际结果
    for k, v in pairs(self.data.match)do 
        if v.robberyScore then
            table.insert(resultRawList, v)
        end
    end
    --可用列表
    if #resultRawList == 1 then
        table.insert(resultList, self:ChangeData(resultRawList[1], "1"))
    else
        local Ids = cache.getTransportIds()
        for k, v in pairs(resultRawList)do 
            local tempData = nil
            if Ids.pid == v.opponentId then
                tempData = self:ChangeData(v, "2")
                resultList[2] = tempData
            else
                tempData = self:ChangeData(v, "1")
                resultList[1] = tempData
            end
        end 
    end
    --最终
    if #resultList == 2 then
        local tempData = {}
        tempData.ourName = resultList[2].ourName
        tempData.enemyName = resultList[2].enemyName
        tempData.ourLogo = resultList[2].ourLogo
        tempData.enemyLogo = resultList[2].enemyLogo
        tempData.score = (resultList[1].robberyScore + resultList[2].robberyScore).." : " ..(resultList[1].opponentScore + resultList[2].opponentScore)
        tempData.order = lang.trans("peak_num_scene",k)
        resultList[3] = tempData
    end

    resultList.isContinue = self.data.express.guardPlayer and (#resultList == 1)
    resultList.reward = self.data.reward
    resultList.robberyReward = self.data.robberyReward
    return resultList
end

function TransportMatchDetailsModel:ChangeData(v, index)
    local tempData = {}
    tempData.ourName = v.robberyName
    tempData.enemyName = v.opponentName
    tempData.ourLogo = v.robberyLogo
    tempData.enemyLogo = v.opponentLogo
    tempData.score = v.robberyScore .." : " .. v.opponentScore 
    tempData.robberyScore = v.robberyScore
    tempData.opponentScore = v.opponentScore 
    tempData.order = lang.trans("peak_num_scene", index)
    return tempData
end

function TransportMatchDetailsModel:CheckIsHaveTeam(mTid)
    local mTeams = cache.getPlayerTeams()
    for k,v in pairs(mTeams.teams) do
        if tonumber(v.tid) == mTid - 1 and tonumber(v.captain) > 0 then
            return true
        end
    end
    return false
end

function TransportMatchDetailsModel:SetTeamID(mTid)
    self.mTid = mTid
end

function TransportMatchDetailsModel:GetTeamID()
    return self.mTid
end

function TransportMatchDetailsModel:GetUrlData()
    local urlData = cache.getTransportIds()
    urlData.ptid = self.mTid - 1
    urlData.robberyId = self.data.robberyId
    return urlData
end

return TransportMatchDetailsModel