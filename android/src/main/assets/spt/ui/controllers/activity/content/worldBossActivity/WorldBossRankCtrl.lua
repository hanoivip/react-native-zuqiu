local BaseCtrl = require("ui.controllers.BaseCtrl")
local WorldBossRankModel = require("ui.models.activity.worldBossActivity.WorldBossRankModel")
local PlayerDetailCtrl = require("ui.controllers.playerDetail.PlayerDetailCtrl")
local WorldBossRankCtrl = class(BaseCtrl)

WorldBossRankCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/WorldBossActivity/WorldBossRankBroad.prefab"
WorldBossRankCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

function WorldBossRankCtrl:Init(data)
    self.isSelf = data
end

function WorldBossRankCtrl:GetStatusData()
    return self.isSelf
end

function WorldBossRankCtrl:Refresh()
    self:InitView()
end

function WorldBossRankCtrl:AheadRequest(isSelf)
    local response = nil
    if isSelf then
        response = req.activityWorldBossPlayerSort()
    else
        response = req.activityWorldBossServerSort()
    end
    if api.success(response) then
        self.worldBossRankModel = WorldBossRankModel.new(isSelf)
        self.worldBossRankModel:InitWithProtocol(response.val)
    end
end

function WorldBossRankCtrl:InitView()
    self.view.onHelpClick = function() self:OnHelpClick() end
    self.view:InitView(self.worldBossRankModel)
    self:CreateItemList()
end

function WorldBossRankCtrl:OnHelpClick()
    res.PushDialog("ui.controllers.activity.content.worldBossActivity.WorldBossRankRuleCtrl", self.isSelf)
end

function WorldBossRankCtrl:CreateItemList()
    self.view.scrollView.onScrollCreateItem = function(index)
        local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Activties/WorldBossActivity/WorldBossRankBar.prefab")
        return obj, spt
    end
    self.view.scrollView.onScrollResetItem = function(spt, index)
        local rankListData = self.view.scrollView.itemDatas[index]
        spt.onViewOpponentDetail = function() self:OnViewOpponentDetail(rankListData.pid, rankListData.sid) end
        rankListData.rank = index
        spt:InitView(rankListData, self.isSelf)
        self.view.scrollView:updateItemIndex(spt, index)
    end
    self:RefreshScrollView()
end

function WorldBossRankCtrl:RefreshScrollView()
    local rankList = self.worldBossRankModel:GetRankList()
    self.view.scrollView:clearData()
    for i = 1, #rankList do
        table.insert(self.view.scrollView.itemDatas, rankList[i])
    end
    self.view.scrollView:refresh()
end

-- 查看对手信息
function WorldBossRankCtrl:OnViewOpponentDetail(pid , sid)
    if not self.pid then
        self.pid = require("ui.models.PlayerInfoModel").new():GetID()
    end
    PlayerDetailCtrl.ShowPlayerDetailView(function() return req.friendsDetail(pid, sid) end, pid, sid, self.pid == pid)
end

return WorldBossRankCtrl