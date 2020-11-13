local BaseCtrl = require("ui.controllers.BaseCtrl")
local GachaMainCtrl = class(BaseCtrl)
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local GachaMainModel = require("ui.models.gacha.GachaMainModel")
local InfoBarCtrl = require("ui.controllers.common.InfoBarCtrl")
local StaticCardModel = require("ui.models.cardDetail.StaticCardModel")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local RewardUpdateCacheModel = require("ui.models.common.RewardUpdateCacheModel")
local GachaTenCtrl = require("ui.controllers.gacha.GachaTenCtrl")
local CustomEvent = require("ui.common.CustomEvent")
local CostDiamondHelper = require("ui.common.CostDiamondHelper")
local GachaDetailCtrl = require("ui.controllers.gacha.GachaDetailCtrl")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local MusicManager = require("ui.control.manager.MusicManager")

GachaMainCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Gacha/GachaCanvas.prefab"

function GachaMainCtrl:Init()
    self.view.infoBar:RegOnDynamicLoad(function (child)
        self.infoBarCtrl = InfoBarCtrl.new(child, self)
    end)

    self.view:OnBuyOneClick(function() self:OnBtnBuyOneClick() end)
    self.view:OnBuyTenClick(function() self:OnBtnBuyTenClick() end)
    self.view:OnDetailBtnClick(function() self:OnBtnDetailClick() end)
end

local function IsInTable(e, t)
    for i, v in ipairs(t) do
        if v == e then
            return true
        end
    end
    return false
end

function GachaMainCtrl:Refresh(resp, isBuyOne, tag)
    GachaMainCtrl.super.Refresh(self)

    self.view:coroutine(function()
        local response = req.storeInfo()
        if api.success(response) then
            self.gachaModel = GachaMainModel.new()
            self.gachaModel:InitData(response.val)

            self.labelTab = self.gachaModel:GetLabels()
            self.view:InitView(self.gachaModel)
            self.view:ClearAllLabels()

            for _, tag in ipairs(self.labelTab) do
                self.view:CreateLabel(tag, function(i)
                    self:OnClickLabel(i)
                end)
            end

            if (not tag or not IsInTable(tag, self.labelTab)) and #self.labelTab >= 1 then
                tag = self.labelTab[1]
            end
            self.view.menuGroup:selectMenuItem(tag)
            self:OnClickLabel(tag)

            if resp then
                if isBuyOne then
                    local dialog, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/Congratulations/Congratulations.prefab", "camera", true, true)
                    local script = dialogcomp.contentcomp
                    local playerInfoModel = PlayerInfoModel.new()
                    script:InitView(resp.contents, playerInfoModel)
                    if resp.contents and type(resp.contents.card) == "table" and resp.contents.card[1] then
                        local playerCardStaticModel = StaticCardModel.new(resp.contents.card[1].cid)
                        script:PlayQualityAnim(playerCardStaticModel:GetCardQuality())
                    end

                    GuideManager.Show()
                else
                    GachaTenCtrl.new(resp.contents, self)
                end
            else
                GuideManager.Show()
            end
        end
    end)
end

function GachaMainCtrl:GetStatusData()
    return self.resp, self.isBuyOne, self.gachaModel:GetLabelTag()
end

function GachaMainCtrl:OnExitScene()
    self.resp = nil
    self.isBuyOne = nil
    self.view.curTag = nil
end

function GachaMainCtrl:OnClickLabel(tag)
    if self.view.curTag == tag then
        return
    end
    
    self.view:OnClickLabel(tag)
    self.view:SetBanner(self.gachaModel:GetBanner())
    self.view:SetBoard(self.gachaModel:GetBoard())
    self.view:SetBuyOnePrice(self.gachaModel:GetPrice())
    self.view:SetBuyTenPrice(self.gachaModel:GetTenPrice())
    self.view:RefreshIcon(self.gachaModel:GetPriceType())
    self.view:SetBuyOneTip(self.gachaModel:GetOneTip())
    self.view:SetBuyTenTip(self.gachaModel:GetTenTip())
    self.view:SetDetailButton(self.gachaModel:GetButtonTip(), self.gachaModel:GetTipPicPath(), self.gachaModel:GetButtonPos(), self.gachaModel:GetTipBoardPos(), self.gachaModel:GetTipBoardRotation(), self.gachaModel:GetTipTextRotation(), self.gachaModel:GetTipTextPos())
    self.view:SetLeftTime(self.gachaModel:GetLeftTime())
    self.view:SetFriendPoint(self.gachaModel:GetFriendshipPoint())
end

local friendPointGachaTag = "C1"
function GachaMainCtrl:OnBtnBuyOneClick()
    local costDiamond
    if tostring(self.gachaModel:GetLabelTag()) == friendPointGachaTag then
        costDiamond = nil
    else
        costDiamond = self.gachaModel:GetPrice()
    end
    CostDiamondHelper.CostDiamond(costDiamond, nil, function()
        clr.coroutine(function()
            local response = req.buyOneCard(self.view.curTag)
            if api.success(response) then
                if next(response.val) then
                    CustomEvent.GachaOne(self.view.curTag, response.val.cost.num)
                    MusicManager.stop()
                    clr.coroutine(function()
                        unity.waitForEndOfFrame()
                        self.isBuyOne = true
                        self.resp = response.val
                        local rewardUpdateCacheModel = RewardUpdateCacheModel.new()
                        rewardUpdateCacheModel:UpdateCache(response.val.contents)
                        local playerInfoModel = PlayerInfoModel.new()
                        if response.val.cost.type == "d" then
                            playerInfoModel:SetDiamond(response.val.cost.curr_num)
                            CustomEvent.ConsumeDiamond("6", response.val.cost.num)
                        elseif response.val.cost.type == "fp" then
                            playerInfoModel:SetFriendshipPoint(response.val.cost.curr_num)
                        end
                        res.ChangeSceneAsync("ui.controllers.gacha.GachaAnimationCtrl", response.val.contents)
                    end)
                end
            end
        end)
    end)
end

function GachaMainCtrl:OnBtnBuyTenClick()
    local costDiamond
    if tostring(self.gachaModel:GetLabelTag()) == friendPointGachaTag then
        costDiamond = nil
    else
        costDiamond = self.gachaModel:GetTenPrice()
    end
    CostDiamondHelper.CostDiamond(costDiamond, nil, function()
        clr.coroutine(function()
            local response = req.buyTenCard(self.view.curTag)
            if api.success(response) then
                if next(response.val) then
                    CustomEvent.GachaTen(self.view.curTag, response.val.cost.num)
                    MusicManager.stop()
                    clr.coroutine(function()
                        unity.waitForEndOfFrame()
                        self.isBuyOne = false
                        self.resp = response.val
                        local rewardUpdateCacheModel = RewardUpdateCacheModel.new()
                        rewardUpdateCacheModel:UpdateCache(response.val.contents)
                        local playerInfoModel = PlayerInfoModel.new()
                        if response.val.cost.type == "d" then
                            playerInfoModel:SetDiamond(response.val.cost.curr_num)
                            CustomEvent.ConsumeDiamond("6", response.val.cost.num)
                        elseif response.val.cost.type == "fp" then
                            playerInfoModel:SetFriendshipPoint(response.val.cost.curr_num)
                        end
                        res.ChangeSceneAsync("ui.controllers.gacha.GachaAnimationCtrl", response.val.contents)
                    end)
                end
            end
        end)
    end)
end

function GachaMainCtrl:OnBtnDetailClick()
    GachaDetailCtrl.new(self.gachaModel)
end

return GachaMainCtrl
