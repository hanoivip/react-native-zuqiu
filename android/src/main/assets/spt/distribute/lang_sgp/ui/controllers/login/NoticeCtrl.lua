local BaseCtrl = require("ui.controllers.BaseCtrl")
local NoticeLabelCtrl = require("ui.controllers.login.NoticeLabelCtrl")
local NoticeCtrl = class(BaseCtrl)

NoticeCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Login/Notice.prefab"

NoticeCtrl.dialogStatus = {
    touchClose = false,
    withShadow = false,
    unblockRaycast = false,
}

function NoticeCtrl:Refresh(channel ,callback)
    self.view.closeCallback = callback
    if not channel and cache.getChannel() then
        channel = cache.getChannel()
    end
    cache.setIsContainHWCard(channel == "huawei")
    self.view:coroutine(function()
        local resp = req.bulletin(channel)
        if api.success(resp) then
            local data = resp.val.bulletin
            local qqData = nil
            if resp.val.channelSet ~= nil and resp.val.channelSet.QQGroup ~= nil then
                qqData = resp.val.channelSet.QQGroup
            end
            -- if resp.val.channelSet ~= nil and resp.val.channelSet.share ~= nil then
            --     -- 主线新手引导阶段屏蔽分享
            --     cache.setIsOpenShareSDK(resp.val.channelSet.share == 1)
            -- end

            if luaevt.trig("___EVENT__SHARE_FORBIDDEN") then
                cache.setIsOpenShareSDK(false)
            else
                cache.setIsOpenShareSDK(true)
            end

            self.view:Init(data, qqData)
            -- 防止公告内容是空
            if #data ~= 0 then
                self.noticeLabelCtrl = NoticeLabelCtrl.new(self.view.labelScroll, self, data)
                self.noticeLabelCtrl:InitView(1)
            end
        end
    end)
end

-- 点击label，选择哪个公告
function NoticeCtrl:RefreshContent(selIndex)
    self.view:Show(selIndex)
end

function NoticeCtrl:OnExitScene()
    self.view:OnExitScene()
end

return NoticeCtrl
