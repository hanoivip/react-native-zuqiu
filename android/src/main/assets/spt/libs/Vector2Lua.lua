--------------------------------------------------------------------------------
--      Copyright (c) 2015 , 蒙占志(topameng) topameng@gmail.com
--      All rights reserved.
--
--      Use, modification and distribution are subject to the "New BSD License"
--      as listed at <url: http://www.opensource.org/licenses/bsd-license.php >.
--------------------------------------------------------------------------------

local sqrt = math.sqrt
local setmetatable = setmetatable
local rawset = rawset
local rawget = rawget

Vector2Lua = 
{
	class = "Vector2Lua"
}

setmetatable(Vector2Lua, Vector2Lua)

local fields = {}

Vector2Lua.__index = function(t,k)
	local var = rawget(Vector2Lua, k)
	
	if var == nil then							
		var = rawget(fields, k)
		
		if var ~= nil then
			return var(t)
		end
	end
	
	return var
end

Vector2Lua.__call = function(t,x,y)
	return Vector2Lua.New(x,y,z)
end

function Vector2Lua.New(x, y)
	local v = {x = x or 0, y = y or 0}
	setmetatable(v, Vector2Lua)	
	return v
end

function Vector2Lua:Set(x,y)
	self.x = x or 0
	self.y = y or 0	
end

function Vector2Lua:Get()
	return self.x, self.y
end

function Vector2Lua:SqrMagnitude()
	return self.x * self.x + self.y * self.y
end

function Vector2Lua:Clone()
	return Vector2Lua.New(self.x, self.y)
end

function Vector2Lua:Normalize()
	local v = self:Clone()
	return v:SetNormalize()	
end

function Vector2Lua:SetNormalize()
	local num = self:Magnitude()	
	
	if num == 1 then
		return self
    elseif num > 1e-05 then    
        self:Div(num)
    else    
        self:Set(0,0)
	end 

	return self
end

function Vector2Lua.Distance(va, vb)
	return sqrt((va.x - vb.x)^2 + (va.y - vb.y)^2)
end

function Vector2Lua.SqrDistance(va, vb)
	return (va.x - vb.x)^2 + (va.y - vb.y)^2
end

function Vector2Lua.Dot(lhs, rhs)
	return lhs.x * rhs.x + lhs.y * rhs.y
end

function Vector2Lua.Angle(from, to)
	return math.acos(math.clamp(Vector2Lua.Dot(from:Normalize(), to:Normalize()), -1, 1)) * 57.29578
end

function Vector2Lua.Cross(lhs, rhs)
	return lhs.x * rhs.y - lhs.y * rhs.x
end

--Left-Handed Coordinates
function Vector2Lua.SAngle(from, to)
	local _angle = Vector2Lua.Angle(from, to)
	if math.sign(Vector2Lua.Cross(from, to)) >= 0 then
		return -_angle
	else
		return _angle
	end
end

function Vector2Lua.Magnitude(v2)
	return sqrt(v2.x * v2.x + v2.y * v2.y)
end

function Vector2Lua:Div(d)
	self.x = self.x / d
	self.y = self.y / d	
	
	return self
end

function Vector2Lua:Mul(d)
	self.x = self.x * d
	self.y = self.y * d
	
	return self
end

function Vector2Lua:Add(b)
	self.x = self.x + b.x
	self.y = self.y + b.y
	
	return self
end

function Vector2Lua:Sub(b)
	self.x = self.x - b.x
	self.y = self.y - b.y
	
	return
end

Vector2Lua.__tostring = function(self)
	return string.format("[%s,%s]", tostring(self.x), tostring(self.y))
end

Vector2Lua.__div = function(va, d)
	return Vector2Lua.New(va.x / d, va.y / d)
end

Vector2Lua.__mul = function(va, d)
	return Vector2Lua.New(va.x * d, va.y * d)
end

Vector2Lua.__add = function(va, vb)
	return Vector2Lua.New(va.x + vb.x, va.y + vb.y)
end

Vector2Lua.__sub = function(va, vb)
	return Vector2Lua.New(va.x - vb.x, va.y - vb.y)
end

Vector2Lua.__unm = function(va)
	return Vector2Lua.New(-va.x, -va.y)
end

Vector2Lua.__eq = function(va,vb)
	return va.x == vb.x and va.y == vb.y
end

fields.up 		= function() return Vector2Lua.New(0,1) end
fields.right	= function() return Vector2Lua.New(1,0) end
fields.zero		= function() return Vector2Lua.New(0,0) end
fields.one		= function() return Vector2Lua.New(1,1) end

fields.magnitude 	= Vector2Lua.Magnitude
fields.normalized 	= Vector2Lua.Normalize
fields.sqrMagnitude = Vector2Lua.SqrMagnitude