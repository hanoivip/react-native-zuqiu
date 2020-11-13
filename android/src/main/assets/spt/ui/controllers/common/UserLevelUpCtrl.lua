local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local UserLevelUpCtrl = class()

function UserLevelUpCtrl:ctor(levelData)
    local dlg, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Common/UserLevelUp/UserLevelUp.prefab", "camera", false, true)
    dialogcomp.contentcomp:InitData(levelData)
    local aftLvl = levelData.aftLvl
    local playerInfoModel = PlayerInfoModel.new()
    local roleId = playerInfoModel:GetID()
    local roleName = playerInfoModel:GetName()
    local rolePower = playerInfoModel:GetPower()
    local vipLvl = playerInfoModel:GetVipLevel()
    local server = cache.getCurrentServer()
    local serverCode = server.id
    local serverName = server.name
    luaevt.trig("SDK_Report", "levelup", aftLvl, roleId, roleName, serverCode, serverName, rolePower, vipLvl)
end

return UserLevelUpCtrl