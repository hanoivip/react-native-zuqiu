local Introduce = require("data.Introduce")
local PlayIntroduceView = class(unity.base)

function PlayIntroduceView:ctor()
--------Start_Auto_Generate--------
    self.playIntroduceTxt = self.___ex.playIntroduceTxt
--------End_Auto_Generate----------
end

function PlayIntroduceView:InitView()
    local introduceStr = (Introduce["13"] and Introduce["13"].introduce) or ""
    self.playIntroduceTxt.text = introduceStr
end

return PlayIntroduceView
