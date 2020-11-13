local UnityEngine = clr.UnityEngine
local Input = UnityEngine.Input
local Random = UnityEngine.Random
local Vector2 = UnityEngine.Vector2
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogManager = require("ui.control.manager.DialogManager")
local Timer = require("ui.common.Timer")
local ReqEventModel = require("ui.models.event.ReqEventModel")

local TransportMainView = class(unity.base)

function TransportMainView:ctor()
    self.infoBarDynParent = self.___ex.infoBarDynParent
    self.skyRect =self.___ex.skyRect
    self.descBtn = self.___ex.descBtn
    self.matchRecordBtn = self.___ex.matchRecordBtn
    self.inviteRecordBtn = self.___ex.inviteRecordBtn
    self.bargainBtn = self.___ex.bargainBtn
    self.bestBtn = self.___ex.bestBtn
    self.refreshBtn = self.___ex.refreshBtn
    self.settingBtn = self.___ex.settingBtn
    self.bargainFreeTimeTxt = self.___ex.bargainFreeTimeTxt
    self.bestTxt = self.___ex.bestTxt
    self.refreshTimeTxt = self.___ex.refreshTimeTxt
    self.challengeTimeTxt = self.___ex.challengeTimeTxt
    self.sponsorListRect = self.___ex.sponsorListRect
    self.mySponsorScroll = self.___ex.mySponsorScroll
    self.courseBgRect = self.___ex.courseBgRect
    self.bargainPriceTxt = self.___ex.bargainPriceTxt
    self.mapRefreshTimeTxt = self.___ex.mapRefreshTimeTxt
    self.refreshMapPriceTxt = self.___ex.refreshMapPriceTxt
    self.matchRedPoint = self.___ex.matchRedPoint
    self.inviteRedPoint = self.___ex.inviteRedPoint
end

function TransportMainView:start()
    self.courseItemPath = "Assets/CapstonesRes/Game/UI/Scene/Transfort/CourseItem.prefab"
    self.sponsorItemPath = "Assets/CapstonesRes/Game/UI/Scene/Transfort/SponsorItem.prefab"

    self.descBtn:regOnButtonClick(function ()
        if self.onDescBtnClick then
            self.onDescBtnClick()
        end
    end)
    self.matchRecordBtn:regOnButtonClick(function ()
        if self.onMatchRecordBtnClick then
            self.onMatchRecordBtnClick()
        end
    end)
    self.inviteRecordBtn:regOnButtonClick(function ()
        if self.onInviteRecordBtnClick then
            self.onInviteRecordBtnClick()
        end
    end)
    self.bargainBtn:regOnButtonClick(function ()
        if self.onBargainBtnClick then
            self.onBargainBtnClick()
        end
    end)
    self.bestBtn:regOnButtonClick(function ()
        if self.onBestBtnClick then
            self.onBestBtnClick()
        end
    end)
    self.refreshBtn:regOnButtonClick(function ()
        if self.onRefreshBtnClick then
            self.onRefreshBtnClick()
        end
    end)
    self.settingBtn:regOnButtonClick(function ()
        if self.onSettingBtnClick then
            self.onSettingBtnClick()
        end
    end)
end

function TransportMainView:InitView(transportModel)
    self.transportModel = transportModel
    self:InitCourseScrollView()
    self:InitSponsorView()
    self:InitMySponsorScrollView()
    self:InitCommonView()

    if self.nextRefreshTimer then
        self.nextRefreshTimer:Destroy()
        self.nextRefreshTimer = nil
    end
    local refreshTime = self.transportModel:GetNextRefreshTime()
    if refreshTime <= 0 then return end
    self.nextRefreshTimer = Timer.new(refreshTime, function (time)
        self.transportModel:SetNextRefreshTime(toint(time))
        if time <= 0 then
            self.nextRefreshTimer:Destroy()
            self.nextRefreshTimer = nil
            EventSystem.SendEvent("Transport_Refresh_Main_View")
        end
    end)
    self:UpdateMatchRedPoint()
    self:UpdateInviteRedPoint()
end

function TransportMainView:InitMySponsorScrollView()
    self.mySponsorScroll:InitView(self.transportModel:GetMySponsorDataList(), self.transportModel)
end

function TransportMainView:InitMapRefreshTime()
    local refreshTime = self.transportModel:GetNextRefreshTime()
    self.mapRefreshTimeTxt.text = lang.trans("transport_next_refresh_time", string.convertSecondToTime(refreshTime))
end

