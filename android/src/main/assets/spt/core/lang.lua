lang = {}

function lang.trans(key, ...)
    local t = {key, ...}

    for i, v in ipairs(t) do
        t[i] = tostring(v)
    end

    return clr.trans(t)
end

function lang.transstr(key, ...)
    -- 由于经常有key是空的用法，所以加个log
    if not key or key == "" then
        dump("warning-----------------------, the key is null, please check.")
        return ""
    end
    
    local t = {key, ...}

    for i, v in ipairs(t) do
        t[i] = tostring(v)
    end

    return clr.transstr(t)
end

return lang