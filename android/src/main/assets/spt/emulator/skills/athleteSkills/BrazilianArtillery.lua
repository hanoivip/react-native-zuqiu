local HeavyGunner = import("./HeavyGunner")

local BrazilianArtillery = class(HeavyGunner, "BrazilianArtillery")
BrazilianArtillery.id = "D07_B"
BrazilianArtillery.alias = "巴西火炮"

BrazilianArtillery.minAbilitiesSumMultiply = 0.396
BrazilianArtillery.maxAbilitiesSumMultiply = 3.96

return BrazilianArtillery
