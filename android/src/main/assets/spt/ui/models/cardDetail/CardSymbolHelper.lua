local PlayerChemical = require("data.PlayerChemical")
local Card = require("data.Card")
local Skills = require("data.Skills")
local PlayerTeamsModel = require("ui.models.PlayerTeamsModel")
local CardSymbolHelper = {}

--获取化学反应的cids
function CardSymbolHelper.GetChemicalCids(cidList, cCidList)
    for _,mCid in pairs(cidList) do
        if PlayerChemical[mCid] then
            for _, playerInfo in pairs(PlayerChemical[mCid]) do
                if playerInfo and playerInfo.cids then
                    for __, playerCid in pairs(playerInfo.cids) do
                        --去重
                        cCidList[playerCid] = mCid
                    end
                end
            end
        end
    end
end

--获取teams 球员的化学反省cids (key)
function CardSymbolHelper.GetChemicalCidsInTeams()
    local playerTeamsModel = PlayerTeamsModel.new()
    local teamCidList = playerTeamsModel:GetTeamsCidList()
    local cCidList = {}
    if teamCidList.init and next(teamCidList.init) then
        CardSymbolHelper.GetChemicalCids(teamCidList.init, cCidList)
    end
    return cCidList
end

--获取teams 球员的最佳拍档(key)
function CardSymbolHelper.GetBestPartnerInTeams()
    local playerTeamsModel = PlayerTeamsModel.new()
    local teamCidList = playerTeamsModel:GetTeamsCidList()
    local bCidList = {}
    if teamCidList.init and next(teamCidList.init) then
        CardSymbolHelper.GetBestPartnerCids(teamCidList.init, bCidList)
    end
    return bCidList
end

--获取最佳拍档的cids
function CardSymbolHelper.GetBestPartnerCids(cidList,bCidList)
    for k, v in pairs(cidList) do
        for _, skill in pairs(Card[v].skill) do
            local skillData = Skills[skill]
            if skillData and skillData.type == 3 then
                bCidList[skillData.cardID2] = v
            end
        end
    end
end
return CardSymbolHelper