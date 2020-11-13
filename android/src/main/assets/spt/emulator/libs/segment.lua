local segment = {}
local mt = {}

function segment.new(s, e)
    local ret = { s = s, e = e }
    setmetatable(ret, mt)
    return ret
end

return segment
