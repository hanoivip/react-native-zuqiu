local DialogManager = require("ui.control.manager.DialogManager")
local GreenswardInfoBarCtrl = require("ui.controllers.common.GreenswardInfoBarCtrl")
local GreenswardBuildModel = require("ui.models.greensward.build.GreenswardBuildModel")
local GreenswardMatchModel = require("ui.models.greensward.build.GreenswardMatchModel")
local GreenswardItemMapModel = require("ui.models.greensward.item.GreenswardItemMapModel")
local GreenswardWeatherBuildModel = require("ui.models.greensward.weather.GreenswardWeatherBuildModel")
local GreenswardStarBuildModel = require("ui.models.greensward.star.GreenswardStarBuildModel")
local GreenswardMoraleSupplyModel = require("ui.models.greensward.moraleSupply.GreenswardMoraleSupplyModel")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local BaseCtrl = require("ui.controllers.BaseCtrl")

local GreenswardMainCtrl = class(BaseCtrl, "GreenswardMainCtrl")

GreenswardMainCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Greensward.unity"

function GreenswardMainCtrl:AheadRequest(buildModel)
    if buildModel then
        self.greenswardBuildModel = buildModel
        self.greenswardBuildModel:CreateInstance()
    else
        self.greenswardBuildModel = GreenswardBuildModel.new()
    end
    self.itemMapModel = GreenswardItemMapModel.new()
    local response = req.greenswardAdventure()
    if api.success(response) then
        local data = response.val
        self.itemMapModel:InitWithProtocol(data.item or {})
        self.greenswardBuildModel:InitWithProtocol(data)
        if not table.isEmpty(data.base) then
            self.weaBuildModel = GreenswardWeatherBuildModel.new(data.base.wea)
            self.starBuildModel = GreenswardStarBuildModel.new(data.base.star)
        end
        local welcome = self.greenswardBuildModel:GetWelcome()
        if not welcome then
            local currentFloor = self.greenswardBuildModel:GetCurrentFloor()
            GuideManager.InitCurModule("adventureF" .. currentFloor)
            GuideManager.Show(self)
        end
    end
end

function GreenswardMainCtrl:GetStatusData()
    return self.greenswardBuildModel
end

function GreenswardMainCtrl:Init()
    self.view:RegOnInfoBarDynamicLoad(function(child)
        self.infoBarCtrl = GreenswardInfoBarCtrl.new(child, self.greenswardBuildModel)
        self.infoBarCtrl:RegOnBtnBack(function()
            self:OnClickBack()
        end)
    end)
    self.view:SetInforBar(self.infoBarCtrl)
    self.view.onBtnAvatar = function() self:OnBtnAvatar() end
    self.view.onClickBack = function() self:OnClickBack() end
    self.view.onBagClick = function() self:OnBagClcik() end
    self.view.onCycleDetailClick = function() self:OnCycleDetailClick() end
	self.view.filterClick = function(index) self:OnFilterClick(index) end
    self.view.onBtnPowerClick = function() self:OnBtnPowerClick() end
    self.view.onBtnStoreClick = function() self:OnBtnStoreClick() end
    self.view.onInfoUpdate = function() self:OnInfoUpdate() end
    self.view.onStartNewSeasonClick = function() self:OnStartNewSeasonClick() end
    self.view.onBuffExpandClick = function(greenswardBuildModel, greenswardResourceCache) self:OnBuffExpandClick(greenswardBuildModel, greenswardResourceCache) end
    self.view.onViewClick = function(greenswardResourceCache) self:OnViewClick(greenswardResourceCache) end
    self.view.onTipsTrigger = function(tips) self:OnTipsTrigger(tips) end
end

function GreenswardMainCtrl:OnTipsTrigger(tips)
    DialogManager.ShowToast(tips)
end

function GreenswardMainCtrl:OnFilterClick(index)
    local topFloor = self.greenswardBuildModel:GetOpenFloor()
    local tips = ""
    local finalConsume = 0
    local starSymbol = ""
    if index == topFloor then
        tips = lang.trans("floor_tip1", index)
    else
        local consume = self.greenswardBuildModel:GetReturnFloorConsume()
        finalConsume, starSymbol = self.greenswardBuildModel:GetStarEffectMoraleNum(consume)
        local color16 = "yellow"
        if starSymbol == 1 then
            color16 = "red"
        elseif starSymbol == -1 then
            color16 = "#65d203"
        end
        local finalTxt = "<color=" .. color16 .. ">" .. finalConsume .. "</color>"
        tips = lang.trans("floor_tip2", index, finalTxt)
    end
    local callback = function()
        local morale = self.greenswardBuildModel:GetMoraleNum()
        if morale >= tonumber(finalConsume) then
            self.view:coroutine(function()
                local respone = req.greenswardAdventureChangeFloor(index)
                if api.success(respone) then
                    local data = respone.val
                    local base = data.base or { }
                    local map = data.ret and data.ret.map or { }

                    self.greenswardBuildModel:RefreshBaseInfo(base)
                    self.greenswardBuildModel:RefreshEventModel(map)
                    self.view:PlaneFilterTrigger()
                    self.view:MoveConstructionPos(self.greenswardBuildModel)
                end
            end)
        else
            local titleText = lang.trans("tips")
            local contentText = lang.trans("need_morale_enough2")
            local callback = function() res.PushDialog("ui.controllers.greensward.GreenswardMoraleDialogCtrl", self.greenswardBuildModel) end
            DialogManager.ShowMessageBox(titleText, contentText, callback)
        end
    end

    DialogManager.ShowConfirmPop(lang.trans("tips"), tips, callback)
