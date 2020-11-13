local CommentSettingCtrl = class()

function CommentSettingCtrl:ctor()
    local settings, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/CommentSetting/CommentSetting.prefab", "camera", false, true)
    self.settingsView = dialogcomp.contentcomp

    self:InitView()
end

function CommentSettingCtrl:InitView()
    local commentResTest = {
        {
            icon = "Assets/CapstonesRes/Game/UI/Scene/CommentSetting/Images/DefaultIcon.png",
            title = "默认语音包",
            commentIndex = "default"
        },
        {
            icon = "Assets/CapstonesRes/Game/UI/Scene/CommentSetting/Images/GirlGMH.png",
            title = "妹子语音包",
            commentIndex = "commentGuoMingHui"
        }
    }

    for k, v in ipairs(commentResTest) do
        local commentItem, commentItemView = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/CommentSetting/CommentItem.prefab")
        commentItem.transform:SetParent(self.settingsView.scorllContent.transform, false)
        commentItemView:InitView(v.commentIndex, v.icon, v.title)
    end
end

return CommentSettingCtrl
