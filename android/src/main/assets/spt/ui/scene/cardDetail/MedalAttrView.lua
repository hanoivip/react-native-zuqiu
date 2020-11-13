local MedalAttrView = class(unity.base)

function MedalAttrView:ctor()
    self.attrName = self.___ex.attrName
    self.attrPlus = self.___ex.attrPlus
end

function MedalAttrView:InitView(data)
    local name = ""
    if data.title ~= "" and data.name ~= "" then 
        name = data.title .. ":" .. data.name
    elseif data.title ~= "" then 
        name = data.title
    elseif data.name ~= "" then
        name = data.name
    end
    self.attrName.text = name
    self.attrPlus.text = data.lvl
end

return MedalAttrView
