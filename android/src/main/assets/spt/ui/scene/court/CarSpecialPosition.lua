local CarSpecialPosition = {}
CarSpecialPosition.bornPos = {}
CarSpecialPosition.posDescMap = {}

function CarSpecialPosition.InitPosition()
    if not CarSpecialPosition.hasInit then
        CarSpecialPosition.AddLine(2, {-297, -112}, {-217, -64}, {-32, 47}, {88, 119}, {403, 308}, {758, 521})
        CarSpecialPosition.AddCurve({713, -238}, 1, {423, -64}, 2, {648, 71}, 1, {473, 182}, 2, {543, 224}, 1, {403, 308})
        CarSpecialPosition.AddCurve({598, -565}, 1, {123, -280}, 2, {318, -163}, 1, {-32, 47})
        CarSpecialPosition.AddCurve({-622, -625}, 2, {-287, -424}, 2, {48, -223}, 1, {-217, -64})
        CarSpecialPosition.AddCurve({-297, -112}, 1, {-672, 113}, 2, {-287, 344}, 2, {88, 569}, 3, {298, 461})
        CarSpecialPosition.AddSegment(1, {123, -670}, {-287, -424})
        CarSpecialPosition.AddSegment(1, {758, 521}, {578, 629})
        CarSpecialPosition.AddLine(1, {88, 119}, {-92, 227}, {-287, 344}, {-707, 596})
        CarSpecialPosition.AddLine(2, {-92, 227}, {223, 416}, {298, 461}, {578, 629})
        CarSpecialPosition.AddSegment(3, {223, 416}, {403, 308})
        CarSpecialPosition.InitBornPos()
        CarSpecialPosition.hasInit = true
    end
    return CarSpecialPosition
end

function CarSpecialPosition.AddLine(direction, ...)
    local positions = cache.totable(...)
    if positions and #positions >= 2 then
        for i = 1, #positions - 1 do
            CarSpecialPosition.AddSegment(direction, positions[i], positions[i + 1])
        end
    end
end

function CarSpecialPosition.AddSegment(direction, start, dest)
    if not CarSpecialPosition.posDescMap[start[1] .. "_" .. start[2]] then
        CarSpecialPosition.posDescMap[start[1] .. "_" .. start[2]] = {}
    end

    if not CarSpecialPosition.posDescMap[dest[1] .. "_" .. dest[2]] then
        CarSpecialPosition.posDescMap[dest[1] .. "_" .. dest[2]] = {}
    end
    CarSpecialPosition.posDescMap[start[1] .. "_" .. start[2]][0] = {start[1], start[2]} --0:pos 1234:neighbour
    CarSpecialPosition.posDescMap[start[1] .. "_" .. start[2]][direction] = {dest[1], dest[2]}
    CarSpecialPosition.posDescMap[dest[1] .. "_" .. dest[2]][0] = {dest[1], dest[2]}
    CarSpecialPosition.posDescMap[dest[1] .. "_" .. dest[2]][(direction + 1) % 4 + 1] = {start[1], start[2]}
end

function CarSpecialPosition.AddCurve(...)
    local curve = cache.totable(...)
    for i = 1, (#curve - 1) / 2 do
        CarSpecialPosition.AddSegment(curve[i * 2], curve[i * 2 - 1], curve[i * 2 + 1])
    end
end

function CarSpecialPosition.InitBornPos()
    for k, v in pairs(CarSpecialPosition.posDescMap) do
        if #table.keys(v) == 2 then -- 0 + neighbour * 1
            table.insert(CarSpecialPosition.bornPos, {v[0][1], v[0][2]})
        end
        v[0] = nil --unset 0
    end
end

function CarSpecialPosition.IsBornPos(pos)
    return #table.keys(CarSpecialPosition.posDescMap[pos[1] .. "_" .. pos[2]]) == 1
end

return CarSpecialPosition