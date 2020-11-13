local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local GameObjectHelper = require("ui.common.GameObjectHelper")

local HeroHallMainView = class(unity.base, "HeroHallMainView")

function HeroHallMainView:ctor()
    self.infoBarDynParent = self.___ex.infoBarDynParent
    self.mainView = self.___ex.mainView
    self.indicator = self.___ex.indicator
    self.btnLeft = self.___ex.btnLeft
    self.btnRight = self.___ex.btnRight
    self.totalScore = self.___ex.totalScore
    self.halls = self.___ex.halls
    self.showArea = self.___ex.showArea
    self.showAreaCanvasGroup = self.___ex.showAreaCanvasGroup
    self.btnIntro = self.___ex.btnIntro
    self.btnRank = self.___ex.btnRank
    self.bgAnimator = self.___ex.bgAnimator
    self.clickMask = self.___ex.clickMask

    self.onClickBtnLeft = nil
    self.onClickBtnRight = nil
    self.onItemClick = nil
    self.onIntroClick = nil
    self.onRankClick = nil
    self.canButtonClick = true
end

function HeroHallMainView:start()
    self:RegBtnEvent()
end

function HeroHallMainView:InitView(heroHallMainModel)
    self.model = heroHallMainModel

    self:RefreshTotalScore()

    self.indicator:InitView(self.model:GetGroupNum(), self.model:GetCurrGroup())

    self:InitHallsView()
end

function HeroHallMainView:InitHallsView()
    local maxCount = self.model:GetMaxCountInCurrGroup()
    local itemDatas = self.model:GetCurrGroupItemDatas()
    for i = 1, maxCount do
        local hallSpt = self.halls[tostring(i)]
        GameObjectHelper.FastSetActive(hallSpt.gameObject, true)
        hallSpt:InitView(itemDatas[i], self.onItemClick, self)
    end

    local default_cluster_num = self.model:GetDefaultClusterNum()
    for i = maxCount + 1, default_cluster_num do
        GameObjectHelper.FastSetActive(self.halls[tostring(i)].gameObject, false)
    end
end

function HeroHallMainView:RefreshHallsView()
    self:InitHallsView()
end

function HeroHallMainView:ActivateHallView(id)
    self.canButtonClick = false
    GameObjectHelper.FastSetActive(self.clickMask.gameObject, true)
    local hallIndex = self.model:GetHallIndexByHallID(id)
    local hallSpt = self.halls[tostring(hallIndex)]
    local itemDatas = self.model:GetCurrGroupItemDatas()
    hallSpt:ActivateHall(itemDatas[hallIndex])
end

-- 解锁动画结束，在itemView中被调用
function HeroHallMainView:EndUnlockAnim()
    self.canButtonClick = true
    GameObjectHelper.FastSetActive(self.clickMask.gameObject, false)
    self:RefreshHallsView()
end

function HeroHallMainView:RefreshHallViewById(id)
    local hallIndex = self.model:GetHallIndexByHallID(id)
    local hallSpt = self.halls[tostring(hallIndex)]
    local itemDatas = self.model:GetCurrGroupItemDatas()
    hallSpt:InitView(itemDatas[hallIndex], self.onItemClick)
end

function HeroHallMainView:RefreshTotalScore()
    self.totalScore.text = tostring(self.model:GetTotalScore())
end

function HeroHallMainView:RegBtnEvent()
    self.btnLeft:regOnButtonClick(function()
        self:OnClickBtnLeft()
    end)

    self.btnRight:regOnButtonClick(function()
        self:OnClickBtnRight()
    end)

    self.btnIntro:regOnButtonClick(function()
        self:OnIntroBtnClick()
    end)
    
    self.btnRank:regOnButtonClick(function()
        self:OnRankBtnClick()
    end)

    self.clickMask:regOnButtonClick(function()
        self:OnClickMask()
    end)
    if luaevt.trig("__KR__VERSION__") then
        GameObjectHelper.FastSetActive(self.btnRank.gameObject, false)
    end
end

function HeroHallMainView:ShowDisplayArea(isShow)
    GameObjectHelper.FastSetActive(self.mainView.gameObject, isShow)
end

function HeroHallMainView:RegOnDynamicLoad(func)
    self.infoBarDynParent:RegOnDynamicLoad(func)
end

function HeroHallMainView:OnClickBtnLeft()
    if self.onClickBtnLeft and self.canButtonClick then
        self.onClickBtnLeft()
    end

    self.indicator:Previous()
end

function HeroHallMainView:OnClickBtnRight()
    if self.onClickBtnRight and self.canButtonClick then
        self.onClickBtnRight()
    end

    self.indicator:Next()
end

function HeroHallMainView:OnIntroBtnClick()
    if self.onIntroClick and self.canButtonClick then
        self.onIntroClick()
    end
end

function HeroHallMainView:OnRankBtnClick()
    if self.onRankClick and self.canButtonClick then
        self.onRankClick()
    end
end

function HeroHallMainView:OnClickMask()
    -- DO NOTHING
end

-- 背景，动画事件
function HeroHallMainView:ChangeEFXToLoop()
    self.bgAnimator:SetBool("isLoop", true)  --Lua assist checked flag
end

function HeroHallMainView:ExitScene()
    for k, hallSpt in pairs(self.halls) do
        hallSpt:RebindAllAnimator()
    end
end

return HeroHallMainView
