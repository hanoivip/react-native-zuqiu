local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local GroupBarInfoView = class(unity.base)

function GroupBarInfoView:ctor()
    self.vertical = self.___ex.vertical
    self.barMap = {}
end

function GroupBarInfoView:GetGroupBarRes()
    if not self.groupBarRes then 
        self.groupBarRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Compete/Cross/Prefab/Schedule/GroupBar.prefab")
    end
    return self.groupBarRes
end

function GroupBarInfoView:InitView(groupData, scheduleModel, groupIndex)
    local playerId = scheduleModel:GetPlayerRoleId()
    for i, v in ipairs(groupData) do
        if not self.barMap[i] then 
            local node = Object.Instantiate(self:GetGroupBarRes())
            local nodeScript = node:GetComponent(clr.CapsUnityLuaBehav)
            node.transform:SetParent(self.transform, false)
            self.barMap[i] = nodeScript 
        end
        self.barMap[i]:InitView(i, v, playerId, scheduleModel, groupIndex)
    end
end

function GroupBarInfoView:OnClickVideo(vid, version)
    if self.clickVideo then 
        self.clickVideo(vid, version)
    end
end

return GroupBarInfoView