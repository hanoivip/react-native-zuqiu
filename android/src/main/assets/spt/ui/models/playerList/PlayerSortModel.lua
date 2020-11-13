local PlayerSortModel = class()

function PlayerSortModel:ctor()
    self.priorityMap = {}
    self.powerMap = {}
    self.rarityMap = {}
    self.qualitySpecialMap = {}
end

function PlayerSortModel:GetQualitySpecial(cardModel)
    local pcid = cardModel:GetPcid();
    local qualitySpecial = self.qualitySpecialMap[pcid]
    if not qualitySpecial then
        qualitySpecial = cardModel:GetCardQualitySpecial()
        self.qualitySpecialMap[pcid] = qualitySpecial
    end
    return qualitySpecial
end

function PlayerSortModel:GetPlayerPriority(cardModel, playerTeamsModel)
    local pcid = cardModel:GetPcid()
    local priority = self.priorityMap[pcid]
    if not priority then 
        if playerTeamsModel:IsPlayerInInitTeam(pcid) then
            priority = 2
        elseif playerTeamsModel:IsPlayerInReplaceTeam(pcid) then
            priority = 1
        else
            priority = 0
        end
        self.priorityMap[pcid] = priority
    end
    return priority
end

function PlayerSortModel:GetPower(cardModel)
    local pcid = cardModel:GetPcid()
    local power = self.powerMap[pcid]
    if not power then 
        power = cardModel:GetPower()
        self.powerMap[pcid] = power
    end
    return tonumber(power)
end

function PlayerSortModel:GetRarity(cardModel)
    local pcid = cardModel:GetPcid()
    local rarity = self.rarityMap[pcid]
    if not rarity then 
        rarity = cardModel:GetRarity()
        self.rarityMap[pcid] = rarity
    end
    return tonumber(rarity)
end

function PlayerSortModel:GetName(cardModel)
    return cardModel:GetNameByEnglish()
end

return PlayerSortModel
