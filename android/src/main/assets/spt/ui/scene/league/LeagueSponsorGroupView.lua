local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector3 = UnityEngine.Vector3
local Tweening = clr.DG.Tweening
local DOTween = Tweening.DOTween
local Tweener = Tweening.Tweener
local ShortcutExtensions = Tweening.ShortcutExtensions
local TweenSettingsExtensions = Tweening.TweenSettingsExtensions
local TweenExtensions = Tweening.TweenExtensions
local Ease = Tweening.Ease
local LoopType = Tweening.LoopType

local LeagueConstants = require("ui.scene.league.LeagueConstants")

local LeagueSponsorGroupView = class(unity.base)

function LeagueSponsorGroupView:ctor()
    self.mRectTrans = self.___ex.mRectTrans
    -- 赞助费数量
    self.sponsorNum = self.___ex.sponsorNum
    -- 确认图标
    self.confirmIcon = self.___ex.confirmIcon
    -- 触摸遮罩层
    self.confirmButton = self.___ex.confirmButton
    -- 标题
    self.sponsorTitle = self.___ex.sponsorTitle
    -- 描述
    self.sponsorDesc = self.___ex.sponsorDesc
    -- 动画管理器
    self.animator = self.___ex.animator
    -- 赞助商数据
    self.sponsorData = nil
    -- model
    self.leagueInfoModel = nil
end

function LeagueSponsorGroupView:InitView(leagueInfoModel, sponsorData)
    self.leagueInfoModel = leagueInfoModel
    self.sponsorData = sponsorData
    self:BuildPage()
    self:BindAll()
    self:RegisterEvent()
end

function LeagueSponsorGroupView:BindAll()
    self.confirmButton:regOnButtonClick(function ()
        EventSystem.SendEvent("LeagueSponsor.DisableTouch")
        self.confirmIcon.gameObject:SetActive(true)
        self.animator:Play("SponsorGroupAnimation")
    end)
end

--- 注册事件
function LeagueSponsorGroupView:RegisterEvent()
    EventSystem.AddEvent("LeagueSponsor.DisableTouch", self, self.DisableTouch)
end

--- 移除事件
function LeagueSponsorGroupView:RemoveEvent()
    EventSystem.RemoveEvent("LeagueSponsor.DisableTouch", self, self.DisableTouch)
end

function LeagueSponsorGroupView:BuildPage()
    self.sponsorNum.text = string.formatNumWithUnit(self.sponsorData.reward)
    self.sponsorTitle.text = self.sponsorData.sponsor
    self.sponsorDesc.text = self.sponsorData.sponsorDesc
    self.confirmIcon.gameObject:SetActive(false)
    self.confirmButton:onPointEventHandle(true)
end

function LeagueSponsorGroupView:OnAnimEnd()
    EventSystem.SendEvent("LeagueSponsor_SelectSponsor", self.sponsorData.ID)
end

--- 禁用触摸
function LeagueSponsorGroupView:DisableTouch()
    self.confirmButton:onPointEventHandle(false)
end

function LeagueSponsorGroupView:onDestroy()
    self:RemoveEvent()
end

return LeagueSponsorGroupView
