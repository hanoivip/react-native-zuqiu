local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector2 = UnityEngine.Vector2
local Vector3 = UnityEngine.Vector3
local GameObjectHelper = require("ui.common.GameObjectHelper")
local MenuType = require("ui.controllers.playerList.MenuType")
local CardResourceCache = require("ui.common.card.CardResourceCache")
local CardBuilder = require("ui.common.card.CardBuilder")
local CardOpenFromType = require("ui.controllers.cardDetail.CardOpenFromType")
local ThreeRollCtrl = require("ui.controllers.activity.content.recruitReward.ThreeRollCtrl")

local SpecialCardView = class(unity.base)

local scaleFactor = 1.25
local scaleOriginal = 1

function SpecialCardView:ctor()
    SpecialCardView.super.ctor(self)
    self.contentTrans = self.___ex.contentTrans
    self.staticCardArea = self.___ex.staticCardArea
    self.moreThan2Obj = self.___ex.moreThan2Obj
    self.oneOrTwoObj = self.___ex.oneOrTwoObj

    self.threeRollRect = self.___ex.threeRollRect
    self.threeRollCtrl = self.___ex.threeRollCtrl
    self.btnLeftSwitch = self.___ex.btnLeftSwitch
    self.btnRightSwitch = self.___ex.btnRightSwitch
end

function SpecialCardView:OnCardClick(cid)
    -- 点击卡牌，弹出卡牌详情页面
    local cardList = self.specialCardCidList
    for i, v in ipairs(cardList) do
        if tostring(v) == tostring(cid) then
            local currentModel = CardBuilder.GetBaseCardModel(cid)
            --开启贴纸图鉴模式
            currentModel:SetIsPasterPokedex(true)
            currentModel:SetOpenFromPageType(CardOpenFromType.HANDBOOK)
            clr.coroutine(function()
                unity.waitForEndOfFrame()
                local CardDetailMainCtrl = res.PushSceneImmediate("ui.controllers.cardDetail.CardDetailMainCtrl", cardList, i, currentModel)
            end)
            break
        end
    end
end

function SpecialCardView:GetCardRes()
    if not self.cardRes then 
        self.cardRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Card/Prefab/Card.prefab")
    end
    return self.cardRes
end

function SpecialCardView:GetPlayerRes()
    if not self.playerRes then 
        self.playerRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/PlayerList/Player.prefab")
    end
    return self.playerRes
end

function SpecialCardView:GetScrollNormalizedPosition()
    return self:getScrollNormalizedPos()
end

function SpecialCardView:RefreshItemWithScrollPos(data, scrollPos, cardIndexModel)
    self.cardResourceCache = CardResourceCache.new()
    self.cardIndexModel = cardIndexModel
    self.specialCardCidList = data

    local specialCardList = {}
    for i, cid in ipairs(data) do
        local cardModel = self.cardIndexModel:GetCardModel(cid)
        table.insert(specialCardList, cardModel)
    end
    
    GameObjectHelper.FastSetActive(self.oneOrTwoObj, #specialCardList < 3)
    GameObjectHelper.FastSetActive(self.moreThan2Obj, #specialCardList > 2)

    if #specialCardList == 1 then
        self:CreateOneCardHere(specialCardList)
    elseif #specialCardList == 2 then
        self:CreateTwoCardsHere(specialCardList)
    else
        local needVariables = {
            isElastic = true,
            scaleOriginal = scaleOriginal,
            scaleFactor = scaleFactor,
            offsetRatio = 1,
            parentCtrl = self,
            positionList = {lHidden = Vector3Lua(-320, 0, 0), left = Vector3Lua(-170, 0, 0), middle = Vector3Lua(0, 0, 0), right = Vector3Lua(170, 0, 0), rHidden = Vector3Lua(320, 0, 0)},
            btnLeftSwitch = self.btnLeftSwitch,
            btnRightSwitch = self.btnRightSwitch,
            isLoop = false,
        }   

        self.threeRollCtrl:InitVariables(specialCardList, 2, self.threeRollRect, needVariables)
    end
end

function SpecialCardView:CreateOnePrefab(scaleValueVector, prefabData)
    local obj = Object.Instantiate(self:GetPlayerRes())
    obj.transform.localScale = self:ConvertVector3(scaleValueVector)
    obj.transform:SetParent(self.threeRollRect, false)
    obj.transform.pivot = Vector2(0.5, 0.5)
    obj.transform.anchorMin = Vector2(0.5, 0.5)
    obj.transform.anchorMax = Vector2(0.5, 0.5)

    return self:ResetOnePrefab(obj, prefabData)
end

function SpecialCardView:ResetOnePrefab(obj, prefabData)
    local spt = res.GetLuaScript(obj)
    local itemData = prefabData
    spt:InitView(itemData, MenuType.LIST, self.cardIndexModel, self.cardResourceCache, self)
    itemData:InitEquipsAndSkills()
    spt:SetCardTip(false)
    spt:SetNameBg(false)
    GameObjectHelper.FastSetActive(spt.message, false)
    spt.clickCard = function() self:OnCardClick(itemData:GetCid()) end

    return obj
end

function SpecialCardView:CreateOneCardHere(specialCardList)
    local scaleVector = Vector3Lua(scaleFactor, scaleFactor, 1)
    local obj = self:CreateOnePrefab(scaleVector, specialCardList[1])

    obj.transform:SetParent(self.staticCardArea, false)
    obj.transform.localPosition = Vector3(0, 0, 0)
end

function SpecialCardView:CreateTwoCardsHere(specialCardList)
    local scaleVector = Vector3Lua(scaleFactor, scaleFactor, 1)
    local obj = self:CreateOnePrefab(scaleVector, specialCardList[1])
    obj.transform:SetParent(self.staticCardArea, false)
    obj.transform.localPosition = Vector3(-100, 0, 0)

    local scaleVector = Vector3Lua(scaleFactor, scaleFactor, 1)
    local obj = self:CreateOnePrefab(scaleVector, specialCardList[2])
    obj.transform:SetParent(self.staticCardArea, false)
    obj.transform.localPosition = Vector3(100, 0, 0)
end

function SpecialCardView:ConvertVector3(vector)
    return Vector3(vector.x, vector.y, vector.z)
end

return SpecialCardView