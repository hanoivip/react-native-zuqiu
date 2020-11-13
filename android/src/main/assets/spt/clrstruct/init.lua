require("clrstruct.Mathf")
require("clrstruct.YieldInstructions")

local LuaHubC = clr.Capstones.LuaLib.LuaHub.LuaHubC
local SupportedVer = 7
if LuaHubC.LuaPrecompileEnabled and LuaHubC.LIB_VER >= SupportedVer then
    require("clrstruct.Vector3")
end
