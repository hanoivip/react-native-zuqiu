local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Timer = require("ui.common.Timer")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local StoreMarketDialog = class(unity.base)

function StoreMarketDialog:ctor()
--------Start_Auto_Generate--------
    self.titleTxt = self.___ex.titleTxt
    self.contentTrans = self.___ex.contentTrans
    self.residualTimerTxt = self.___ex.residualTimerTxt
    self.closeBtnSpt = self.___ex.closeBtnSpt
--------End_Auto_Generate----------
    self.itemObjPath = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Dialog/Shop/AdventureStoreItem.prefab"
    self.itemSptMap = {}
end

function StoreMarketDialog:start()
	DialogAnimation.Appear(self.transform)
    self.closeBtnSpt:regOnButtonClick(function()
        self:Close()
    end)
end

function StoreMarketDialog:Close()
    DialogAnimation.Disappear(self.transform, nil, function() self.closeDialog() end)
end

function StoreMarketDialog:InitView(eventModel)
    self.eventModel = eventModel
    self.titleTxt.text = eventModel:GetEventName()

    local storeList = eventModel:GetStoreList()
    local itemObj = res.LoadRes(self.itemObjPath)
    for index, itemData in ipairs(storeList) do
        local id = itemData.id
        local spt = self.itemSptMap[id]
        if not spt then
            local o = Object.Instantiate(itemObj)
            o.transform:SetParent(self.contentTrans, false)
            spt = res.GetLuaScript(o)
            self.itemSptMap[id] = spt
        end
        spt:InitView(itemData)
        spt.buyClick = function()
            if self.buyClick then
                self.buyClick(itemData)
            end
        end
    end
    self:RefreshTimer()
end

function StoreMarketDialog:RefreshTimer()
    if self.residualTimer ~= nil then
        self.residualTimer:Destroy()
    end
    local remainTime = self.eventModel:GetRemainTime()
    if remainTime <= 1 then
        self:SetRunOutOfTimeView()
        return
    end
    self.residualTimer = Timer.new(remainTime, function(time)
        if time <= 1 then
            self:SetRunOutOfTimeView()
            return
        else
            local t = string.convertSecondToTime(time)
            self.residualTimerTxt.text = t
        end
    end)
end

function StoreMarketDialog:SetRunOutOfTimeView()
    if self.residualTimer ~= nil then
        self.residualTimer:Destroy()
    end
    if self.runOutOfTime then
        self.runOutOfTime()
    end
    self.residualTimerTxt.text = lang.trans("belatedGift_item_nil_time")
end

function StoreMarketDialog:OnExitScene()
    if self.residualTimer ~= nil then
        self.residualTimer:Destroy()
    end
end

return StoreMarketDialog
