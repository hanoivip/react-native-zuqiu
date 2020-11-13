local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local ArenaScheduleTeamModel = require("ui.models.arena.schedule.ArenaScheduleTeamModel")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local GroupPageView = class(unity.base)

function GroupPageView:ctor()
    self.content = self.___ex.content
    self.groupIndex = 1
    self.scoreInfoView = nil
    self.groupBarInfoView = nil
end

function GroupPageView:InitView(arenaTeamMatchModel, defaultIndex)
    self.groupIndex = defaultIndex or self.groupIndex
    self.arenaTeamMatchModel = arenaTeamMatchModel
    self:ShowTeamInfo(arenaTeamMatchModel, self.groupIndex)
end

function GroupPageView:ShowPageVisible(isVisible)
    GameObjectHelper.FastSetActive(self.gameObject, isVisible)
end

function GroupPageView:ArenaGroupMenuClick(index)
    self.groupIndex = index
    self:ShowTeamInfo(self.arenaTeamMatchModel, self.groupIndex)
end

function GroupPageView:EnterScene()
    EventSystem.AddEvent("ArenaGroupMenuClick", self, self.ArenaGroupMenuClick)
end

function GroupPageView:ExitScene()
    EventSystem.RemoveEvent("ArenaGroupMenuClick", self, self.ArenaGroupMenuClick)
end

function GroupPageView:GetScoreRes()
    if not self.scoreRes then 
        self.scoreRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Arena/Prefab/TeamScoreInfo.prefab")
    end
    return self.scoreRes
end

function GroupPageView:GetGroupBarAreaRes()
    if not self.groupBarAreaRes then 
        self.groupBarAreaRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Arena/Prefab/GroupBarArea.prefab")
    end
    return self.groupBarAreaRes
end

function GroupPageView:OnClickCheckFormation(id, sid)
    if self.onClickCheckFormation then 
        self.onClickCheckFormation(id, sid)
    end
end

function GroupPageView:ShowTeamInfo(arenaTeamMatchModel, groupIndex)
    local scoreData = arenaTeamMatchModel:GetScoreData(groupIndex)
    if not self.scoreInfoView then 
        local node = Object.Instantiate(self:GetScoreRes())
        local nodeScript = node:GetComponent(clr.CapsUnityLuaBehav)
        node.transform:SetParent(self.content, false)
        self.scoreInfoView = nodeScript 
        self.scoreInfoView.onClickCheckFormation = function(id, sid) self:OnClickCheckFormation(id, sid) end
    end
    self.scoreInfoView:InitView(scoreData,  ArenaScheduleTeamModel.GetInstance(), groupIndex)

    local groupData = arenaTeamMatchModel:GetGroupData(groupIndex)
    if not self.groupBarInfoView then 
        local node = Object.Instantiate(self:GetGroupBarAreaRes())
        local nodeScript = node:GetComponent(clr.CapsUnityLuaBehav)
        node.transform:SetParent(self.content, false)
        self.groupBarInfoView = nodeScript 
    end
    self.groupBarInfoView:InitView(groupData, ArenaScheduleTeamModel.GetInstance())

    self.groupBarInfoView.clickVideo = function(vid, version) self:OnClickVideo(vid, version) end
end

function GroupPageView:OnClickVideo(vid, version)
    if self.clickVideo then 
        self.clickVideo(vid, version)
    end
end

return GroupPageView
