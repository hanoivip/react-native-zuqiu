local LoseGuideModel = require("ui.models.loseGuide.LoseGuideModel")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")

local LoseGuideCtrl = class()

function LoseGuideCtrl:ctor(matchResult)
    self.loseGuideModel = nil
    self.matchResult = matchResult
    self:Init()
end

function LoseGuideCtrl:Init()
    if GuideManager.GuideIsOnGoing("main") then
       return 
    end

    local matchResultData = cache.getMatchResult()
    if self.matchResult ~= -1 or matchResultData == nil then
        return
    end

    local loseGuideData = matchResultData.loseGuide

    if type(loseGuideData) == "table" then
        self.loseGuideModel = LoseGuideModel.new()
        self.loseGuideModel:InitWithProtocol(loseGuideData)
        local dialog, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/LoseGuide/LoseGuide.prefab", "camera", true, true)
        local script = dialogcomp.contentcomp
        script:InitView(self.loseGuideModel)
    end
end

return LoseGuideCtrl
