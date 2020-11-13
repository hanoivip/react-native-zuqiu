local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector3 = UnityEngine.Vector3
local AssetFinder = require("ui.common.AssetFinder")
local HonorPalaceModel = require("ui.models.honorPalace.HonorPalaceModel")

local TrophyDetailView = class(unity.base)

function TrophyDetailView:ctor()
    self.trophyImage = self.___ex.trophyImage
    self.closeArea = self.___ex.closeArea
    self.displayButton = self.___ex.displayButton
    self.displayButtonEnableText = self.___ex.displayButtonEnableText
    self.displayButtonDisabledText = self.___ex.displayButtonDisabledText
    self.showInfoButton = self.___ex.showInfoButton
    self.displayArea = self.___ex.displayArea
    self.trophy = self.___ex.trophy
    self.trophtItemParent = self.___ex.trophtItemParent
    self.displayButtonScript = self.___ex.displayButtonScript
    self.trophyDetailArea = self.___ex.trophyDetailArea
    self.bg = self.___ex.bg
    self.trophyName = self.___ex.trophyName
    self.description = self.___ex.description
    self.finishTime = self.___ex.finishTime
    self.trophyInfoArea = self.___ex.trophyInfoArea
    self.isTrophyInfoAreaPosRight = true
end

function TrophyDetailView:start()
    self.closeArea:regOnButtonClick(function()
        self:Close()
    end)
    self.displayButton:regOnButtonClick(function()
        self:DisplayTrophy()
    end)
    self.showInfoButton:regOnButtonClick(function()
        self:ShowTrophyInfo()
    end)
end

function TrophyDetailView:InitView(honorPalaceItemModel, pageIndex, maxPerLine, index)
    local showIndex = index - (pageIndex - 1) * maxPerLine
    if showIndex / 6 <= 1 then
        self.trophyDetailArea.localPosition = Vector3((showIndex - 1) * 156, 0, self.trophyDetailArea.localPosition.z)
    else
        self.trophyDetailArea.localPosition = Vector3((showIndex - 7) * 156, -129, self.trophyDetailArea.localPosition.z)
    end
    if showIndex == 6 or showIndex == 12 then
        self.isTrophyInfoAreaPosRight = false
    else
        self.isTrophyInfoAreaPosRight = true
    end
    self.honorPalaceItemModel = honorPalaceItemModel
    self.trophyId = honorPalaceItemModel:GetID()
    local isTrophyBeShowed = self:IsTrophyBeShowed()
    self:InitDisplayButton(isTrophyBeShowed)
    local trophyItemObj, trophyItemView = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/HonorPalace/TrophyItem.prefab")
    self.trophyItemView = trophyItemView
    trophyItemObj.transform:SetParent(self.trophtItemParent, false)
    trophyItemView:InitView(self.trophyId)
    trophyItemView:IsShowInfo(false)
    trophyItemView:DisableBeDraged()
end

function TrophyDetailView:InitDisplayButton(isTrophyBeShowed)
    self.displayButtonScript.interactable = isTrophyBeShowed
    self.displayButton:onPointEventHandle(isTrophyBeShowed)
    self.displayButtonEnableText.gameObject:SetActive(isTrophyBeShowed)
    self.displayButtonDisabledText.gameObject:SetActive(not isTrophyBeShowed)
end

function TrophyDetailView:IsTrophyBeShowed()
    local honorPalaceModel = HonorPalaceModel.new()
    local trophyShowList = honorPalaceModel:GetTrophyShowList()
    if trophyShowList then
        for posIndex, trophyID in pairs(trophyShowList) do
            if trophyID == self.trophyId then
                return false
            end
        end
    end
    return true
end

function TrophyDetailView:ShowTrophyInfo()
    self.trophyName.text = self.honorPalaceItemModel:GetName()
    self.description.text = self.honorPalaceItemModel:GetDesc()
    self.finishTime.text = self.honorPalaceItemModel:GetTime()
    self.trophyInfoArea:SetActive(true)
    if self.isTrophyInfoAreaPosRight then
        self.trophyInfoArea.transform.localPosition = Vector3(196, 4, 0)
    else
        self.trophyInfoArea.transform.localPosition = Vector3(-262, 4, 0)
    end
end

function TrophyDetailView:DisplayTrophy()
    self.displayButton.gameObject:SetActive(false)
    self.showInfoButton.gameObject:SetActive(false)
    self.bg:SetActive(false)
    self.displayArea:SetActive(true)
    self.trophyItemView:PlayShakeAnim(true)
    EventSystem.SendEvent("TrophyItem.EnableBeDraged")
end

function TrophyDetailView:Close()
    Object.Destroy(self.gameObject)
end

return TrophyDetailView
