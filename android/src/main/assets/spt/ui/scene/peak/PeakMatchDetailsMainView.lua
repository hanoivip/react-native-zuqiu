local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GameObjectHelper = require("ui.common.GameObjectHelper")

local PeakMatchDetailsMainView = class(unity.base)

function PeakMatchDetailsMainView:ctor()
    self.myScroll = self.___ex.myScroll
    self.btnChangeOver = self.___ex.btnChangeOver
    self.btnHandContinueChallenge = self.___ex.btnHandContinueChallenge
    self.btnSweepContinueChallenge = self.___ex.btnSweepContinueChallenge
    self.textEnemyName = self.___ex.textEnemyName
    self.textEnemyZone = self.___ex.textEnemyZone
    self.imgEnemyFace = self.___ex.imgEnemyFace
    self.textOurName = self.___ex.textOurName
    self.textOurZone = self.___ex.textOurZone
    self.imgOurFace = self.___ex.imgOurFace
    self.textContinue = self.___ex.textContinue
    self.vectory = self.___ex.vectory
    self.defeat = self.___ex.defeat
end

function PeakMatchDetailsMainView:start()
    self:BindButtonHandler()
    DialogAnimation.Appear(self.transform, nil)
end

function PeakMatchDetailsMainView:InitView(matchTitleData)
    self.textEnemyName.text = matchTitleData.EnemyName
    self.textEnemyZone.text = matchTitleData.EnemyZone
    self:InitTeamLogo(self.imgEnemyFace , matchTitleData.EnemyFaceId)
    self.textOurName.text = matchTitleData.OurName
    self.textOurZone.text = matchTitleData.OurZone
    self:InitTeamLogo(self.imgOurFace , matchTitleData.OurFaceId)
    GameObjectHelper.FastSetActive(self.vectory, matchTitleData.win)
    GameObjectHelper.FastSetActive(self.defeat, matchTitleData.fail)
end

function PeakMatchDetailsMainView:InitChildView(matchResultDataList)
    self:ClearItemBox()
    for i=1, #matchResultDataList do
        local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Peak/PeakResultItem.prefab")
        self:AddItemBox(obj)
        spt.onViewFightDetail = self.onChildViewFightDetail
        spt:InitView(matchResultDataList[i])
    end
end

function PeakMatchDetailsMainView:AddItemBox(itemBox)
    itemBox.transform:SetParent(self.myScroll.transform, false)
end

function PeakMatchDetailsMainView:ClearItemBox()
    local count = self.myScroll.transform.childCount
    for i = 3, count - 1 do
        Object.Destroy(self.myScroll.transform:GetChild(i).gameObject)
    end
end

function PeakMatchDetailsMainView:BindButtonHandler()
    self.btnHandContinueChallenge:regOnButtonClick(function ()
        if self.onContineChallenge and not self.isRequesting then
            self.isRequesting = true
            self.onContineChallenge(function()
                self.isRequesting = false
            end, false)
        end
    end)
    self.btnSweepContinueChallenge:regOnButtonClick(function ()
        if self.onContineChallenge and not self.isRequesting then
            self.isRequesting = true
            self.onContineChallenge(function()
                self.isRequesting = false
            end, true)
        end
    end)
    self.btnChangeOver:regOnButtonClick(function ()
        self:Close()
    end)
end

function PeakMatchDetailsMainView:ShowChangeContinue(flag)
    GameObjectHelper.FastSetActive(self.btnChangeOver.gameObject,not flag)
    GameObjectHelper.FastSetActive(self.btnHandContinueChallenge.gameObject, flag)
    GameObjectHelper.FastSetActive(self.btnSweepContinueChallenge.gameObject, cache.getPeakSweepFlag() and flag)
end

function PeakMatchDetailsMainView:InitTeamLogo(imgLogo ,logoId)
    if self.onInitTeamLogo then
        self.onInitTeamLogo(imgLogo , logoId)
    end
end

function PeakMatchDetailsMainView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function ()
            self.closeDialog()
        end)
    end
end

function PeakMatchDetailsMainView:CloseImmediate()
    if type(self.closeDialog) == "function" then
        self.closeDialog()
    end
end

return PeakMatchDetailsMainView
