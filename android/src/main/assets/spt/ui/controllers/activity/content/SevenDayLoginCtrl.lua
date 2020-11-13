local BaseCtrl = require("ui.controllers.BaseCtrl")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local EventSystem = require("EventSystem")
local SevenDayLoginCtrl = class(BaseCtrl, "SevenDayLoginCtrl")

SevenDayLoginCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

SevenDayLoginCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/Calendar/SevenDayBroad.prefab"
function SevenDayLoginCtrl:ctor()
end

function SevenDayLoginCtrl:Init(sevenDayLoginModel)
    self.sevenDayLoginModel = sevenDayLoginModel
    self:InitView()
end

function SevenDayLoginCtrl:GetStatusData()
    return self.sevenDayLoginModel
end

function SevenDayLoginCtrl:InitView()
    self.view.onClose = function() self:OnClose() end
    self.view:InitView(self.sevenDayLoginModel)
    self:CreateItemList()
end

function SevenDayLoginCtrl:CreateItemList()
    self.view.scrollView.onScrollCreateItem = function(index)
        local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Activties/Calendar/SevenDayItem.prefab")
        return obj, spt
    end
    self.view.scrollView.onScrollResetItem = function(spt, index)
        local tempData = self.view.scrollView.itemDatas[index]
        spt.onRewardBtnClick = function (subID, stateCallBack) self:OnRewardBtnClick(subID, stateCallBack) end
        spt:InitView(tempData)
        self.view.scrollView:updateItemIndex(spt, index)
    end
    self:RefreshScrollView()
end

function SevenDayLoginCtrl:RefreshScrollView()
    self.view.scrollView:clearData()
    self.view.scrollView.itemDatas = self.sevenDayLoginModel:GetGiftList()
    self.view.scrollView:refresh()
end

function SevenDayLoginCtrl:OnRewardBtnClick(subID, stateCallBack)
    clr.coroutine(function()
        local response = req.activityReceive(self.sevenDayLoginModel:GetType(), subID)
        if api.success(response) then
            local data = response.val
            if data and next(data) then
                CongratulationsPageCtrl.new(data.contents)
                stateCallBack()
                if self.sevenDayLoginModel:IsEnd(subID) then
                    local flags = clone(cache.getEnterBtnGroupShowFlags())
                    flags.sevenDayShow = false
                    cache.setEnterBtnGroupShowFlags(flags)
                    EventSystem.SendEvent("RefreshHomeEnterBtnState")
                end
            end
        end
    end)
end

function SevenDayLoginCtrl:OnClose()
    EventSystem.SendEvent("HomeEnterBtnAtuoShow")
end

return SevenDayLoginCtrl
