local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local UI = UnityEngine.UI
local Text = UI.Text

local EventSystem = require("EventSystem")
local LeagueConstants = require("ui.scene.league.LeagueConstants")
local SimpleCardModel = require("ui.models.cardDetail.SimpleCardModel")

local LeaguePlayerRewardPageView = class(unity.base)

function LeaguePlayerRewardPageView:ctor()
    -- 滚动区域内容框
    self.scrollerContent = self.___ex.scrollerContent
    -- 触摸层
    self.touchMask = self.___ex.touchMask
    -- 结算数据
    self.settlementData = nil
    -- 界面销毁时的回调
    self.destroyCallback = nil
end

function LeaguePlayerRewardPageView:InitView(settlementData, destroyCallback)
    self.settlementData = settlementData
    self.destroyCallback = destroyCallback
    
    self:BuildPage()
end

function LeaguePlayerRewardPageView:start()
    self:BindAll()
end

function LeaguePlayerRewardPageView:BindAll()
    self.touchMask:regOnButtonClick(function ()
        if type(self.closeDialog) == "function" then
            self.closeDialog()
        end
        if type(self.destroyCallback) == "function" then
            self.destroyCallback()
        end
    end)
end

function LeaguePlayerRewardPageView:BuildPage()
    local obj = res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Part/PlayerAvatarBox.prefab")
    local playerListData = self.settlementData.freeAdvance

    for i, rewardData in ipairs(playerListData) do
        local go = Object.Instantiate(obj)
        go.transform:SetParent(self.scrollerContent, false)
        local playerCardModel = SimpleCardModel.new(rewardData.pcid)
        local goScript = go:GetComponent(clr.CapsUnityLuaBehav)
        goScript:InitView(playerCardModel:GetCid(), true)
    end
end

return LeaguePlayerRewardPageView
