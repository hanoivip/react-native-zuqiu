local UnityEngine = clr.UnityEngine
local Vector3 = UnityEngine.Vector3
local Vector2 = UnityEngine.Vector2
local RectTransform = UnityEngine.RectTransform
local Time = UnityEngine.Time
local ShareHelper = require("ui.common.ShareHelper")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local ShareConstants = require("ui.scene.shareSDK.ShareConstants")
local StaticCardModel = require("ui.models.cardDetail.StaticCardModel")

local CloseButtonPosition = {
    CloseShare = {X = -130, Y = 50},
    OpenShare = {X = -330, Y = 50},
}
-- 第N张卡牌翻面完成时显示分享、关闭按钮(仅在打开分享功能时使用) N ∈ [1, 10]
local ShowIndex = 1
local GachaTenView = class(unity.base)

function GachaTenView:ctor()
    self.close = self.___ex.closeBtn
    self.again = self.___ex.againBtn
    self.sell = self.___ex.sellBtn
    self.all = self.___ex.allBtn
    self.contentArea = self.___ex.contentArea
    self.rollManager = self.___ex.rollManager
    -- 分享按钮
    self.shareBtn = self.___ex.shareBtn
    -- 奖励信息
    self.shareInfo = self.___ex.shareInfo
    -- 奖励信息文字
    self.shareInfoText = self.___ex.shareInfoText
    self.check = self.___ex.check
    self.cardTargetScale = 0.5
    self.middleTargetScale = 0.54
    self.firstAnimTime = 0.15
    self.secondAnimTime = 0.1
    self.thirdAnimTime = 0.1
    self.cardBeginScale = 0.8
    -- 十连抽时,完成翻面的卡牌数量(0-10)
    self.showCount = 0
end

function GachaTenView:start()
    GameObjectHelper.FastSetActive(self.all.gameObject, true)
    GameObjectHelper.FastSetActive(self.sell.gameObject, true)
    self.close:regOnButtonClick(function()
        EventSystem.SendEvent("CardLibraryStatus", true)
        if type(self.closeDialog) == "function" then
            self.closeDialog()
        end
    end)
    self.again:regOnButtonClick(function()
        if type(self.againFunc) == "function" then
            self.againFunc()
        end
    end)
    self.sell:regOnButtonClick(function()
        if type(self.sellFunc) == "function" then
            self.sellFunc()
        end       
    end)    
    self.all:regOnButtonClick(function()
        if type(self.allFunc) == "function" then
            self.allFunc()
        end       
    end)    
    self.shareBtn:regOnButtonClick(function()
        self:OnBtnShareClick()
    end)
    self.showCount = 0
    self:RegisterEvent()
end

function GachaTenView:InitView()
    local isOpenShare = cache.getIsOpenShareSDK()
    if isOpenShare then
    	GameObjectHelper.FastSetActive(self.all.gameObject, false)
    	GameObjectHelper.FastSetActive(self.sell.gameObject, false)
        GameObjectHelper.FastSetActive(self.close.gameObject, false)
    else
        GameObjectHelper.FastSetActive(self.shareBtn.gameObject, false)
        self.close:GetComponent(RectTransform).anchoredPosition = Vector2(CloseButtonPosition.CloseShare.X, CloseButtonPosition.CloseShare.Y)
    end
end

function GachaTenView:InitShareButtonView()
    if cache.getIsOpenShareSDK() then
        self.showCount = self.showCount + 1
        if self.showCount == ShowIndex then
            GameObjectHelper.FastSetActive(self.shareBtn.gameObject, true)
            GameObjectHelper.FastSetActive(self.close.gameObject, true)
            GameObjectHelper.FastSetActive(self.all.gameObject, true)
            GameObjectHelper.FastSetActive(self.sell.gameObject, true)
            GameObjectHelper.FastSetActive(self.shareInfo, not cache.getIsShareTaskComplete())
        end
    end
end

function GachaTenView:SetGachaData(cid)
    self.rewardCid = cid
end

function GachaTenView:OnBtnShareClick()
    self:SetViewOnShareRender()
    local cardModel = StaticCardModel.new(self.rewardCid)
    self:coroutine(function()
        unity.waitForNextEndOfFrame()
        ShareHelper.CaptrueCamera(ShareConstants.Type.GachaTen, cardModel:GetName())
    end)
end


function GachaTenView:SetViewOnShareRender()
    GameObjectHelper.FastSetActive(self.shareBtn.gameObject, false)
    GameObjectHelper.FastSetActive(self.close.gameObject, false)
    GameObjectHelper.FastSetActive(self.again.gameObject, false)
    GameObjectHelper.FastSetActive(self.all.gameObject, false)
    GameObjectHelper.FastSetActive(self.sell.gameObject, false)
end

function GachaTenView:SetViewOnShareRenderComplete()
    GameObjectHelper.FastSetActive(self.shareBtn.gameObject, true)
    GameObjectHelper.FastSetActive(self.close.gameObject, true)
    GameObjectHelper.FastSetActive(self.again.gameObject, true)
    GameObjectHelper.FastSetActive(self.all.gameObject, true)
    GameObjectHelper.FastSetActive(self.sell.gameObject, true) 
end

function GachaTenView:UpdateShareTaskState()
    GameObjectHelper.FastSetActive(self.shareInfo, not cache.getIsShareTaskComplete())
end

function GachaTenView:SetViewOnShareComplete()
    GameObjectHelper.FastSetActive(self.shareInfo, not cache.getIsShareTaskComplete())
end

function GachaTenView:OnShareComplete()
    self:SetViewOnShareComplete()
    if type(self.shareStartFunc) == "function" then
        self.shareStartFunc()
    end     
end

function GachaTenView:OnShareCancel()
    self:SetViewOnShareRenderComplete()
    if type(self.shareEndFunc) == "function" then
        self.shareEndFunc()
    end
end

function GachaTenView:RegisterEvent()
    EventSystem.AddEvent("ShareRenderComplete", self, self.SetViewOnShareRenderComplete)
    EventSystem.AddEvent("ShareTask_UpdateState", self, self.UpdateShareTaskState)
    EventSystem.AddEvent("GachaTenCard.OnAnimEnd", self, self.InitShareButtonView)
    luaevt.reg("ShareSDK_OnComplete", function(cate, action)
        self:OnShareComplete() 
    end)
    luaevt.reg("ShareSDK_OnCancel", function(cate, action)
        self:OnShareCancel()
    end)
end

-- 移除事件
function GachaTenView:RemoveEvent()
    EventSystem.RemoveEvent("ShareRenderComplete", self, self.SetViewOnShareRenderComplete)
    EventSystem.RemoveEvent("ShareTask_UpdateState", self, self.UpdateShareTaskState)
    EventSystem.RemoveEvent("GachaTenCard.OnAnimEnd", self, self.InitShareButtonView)
    luaevt.unreg("ShareSDK_OnComplete")
    luaevt.unreg("ShareSDK_OnCancel")
end

function GachaTenView:onDestroy()
    if type(self.destroyFunc) == "function" then
        self.destroyFunc()
    end
    self:RemoveEvent()
end

function GachaTenView:onBeginDrag(eventData)
    self.rollManager:onBeginDrag(eventData)
end

function GachaTenView:onDrag(eventData)
    self.rollManager:onDrag(eventData)
end

function GachaTenView:onEndDrag(eventData)
    self.rollManager:onEndDrag(eventData)
end

function GachaTenView:HideAgainButton() 
    self.again.gameObject:SetActive(false)
end

function GachaTenView:SetAll(flag)
    self.check:SetActive(flag)
end

return GachaTenView