function TransportMainView:InitCommonView()
    local bargainTime = self.transportModel:GetBargainTime()
    local maxBargainTime = self.transportModel:GetMaxBargainTime()
    local bargainPrice = self.transportModel:GetBargainPrice()
    GameObjectHelper.FastSetActive(self.bargainFreeTimeTxt.gameObject, bargainTime > 0)
    GameObjectHelper.FastSetActive(self.bargainPriceTxt.gameObject, bargainTime <= 0)
    self.bargainPriceTxt.text = "x" .. bargainPrice
    self.bargainFreeTimeTxt.text = lang.trans("transfort_free_time", bargainTime, maxBargainTime)

    local refreshedTime = self.transportModel:GetMapRefreshedTime()
    local maxRefreshTime = self.transportModel:GetMaxRefreshTime()
    GameObjectHelper.FastSetActive(self.refreshTimeTxt.gameObject, refreshedTime > 0)
    GameObjectHelper.FastSetActive(self.refreshMapPriceTxt.gameObject, refreshedTime <= 0)
    self.refreshTimeTxt.text = lang.trans("transfort_free_time", refreshedTime, maxRefreshTime)
    self.refreshMapPriceTxt.text = "x" .. self.transportModel:GetMapRefreshPrice()

    self.bestTxt.text = "x" .. self.transportModel:GetBestPrice()

    local challengedTime = self.transportModel:GetRobberyTime()
    self.challengeTimeTxt.text = lang.trans("transfort_challenge_time", challengedTime)
end

function TransportMainView:RegOnDynamicLoad(func)
    self.infoBarDynParent:RegOnDynamicLoad(func)
end

function TransportMainView:InitCourseScrollView()
    local childNum = self.skyRect.childCount
    local courseDataList = self.transportModel:GetCourseDataList()
    for i = 1, childNum do
        local parentRect = self.skyRect:GetChild(i-1)
        res.ClearChildren(parentRect)
        local obj, spt = res.Instantiate(self.courseItemPath)
        spt:InitView(courseDataList[i])
        obj.transform:SetParent(parentRect, false)
        spt.onDetailBtnClick = function ()
            self:OnClickCourseItem(courseDataList[i])
        end
    end
end

function TransportMainView:OnClickCourseItem(data)
    if data.robberyRewardTimes == 0 then
        DialogManager.ShowToastByLang("transport_no_time_challenge")
        return
    end
    res.PushDialog("ui.controllers.transfort.TransportDetailResultCtrl", data.pid, (self.transportModel:GetRobberyTime() > 0))
end

function TransportMainView:InitSponsorView(oldLvl)
    local sponsorInfo = self.transportModel:GetSponsorInfoList()
    local sponsorLvl = self.transportModel:GetCurrSponsorLvl()
    res.ClearChildren(self.sponsorListRect)
    for i = 1, 5 do
        local obj, spt = res.Instantiate(self.sponsorItemPath)
        spt:InitView(sponsorInfo[tostring(i)], i, sponsorLvl, oldLvl)
        obj.transform:SetParent(self.sponsorListRect, false)
    end
end

function TransportMainView:UpdateMatchRedPoint()
    GameObjectHelper.FastSetActive(self.matchRedPoint, tonumber(ReqEventModel.GetInfo("transportLog")) > 0)
end

function TransportMainView:UpdateInviteRedPoint()
    GameObjectHelper.FastSetActive(self.inviteRedPoint, tonumber(ReqEventModel.GetInfo("transportApply")) > 0)
end

function TransportMainView:OnEnterScene()
    EventSystem.AddEvent("Transport_Refresh_My_Sponsor", self, self.InitMySponsorScrollView)
    EventSystem.AddEvent("Transfort_Refresh_Sponsor_Info", self, self.InitSponsorView)
    EventSystem.AddEvent("Transport_Refresh_Common", self, self.InitCommonView)
    EventSystem.AddEvent("Transport_Refresh_Map_Time", self, self.InitMapRefreshTime)
    EventSystem.AddEvent("ReqEventModel_transportLog", self, self.UpdateMatchRedPoint)
    EventSystem.AddEvent("ReqEventModel_transportApply", self, self.UpdateInviteRedPoint)
end

function TransportMainView:OnExitScene()
    EventSystem.RemoveEvent("Transport_Refresh_My_Sponsor", self, self.InitMySponsorScrollView)
    EventSystem.RemoveEvent("Transfort_Refresh_Sponsor_Info", self, self.InitSponsorView)
    EventSystem.RemoveEvent("Transport_Refresh_Common", self, self.InitCommonView)
    EventSystem.RemoveEvent("Transport_Refresh_Map_Time", self, self.InitMapRefreshTime)
    EventSystem.RemoveEvent("ReqEventModel_transportLog", self, self.UpdateMatchRedPoint)
    EventSystem.RemoveEvent("ReqEventModel_transportApply", self, self.UpdateInviteRedPoint)
end

function TransportMainView:onDestroy()
    if self.nextRefreshTimer then
        self.nextRefreshTimer:Destroy()
        self.nextRefreshTimer = nil
    end
end

return TransportMainView
