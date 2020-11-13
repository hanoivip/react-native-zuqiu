local DragHandler = class(unity.base)

function DragHandler:onBeginDrag(eventData)
    if type(self.onBeginDragCallback) == "function" then
        self.onBeginDragCallback(eventData)
    end
end

function DragHandler:onDrag(eventData)
    if type(self.onDragCallback) == "function" then
        self.onDragCallback(eventData)
    end
end

function DragHandler:onEndDrag(eventData)
    if type(self.onEndDragCallback) == "function" then
        self.onEndDragCallback(eventData)
    end
end

function DragHandler:RegOnBeginDrag(func)
    if type(func) == "function" then
        self.onBeginDragCallback = func
    end
end

function DragHandler:UnregOnBeginDrag()
    self.onBeginDragCallback = nil
end

function DragHandler:RegOnDrag(func)
    if type(func) == "function" then
        self.onDragCallback = func
    end
end

function DragHandler:UnregOnDrag()
    self.onDragCallback = nil
end

function DragHandler:RegOnEndDrag(func)
    if type(func) == "function" then
        self.onEndDragCallback = func
    end
end

function DragHandler:UnregOnEndDrag()
    self.onEndDragCallback = nil
end

return DragHandler
