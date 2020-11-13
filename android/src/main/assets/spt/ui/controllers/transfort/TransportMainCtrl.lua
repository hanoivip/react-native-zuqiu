local BaseCtrl = require("ui.controllers.BaseCtrl")
local TransportMainModel = require("ui.models.transfort.TransportMainModel")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local TransportInfoBarCtrl = require("ui.controllers.transfort.TransportInfoBarCtrl")
local CourtBuildModel = require("ui.models.court.CourtBuildModel")
local TechnologySettingConfig = require("ui.scene.court.technologyHall.TechnologySettingConfig")
local DialogManager = require("ui.control.manager.DialogManager")
local MatchConstants = require("ui.scene.match.MatchConstants")
local TransportMainCtrl = class(BaseCtrl, "TransportMainCtrl")
local CostDiamondHelper = require("ui.common.CostDiamondHelper")

TransportMainCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Transfort/Transport.prefab"

function TransportMainCtrl:AheadRequest()
    local response = req.transportIndex()
    if api.success(response) then
        local data = response.val
        self.transportMainModel = TransportMainModel.new()
        self.transportMainModel:InitWithProtocol(data)
    end
end

function TransportMainCtrl:Init()
    self.playerInfoModel = PlayerInfoModel.new()
    self.view:RegOnDynamicLoad(function (child)
        self.infoBarCtrl = TransportInfoBarCtrl.new(child)
        self.infoBarCtrl:RegOnBtnBack(function ()
            res.PopScene()
        end)
    end)

    self.view.onDescBtnClick = function () self:OnDescBtnClick() end
    self.view.onMatchRecordBtnClick = function () self:OnMatchRecordBtnClick() end
    self.view.onInviteRecordBtnClick = function () self:OnInviteRecordBtnClick() end
    self.view.onBargainBtnClick = function () self:OnBargainBtnClick() end
    self.view.onBestBtnClick = function () self:OnBestBtnClick() end
    self.view.onRefreshBtnClick = function () self:OnRefreshBtnClick() end
    self.view.onSettingBtnClick = function () self:OnSettingBtnClick() end
end

function TransportMainCtrl:Refresh()
    TransportMainCtrl.super.Refresh(self)
    self.view:InitView(self.transportMainModel)
    self:CheckIsOpenMatchDetailsWindow()
end

function TransportMainCtrl:CheckIsOpenMatchDetailsWindow()
    local matchResultData = clone(cache.getMatchResult())
    if matchResultData and matchResultData.matchType == MatchConstants.MatchType.TRANSPORT then
        cache.setMatchResult(nil)
        res.PushDialog("ui.controllers.transfort.TransportMatchDetailCtrl", matchResultData.settlement)
    end
end

function TransportMainCtrl:OnDescBtnClick()
    res.PushScene("ui.controllers.transfort.TransportRuleCtrl")
end

function TransportMainCtrl:OnSettingBtnClick()
    local courtBuildModel = CourtBuildModel.new()
    if courtBuildModel.data and type(courtBuildModel.data) == "table" then
        res.PushDialog("ui.controllers.court.technologyHall.CourtDisplayCtrl", courtBuildModel, TechnologySettingConfig.Transport)
    else
        clr.coroutine(function()
            local response = req.buildInfo()
            if api.success(response) then
                local data = response.val
                local courtBuildModel = CourtBuildModel.new()
                courtBuildModel:InitWithProtocol(data)
                res.PushDialog("ui.controllers.court.technologyHall.CourtDisplayCtrl", courtBuildModel, TechnologySettingConfig.Transport)
            end
        end)
    end
end

function TransportMainCtrl:OnMatchRecordBtnClick()
    res.PushDialog("ui.controllers.transfort.TransportJournalCtrl")
end

function TransportMainCtrl:OnInviteRecordBtnClick()
    res.PushDialog("ui.controllers.transfort.TransportInviteHistoryCtrl")
end

