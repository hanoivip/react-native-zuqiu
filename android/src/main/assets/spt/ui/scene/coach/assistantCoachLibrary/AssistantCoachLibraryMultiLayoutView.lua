local GameObjectHelper = require("ui.common.GameObjectHelper")

local AssistantCoachLibraryMultiLayoutView = class(unity.base, "AssistantCoachLibraryMultiLayoutView")

function AssistantCoachLibraryMultiLayoutView:ctor()
    self.sptItem = self.___ex.sptItem
end

-- @param multiData: 一个数组，包含所需显示的项目
function AssistantCoachLibraryMultiLayoutView:InitView(multiData, ...)
    self.data = multiData
    if self.data == nil then return end
    local args = {...}
    local argc = select("#", ...)

    local capacity = table.nums(self.sptItem)
    local realNum = math.min(table.nums(self.data), capacity)
    for i = 1, capacity do
        GameObjectHelper.FastSetActive(self.sptItem[tostring(i)].gameObject, i <= realNum)
    end
    for i, itemData in ipairs(self.data) do
        if self.sptItem[tostring(i)] then
            self.sptItem[tostring(i)]:InitView(itemData, unpack(args, 1, argc))
        end
    end
end

return AssistantCoachLibraryMultiLayoutView
