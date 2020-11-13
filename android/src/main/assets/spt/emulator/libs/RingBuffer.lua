local RingBuffer = {
}

RingBuffer.__index = RingBuffer

function RingBuffer.new(capacity)
    local ret = {
        head = 0,
        tail = 0,
        count = 0,
        array = {n = capacity}
    }
    setmetatable(ret, RingBuffer)
    return ret
end

function RingBuffer:enqueue(obj)
    if self.count == self.array.n then
        return
    end

    self.array[self.tail] = obj
    self.tail = self.tail % self.array.n + 1
    self.count = self.count + 1
end

function RingBuffer:dequeue()
    if self.count == 0 then
        error()
    end

    local removed = self.array[self.head]
    self.array[self.head] = nil
    self.head = self.head % self.array.n + 1
    self.count = self.count - 1
    return removed
end

function RingBuffer:peek()
    if self.count == 0 then
        error()
    end
    return self.array[self.head]
end

function RingBuffer:last()
    if self.count == 0 then
        error()
    end
    return self:getElement(self.count)
end

function RingBuffer:skip(count)
    if count > self.count then
        error()
    end

    self.head = (self.head + count - 1) % self.array.n + 1
end

function RingBuffer:getElement(index)
    return self.array[(self.head + index - 2) % self.array.n + 1]
end

function RingBuffer:isFull()
    return self.count == self.array.n
end

function RingBuffer:isEmpty()
    return self.count == 0
end

function RingBuffer:clear()
    self.head = 0
    self.tail = 0
    self.count = 0
end

local function getnext(buffer, i)
    if i == nil then
        i = 0
    end
    i = i + 1
    if i > buffer.count then
        return nil, nil
    else
        return i, buffer:getElement(i)
    end
end

function RingBuffer:iterator()
    assert(self ~= nil)
    return getnext, self, nil
end

function RingBuffer:output()
    print('RingBuffer: ' .. 'capacity:' .. self.array.n .. ', count:' .. self.count)
    local ret = 'Element: '
    local cnt = self.count
    local index = self.head
    while cnt > 0 do
        local cur = self.array[index] or 'nil'
        ret = ret .. cur .. ','
        index = index % self.array.n + 1
        cnt = cnt - 1
    end
    print(ret)
end

return RingBuffer