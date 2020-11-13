local BaseCtrl = require("ui.controllers.BaseCtrl")
local GuildRankingModel = require("ui.models.guild.GuildRankingModel")
local InfoBarCtrl = require("ui.controllers.common.InfoBarCtrl")

local GuildRankingCtrl = class(BaseCtrl)

GuildRankingCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildRanking.prefab"

function GuildRankingCtrl:AheadRequest(rankData)
    self.rankData = rankData
    self.model = GuildRankingModel.new()
    self.model:InitWithProtocol(rankData)
    local response = req.GetGuildTop()
    if api.success(response) then
        local data = response.val
        for i, v in ipairs(data) do
            v.isSelf = (v.rank == self.model:GetRank())
        end
        self.model:InitLivesData(data)
    end
end

function GuildRankingCtrl:Init()
    self.view.onBtnArrowClick = function()
        self:MoveThePanel()
        self.model:SetMoveUpState()
    end
    self.view:RegOnDynamicLoad(function (child)
        self.infoBarCtrl = InfoBarCtrl.new(child, self)
        self.infoBarCtrl:RegOnBtnBack(function()
            res.PopScene()
        end)
    end)
    self.view:RegOnMenuGroup("power", function ()
        self:SwitchContent("power")
    end)
    self.view:RegOnMenuGroup("liveness", function ()
        self:SwitchContent("liveness")
    end)
    self.view.onBtnCommonClick = function() self:SwitchContent("power") end
    self.view.onBtnMistClick = function() self:SwitchContent("mist") end
end

function GuildRankingCtrl:MoveThePanel()
    local isUp = self.model:GetMoveUpState()
    if isUp then
        self.view.onCompleteCallBack = function()
            self.view:SetCenterAreaState(false)
        end
        self.view:MoveUpThePanel()
        self.view:SetArrowDownState()
    else
        self.view:MoveDownThePanel()
        self.view:SetArrowUpState()
        self.view:SetCenterAreaState(true)
    end
end

function GuildRankingCtrl:Refresh(data)
    GuildRankingCtrl.super.Refresh(self)
    self.view:InitView(self.model)
    self:SwitchContent("liveness")
end

function GuildRankingCtrl:SwitchContent(tag)
    if tag == "power" then
        local powerData = self.model:GetPowerData()
        if not powerData then
            clr.coroutine(function ()
                local response = req.GetGuildPowerTop()
                if api.success(response) then
                    local data = response.val
                    self.model:InitPowerData(data)
                    self.view:InitPowerView()
                end
            end)
        else
            self.view:InitPowerView()
        end
    elseif tag == "liveness" then
        self.view:InitLivnessView()
    elseif tag == "mist" then
        local mistData = self.model:GetMistData()
        if not mistData then
            clr.coroutine(function ()
                local response = req.guildPowerMistRank()
                if api.success(response) then
                    local data = response.val
                    self.model:InitMistData(data)
                    self.view:InitMistView()
                end
            end)
        else
            self.view:InitMistView()
        end
    end
    if tag == "mist" then
        tag = "power"
    end
    self.view.menuGroup:selectMenuItem(tag)
end

function GuildRankingCtrl:EventRankingItemDetailClick(gid)
    clr.coroutine(function()
        local respone = req.GuildDetail(gid)
        if api.success(respone) then
            local data = respone.val
            if data.base.isExsit == true then
                res.PushDialog("ui.controllers.guild.GuildDetailCtrl", data.base)
            end
        end
    end)
end

function GuildRankingCtrl:GetStatusData()
    return self.rankData
end

function GuildRankingCtrl:OnEnterScene()
    EventSystem.AddEvent("GuildRankingItem_Detail",self, self.EventRankingItemDetailClick)
end

function GuildRankingCtrl:OnExitScene()
    EventSystem.RemoveEvent("GuildRankingItem_Detail",self, self.EventRankingItemDetailClick)
end

return GuildRankingCtrl