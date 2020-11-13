local Action = import("./Action")

local ManualOperate = class(Action)

function ManualOperate:ctor()
    self.name = "ManualOperate"
end

function ManualOperate:toString()
    return "[ManualOperate Action]"
end

return ManualOperate
