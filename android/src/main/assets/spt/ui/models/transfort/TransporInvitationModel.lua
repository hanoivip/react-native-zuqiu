local Model = require("ui.models.Model")
local PlayerTeamsModel = require("ui.models.PlayerTeamsModel")
local TransporInvitationType = require("ui.models.transfort.TransporInvitationType")

local TransporInvitationModel = class(Model)

function TransporInvitationModel:InitWithProtocol(data)
    assert(data)
    self.data = data
end

local function DataSort(a, b)
    if a.gd_times == 0 then return false end
    return a.power > b.power
end

function TransporInvitationModel:GetGuildData()
    table.sort(self.data.guildMembers, DataSort)
    return self.data.guildMembers
end

function TransporInvitationModel:GetFriendsData()
    table.sort(self.data.friends, DataSort)
    return self.data.friends
end

function TransporInvitationModel:GetMenuType()
    return self.menuType or TransporInvitationType.FRIENDS
end

function TransporInvitationModel:SetMenuType(menuType)
    self.menuType = menuType
end

-- 根据标签判断是全部邀请好友还是全部邀请公会成员
function TransporInvitationModel:GeAllPlayerPidList()
    local menuType = self.menuType or "friends"
    local info = {}
    for k, v in pairs(self.data[menuType]) do
        if v.gd_times ~= 0 then
            info[v.pid] = v.sid
        end
    end
    return info
end

-- 用于一键邀请高战力
function TransporInvitationModel:GetHigherPlayerList()
    local power = PlayerTeamsModel.new():GetTotalPower()
    local menuType = self.menuType or TransporInvitationType.FRIENDS
    local info = {}
    for k, v in pairs(self.data[menuType]) do
        if v.power > power and v.gd_times ~= 0 then
            info[v.pid] = v.sid
        end
    end
    return info
end

function TransporInvitationModel:IsAllInvited()
    local menuType = self.menuType or TransporInvitationType.FRIENDS
    if not next(self.data[menuType]) then return true end
    for k, v in pairs(self.data[menuType]) do
        if not v.applyGuardStatus then
            return false
        end
    end
    return true
end

function TransporInvitationModel:IsAllHigherPlayerList()
    local menuType = self.menuType or "friends"
    if not next(self.data[menuType]) then return true end
    local power = PlayerTeamsModel.new():GetTotalPower()
    for k, v in pairs(self.data[menuType]) do
        if v.power > power then
            if not v.applyGuardStatus then
                return false
            end
        end
    end
    return true
end

return TransporInvitationModel