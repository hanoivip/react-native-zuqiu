local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local ItemModel = require("ui.models.cardDetail.ItemModel")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local FancyStarUpView = class(unity.base)

function FancyStarUpView:ctor()
    self.closeBtn = self.___ex.closeBtn
    self.cardParent = self.___ex.cardParent
    self.cardGroup = self.___ex.cardGroup
    self.cardBigGroup = self.___ex.cardBigGroup
    self.cardCount = self.___ex.cardCount
    self.curStar = self.___ex.curStar
    self.curStarAttr = self.___ex.curStarAttr
    self.nextStar = self.___ex.nextStar
    self.nextStarAttr = self.___ex.nextStarAttr
    self.unNextStar = self.___ex.unNextStar
    self.operateBtn = self.___ex.operateBtn
    self.cost = self.___ex.cost
    self.costShow = self.___ex.costShow
    self.noneStar = self.___ex.noneStar
    self.cardName = self.___ex.cardName
    self.InfoBar = self.___ex.InfoBar
    self.effect = self.___ex.effect
end

function FancyStarUpView:start()
    self.closeBtn:regOnButtonClick(function ()
        self:Close()
    end)
    self.operateBtn:regOnButtonClick(function ()
        self:OnStarUpReq()
    end)
    self:PlayInAnimator()
    EventSystem.AddEvent("FancyUpStar", self, self.FancyUpStar)
end

function FancyStarUpView:InitView(card)
    self.card = card
    local itemObj, itemSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Fancy/Prefab/FancyCardBig.prefab")
    itemObj.transform:SetParent(self.cardParent.transform, false)
    itemSpt:InitView(card, {showStar = true})
    self.itemSpt = itemSpt
    self.cardGroup.text = card:GetBigGroupName()
    self.cardBigGroup.text = card:GetGroupName()
    self.cardName.text = card:GetName()
    self:ShowStarInfo()
end

function FancyStarUpView:GetCountText(haveCount, costCount, bUnit)
    local str = bUnit and string.formatNumWithUnit(costCount) or tostring(costCount)
    if haveCount >= costCount then
        return "<color=#9bef49FF>" .. str .. "</color>"
    else
        self.bCanUp = false
        return "<color=#ef4949ff>" .. str .. "</color>"
    end
end

local function GetAddStr(attr, skillLevel, addAttr)
    local str = lang.transstr("fancyAttrContent") .. ": " .. attr
    if tobool(addAttr) then
        str = str .. " <color=#9bef49FF>+" .. addAttr .. "</color>"
    end
    if skillLevel > 0 then
        str = str .. '\n' .. lang.transstr("fancyAttrLevelContent") .. "+" .. skillLevel
    end
    return str
end

function FancyStarUpView:ShowStarInfo()
    self.cardCount.text = tostring(self.card:GetCount()) .. lang.transstr("fancy_count")
    local star = self.card:GetStar()
    for i = 1, 6 do
        GameObjectHelper.FastSetActive(self.curStar['s' .. i], star >= i)
    end
    local curAttr = self.card:GetStarUpAttr()
    
    self.curStarAttr.text = GetAddStr(curAttr, self.card:GetSkillAdd())
    local bHaveNextAttr = self.card:IsHaveNextStar()
    GameObjectHelper.FastSetActive(self.unNextStar.gameObject, not bHaveNextAttr)
    GameObjectHelper.FastSetActive(self.operateBtn.gameObject, bHaveNextAttr)
    GameObjectHelper.FastSetActive(self.cost.gameObject, bHaveNextAttr)
    GameObjectHelper.FastSetActive(self.noneStar, star == 0)
    if bHaveNextAttr then
        self.nextStarAttr.text = GetAddStr(curAttr, self.card:GetNextSkillAdd(), self.card:GetNextStarUpAttr() - curAttr)
    else
        self.nextStarAttr.text = lang.transstr("fancyStarOverContent")
    end
    for i = 1, 6 do
        GameObjectHelper.FastSetActive(self.nextStar['s' .. i], bHaveNextAttr and (star + 1 >= i) or false)
    end
    --显示消耗
    if bHaveNextAttr then
        self.bCanUp = true
        local playerInfoModel = PlayerInfoModel.new()
        local starConfig = self.card:GetStarUpConfig()
        if starConfig.fancyCard > 0 then
            local data = {}
            data.name = self.card:GetName()
            data.content = {fancyCard = { {id = self.card:GetID()}}}
            data.count = self:GetCountText(self.card:GetCount(), starConfig.fancyCard)
            GameObjectHelper.FastSetActive(self.costShow.card.gameObject, true)
            self.costShow.card:InitView(data)
        else
            GameObjectHelper.FastSetActive(self.costShow.card.gameObject, false)
        end
        local costTb = {}
        if starConfig.d > 0 then
            local itemModel = ItemModel.new()
            itemModel:InitWithDiamondAddNum(0)
            local data = {}
            data.name = itemModel:GetName()
            data.count = self:GetCountText(playerInfoModel:GetDiamond(), starConfig.d)
            data.content = {d = starConfig.d}
            table.insert(costTb, data)
        end
        if starConfig.m > 0 then
            local itemModel = ItemModel.new()
            itemModel:InitWithMoneyAddNum(0)
            local data = {}
            data.name = itemModel:GetName()
            data.count = self:GetCountText(playerInfoModel:GetMoney(), starConfig.m, true)
            data.content = {m = starConfig.m}
            table.insert(costTb, data)
        end
        if starConfig.fs > 0 then
            local itemModel = ItemModel.new()
            itemModel:InitWithFsAddNum(0)
            local data = {}
            data.name = itemModel:GetName()
            data.count = self:GetCountText(playerInfoModel:GetFS(), starConfig.fs)
            data.content = {fs = starConfig.fs}
            table.insert(costTb, data)
        end
        if starConfig.fancyPiece > 0 then
            local itemModel = ItemModel.new()
            itemModel:InitWithFancyPieceAddNum(0)
            local data = {}
            data.name = itemModel:GetName()
            data.count = self:GetCountText(playerInfoModel:GetFancyPiece(), starConfig.fancyPiece)
            data.content = {fancyPiece = starConfig.fancyPiece}
            table.insert(costTb, data)
        end

        for i = 1, 3 do
            local costInfo = costTb[i]
            local costUI = self.costShow['c' .. i]
            if costInfo then
                GameObjectHelper.FastSetActive(costUI.gameObject, true)
                costUI:InitView(costInfo)
            else
                GameObjectHelper.FastSetActive(costUI.gameObject, false)
            end
        end
        GameObjectHelper.FastSetActive(self.effect, self.bCanUp)
    end
end

function FancyStarUpView:FancyUpStar()
    self.itemSpt:RefreshStar(true)
    self:ShowStarInfo()
end

function FancyStarUpView:OnConfirm()
    self:Close()
end
--申请升级
function FancyStarUpView:OnStarUpReq()
    if self.StarUp then
        self.StarUp()
    end
end
function FancyStarUpView:PlayInAnimator()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function FancyStarUpView:PlayOutAnimator()
    DialogAnimation.Disappear(self.transform, self.canvasGroup, function() self:CloseView() end)
end

function FancyStarUpView:CloseView()
    EventSystem.RemoveEvent("FancyUpStar", self, self.FancyUpStar)
    if type(self.closeDialog) == 'function' then
        self.closeDialog()
    end
end

function FancyStarUpView:Close()
    self:PlayOutAnimator()
end

return FancyStarUpView