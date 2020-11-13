local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local LuaButton = require("ui.control.button.LuaButton")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CardIndexPlayer = class(LuaButton)

function CardIndexPlayer:ctor()
    CardIndexPlayer.super.ctor(self)
    -- 卡牌父节点
    self.cardParent = self.___ex.cardParent
    -- 名称
    self.nameTxt = self.___ex.name
    -- 遮罩
    self.mask = self.___ex.mask
    -- 点击区域
    self.playerCardStaticModel = nil
    self.cardIndexModel = nil
    self.cardIndexViewModel = nil
    self.cardView = nil
end

function CardIndexPlayer:InitView(cardModel, cardIndexViewModel)
    self.playerCardStaticModel = cardModel
    self.cardIndexViewModel = cardIndexViewModel
    self.cardIndexModel = cardIndexViewModel:GetModel()
    
    self:BuildPage()
end

function CardIndexPlayer:start()
    self:BindAll()
end

function CardIndexPlayer:BindAll()
    self:regOnButtonClick(function()
        EventSystem.SendEvent("CardIndex.ShowCardDetail", self.playerCardStaticModel:GetCid())
    end)
end

function CardIndexPlayer:BuildPage()
    if not self.cardView then
        self:coroutine(function ()
            local loadInfo = res.LoadResAsync("Assets/CapstonesRes/Game/UI/Common/Card/Prefab/Card.prefab")
            if loadInfo then
                while not loadInfo.isDone do
                    unity.waitForNextEndOfFrame()
                end
                local prefab = loadInfo.asset
                if prefab then
                    local cardObject = Object.Instantiate(prefab)
                    cardObject.transform:SetParent(self.cardParent, false)
                    self.cardView = cardObject:GetComponent(clr.CapsUnityLuaBehav)
                    self.cardView:SetCardResourceCache(self.cardIndexViewModel:GetCardResCache())
                    self.cardView:InitView(self.playerCardStaticModel)
                end
            end
        end)
    else
        self.cardView:InitView(self.playerCardStaticModel)
    end
    self.nameTxt.text = self.playerCardStaticModel:GetName()
    GameObjectHelper.FastSetActive(self.mask.gameObject, not self.cardIndexModel:IsCardGeted(self.playerCardStaticModel:GetCid()))
end

return CardIndexPlayer
