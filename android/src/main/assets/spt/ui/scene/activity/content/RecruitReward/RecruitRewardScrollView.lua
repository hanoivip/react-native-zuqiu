local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local EventSystem = require("EventSystem")
local RecruitRewardScrollView = class(LuaScrollRectExSameSize)

function RecruitRewardScrollView:ctor()
    RecruitRewardScrollView.super.ctor(self)

    self.scrollRect = self.___ex.scrollRect
end

function RecruitRewardScrollView:start()
end

function RecruitRewardScrollView:createItem(index)
    local prefab = "Assets/CapstonesRes/Game/UI/Scene/Activties/RecruitReward/RewardItem.prefab"
    local obj, spt = res.Instantiate(prefab)
    self:resetItem(spt, index)
    return obj
end

function RecruitRewardScrollView:resetItem(spt, index)
    spt.clickCollectBtn = function(id) self:ClickCollectBtn(id) end
    spt.showCollectedTag = function(isShow) self:ShowCollectedTag(isShow, spt) end

    local rTimeRewardState = self.recruitRewardModel:GetRecruitTimeRewardState()
    local recruitTime = tonumber(self.recruitRewardModel:GetRecruitTime())

    local data = self.itemDatas[index]
    self.spts[tostring(data.count)] = spt
    if tostring(rTimeRewardState[tostring(data.count)]) == "true" or (not self.activityState and data.count <= tonumber(self.recruitTime)) then
        data.btnStatus = -1
    elseif data.count <= tonumber(recruitTime) then
        data.btnStatus = 0
    else
        data.btnStatus = 1
    end
    spt:InitView(data, self.scrollRect, self.activityState)  
    self:updateItemIndex(spt, index)
end

function RecruitRewardScrollView:InitView(progressDataList, recruitRewardModel)
    self.recruitRewardModel = recruitRewardModel
    self.activityState = self.recruitRewardModel:GetActivityState() or false
    self.recruitTime = self.recruitRewardModel:GetRecruitTime()
    self.spts = {}
    self:refresh(progressDataList)
end

function RecruitRewardScrollView:ShowCollectedTag(isShow, spt)
    GameObjectHelper.FastSetActive(spt.collectedTag, isShow)
    if isShow then
        GameObjectHelper.FastSetActive(spt.btnCollect.gameObject, false)
        GameObjectHelper.FastSetActive(spt.btnDisable, false)
    else
        if self.activityState then
            GameObjectHelper.FastSetActive(spt.btnCollect.gameObject, spt.model.count <= tonumber(self.recruitTime))
            GameObjectHelper.FastSetActive(spt.btnDisable, spt.model.count > tonumber(self.recruitTime))
        else
            GameObjectHelper.FastSetActive(spt.btnCollect.gameObject, false)
            GameObjectHelper.FastSetActive(spt.btnDisable, true)
        end
    end
end

function RecruitRewardScrollView:ClickCollectBtn(id)
    self:coroutine(function()
        local respone = req.collectReward(self.recruitRewardModel:GetActivityType(), self.recruitRewardModel:GetCurrentPhase(),  tostring(id))
        if api.success(respone) then
            local data = respone.val
            if type(data) == "table" and next(data) then
                self:ShowCollectedTag(true, self.spts[tostring(id)])
                self.recruitRewardModel:SetRewardCollectedByNum(id)
                EventSystem.SendEvent("RecruitReward.UpdateState", id)
                local popCongratulationsPage = function()
                    CongratulationsPageCtrl.new(data.contents, false)
                end
                self:Close(popCongratulationsPage)
            end
        end
    end)
end

function RecruitRewardScrollView:Close(popCongratulationsPage)
    popCongratulationsPage()
end

return RecruitRewardScrollView
