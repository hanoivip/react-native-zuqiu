local AssetFinder = require("ui.common.AssetFinder")
local Timer = require("ui.common.Timer")
local TransportMySponsorType = require("ui.scene.transfort.TransportMySponsorType")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local Button = UnityEngine.UI.Button
local Text = UnityEngine.UI.Text

local TransportMySponsorItemView = class(unity.base)

function TransportMySponsorItemView:ctor()
    self.logoImg = self.___ex.logoImg
    self.nameTxt = self.___ex.nameTxt
    self.normalRect = self.___ex.normalRect
    self.specialRect = self.___ex.specialRect
    self.normalCountTxt = self.___ex.normalCountTxt
    self.specialCountTxt = self.___ex.specialCountTxt
    self.signTxt = self.___ex.signTxt
    self.signBtn = self.___ex.signBtn
    self.receiveTimeTxt = self.___ex.receiveTimeTxt
    self.receiveBtn = self.___ex.receiveBtn
    self.startBtn = self.___ex.startBtn
    self.inviteBtn = self.___ex.inviteBtn
    self.goodsRect = self.___ex.goodsRect
    self.special = self.___ex.special
    self.acceptProtection = self.___ex.acceptProtection
end

function TransportMySponsorItemView:start()
    self.signBtn:regOnButtonClick(function ()
        if self.onSignBtnClick then
            self.onSignBtnClick()
        end
    end)
    self.startBtn:regOnButtonClick(function ()
        if self.onStartBtnClick then
            self.onStartBtnClick()
        end
    end)
    self.inviteBtn:regOnButtonClick(function ()
        if self.onInviteBtnClick then
            self.onInviteBtnClick()
        end
    end)
    self.receiveBtn:regOnButtonClick(function ()
        if self.onReceiveBtnClick then
            self.onReceiveBtnClick()
        end
    end)
end

function TransportMySponsorItemView:InitView(data, mainModel)
    self.mainModel = mainModel
    self:InitButtonState(data.status, data.receiveGift, data.guardPlayer)
    self:InitCommonContent(data)
end

function TransportMySponsorItemView:InitCommonContent(data)
    self.nameTxt.text = self.mainModel:GetSpnsorNameBySponsorId(data.sponsorId)
    self.signTxt.text = lang.trans("transfort_sign_time", self.mainModel:GetSignedTime(), self.mainModel:GetMaxSignTime())
    self.logoImg.overrideSprite = AssetFinder.GetSponsorIcon(data.sponsorId)

    local num = 0
	local contents = data.sponsorReward and data.sponsorReward.baseReward.contents or data.baseReward.contents or {}
    for k, v in pairs(contents) do
        if type(v) == "table" then
            num = v[1].num
        elseif type(v) == "number" then
            num = v
        end
    end
    self.normalCountTxt.text = "x" .. string.formatNumWithUnit(num)
    -- 是否被抢劫
    if data.robberyBaseRewardCount and data.robberyBaseRewardCount ~= 0 then
        self.normalCountTxt.text = lang.trans("transfort_general_sponsor_count", string.formatNumWithUnit(num), string.formatNumWithUnit(data.robberyBaseRewardCount))
    end

    if self.lastTimer then
        self.lastTimer:Destroy()
        self.lastTimer = nil
    end

    -- 完成奖励的倒计时
    if data.remainTime and data.remainTime ~= 0 and data.status == TransportMySponsorType.AfterStartAndNotFinish then
        self.lastTimer = Timer.new(data.remainTime, function (time)
            self.receiveTimeTxt.text = lang.trans("transfort_finish_game", string.convertSecondToTime(time))
            if time <= 0 then
                self.lastTimer:Destroy()
                self.lastTimer = nil
                clr.coroutine(function ()
                    response = req.transportOver()
                    if api.success(response) then
                        self.mainModel:SetMySponsorDataList(response.val.transport.express)
                    end
                end)
            end
        end)
    elseif data.remainTime and data.remainTime == 0 and data.status == TransportMySponsorType.AfterStartAndNotFinish then
        clr.coroutine(function ()
            response = req.transportOver()
            if api.success(response) then
                self.mainModel:SetMySponsorDataList(response.val.transport.express)
            end
        end)
    end
    
    -- 基础奖励
    res.ClearChildren(self.normalRect)
    local rewardParams = {
        parentObj = self.normalRect,
        rewardData = data.sponsorReward and data.sponsorReward.baseReward.contents or data.baseReward.contents,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = false,
        hideCount = true
    }
    RewardDataCtrl.new(rewardParams)

    -- 特殊奖励
    res.ClearChildren(self.specialRect)
    if not data.specialReward then
        GameObjectHelper.FastSetActive(self.special, false)
        return
    end

    local num = 0
	local contents = data.sponsorReward and data.sponsorReward.specialReward.contents or data.specialReward.contents or {}
    for k, v in pairs(contents) do
        if type(v) == "table" then
            num = v[1].num
        elseif type(v) == "number" then
            num = v
        end
    end
    self.specialCountTxt.text = "x" .. num
    -- 是否被抢劫
    if data.robberySpecialRewardCount and data.robberySpecialRewardCount ~= 0 then
        self.specialCountTxt.text = lang.trans("transfort_general_sponsor_count", num, data.robberySpecialRewardCount)
    end

    GameObjectHelper.FastSetActive(self.special, true)
    local rewardParams = {
        parentObj = self.specialRect,
        rewardData = data.sponsorReward and data.sponsorReward.specialReward.contents or data.specialReward.contents,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = false,
        hideCount = true
    }
    RewardDataCtrl.new(rewardParams)
