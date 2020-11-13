local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector2 = UnityEngine.Vector2
local Vector3 = UnityEngine.Vector3
local Mathf = UnityEngine.Mathf
local Tweening = clr.DG.Tweening
local DOTween = Tweening.DOTween
local Tweener = Tweening.Tweener
local ShortcutExtensions = Tweening.ShortcutExtensions
local TweenSettingsExtensions = Tweening.TweenSettingsExtensions
local TweenExtensions = Tweening.TweenExtensions
local Ease = Tweening.Ease
local LoopType = Tweening.LoopType

local LeagueConstants = require("ui.scene.league.LeagueConstants")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local CommonConstants = require("ui.common.CommonConstants")

local LeagueWelcomePageView = class(unity.base)

function LeagueWelcomePageView:ctor()
    -- 标题
    self.title = self.___ex.title
    -- 标题提示
    self.titleTip = self.___ex.titleTip
    -- 联赛等级标题
    self.levelTitle = self.___ex.levelTitle
    -- 联赛等级标题下划线
    self.levelUnderline = self.___ex.levelUnderline
    -- 连线
    self.connectLine = self.___ex.connectLine
    -- 标识联赛等级的点
    self.point = self.___ex.point
    -- 点击继续提示
    self.continueTip = self.___ex.continueTip
    -- 点击区域
    self.clickArea = self.___ex.clickArea
    -- 联赛金字塔闪光区域
    self.pyramidEffect = self.___ex.pyramidEffect
    -- 动画管理器
    self.animator = self.___ex.animator
    -- model
    self.leagueInfoModel = nil
    -- 动画是否已完成
    self.isAnimComplete = false
    -- 动画序列
    self.mySequence = nil
    -- 联赛等级
    self.leagueLevel = nil
end

function LeagueWelcomePageView:InitView(leagueInfoModel)
    self.leagueInfoModel = leagueInfoModel
    self.leagueLevel = self.leagueInfoModel:GetLeagueLevel()
    
    self:BuildPage()
end

function LeagueWelcomePageView:start()
    self:BindAll()
    self:PlayAnim()
    GuideManager.InitCurModule("league")
    GuideManager.Show()
end

function LeagueWelcomePageView:BuildPage()
    self:BuildTitleArea()
    self:BuildPyramidLevelArea()
    self:BuildLine()
end

function LeagueWelcomePageView:BindAll()
    -- 点击区域
    self.clickArea:regOnButtonClick(function ()
        if not self.isAnimComplete then
            TweenExtensions.Complete(self.mySequence, true)
        else
            self:PlayMoveOutAnim()
        end
    end)
end

--- 构建标题区域
function LeagueWelcomePageView:BuildTitleArea()
    self.title.text = lang.trans("league_welcomeIn", self.leagueLevel)
    if self.leagueLevel >= LeagueConstants.LeagueMaxLevel then
        self.titleTip:SetActive(false)
    else
        self.titleTip:SetActive(true)
    end
end

--- 构建金字塔等级区域
function LeagueWelcomePageView:BuildPyramidLevelArea()
    self.levelTitle.text = lang.trans("league_leagueLevel", self.leagueLevel)
    local materialPath = "Assets/CapstonesRes/Game/UI/Scene/League/Material/EffectPyr" .. self.leagueLevel .. "side.mat"
    self.pyramidEffect.material = Object.Instantiate(res.LoadRes(materialPath))
end

--- 构建指示联赛等级的线
function LeagueWelcomePageView:BuildLine()
    local pointData = LeagueConstants.PyramidLineData[self.leagueLevel].POINT
    self.point.anchoredPosition = Vector2(pointData.X, pointData.Y)
    local pointPos = self.point.anchoredPosition
    local underlinePos = self.levelUnderline.anchoredPosition
    self.connectLine.anchoredPosition = Vector2.Lerp(pointPos, underlinePos, 0.5)
    self.connectLine.sizeDelta = Vector2(Vector2.Distance(pointPos, underlinePos), self.connectLine.sizeDelta.y)
    local radian = (underlinePos.y - pointPos.y) / self.connectLine.sizeDelta.x
    self.connectLine.eulerAngles = Vector3(0, 0, Mathf.Asin(radian) * Mathf.Rad2Deg)
end

--- 播放动画
function LeagueWelcomePageView:PlayAnim()
    -- 按钮
    local continueBtnFadeInTweener = ShortcutExtensions.DOFade(self.continueTip, 1, 1)
    self.mySequence = DOTween.Sequence()
    TweenSettingsExtensions.Append(self.mySequence, continueBtnFadeInTweener)
    TweenSettingsExtensions.AppendCallback(self.mySequence, function ()
        self.isAnimComplete = true
        local continueBtnFadeInOutTweener = ShortcutExtensions.DOFade(self.continueTip, 0.3, 1)
        TweenSettingsExtensions.SetLoops(continueBtnFadeInOutTweener, -1, LoopType.Yoyo)
    end)
end

function LeagueWelcomePageView:OnClick()
    if not self.isAnimComplete then
        TweenExtensions.Complete(self.mySequence, true)
    else
        clr.coroutine(function()
            unity.waitForEndOfFrame()
            local leagueWelcomeInfoPageView = res.LoadSceneImmediate("Assets/CapstonesRes/Game/UI/Scene/League/LeagueWelcomeInfo.prefab")
            leagueWelcomeInfoPageView:InitView(self.leagueInfoModel)
        end)
    end
end

function LeagueWelcomePageView:PlayMoveOutAnim()
    self.animator:Play("MoveOut")
end

function LeagueWelcomePageView:OnAnimEnd(animMoveType)
    if animMoveType == CommonConstants.UIAnimMoveType.MOVE_OUT then
        self:OnClick()
    end
end

return LeagueWelcomePageView
