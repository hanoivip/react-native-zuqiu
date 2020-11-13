local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector2 = UnityEngine.Vector2
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local GroupBarInfoView = class(unity.base)

function GroupBarInfoView:ctor()
    self.vertical = self.___ex.vertical
    self.barMap = {}
end

function GroupBarInfoView:GetGroupBarRes()
    if not self.groupBarRes then 
        self.groupBarRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Arena/Prefab/GroupBar.prefab")
    end
    return self.groupBarRes
end

function GroupBarInfoView:InitView(groupData, arenaScheduleTeamModel)
    local row = #groupData / 2
    local height = row * self.vertical.cellSize.y + (row - 1) * self.vertical.spacing.y
    self.transform.sizeDelta = Vector2(self.transform.sizeDelta.x, height)

    local playerInfoModel = PlayerInfoModel.new()
    local playerId = playerInfoModel:GetID()
    for i, v in ipairs(groupData) do
        if not self.barMap[i] then 
            local node = Object.Instantiate(self:GetGroupBarRes())
            local nodeScript = node:GetComponent(clr.CapsUnityLuaBehav)
            node.transform:SetParent(self.transform, false)
            self.barMap[i] = nodeScript 
        end
        self.barMap[i]:InitView(i, v, playerId, arenaScheduleTeamModel)
        self.barMap[i].video1:regOnButtonClick(function()
            self:OnClickVideo(v[1].vid, v[1].version)
        end)
        self.barMap[i].video2:regOnButtonClick(function()
            self:OnClickVideo(v[2].vid, v[2].version)
        end)
    end
end

function GroupBarInfoView:OnClickVideo(vid, version)
    if self.clickVideo then 
        self.clickVideo(vid, version)
    end
end

return GroupBarInfoView
