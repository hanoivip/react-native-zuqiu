local floor = math.floor
local abs = math.abs
local clamp = math.clamp

function math.Repeat(t, length)    
	return t - (floor(t / length) * length)
end        

function math.LerpAngle(a, b, t)
	local num = math.Repeat(b - a, 360)

	if num > 180 then
		num = num - 360
	end

	return a + num * clamp(t, 0, 1)
end

function math.MoveTowards(current, target, maxDelta)
	if abs(target - current) <= maxDelta then
		return target
	end

	return current + mathf.sign(target - current) * maxDelta
end

function math.DeltaAngle(current, target)    
	local num = math.Repeat(target - current, 360)

	if num > 180 then
		num = num - 360
	end

	return num
end    

function math.MoveTowardsAngle(current, target, maxDelta)
	target = current + math.DeltaAngle(current, target)
	return math.MoveTowards(current, target, maxDelta)
end

function math.Approximately(a, b)
	return abs(b - a) < math.max(1e-6 * math.max(abs(a), abs(b)), 1.121039e-44)
end

function math.InverseLerp(from, to, value)
	if from < to then      
		if value < from then 
			return 0
		end

		if value > to then      
			return 1
		end

		value = value - from
		value = value/(to - from)
		return value
	end

	if from <= to then
		return 0
	end

	if value < to then
		return 1
	end

	if value > from then
        return 0
	end

	return 1.0 - ((value - to) / (from - to))
end

function math.PingPong(t, length)
    t = math.Repeat(t, length * 2)
    return length - abs(t - length)
end

function math.clamp(value, min, max)
    assert(type(value) == "number" and type(min) == "number" and type(max) == "number", "type has error")

    if value < min then value = min end
    if value > max then value = max end

    return value;
end

math.deg2Rad = math.pi / 180
math.rad2Deg = 180 / math.pi
math.epsilon = 1.401298e-45
