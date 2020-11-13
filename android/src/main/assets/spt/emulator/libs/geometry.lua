local segment = import("./segment")
local vector2 = import("./vector")

local geometry = {}
local cross3, dot3, sign = vector2.cross3, vector2.dot3, math.sign

local function p(u, v)
    if u == v then return u else return u, v end
end

local function interPoint(a, b, c, d)
    local s1, s2, s3, s4 = cross3(a, b, c), cross3(a, b, d), cross3(c, d, a), cross3(c, d, b)
    local c1, c2, c3, c4 = sign(s1), sign(s2), sign(s3), sign(s4)
    local d1, d2, d3, d4 = sign(dot3(a, c, d)), sign(dot3(b, c, d)), sign(dot3(c, a, b)), sign(dot3(d, a, b))

    if c1 == 0 and c2 == 0 then
        if d3 <= 0 and d4 <= 0 then
            return p(c, d)
        elseif d1 <= 0 and d2 <= 0 then
            return p(a, b)
        elseif d3 <= 0 and d2 <= 0 then
            return p(c, b)
        elseif d3 <= 0 and d1 <= 0 then
            return p(c, a)
        elseif d4 <= 0 and d2 <= 0 then
            return p(d, b)
        elseif d4 <= 0 and d1 <= 0 then
            return p(d, a)
        end
    end

    if (c1* c2 == -1 and c3 * c4 == -1) or (c1 == 0 and d3 <= 0) or (c2 == 0 and d4 <= 0) or (c3 == 0 and d1 <= 0) or (c4 == 0 and d2 <= 0) then
        return c * (s2 / (s2 - s1)) - d * (s1 / (s2 - s1))
    end
end

--[Comment]
--judge whether two segments intersect, if true, return intersect point(s)
function geometry.intersectPoint(segment1, segment2)
    return interPoint(segment1.s, segment1.e, segment2.s, segment2.e)
end

return geometry
