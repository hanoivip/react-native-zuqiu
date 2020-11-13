local HomeEntryTest = class(unity.base)

function HomeEntryTest:ctor()
    res.ChangeScene("ui.controllers.home.HomeMainCtrl")
end

return HomeEntryTest