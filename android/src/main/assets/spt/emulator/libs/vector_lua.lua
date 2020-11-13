local vector2 = {}
local mt = {}

local sqrt = math.sqrt
local sin = math.sin
local cos = math.cos
local acos = math.acos
local clamp = math.clamp
local cmpf = math.cmpf
local sign = math.sign

local function new(x, y)
    local ret = { x = x, y = y }
    setmetatable(ret, mt)
    return ret
end

local function clone(v)
    local ret = { x = v.x, y = v.y }
    setmetatable(ret, mt)
    return ret
end

--[Comment]
--return a + b
local function add(a, b)
    return new(a.x + b.x, a.y + b.y)
end

--[Comment]
--return a - b
local function sub(a, b)
    return new(a.x - b.x, a.y - b.y)
end

--[Comment]
--multiply the vector2 v by scalar d
local function mul(v, d)
    return new(v.x * d, v.y * d)
end

--[Comment]
--divide the vector2 v by scalar d
local function div(v, d)
    return new(v.x / d, v.y / d)
end

--[Comment]
--return reverse of v
local function unm(v)
    return new(-v.x, -v.y)
end

--[Comment]
--convert the vector to string
local function tostring(v)
    return string.format("(%.2f, %.2f)", v.x, v.y)
end

--[Comment]
--judge whether a equals b
local function eq(a, b)
    -- a and b cannot be both nil
    if rawequal(a, nil) or rawequal(b, nil) then return false end
    return cmpf(a.x, b.x) == 0 and cmpf(a.y, b.y) == 0
end

local function turnLeft(v)
    return new(-v.y, v.x)
end

local function turnRight(v)
    return new(v.y, -v.x)
end

--[Comment]
--rotate the vector2 v by angle (rad), counterclockwise
local function rotate(v, angle)
    local ca = cos(angle)
    local sa = sin(angle)
    return new(v.x * ca - v.y * sa, v.x * sa + v.y * ca)
end

--[Comment]
--rotate the vector2 v by direction (unit vector), e.g. make the x axis of v point to dir, and return the new v
local function vrotate(v, dir)
    return new(v.x * dir.x - v.y * dir.y, v.x * dir.y + v.y * dir.x)
end

--[Comment]
--rotate the vector2 v by direction (unit vector), e.g. make the y axis of v point to dir, and return the new v
local function vyrotate(v, dir)
    return new(v.x * dir.y + v.y * dir.x, -v.x * dir.x + v.y * dir.y)
end

--[Comment]
--dot product of 2 vector2s (a, b)
local function dot(a, b)
    return a.x * b.x + a.y * b.y
end

--[Comment]
--dot product of 2 vectors b-a and c-a
local function dot3(a, b, c)
    return (b.x - a.x) * (c.x - a.x) + (b.y - a.y) * (c.y - a.y)
end

--[Comment]
--cross product of 2 vector2s (a, b)
local function cross(a, b)
    return a.x * b.y - a.y * b.x
end

--[Comment]
--cross product of 2 vectors b-a and c-a
local function cross3(a, b, c)
    return (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x)
end

--[Comment]
--square of magnitude of vector2 v
local function sqrmagnitude(v)
    return v.x * v.x + v.y * v.y
end

--[Comment]
--magnitude of vector2 v
local function magnitude(v)
    return sqrt(v.x * v.x + v.y * v.y)
end

--[Comment]
--normalize the vector2 v
local function norm(v)
    if sign(v.x) == 0 and sign(v.y) == 0 then return new(0, 0) end
    local m = sqrt(v.x * v.x + v.y * v.y)
    return new(v.x / m, v.y / m)
end

--[Comment]
--square of distance between the vector2 a and b
local function sqrdist(a, b)
    return (a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y)
end

--[Comment]
--distance between the vector2 a and b
local function dist(a, b)
    return sqrt((a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y))
end

--[Comment]
--linearly interpolate between vector2 a and b, use t as parameter
local function lerp(a, b, t)
    return new(a.x + (b.x - a.x) * t, a.y + (b.y - a.y) * t)
end

--[Comment]
--project vector2 a to b
--return c. c and b will be same direction
local function project(a, b)
    return mul(b, dot(a, b) / sqrmagnitude(b))
end

--[Comment]
--calculate angle between vector2 a and b
--return value in range [0, PI]
local function angle(a, b)
    local t = dot(a, b) / sqrt(sqrmagnitude(a) * sqrmagnitude(b))
    --here we clamp t to [-1, 1] because of float number error could make t slightly < -1 or > 1
    return acos(clamp(t, -1, 1))
end

--[Comment]
--calculate signed angle between vector2 a and b
--return value in range (-PI, PI]
--if a->b turns left, returns (0, PI)
--if a->b turns right, returns (-PI, 0)
local function sangle(a, b)
    local _angle = angle(a, b)
    local cross = cross(a, b)
    if sign(cross) >= 0 then
        return _angle
    else
        return -_angle
    end
end

--[Comment]
--convert a radian angle to a normalized vector
--angle range: (0, PI), (0, -PI)
local function angleToVector(angle)
    local c = cos(angle)
    local s = sin(angle)
    return new(cos(angle), sin(angle))
end

--[Comment]
--if v.magnitude > a, make v.magnitude = a, keeping direction of v
--return v (v is modified!)
local function clamp(v, a)
    local mv = magnitude(v)
    if mv > a then
        v.x = v.x / mv * a
        v.y = v.y / mv * a
    end
    return v
end

vector2.new = new
vector2.clone = clone
vector2.add = add
vector2.sub = sub
vector2.mul = mul
vector2.div = div
vector2.unm = unm
vector2.tostring = tostring
vector2.eq = eq
vector2.turnLeft = turnLeft
vector2.turnRight = turnRight
vector2.rotate = rotate
vector2.vrotate = vrotate
vector2.vyrotate = vyrotate
vector2.dot = dot
vector2.dot3 = dot3
vector2.cross = cross
vector2.cross3 = cross3
vector2.sqrmagnitude = sqrmagnitude
vector2.magnitude = magnitude
vector2.norm = norm
vector2.sqrdist = sqrdist
vector2.dist = dist
vector2.lerp = lerp
vector2.project = project
vector2.angle = angle
vector2.sangle = sangle
vector2.clamp = clamp
vector2.angleToVector = angleToVector

vector2.zero    = new(0, 0)
vector2.forward = new(0, 1)
vector2.back    = new(0, -1)
vector2.left    = new(-1, 0)
vector2.right   = new(1, 0)

vector2.forwardRight = new(0.7071, 0.7071)
vector2.forwardLeft  = new(-0.7071, 0.7071)
vector2.backRight    = new(0.7071, -0.7071)
vector2.backLeft     = new(-0.7071, -0.7071)

vector2.standardDirections = {
    vector2.forward,
    vector2.forwardLeft,
    vector2.left,
    vector2.backLeft,
    vector2.back,
    vector2.backRight,
    vector2.right,
    vector2.forwardRight,
}

--metatable
mt.__add = add
mt.__sub = sub
mt.__mul = mul
mt.__div = div
mt.__unm = unm
mt.__eq = eq
mt.__tostring = tostring

return vector2
