local GridSwitchView = class(unity.base, "GridSwitchView")

function GridSwitchView:ctor()

end

function GridSwitchView:InitView()
    EventSystem.SendEvent("Greensward_GridMove", 4, 14)
end

return GridSwitchView