end

function TransportMySponsorItemView:InitButtonState(status, receiveGift, guardInfo)
    self.goodsRect.sizeDelta = Vector2(257, 300)
    GameObjectHelper.FastSetActive(self.signTxt.gameObject, status == TransportMySponsorType.BeforeSign)
    GameObjectHelper.FastSetActive(self.signBtn.gameObject, status == TransportMySponsorType.BeforeSign)
    GameObjectHelper.FastSetActive(self.startBtn.gameObject, status == TransportMySponsorType.AfterSignAndBeforeStart)
    GameObjectHelper.FastSetActive(self.inviteBtn.gameObject, status == TransportMySponsorType.AfterSignAndBeforeStart)
    GameObjectHelper.FastSetActive(self.receiveBtn.gameObject, status == TransportMySponsorType.AfterStartAndNotFinish or status == TransportMySponsorType.AfterFinsh)
    GameObjectHelper.FastSetActive(self.receiveTimeTxt.gameObject, status == TransportMySponsorType.AfterStartAndNotFinish or status == TransportMySponsorType.AfterFinsh)
    GameObjectHelper.FastSetActive(self.acceptProtection, false)
    if status == TransportMySponsorType.BeforeSign then -- 0
        self.goodsRect.sizeDelta = Vector2(257, 318)
    elseif status == TransportMySponsorType.AfterSignAndBeforeStart then -- 1
        GameObjectHelper.FastSetActive(self.acceptProtection, guardInfo)
        if guardInfo then
            self.inviteBtn:GetComponentInChildren(Text).text = lang.trans("transport_view_protection")  --Lua assist checked flag
        else
            self.inviteBtn:GetComponentInChildren(Text).text = lang.trans("transfort_invite_protect")  --Lua assist checked flag
        end
    elseif status == TransportMySponsorType.AfterStartAndNotFinish then -- 2
        self.receiveBtn:GetComponent(Button).interactable = false
        self.receiveBtn:onPointEventHandle(false)
        self.receiveBtn:GetComponentInChildren(Text).text = lang.trans("mail_collectRewards")  --Lua assist checked flag
    elseif status == TransportMySponsorType.AfterFinsh then -- 3
        self.receiveBtn:GetComponent(Button).interactable = true
        self.receiveBtn:onPointEventHandle(true)
        self.receiveTimeTxt.text = lang.trans("finished_cumulative_login")
        self.receiveBtn:GetComponentInChildren(Text).text = lang.trans("mail_collectRewards")  --Lua assist checked flag
        if receiveGift then
            self.receiveBtn:GetComponent(Button).interactable = false
            self.receiveBtn:onPointEventHandle(false)
            self.receiveBtn:GetComponentInChildren(Text).text = lang.trans("have_received")  --Lua assist checked flag
        end
    end
end

function TransportMySponsorItemView:onDestroy()
    if self.lastTimer then
        self.lastTimer:Destroy()
        self.lastTimer = nil
    end
end

return TransportMySponsorItemView
