local Model = require("ui.models.Model")
local IntroduceConstants = require("ui.models.compete.introduce.IntroduceConstants")
local RewardScrollerItemModel = class(Model)

function RewardScrollerItemModel:ctor(data)
	RewardScrollerItemModel.super.ctor(self)
    self.data = data
end

function RewardScrollerItemModel:ParseModelData()
    self.data.rankLow = nil
    self.data.rankHigh = nil
    self.data.leftText = nil
    local matchType = self:GetMatchType()
    local resultShow = self:GetResultShow()
    local resultType = self:GetResultType()

    if #matchType == 1 then
        if self:IsInSeven(tonumber(matchType[1])) then
            if self:IsRankType(resultType) then --yellow
                if #resultShow == 2 then
                    self.data.rankLow = tonumber(resultShow[1])
                    self.data.rankHigh = tonumber(resultShow[2])
                else
                    self.data.rankLow = tonumber(resultShow[1])
                    self.data.rankHigh = tonumber(resultShow[1])
                end
            elseif self:IsWinType(resultType) then --grey
                if tonumber(resultShow[1]) == IntroduceConstants.WIN_RESULT then
                    self.data.leftText = lang.transstr("compete_introduce_label13")
                else
                    self.data.leftText = lang.transstr("compete_introduce_label14")
                end
            elseif tonumber(resultShow[1]) == IntroduceConstants.TIE_OR_OUT_RESULT then --orange
                self.data.leftText = lang.transstr("compete_introduce_label16")
            else
                self.data.leftText = lang.transstr("compete_introduce_label17")
            end
        elseif self:IsRankType(resultType) then  --green
            self.data.leftText = lang.transstr("compete_introduce_label18", tostring(resultShow[1]))
        elseif self:IsWinType(resultType) then   --blue
            self.data.leftText = lang.transstr("compete_introduce_label19")
        else                                   --greenish
            self.data.leftText = lang.transstr("compete_introduce_label20")
        end
        if (matchType[1] == IntroduceConstants.BIG_EAR_CUP_GROUP or matchType[1] == IntroduceConstants.SMALL_EAR_CUP_GROUP) and self:IsWinType(resultType) then
            self.data.leftText = lang.transstr("compete_introduce_label30")
        end
    elseif tonumber(resultShow[1]) == IntroduceConstants.WIN_RESULT then     --white
        self.data.leftText = lang.transstr("compete_introduce_label21")
    elseif tonumber(resultShow[1]) == IntroduceConstants.TIE_OR_OUT_RESULT then
        self.data.leftText = lang.transstr("compete_introduce_label22")
    else
        self.data.leftText = lang.transstr("compete_introduce_label23")
    end
end

function RewardScrollerItemModel:Get()
end

function RewardScrollerItemModel:GetMatchType()
    return self.data.matchType
end

function RewardScrollerItemModel:GetItem()
    return self.data.item
end

function RewardScrollerItemModel:GetResultType()
    return self.data.resultType
end

function RewardScrollerItemModel:GetResultShow()
    return self.data.resultShow
end

function RewardScrollerItemModel:IsInSeven(num)
    if num ~= tonumber(IntroduceConstants.BIG_EAR_CUP_GROUP) and num ~= tonumber(IntroduceConstants.BIG_EAR_CUP_PRELININARY) and num ~= tonumber(IntroduceConstants.SMALL_EAR_CUP_GROUP) and num ~= tonumber(IntroduceConstants.SMALL_EAR_CUP_PRELIMINARY) then
        return true
    else
        return false
    end
end

function RewardScrollerItemModel:IsRankType(resultType)
    if tonumber(resultType) == IntroduceConstants.RANK_TYPE then
        return true
    else
        return false
    end
end

function RewardScrollerItemModel:IsWinType(resultType)
    if tonumber(resultType) == IntroduceConstants.WIN_TYPE then
        return true
    else
        return false
    end
end

function RewardScrollerItemModel:GetDataItem()
    local rewardIDs = {}
    local rewardItemNum = {}                                                                          
    for k,v in ipairs(self.data.contents.item) do
        table.insert(rewardIDs, v.id)
        table.insert(rewardItemNum, v.num)
    end
    return rewardIDs, rewardItemNum
end

return RewardScrollerItemModel