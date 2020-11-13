local Model = require("ui.models.Model")

local VideoReplayModel = class(Model)

function VideoReplayModel:ctor()
    VideoReplayModel.super.ctor(self)
end

function VideoReplayModel:InitWithProtocol(data)
    self.cacheData = clone(data)
end

-- 获取录像信息列表
function VideoReplayModel:GetVideoList()
    return self.cacheData.list
end

return VideoReplayModel