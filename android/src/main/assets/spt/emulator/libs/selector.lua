local selector = {}

local cmpf = math.cmpf

function selector.randomOrWeightedRandom(array)
    local sp = 0
    for i, v in ipairs(array) do
        sp = sp + v.probability
    end

    if math.cmpf(sp, 1) > 0 then
        for i, v in ipairs(array) do
            v.probability = v.probability / sp
        end
    end

    return selector.random(array)
end

--[Comment]
--random select one item from input array
--array format: {{key=object, probability=probability}, ... }
--note: sum of all probabilities (Sp) should be <= 1. If Sp < 1 then nil might be returned
function selector.random(array)
    local sp = 0
    local rnd = math.random()
    for i, v in ipairs(array) do
        sp = sp + v.probability
        if cmpf(rnd, sp) <= 0 then
            return v.key, v.probability
        end
    end
    return nil
end

--[Comment]
--random select one item from input array
--array format: {{key=object, weight=weight}, ... }
--note: selection probability based on weight
function selector.weightedRandom(array)
    local sw = 0
    for i, v in ipairs(array) do
        sw = sw + v.weight
    end

    local sp = 0
    local rnd = math.random()
    for i, v in ipairs(array) do
        sp = sp + v.weight / sw
        if cmpf(rnd, sp) <= 0 then
            return v.key, v.weight
        end
    end
end

--[Comment]
--random select one item from input array with equal probability
function selector.randomSelect(array)
    local sp = 0
    local rnd = math.random()
    local size = #array
    local avgProb = 1 / size
    for i, v in ipairs(array) do
        sp = sp + avgProb
        if cmpf(rnd, sp) <= 0 then
            return v
        end
    end
    return nil
end

--[Comment]
--select the item based on max value from input array
--array format: {{key=object, weight=weight}, ... }
function selector.max(array)
    local maxWeight = -math.huge
    local selectedObject = nil
    for i, v in ipairs(array) do
        if cmpf(v.weight, maxWeight) > 0 then
            maxWeight = v.weight
            selectedObject = v.key
        end
    end

    return selectedObject, maxWeight
end

--[Comment]
--select the items based on max fn(array[i]) from input array
function selector.maxn(array, n, fn)
    n = math.min(n, #array)
    local id, w = {}, {}
    for i = 1, #array do
        table.insert(id, i)
        table.insert(w, fn(array[i]))
    end

    table.sort(id, function(a, b) return w[a] > w[b] end)

    local ret = {}
    for i = 1, n do
        table.insert(ret, array[id[i]])
    end

    return ret
end

--[Comment]
--select the items based on min fn(array[i]) from input array
function selector.minn(array, n, fn)
    n = math.min(n, #array)
    local id, w = {}, {}
    for i = 1, #array do
        table.insert(id, i)
        table.insert(w, fn(array[i]))
    end

    table.sort(id, function(a, b) return w[a] < w[b] end)

    local ret = {}
    for i = 1, n do
        table.insert(ret, array[id[i]])
    end

    return ret
end

--[Comment]
--return true when math.random() < p, else return false
function selector.tossCoin(p)
    return cmpf(math.random(), p) < 0
end

--[Comment]
--random select [count] items from input array with equal probability
function selector.randomSelectCount(array, count)
    local ret = {}
    local n = #array
    local m = count
    for i = 1, #array do
        local p = m / (n - i + 1)
        local rnd = math.random()
        if math.cmpf(rnd, p) <= 0 then
            table.insert(ret, array[i])
            m = m - 1
        end
        if m == 0 then
            break
        end
    end
    return ret
end

return selector