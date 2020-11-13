local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local GameObjectHelper = require("ui.common.GameObjectHelper")

local MailRewardScrollView = class(unity.base)
-- 重用一些存在的奖励对象
function MailRewardScrollView:ResetRewardShowState(contentTransform)
    self.isUseRewardBars = {}
    self.useCount = 0
    for i = 0, contentTransform.childCount - 1 do
        local obj = contentTransform:GetChild(i).gameObject
        GameObjectHelper.FastSetActive(obj, false)
        table.insert(self.isUseRewardBars, obj)
    end
end

function MailRewardScrollView:InitView(rewardContents, parent)
    self.parent = parent
    self:ResetRewardShowState(parent)
    for rewardType, reward in pairs(rewardContents) do
        if type(reward) == "table" then
            self:CreatTableItem(reward, rewardType)
        else
            self:CreatNumberItem(reward, rewardType)
        end
    end
end

function MailRewardScrollView:CreatTableItem(rewards, rewardType)
    if next(rewards) then
        for i, rewardItem in ipairs(rewards) do
            local rewardBar
            self.useCount = self.useCount + 1
            if self.isUseRewardBars[self.useCount] then
                rewardBar = self.isUseRewardBars[self.useCount]
                GameObjectHelper.FastSetActive(rewardBar, true)
            else
                local obj = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Mail/MailRewardView.prefab")
                rewardBar = Object.Instantiate(obj)
                rewardBar.transform:SetParent(self.parent, false)
            end
            local mailRewardScrollBarView = rewardBar:GetComponent(clr.CapsUnityLuaBehav)
            mailRewardScrollBarView:InitViewWithoutIcon(rewardItem, rewardType)
        end
    end
end

function MailRewardScrollView:CreatNumberItem(reward, rewardType)
    if reward ~= 0 then
        local rewardBar
        self.useCount = self.useCount + 1
        if self.isUseRewardBars[self.useCount] then
            rewardBar = self.isUseRewardBars[self.useCount]
            GameObjectHelper.FastSetActive(rewardBar, true)
        else
            local obj = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Mail/MailRewardView.prefab")
            rewardBar = Object.Instantiate(obj)
            rewardBar.transform:SetParent(self.parent, false)
        end
        local mailRewardScrollBarView = rewardBar:GetComponent(clr.CapsUnityLuaBehav)
        mailRewardScrollBarView:InitViewWithIcon(reward, rewardType)
    end
end

return MailRewardScrollView
