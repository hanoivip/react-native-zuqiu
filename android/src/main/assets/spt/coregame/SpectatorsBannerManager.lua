local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object

local SpectatorsBannerManager = class(unity.base)

local sloganMap = {
    AcmilanPlayer = "Acmilan",
    ArsenalPlayer = "Arsenal",
    AtmadridPlayer = "Atmadrid",
    BarcelonaPlayer = "Barcelona",
    BayernPlayer = "Bayern",
    ChelseaPlayer = "Chelsea",
    DortmundPlayer = "Dortmund",
    InterPlayer = "Inter",
    JuventusPlayer = "Juventus",
    LiverpoolPlayer = "Liverpool",
    MancityPlayer = "Mancity",
    ManutdPlayer = "Manutd",
    PsgPlayer = "Psg",
    RealmadridPlayer = "Realmadrid",
}

local smallAwayBanner = {
    A1 = true,
    C1 = true,
}
local bigAwayBanner = {
    A1 = true,
    B1 = true,
    C1 = true,
    D1 = true,
}

local sloganRootPath = "Assets/CapstonesRes/Game/Models/Stadium/Textures/Slogan/"
local function GetSloganTexturePath(logo, index)
    return sloganRootPath .. logo .. "/" .. logo .. string.format("%02d.jpg", index) 
end

function SpectatorsBannerManager:Init(homeLogo, awayLogo, isAwayBannerBig)
    self.___ex.banners:SetActive(true)
    self:InitMaterial()
    self:SetSloganBanner(homeLogo, awayLogo, isAwayBannerBig)
end

function SpectatorsBannerManager:ctor()
    self.slogan = self.___ex.slogan -- table
    self.sloganMaterial = self.___ex.sloganMaterial -- table
end

function SpectatorsBannerManager:InitMaterial()
    self.instanceMaterial = {}
    self.instanceMaterial.awayMaterial1 = Object.Instantiate(self.sloganMaterial.m1)
    self.instanceMaterial.homeMaterial1 = Object.Instantiate(self.sloganMaterial.m1)
    self.instanceMaterial.homeMaterial2 = Object.Instantiate(self.sloganMaterial.m2)
    self.instanceMaterial.homeMaterial3 = Object.Instantiate(self.sloganMaterial.m3)
end

function SpectatorsBannerManager:onDestroy()
    self.instanceMaterial = nil
    self.sloganMaterial = nil
    self.___ex.sloganMaterial = nil
end

function SpectatorsBannerManager:SetSloganBanner(homeLogo, awayLogo, isAwayBannerBig)
    homeLogo = tostring(homeLogo)
    awayLogo = tostring(awayLogo)

    local isHomeHasSlogan = false
    local isAwayHasSlogan = false
    if sloganMap[homeLogo] then
        isHomeHasSlogan = true
        self.instanceMaterial.homeMaterial1:SetTexture("_MainTex", res.LoadRes(GetSloganTexturePath(sloganMap[homeLogo], 1)))
        self.instanceMaterial.homeMaterial2:SetTexture("_MainTex", res.LoadRes(GetSloganTexturePath(sloganMap[homeLogo], 2)))
        self.instanceMaterial.homeMaterial3:SetTexture("_MainTex", res.LoadRes(GetSloganTexturePath(sloganMap[homeLogo], 3)))
    end
    if sloganMap[awayLogo] then
        isAwayHasSlogan = true
        self.instanceMaterial.awayMaterial1:SetTexture("_MainTex", res.LoadRes(GetSloganTexturePath(sloganMap[awayLogo], 1)))
    end

    local awayBanner = isAwayBannerBig and bigAwayBanner or smallAwayBanner
    for bannerID, bannerRenderer in pairs(self.slogan) do
        if awayBanner[bannerID] then
            if isAwayHasSlogan then
                bannerRenderer.material = self.instanceMaterial.awayMaterial1
            else
                bannerRenderer.gameObject:SetActive(false)
            end        
        else
            if isHomeHasSlogan then
                local lastNum = string.sub(bannerID, -1)
                if lastNum == "1" then
                    bannerRenderer.material = self.instanceMaterial.homeMaterial1
                elseif lastNum == "2" then
                    bannerRenderer.material = self.instanceMaterial.homeMaterial2
                elseif lastNum == "3" then
                    bannerRenderer.material = self.instanceMaterial.homeMaterial3
                end
            else
                bannerRenderer.gameObject:SetActive(false)
            end
        end
    end

end

return SpectatorsBannerManager
