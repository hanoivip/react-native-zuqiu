local GameObjectHelper = require("ui.common.GameObjectHelper")
local SetSpecial = require("data.SetSpecial")

local SpecialTeamView = class(unity.base)

local SuitPath = "Assets/CapstonesRes/Game/UI/Scene/Store/Images/%s.png"
local SuitNameLangKey = "store_special_tip_%s"

function SpecialTeamView:ctor()
    self.infoBarDynParent = self.___ex.infoBarDynParent
    self.title = self.___ex.title
    self.unsel = self.___ex.unsel
    self.sel = self.___ex.sel
    self.setBtn = self.___ex.setBtn
    self.cancelBtn = self.___ex.cancelBtn
    self.setBtnTxt = self.___ex.setBtnTxt
    self.cancelBtnTxt = self.___ex.cancelBtnTxt
    self.suitImg = self.___ex.suitImg
    self.specialSuitTxt = self.___ex.specialSuitTxt
end

function SpecialTeamView:start()
    self.setBtn:regOnButtonClick(function()
        if type(self.setSpcialTeam) == "function" then
            self.setSpcialTeam()
        end
    end)
    self.cancelBtn:regOnButtonClick(function()
        if type(self.cancelSpcialteam) == "function" then
            self.cancelSpcialteam()
        end
    end)
end

function SpecialTeamView:InitView(data, specSuitId)
    self.title.text = lang.trans("set_spcialTeam")
    self.setBtnTxt.text = lang.trans("set_spcialTeam_btn")
    self.cancelBtnTxt.text = lang.trans("set_cancelSpcialTeam_btn")
    local suitConfig = SetSpecial[tostring(specSuitId)]
    if suitConfig then
        self.suitImg.overrideSprite = res.LoadRes(format(SuitPath, suitConfig.picIndex))
        self.specialSuitTxt.text = lang.trans(format(SuitNameLangKey, specSuitId))
    end
    local useSpecific = data.logoShirt.useSpecific
    local isUseSelf = useSpecific == specSuitId
    GameObjectHelper.FastSetActive(self.unsel, not isUseSelf)
    GameObjectHelper.FastSetActive(self.sel, isUseSelf)
    GameObjectHelper.FastSetActive(self.setBtn.gameObject, not isUseSelf)
    GameObjectHelper.FastSetActive(self.cancelBtn.gameObject, isUseSelf)
end

function SpecialTeamView:RegOnDynamicLoad(func)
    self.infoBarDynParent:RegOnDynamicLoad(func)
end

return SpecialTeamView

