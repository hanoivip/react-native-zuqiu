local GameObjectHelper = require("ui.common.GameObjectHelper")
local DreamGuessMainView = class(unity.base)

function DreamGuessMainView:ctor()
    self.scrollView = self.___ex.scrollView
end

function DreamGuessMainView:InitView(data)
    table.sort(data, function (a, b)
        -- 已经公布结果的排在后面
        if a.cardName and not b.cardName then
            return false
        end
        if not a.cardName and b.cardName then
            return true
        end
        if a.cardName and b.cardName then
            return a.matchId < b.matchId
        end
        return a.guessNum > b.guessNum
    end)
    self.scrollView:InitView(data)
end

return DreamGuessMainView
