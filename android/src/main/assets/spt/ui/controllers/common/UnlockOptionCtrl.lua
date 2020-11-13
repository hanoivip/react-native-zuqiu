local LevelLimit = require("data.LevelLimit")
local PlayerNewfunctionModel = require("ui.models.PlayerNewFunctionModel")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local UnlockOptionCtrl = class()

function UnlockOptionCtrl:ctor(levelData)
    self.unlockGroup = { }
    self.preLevel = 0
    self.lastLevel = 0
    self:Init(levelData)
end

function UnlockOptionCtrl:Init(levelData)
    self.preLevel = levelData.befLvl
    self.lastLevel = levelData.aftLvl
    assert(type(LevelLimit) == "table")
    for k, unlockData in pairs(LevelLimit) do
        local needLevel = unlockData.playerLevel
        if self.preLevel < needLevel and self.lastLevel >= needLevel and unlockData.hasTip == 1 then
            table.insert(self.unlockGroup, unlockData)
            self:UnlockNewFunctionRedPoint(k)
        end
    end
    self:PopFunctionNotice()
end

function UnlockOptionCtrl:UnlockNewFunctionRedPoint(functionName)
    local playerNewFunction = PlayerNewfunctionModel.new()
    clr.coroutine(function()
        local response = req.setEnterSenceList(functionName, 1)
        if api.success(response) then
            playerNewFunction:SetWithProtocol(response.val,functionName)
        end
    end)
end 

function UnlockOptionCtrl:PopFunctionNotice()
    if next(self.unlockGroup) then
        local unlockData = table.remove(self.unlockGroup, 1)
        local dlg, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Common/FunctionNotice/NewFunctionNotice.prefab", "camera", false, true)
        dialogcomp.contentcomp:InitView(unlockData)
        dialogcomp.contentcomp.clickConfirm = function() self:OnEnd(dialogcomp) end
        local server = cache.getCurrentServer()
        local serverCode = server.id
        local serverName = server.name
        local playerInfoModel = require("ui.models.PlayerInfoModel").new()
        local roleId = playerInfoModel:GetID()
        local roleName = playerInfoModel:GetName()
        local roleLvl = playerInfoModel:GetLevel()
		luaevt.trig("SDK_Report", "unlock_achievement", unlockData.ID, serverCode, serverName, roleId, roleName, roleLvl)
    else
        GuideManager.LevelGuide()
        EventSystem.SendEvent("LevelUpAndFunctionNoticeEnd")
    end
end

function UnlockOptionCtrl:OnEnd(dialogcomp)
    dialogcomp.closeDialog()
    self:PopFunctionNotice()
end

function UnlockOptionCtrl:ClickCallback(dialogcomp, unlockData)
    dialogcomp:regOnButtonClick(function()
        self:OnEnd(dialogcomp)
    end)
end

return UnlockOptionCtrl