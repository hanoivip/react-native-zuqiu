local UnityEngine = clr.UnityEngine
local Vector3 = UnityEngine.Vector3
local Time = UnityEngine.Time
local Helper = require("ui.scene.formation.Helper")

local FormationAreaView = class(unity.base)

function FormationAreaView:ctor()
    self.circle = self.___ex.circle
    self.formationArea1 = self.___ex.formationArea1
    self.formationArea2 = self.___ex.formationArea2
end

function FormationAreaView:SetPos(pos, formationId, formationWidth, formationHeight, formationRotateX, isPortrait, scale, isPosExisted)
    local posCoords = Helper.GetTrapezoidFormationCoord(pos, formationId, formationWidth, formationHeight, formationRotateX, isPortrait)
    scale = scale or 1
    self.transform.localPosition = Vector3(posCoords.x, posCoords.y, 0)
    self.transform.localScale = Vector3(posCoords.scale * scale, posCoords.scale * scale, 1)
    if isPosExisted then
        self.formationArea1:SetActive(true)
        self.formationArea2:SetActive(false)
    else
        self.formationArea1:SetActive(false)
        self.formationArea2:SetActive(true)
    end
end

return FormationAreaView
