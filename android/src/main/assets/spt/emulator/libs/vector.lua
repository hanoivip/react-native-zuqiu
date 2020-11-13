local useffi = USE_FFI and pcall(require("ffi"))

local vector

if useffi then
    vector = import("./vector_ffi")
else
    vector = import("./vector_lua")
end

return vector
