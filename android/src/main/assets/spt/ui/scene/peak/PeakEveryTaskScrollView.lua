local LuaScrollRectExSameSize = require("ui.control.scroll.LuaScrollRectExSameSize")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local PeakEveryTaskScrollView = class(LuaScrollRectExSameSize)

function PeakEveryTaskScrollView:start()
end

function PeakEveryTaskScrollView:InitView(data, model)
    self.itemDatas = data
    self.model = model
    self:refresh()
end

function PeakEveryTaskScrollView:createItem(index)
    local prefab = "Assets/CapstonesRes/Game/UI/Scene/Peak/PeakEveryTaskItem.prefab"
    local obj, spt = res.Instantiate(prefab)
    self:resetItem(spt, index)
    return obj
end

function PeakEveryTaskScrollView:resetItem(spt, index)
    local data = self.itemDatas[index]
    spt.receiveBtnClick = function ()
        local response = req.peakReceiveDailyTaskReward(data.ID)
        if api.success(response) then
            CongratulationsPageCtrl.new(response.val.contents)
            EventSystem.SendEvent("Refresh_Peak_Every_Task")
        end
    end
    spt:InitView(data, self.model)
end

return PeakEveryTaskScrollView