end

function GreenswardMainCtrl:OnViewClick(greenswardResourceCache)
    res.PushDialog("ui.controllers.greensward.buff.BuffDetailCtrl", self.greenswardBuildModel, greenswardResourceCache)
end

function GreenswardMainCtrl:OnClickBack()
    res.ChangeScene("ui.controllers.home.HomeMainCtrl")
end

function GreenswardMainCtrl:Refresh()
    GreenswardMainCtrl.super.Refresh(self)
    self:ProcessPopDialog()
    self.view:InitView(self.greenswardBuildModel, self.weaBuildModel, self.starBuildModel)
end

-- 处理比赛完回到界面事件
function GreenswardMainCtrl:ProcessPopDialog()
    local greenswardMatchModel = GreenswardMatchModel.new()
    local adventureMatch = greenswardMatchModel:GetAdventureMatch()
    if adventureMatch then 
        local playerScore, opponentScore = greenswardMatchModel:GetScoreData()
        if playerScore > opponentScore then
            res.PushDialog("ui.controllers.greensward.dialog.MatchDialogCtrl", greenswardMatchModel, self.greenswardBuildModel)
        else
            res.PushDialog("ui.controllers.greensward.dialog.LoseDialogCtrl")
            greenswardMatchModel:ClearMatch()
        end
    else
        greenswardMatchModel:ClearMatch()
    end
end

function GreenswardMainCtrl:OnEnterScene()
    self.view:OnEnterScene()
end

function GreenswardMainCtrl:OnExitScene()
    self.view:OnExitScene()
end

-- 点击背包按钮
function GreenswardMainCtrl:OnBagClcik()
    res.PushDialog("ui.controllers.greensward.bag.GreenswardBagCtrl", self.greenswardBuildModel)
end

-- 点击士气补给
function GreenswardMainCtrl:OnBtnPowerClick()
    local greenswardMoraleSupplyModel = GreenswardMoraleSupplyModel.new(self.greenswardBuildModel)
    res.PushDialog("ui.controllers.greensward.moraleSupply.GreenswardMoraleSupplyCtrl", greenswardMoraleSupplyModel)
end

-- 点击周期详情
function GreenswardMainCtrl:OnCycleDetailClick()
    local baseData = self.greenswardBuildModel:GetBaseData()
    res.PushDialog("ui.controllers.greensward.cycleDetail.GreenswardCycleDetailCtrl", baseData, self.weaBuildModel, self.starBuildModel)
end

-- 点击商店
function GreenswardMainCtrl:OnBtnStoreClick()
    res.PushDialog("ui.controllers.greensward.store.GreenswardStoreCtrl", self.greenswardBuildModel)
end

-- 点击玩家形象
function GreenswardMainCtrl:OnBtnAvatar()
    res.PushDialog("ui.controllers.greensward.avatarSelect.GreenswardAvatarSelectCtrl", self.greenswardBuildModel, self.itemMapModel)
end

-- 展开buff
function GreenswardMainCtrl:OnBuffExpandClick(greenswardBuildModel, greenswardResourceCache)
    res.PushDialog("ui.controllers.greensward.buff.BuffExpandCtrl", greenswardBuildModel, greenswardResourceCache)
end

-- base数据有更新
function GreenswardMainCtrl:OnInfoUpdate()
    local baseData = self.greenswardBuildModel:GetBaseData()
    self.weaBuildModel:ChangeWeather(baseData.wea)
    self.starBuildModel:ChangeStar(baseData.star)
end

-- 刷新整个页面
function GreenswardMainCtrl:OnStartNewSeasonClick()
    self.view:coroutine(function()
        self.itemMapModel = GreenswardItemMapModel.new()
        local response = req.greenswardAdventure()
        if api.success(response) then
            local data = response.val
            self.itemMapModel:InitWithProtocol(data.item or {})
            self.greenswardBuildModel:InitWithProtocol(data)
            if not table.isEmpty(data.base) then
                self.weaBuildModel = GreenswardWeatherBuildModel.new(data.base.wea)
                self.starBuildModel = GreenswardStarBuildModel.new(data.base.star)
            end
            self:Refresh()
        end
    end)
end

return GreenswardMainCtrl
