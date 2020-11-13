local UnityEngine = clr.UnityEngine
local WaitForSeconds = UnityEngine.WaitForSeconds
local TypeWriter = require("ui.control.typeWriter.TypeWriter")

local TypeWriterLine = class(unity.base)

function TypeWriterLine:ctor(typeWriters, linePauseTime)
    assert(type(typeWriters) == "table")
    self.typeWriters = typeWriters
    self.linePauseTime = linePauseTime
    self.writingLineIndex = 1
end

function TypeWriterLine:StartWriterLine()
    for i = 1, #self.typeWriters do
        self.typeWriters[i]:regOnFinished(function() self:OnLineFinished() end)
    end
    self.typeWriters[self.writingLineIndex]:StartWriter()
end

function TypeWriterLine:OnLineFinished()
    clr.coroutine(function()
        if self.writingLineIndex < #self.typeWriters then
            self.writingLineIndex = self.writingLineIndex + 1
            coroutine.yield(WaitForSeconds(self.linePauseTime))
            self.typeWriters[self.writingLineIndex]:StartWriter()
        else
            self.onFinished()
        end
        coroutine.yield()
    end)
end

function TypeWriterLine:regOnFinished(func)
    if type(func) == "function" then
        self.onFinished = func
    end
end

function TypeWriterLine:unregOnFinished()
    self.onFinished = nil
end

return TypeWriterLine