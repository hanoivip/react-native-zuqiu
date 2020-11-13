local AssetFinder = require("ui.common.AssetFinder")
local Timer = require("ui.common.Timer")
local GameObjectHelper = require("ui.common.GameObjectHelper")

local TransportCourseItemView = class(unity.base)

function TransportCourseItemView:ctor()
    self.detailBtn = self.___ex.detailBtn
    self.normalTxt = self.___ex.normalTxt
    self.specialTxt = self.___ex.specialTxt
    self.logoImg = self.___ex.logoImg
    self.nameTxt = self.___ex.nameTxt
    self.timeTxt = self.___ex.timeTxt
    self.empty = self.___ex.empty
    self.isEnemy = self.___ex.isEnemy
end

function TransportCourseItemView:start()
    self.detailBtn:regOnButtonClick(function ()
        if self.onDetailBtnClick then
            self.onDetailBtnClick()
        end
    end)
end

function TransportCourseItemView:InitView(data)
    if not data then self.empty:SetActive(false) return end
    self.nameTxt.text = data.name
    self.logoImg.overrideSprite = AssetFinder.GetSponsorIcon(data.sponsorId, true)
    self.normalTxt.text = "x" .. tostring(data.robberyRewardTimes)
    self.specialTxt.text = "x" .. tostring(data.robberySpecialRewardTimes)

    self.timer = Timer.new(data.remainTime, function (time)
        self.timeTxt.text = string.convertSecondToTime(time)
    end)

    -- 是否被标记为仇敌
    GameObjectHelper.FastSetActive(self.isEnemy, data.markStatus)
end

function TransportCourseItemView:onDestroy()
    if self.timer then
        self.timer:Destroy()
        self.timer = nil
    end
end

return TransportCourseItemView
