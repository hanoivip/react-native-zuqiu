if jit and jit.os == "OSX" and (jit.arch == "arm" or jit.arch == "arm64") then
    jit = nil
end

-- import("abc") => require("abc")
-- import("./abc") => require(CURRENT_DIR .. "abc")
-- import("../abc") => require(PARENT_DIR .. "abc")
function import(lib)
    -- if not specified relative path, use default require
    if string.sub(lib, 1, 2) ~= "./" and string.sub(lib, 1, 3) ~= "../" then
        return require(lib)
    end

    -- deal with relative path
    local _, package = debug.getlocal(3, 1)

    local cnt, level = 1, 1
    while cnt ~= 0 do
        -- eat up any "./" prefix
        local t = 1
        while t ~= 0 do
            lib, t = string.gsub(lib, "^(%./)", "", 2)
            if t ~= 0 then
                cnt = 1
            end
        end

        -- count "../", add to level
        lib, cnt = string.gsub(lib, "^(%.%./)", "", 3)
        if cnt ~= 0 then
            level = level + 1
        end
    end

    for i = 1, level do
        package = (package):match("^(.+)[%./][^%./]+") or ""
    end    

    return require(package .. "/" .. lib)
end

import("./libs/func")
import("./libs/log")
import("./libs/event")
import("./Config")
