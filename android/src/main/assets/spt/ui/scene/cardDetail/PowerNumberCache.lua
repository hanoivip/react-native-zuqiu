local PowerNumberCache = class()

function PowerNumberCache:ctor()
    self.numberCache = {}
end

function PowerNumberCache:GetNumberRes(number)
    if not self.numberCache[number] then 
        self.numberCache[number] = res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Card/Number/" .. tostring(number) .. ".png")
    end
    return self.numberCache[number]
end

return PowerNumberCache