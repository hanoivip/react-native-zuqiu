local Card = require("data.Card")
local LegendRoadPlayer = require("data.LegendRoadPlayer")
local CardHelper = require("ui.scene.cardDetail.CardHelper")
local LegendRoadImprove = require("data.LegendRoadImprove")

-- 计算传奇之路属性加成辅助脚本
local LegendRoadImproveModel = {}

local _improveTypeKey = "improveType"
local _detailImproveKey = "detailImprove"
local _improveAttributeKey = "improveAttribute" -- 该球员解锁了ImproveType为3时所增加的属性

-- 根据卡牌品质和关卡获得属性加成
-- @return: (improveType = val, detailImprove = val)，若未找到，返回nil
function LegendRoadImproveModel.GetConfigPlayer(baseId)
    return LegendRoadPlayer[baseId]
end

function LegendRoadImproveModel.GetCardData(cid)
    local cardData = Card[tostring(cid)] or {}
    return cardData
end

function LegendRoadImproveModel.GetConfigPlayerByCid(cid)
    local cardData = LegendRoadImproveModel.GetCardData(cid)
    local baseId = cardData.baseID
    return LegendRoadImproveModel.GetConfigPlayer(baseId)
end

function LegendRoadImproveModel.GetImproveAttr(cid)
    local configPlayer = LegendRoadImproveModel.GetConfigPlayerByCid(cid)
    local attrListMap = configPlayer[_improveAttributeKey]
    return attrListMap
end

function LegendRoadImproveModel.GetImproveConfig(cid, chapter, stage)
    local cardData = Card[tostring(cid)] or {}
    local quality = cardData.quality
    local qualitySpecial = cardData.qualitySpecial or 0

    local qualitySuffix = tostring(CardHelper.GetQualityConfigFixed(quality, qualitySpecial))
    local chapterData = LegendRoadImprove[tostring(chapter)]
    if chapterData then
        local stageData = chapterData[tostring(stage)]
        if stageData then
            local improveTypeVal = stageData[_improveTypeKey .. qualitySuffix]
            local detailImproveVal = stageData[_detailImproveKey .. qualitySuffix]
            if improveTypeVal ~= nil and detailImproveVal ~= nil then
                return {
                    [_improveTypeKey] = improveTypeVal,
                    [_detailImproveKey] = detailImproveVal,
                }
            else
                return nil
            end
        else
            return nil
        end
    else
        return nil
    end
end

return LegendRoadImproveModel
