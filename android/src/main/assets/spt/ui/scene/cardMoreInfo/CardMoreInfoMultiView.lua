local AssetFinder = require("ui.common.AssetFinder")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CardMoreInfoMultiView = class(unity.base)

local chemicalPath = "Assets/CapstonesRes/Game/UI/Scene/CardMoreInfo/ChemicalItem.prefab"
local bestPatnerPath = "Assets/CapstonesRes/Game/UI/Scene/CardMoreInfo/BestParterItem.prefab"
local letterPath = "Assets/CapstonesRes/Game/UI/Scene/CardMoreInfo/JoinedLetterItem.prefab"

function CardMoreInfoMultiView:ctor()
    self.contentRect = self.___ex.contentRect
    self.playerNameTxt = self.___ex.playerNameTxt
    self.bestPatnerTitleTxt = self.___ex.bestPatnerTitleTxt
    self.letterTxt = self.___ex.letterTxt
    self.none = self.___ex.none
end

function CardMoreInfoMultiView:InitView(cardModel, playerLetterData)
    local mySelfCid = cardModel:GetCid()
    local chemicalCards = cardModel:GetJoinedChemicalList()
    local maxChemicalItem = 0
    for k, cid in pairs(chemicalCards) do
        local obj, spt = res.Instantiate(chemicalPath)
        obj.transform:SetParent(self.contentRect, false)
        spt:InitView(cid, mySelfCid, self:GetCardRes())
        maxChemicalItem = maxChemicalItem + 1
    end
    GameObjectHelper.FastSetActive(self.playerNameTxt.transform.parent.gameObject, maxChemicalItem ~= 0)

    self.playerNameTxt.text = lang.trans("joined_chemical", cardModel:GetName())
    self.bestPatnerTitleTxt.text = lang.trans("joined_best_partner", cardModel:GetName())
    self.letterTxt.text = lang.trans("joined_letter", cardModel:GetName())
    -- 最佳拍档标题的位置
    self.bestPatnerTitleTxt.transform.parent:SetSiblingIndex(maxChemicalItem + 2)
    -- 最佳拍档
    local partnerList = cardModel:GetJoinedBestPartnerList()
    if next(partnerList) then
        local obj, spt = res.Instantiate(bestPatnerPath)
        spt:InitView(partnerList, cardModel)
        obj.transform:SetParent(self.contentRect, false)
    end
    GameObjectHelper.FastSetActive(self.bestPatnerTitleTxt.transform.parent.gameObject, next(partnerList))

    -- 来信标题的位置
    local index = maxChemicalItem
    if maxChemicalItem ~= 0 then
        index = index + 1
    end
    if next(partnerList) then
        index = table.nums(partnerList) + index + 2
    end
    self.letterTxt.transform.parent:SetSiblingIndex(index)
    local letterData = cardModel:GetJoinedLetterList()
    for k, v in pairs(playerLetterData) do
        if type(v.cond.card) == "table" then
            local isFinish = {}
            for k, v in pairs(v.cond.card) do
                isFinish[k] = true
            end
            if letterData[tostring(v.ID)] then
                letterData[tostring(v.ID)].isFinish = isFinish
            end
        end
    end
    local maxLetterItem = 0
    for k, v in pairs(letterData) do
        if v.letterPlayer and next(v.letterPlayer) then
            local obj, spt = res.Instantiate(letterPath)
            spt:InitView(v)
            obj.transform:SetParent(self.contentRect, false)
            maxLetterItem = maxLetterItem + 1
        end
    end
    GameObjectHelper.FastSetActive(self.letterTxt.transform.parent.gameObject, maxLetterItem ~= 0)
    local chemicalNums = table.nums(chemicalCards)
    local bestParterNums = table.nums(partnerList)
    local letterNums = 0
    for k, v in pairs(letterData) do
        if next(v) and v.letterPlayer ~= nil then
            letterNums = letterNums + 1
        end
    end
    GameObjectHelper.FastSetActive(self.none, chemicalNums == 0 and bestParterNums == 0 and letterNums == 0)
end

function CardMoreInfoMultiView:GetCardRes()
    if not self.cardRes then
        self.cardRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/CardDetail/ChimicalCard.prefab")
    end
    return self.cardRes
end

return CardMoreInfoMultiView