function TransportMainCtrl:OnBargainBtnClick()
    if self.transportMainModel:GetBargainTime() > 0 then
        self:ChangeRandSponsor()
    else
        CostDiamondHelper.CostDiamond(self.transportMainModel:GetBargainPrice(), nil, function()
            if self.firstIn then
                self:ChangeRandSponsor()
            else
                DialogManager.ShowConfirmPop(lang.trans("tips"), lang.trans("transport_refresh_bargain_tip"), function()
                    self:ChangeRandSponsor()
                    self.firstIn = true
                end)
            end
        end)
    end
end

function TransportMainCtrl:ChangeRandSponsor()
    clr.coroutine(function ()
        local response = req.transportChangeRandSponsor()
        if api.success(response) then
            local data = response.val
            local nowSponsorId = data.contents.preSponsor.sponsorId
            local oldSponsorId = self.transportMainModel:GetCurrSponsorLvl()
            local info 
            if nowSponsorId > oldSponsorId then
                info = lang.trans("transfort_sponsor_upgrade")
            elseif nowSponsorId == oldSponsorId then
                info = lang.trans("transfort_sponsor_same")
            elseif nowSponsorId < oldSponsorId then
                info = lang.trans("transfort_sponsor_downgrading")
            end
            -- 点了确定之后才刷新界面，营造视觉差
            DialogManager.ShowAlertPop(lang.trans("transfort_bargain_solution"), info,function ()
                self.transportMainModel:SetPreSponsor(data.contents.preSponsor)
                if data.cs_times then
                    self.transportMainModel:SetBargainTime(data.cs_times)
                end
                if data.cost.type == "d" then
                    self.playerInfoModel:SetDiamond(data.cost.curr_num)
                end
            end)
        end
    end)
end

function TransportMainCtrl:OnBestBtnClick()
    local isBeing = self.transportMainModel:IsStartAndNotFinish()
    local sponsorLvl = self.transportMainModel:GetCurrSponsorLvl()
    if isBeing then
        DialogManager.ShowAlertPop(lang.trans("tips"),lang.trans("transport_being_tip"))
        return
    end
    if sponsorLvl == self.transportMainModel:GetMaxSponsorLvl() then
        DialogManager.ShowToastByLang("transport_max_lvl_tip")
        return
    end

    DialogManager.ShowConfirmPop(lang.trans("transfort_best_title"), lang.trans("transfort_best_tip", self.transportMainModel:GetBestPrice()) , function ()
        clr.coroutine(function ()
            local response = req.transportChangeMaxSponsor()
            if api.success(response) then
                local data = response.val
                self.transportMainModel:SetPreSponsor(data.contents.preSponsor)
                if data.cs_times then
                    self.transportMainModel:SetBargainTime(data.cs_times)
                end
                if data.cost.type == "d" then
                    self.playerInfoModel:SetDiamond(data.cost.curr_num)
                end
            end
        end)
    end)
end

function TransportMainCtrl:OnRefreshBtnClick()
    local canRefreshTime = self.transportMainModel:GetMapRefreshedTime()
    local refreshPrice = self.transportMainModel:GetMapRefreshPrice()
    if canRefreshTime <= 0 then
        DialogManager.ShowConfirmPop(lang.trans("friends_add_refresh"), lang.trans("transport_refresh_tip", refreshPrice), function ()
            self:RefreshMainView(true)
        end)
    else
        self:RefreshMainView(true)
    end
end

-- 参数为是否是玩家自己点击的刷新
function TransportMainCtrl:RefreshMainView(isSelfRefresh)
    clr.coroutine(function ()
        local response = req.transportIndex(isSelfRefresh)
        if api.success(response) then
            local data = response.val
            self.transportMainModel:InitWithProtocol(data)
            self.view:InitView(self.transportMainModel)
            if data.cost.type == "d" then
                self.playerInfoModel:SetDiamond(data.cost.curr_num)
            end
        end
    end)
end

function TransportMainCtrl:OnEnterScene()
    self.view:OnEnterScene()
    EventSystem.AddEvent("Transport_Refresh_Main_View", self, self.RefreshMainView)
end

function TransportMainCtrl:OnExitScene()
    self.view:OnExitScene()
    EventSystem.RemoveEvent("Transport_Refresh_Main_View", self, self.RefreshMainView)
end

return TransportMainCtrl