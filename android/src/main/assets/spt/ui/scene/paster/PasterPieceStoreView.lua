local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CardPastersMapModel = require("ui.models.CardPastersMapModel")
local CardResourceCache = require("ui.common.card.CardResourceCache")
local PasterPieceStoreView = class(unity.base)

function PasterPieceStoreView:ctor()
    self.scrollView = self.___ex.scrollView
    self.weekPieceNum = self.___ex.weekPieceNum
    self.monthPieceNum = self.___ex.monthPieceNum
    self.weekPiece = self.___ex.weekPiece
    self.monthPiece = self.___ex.monthPiece
    self.lastTime = self.___ex.lastTime
    self.cardResourceCache = CardResourceCache.new()
    self.cardPastersMapModel = CardPastersMapModel.new()
    self:RegScrollViewHandle()
end

function PasterPieceStoreView:SetLastTime(pasterPieceStoreModel)
    local time = pasterPieceStoreModel:GetLastTime()
    if time then 
        local lastTime = string.convertSecondToMonth(time)
        self.lastTime.text = lang.transstr("end_time") .. lastTime
    else
        self.lastTime.text = ""
    end
end

function PasterPieceStoreView:GetPasterRes()
    if not self.pasterRes then 
        self.pasterRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Paster/Paster.prefab")
    end
    return self.pasterRes
end

function PasterPieceStoreView:GetPasterPieceFrameRes()
    if not self.pasterPieceFrameRes then 
        self.pasterPieceFrameRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Paster/PasterPieceFrame.prefab")
    end
    return self.pasterPieceFrameRes
end

function PasterPieceStoreView:RegScrollViewHandle()
    self.scrollView:regOnCreateItem(function(scrollSelf, index)
        local pasterPieceFrameRes = self:GetPasterPieceFrameRes()
        local obj = Object.Instantiate(pasterPieceFrameRes)
        local spt = res.GetLuaScript(obj)
        scrollSelf:resetItem(spt, index)
        return obj
    end)
    self.scrollView:regOnResetItem(function(scrollSelf, spt, index)
        local pasterModel = scrollSelf.itemDatas[index]  -- PasterModel
        local pasterRes = self:GetPasterRes()
        spt:InitView(pasterModel, index, self.cardResourceCache, pasterRes, self.cardPastersMapModel)
        spt.clickPaster = function()
            self:OnPasterClick(pasterModel) 
        end
        spt.clickBuy = function()
            self:OnExchangePaster(pasterModel) 
        end
        scrollSelf:updateItemIndex(spt, index)
    end)
end

function PasterPieceStoreView:start()
end

function PasterPieceStoreView:Close()
end

function PasterPieceStoreView:InitView(pasterPieceStoreModel, cacheScrollPos, pasterType)
    self:SetLastTime(pasterPieceStoreModel)
    local pasterListModelMap = pasterPieceStoreModel:GetPasterListModelMap(pasterType)
    self.scrollView:refresh(pasterListModelMap, cacheScrollPos)
    self:UpdatePieceNum(pasterPieceStoreModel)

    local isShowWeekPiece = false
    local isShowMonthPiece = false
    if not pasterType then 
        isShowWeekPiece = true
        isShowMonthPiece = true
    else
        isShowWeekPiece = tobool(tonumber(pasterType) == 1)
        isShowMonthPiece = tobool(tonumber(pasterType) == 2)
    end
    GameObjectHelper.FastSetActive(self.weekPiece, isShowWeekPiece)
    GameObjectHelper.FastSetActive(self.monthPiece, isShowMonthPiece)
end

function PasterPieceStoreView:UpdatePieceNum(pasterPieceStoreModel)
    local weekPieceNum = pasterPieceStoreModel:GetWeekPieceNum()
    local monthPieceNum = pasterPieceStoreModel:GetMonthPieceNum()
    self.weekPieceNum.text = "x" .. weekPieceNum
    self.monthPieceNum.text = "x" .. monthPieceNum
end

function PasterPieceStoreView:onDestroy()
    self.pasterRes = nil
    self.pasterPieceFrameRes = nil
end

function PasterPieceStoreView:OnPasterClick(pasterModel)
    if self.pasterClick then 
        self.pasterClick(pasterModel)
    end
end

function PasterPieceStoreView:OnExchangePaster(pasterModel)
    if self.exchangePaster then 
        self.exchangePaster(pasterModel)
    end
end

function PasterPieceStoreView:ShowPageVisible(isShow)
    GameObjectHelper.FastSetActive(self.gameObject, isShow)
end

return PasterPieceStoreView
