local TechnologySettingConfig = {}

if luaevt.trig("___EVENT__NOT_OPEN_FORBIDDEN_HK") then
    TechnologySettingConfig.TechnologyHall = 
    {
        {SettingType = "ladder", SettingName = "ladder_config"},
    }
else
    TechnologySettingConfig.TechnologyHall = 
    {
        {SettingType = "ladder", SettingName = "ladder_config"},
        {SettingType = "arena", SettingName = "arena_config"},
    }
end

TechnologySettingConfig.Arena = 
{
    {SettingType = "arena", SettingName = "arena_config"}
}

TechnologySettingConfig.Ladder = 
{
    {SettingType = "ladder", SettingName = "ladder_config"},
}

TechnologySettingConfig.Peak1 = 
{
    {SettingType = "peak1", SettingName = "peak_config"}
}

TechnologySettingConfig.Peak2 = 
{
    {SettingType = "peak2", SettingName = "peak_config"}
}

TechnologySettingConfig.Peak3 = 
{
    {SettingType = "peak3", SettingName = "peak_config"}
}

TechnologySettingConfig.Transport = 
{
    {SettingType = "transport", SettingName = "transport_config"}
}

TechnologySettingConfig.SettingType = 
{
    Arena = "arena",
    Ladder = "ladder",
    Peak = "peak",
}

return TechnologySettingConfig