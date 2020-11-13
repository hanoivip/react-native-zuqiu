-- 作为一个全局类使用
local EventSystem = require("EventSystem")

local ReqEventModel = {}

local cacheEventData = {}

function ReqEventModel.GetInfo(eventKey)
    assert(type(eventKey) == "string")
    return cacheEventData[eventKey]
end

function ReqEventModel.SetInfo(eventKey, data)
    assert(type(eventKey) == "string" and data)
    cacheEventData[eventKey] = data
    EventSystem.SendEvent("ReqEventModel_" .. eventKey)
end

return ReqEventModel
