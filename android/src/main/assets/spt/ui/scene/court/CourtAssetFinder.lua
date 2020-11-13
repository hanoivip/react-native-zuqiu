local CourtBuildType = require("ui.scene.court.CourtBuildType")
local CourtAssetFinder = { }

-- 获取球场资源
function CourtAssetFinder.GetCourtIcon(courtBuildType, icon)
    assert(icon)

    if courtBuildType == CourtBuildType.StadiumBuild then
        return res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Court/Images/Main/" .. icon .. ".png")
    elseif courtBuildType == CourtBuildType.AudienceBuild then
        return res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Court/Images/Audience/" .. icon .. ".png")
    elseif courtBuildType == CourtBuildType.LightingBuild then
        return res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Court/Images/Lighting/" .. icon .. ".png")
    elseif courtBuildType == CourtBuildType.ScoreBoardBuild then
        return res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Court/Images/Board/" .. icon .. ".png")
    elseif courtBuildType == CourtBuildType.StoreBuild then
        return res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Court/Images/Store/" .. icon .. ".png")
    elseif courtBuildType == CourtBuildType.ParkingBuild then
        return res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Court/Images/Main/" .. icon .. ".png")
    elseif courtBuildType == CourtBuildType.ScoutBuild then
        return res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Court/Images/Main/" .. icon .. ".png")
    elseif courtBuildType == CourtBuildType.MixedBuild then
        return res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Court/Images/TechnologyHall/Mixed/" .. icon .. ".png")
    elseif courtBuildType == CourtBuildType.NatureShortBuild then
        return res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Court/Images/TechnologyHall/NatureShort/" .. icon .. ".png")
    elseif courtBuildType == CourtBuildType.NatureLongBuild then
        return res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Court/Images/TechnologyHall/NatureLong/" .. icon .. ".png")
    elseif courtBuildType == CourtBuildType.ArtificialShortBuild then
        return res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Court/Images/TechnologyHall/ArtificialShort/" .. icon .. ".png")
    elseif courtBuildType == CourtBuildType.ArtificialLongBuild then
        return res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Court/Images/TechnologyHall/ArtificialLong/" .. icon .. ".png")
    elseif courtBuildType == CourtBuildType.RainBuild then
        return res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Court/Images/TechnologyHall/Rain/" .. icon .. ".png")
    elseif courtBuildType == CourtBuildType.SnowBuild then
        return res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Court/Images/TechnologyHall/Snow/" .. icon .. ".png")
    elseif courtBuildType == CourtBuildType.WindBuild then
        return res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Court/Images/TechnologyHall/Wind/" .. icon .. ".png")
    elseif courtBuildType == CourtBuildType.FogBuild then
        return res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Court/Images/TechnologyHall/Fog/" .. icon .. ".png")
    elseif courtBuildType == CourtBuildType.SandBuild then
        return res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Court/Images/TechnologyHall/Sand/" .. icon .. ".png")
    elseif courtBuildType == CourtBuildType.HeatBuild then
        return res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Court/Images/TechnologyHall/Heat/" .. icon .. ".png")
    end

    return nil
end

-- 获取建筑底板
function CourtAssetFinder.GetMainBuildFloor(courtBuildType, lvl)
    assert(courtBuildType)
    local floor = ""
    if courtBuildType == CourtBuildType.StadiumBuild then
        if lvl < 7 then
            floor = "Stadium_Floor"
        else
            floor = "Stadium_Floor4"
        end
        return res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Court/Images/Main/" .. floor .. ".png")
    elseif courtBuildType == CourtBuildType.ScoutBuild then
        if lvl < 7 then
            floor = "Scout_Floor"
        else
            floor = "Scout_Floor7"
        end
        return res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Court/Images/Main/" .. floor .. ".png")
    end

    return nil
end

function CourtAssetFinder.GetTechnologyIcon(technologyType)
    return res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Court/Images/TechnologyHall/Details/" .. technologyType .. "_Icon.png")
end

function CourtAssetFinder.GetTechnologyFixIcon(technologyType)
    local iconRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Court/Images/TechnologyHall/Details/FixIcon/" .. technologyType .. "_Icon.png")
    if not iconRes then
        iconRes = CourtAssetFinder.GetTechnologyIcon(technologyType)
    end
    return iconRes
end

return CourtAssetFinder