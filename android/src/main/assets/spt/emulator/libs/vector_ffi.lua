local ffi = require("ffi")
ffi.cdef[[
typedef struct { double x, y; } vector2_t;
]]

local vector2

local mt = {
    --[Comment]
    --return a + b
    __add = function(a, b)
        return vector2(a.x + b.x, a.y + b.y)
    end,

    --[Comment]
    --return a - b
    __sub = function(a, b)
        return vector2(a.x - b.x, a.y - b.y)
    end,

    --[Comment]
    --multiply the vector2 v by scalar d
    __mul = function(v, d)
        return vector2(v.x * d, v.y * d)
    end,

    --[Comment]
    --divide the vector2 v by scalar d
    __div = function(v, d)
        return vector2(v.x / d, v.y / d)
    end,

    --[Comment]
    --return reverse of v
    __unm = function(v)
        return vector2(-v.x, -v.y)
    end,

    --[Comment]
    --convert the vector to string
    __tostring = function(v)
        return "(" .. v.x .. "," .. v.y .. ")"
    end,

    --[Comment]
    --judge whether a equals b
    __eq = function(a, b)
        -- a and b cannot be both nil
        if rawequal(a, nil) or rawequal(b, nil) then return false end
        return a.x == b.x and a.y == b.y
    end,

    __index = {
        --[Comment]
        --create an vector2 object
        new = function(x, y)
            return vector2(x, y)
        end,

        --[Comment]
        --clone an vector2 object
        clone = function(v)
            return vector2(v.x, v.y)
        end,

        --[Comment]
        --rotate the vector2 v by angle (rad), counterclockwise
        rotate = function(v, angle)
            local ca = math.cos(angle)
            local sa = math.sin(angle)
            return vector2(v.x * ca - v.y * sa, v.x * sa + v.y * ca)
        end,

        --[Comment]
        --rotate the vector2 v by direction (unit vector), e.g. make the x axis of v point to dir, and return the new v
        vrotate = function(v, dir)
            return vector2(v.x * dir.x + v.y * dir.y, -v.x * dir.y + v.y * dir.x)
        end,

        --[Comment]
        --dot product of 2 vector2s (a, b)
        dot = function(a, b)
            return a.x * b.x + a.y * b.y
        end,

        --[Comment]
        --dot product of 2 vectors b-a and c-a
        dot3 = function(a, b, c)
            return (b.x - a.x) * (c.x - a.x) + (b.y - a.y) * (c.y - a.y)
        end,

        --[Comment]
        --cross product of 2 vector2s (a, b)
        cross = function(a, b)
            return a.x * b.y - a.y * b.x
        end,

        --[Comment]
        --cross product of 2 vectors b-a and c-a
        cross3 = function(a, b, c)
            return (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x)
        end,

        --[Comment]
        --square of magnitude of vector2 v
        sqrmagnitude = function(v)
            return v.x * v.x + v.y * v.y
        end,

        --[Comment]
        --magnitude of vector2 v
        magnitude = function(v)
            return math.sqrt(vector2.sqrmagnitude(v))
        end,

        --[Comment]
        --normalize the vector2 v
        norm = function(v)
            if v.x == 0 and v.y == 0 then return vector2(0, 0) end
            local m = vector2.magnitude(v)
            return vector2(v.x / m, v.y / m)
        end,

        --[Comment]
        --square of distance between the vector2 a and b
        sqrdist = function(a, b)
            return vector2.sqrmagnitude(a - b)
        end,

        --[Comment]
        --distance between the vector2 a and b
        dist = function(a, b)
            return vector2.magnitude(a - b)
        end,

        --[Comment]
        --linearly interpolate between vector2 a and b, use t as parameter
        lerp = function(a, b, t)
            return vector2(a.x + (b.x - a.x) * t, a.y + (b.y - a.y) * t)
        end,

        --[Comment]
        --project vector2 a to b
        --return c. c and b will be same direction
        project = function(a, b)
            return b * vector2.dot(a, b) / vector2.sqrmagnitude(b)
        end,

        --[Comment]
        --calculate angle between vector2 a and b
        --return value in range [0, PI]
        angle = function(a, b)
            return math.acos(math.clamp(vector2.dot(a, b) / (vector2.magnitude(a) * vector2.magnitude(b)), -1, 1))
        end,

        --[Comment]
        --calculate signed angle between vector2 a and b
        --return value in range (-PI, PI]
        --if a->b turns left, returns (0, PI)
        --if a->b turns right, returns (-PI, 0)
        sangle = function(a, b)
            local _angle = vector2.angle(a, b)
            local cross = vector2.cross(a, b)
            if cross >= 0 then
                return _angle
            else
                return -_angle
            end
        end,

        --[Comment]
        --if v.magnitude > a, make v.magnitude = a, keeping direction of v
        --return v (v is modified!)
        clamp = function(v, a)
            local mv = vector2.magnitude(v)
            if mv > a then
                v.x = v.x / mv * a
                v.y = v.y / mv * a
            end
            return v
        end,

        zero    = ffi.new("vector2_t", {0, 0}),
        forward = ffi.new("vector2_t", {0, 1}),
        back    = ffi.new("vector2_t", {0, -1}),
        left    = ffi.new("vector2_t", {-1, 0}),
        right   = ffi.new("vector2_t", {1, 0}),

        forwardRight = ffi.new("vector2_t", {0.7071, 0.7071}),
        forwardLeft  = ffi.new("vector2_t", {-0.7071, 0.7071}),
        backRight    = ffi.new("vector2_t", {0.7071, -0.7071}),
        backLeft     = ffi.new("vector2_t", {-0.7071, -0.7071}),
    }
}

mt.__index.standardDirections = {
    mt.__index.forward,
    mt.__index.forwardLeft,
    mt.__index.left,
    mt.__index.backLeft,
    mt.__index.back,
    mt.__index.backRight,
    mt.__index.right,
    mt.__index.forwardRight
}

vector2 = ffi.metatype("vector2_t", mt)

return vector2
