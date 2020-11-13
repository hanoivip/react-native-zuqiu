local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local UnlockModel = require("ui.models.common.UnlockModel")
local FancyEnterGuideView = class(unity.base, "FancyEnterGuideView")

function FancyEnterGuideView:ctor()
--------Start_Auto_Generate--------
    self.holeTrans = self.___ex.holeTrans
    self.attentionAreaTrans = self.___ex.attentionAreaTrans
--------End_Auto_Generate----------
end

local SideBtnID = {}
SideBtnID[15] = true
SideBtnID[16] = true
SideBtnID[17] = true
SideBtnID[18] = true
SideBtnID[20] = true
SideBtnID[21] = true
function FancyEnterGuideView:start()
    local playerInfoModel = PlayerInfoModel.new()
    local unlockModel = UnlockModel.new()
    local level = playerInfoModel:GetLevel()
    unlockModel:SetCurrentLevel(level)
    local unlockTable = unlockModel:GetUnlockTable()
    local count = 0
    for i, v in pairs(unlockTable) do
        local id = tonumber(i)
        if SideBtnID[id] and v.isOpen then
            count = count + 1
        end
    end
    count = count - 1
    local pos = 120*count + 10 * (count-1)
    pos = math.clamp(pos, 0, pos)
    pos = Vector2(0, -pos)
    self.holeTrans.anchoredPosition = pos
    self.attentionAreaTrans.anchoredPosition = pos
end

return FancyEnterGuideView
