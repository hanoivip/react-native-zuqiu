local GameObjectHelper = require("ui.common.GameObjectHelper")
local AssetFinder = require("ui.common.AssetFinder")

local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector3 = UnityEngine.Vector3
local Quaternion = UnityEngine.Quaternion

local TeamLogoView = class(unity.base)

local ImagePaths = {
    mask = "Assets/CapstonesRes/Game/UI/Common/Team/Image/Mask/%s.png",
    board = "Assets/CapstonesRes/Game/UI/Common/Team/Image/Board/%s.jpg",
    border = "Assets/CapstonesRes/Game/UI/Common/Team/Image/Border/%s.png",
    icon = "Assets/CapstonesRes/Game/UI/Common/Team/Image/Icon/%s.png",
    ribbon = "Assets/CapstonesRes/Game/UI/Common/Team/Image/Ribbon/%s.png",
    logo = "Assets/CapstonesRes/Game/UI/Common/Images/TeamIcon/%s.png",
}

function TeamLogoView:ctor()
    self.image = self.___ex.image
    self.image1 = self.___ex.image1
    self.base = self.___ex.base
    self.shadow = self.___ex.shadow
    self.mask = self.___ex.mask
    self.maskImage = self.___ex.maskImage
    self.board = self.___ex.board
    self.border = self.___ex.border
    self.icon = self.___ex.icon
    self.ribbon = self.___ex.ribbon
    self.animator = self.___ex.animator
    self.material = Object.Instantiate(res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Team/Material/TeamLogoBoard.mat"))
end

function TeamLogoView:SetUserDefined(isUserDefined)
    if isUserDefined then
        self.image.enabled = false
        self.mask.gameObject:SetActive(true)
        self.board.gameObject:SetActive(true)
        self.border.gameObject:SetActive(true)
        self.icon.gameObject:SetActive(true)
        self.ribbon.gameObject:SetActive(true)
    else
        self.image.enabled = true
        self.mask.gameObject:SetActive(false)
        self.board.gameObject:SetActive(false)
        self.border.gameObject:SetActive(false)
        self.icon.gameObject:SetActive(false)
        self.ribbon.gameObject:SetActive(false)
    end
end

function TeamLogoView:IsUserDefined()
    return self.model:IsUserDefined()
end

function TeamLogoView:InitView(model, isShowBase)
    GameObjectHelper.FastSetActive(self.gameObject, false)
    GameObjectHelper.FastSetActive(self.gameObject, true)
    self.model = model
    if self:IsUserDefined() then
        self:SetUserDefined(true)
        self:SetBoard(model:GetBoardId())
        self:SetBorder(model:GetBorderId())
        self:SetIcon(model:GetIconId())
        self:SetRibbon(model:GetRibbonId())
        if model:GetBoardId() then
            self:SetBoardColor(model:GetBoardColorRed(), model:GetBoardColorGreen(), model:GetBoardColorBlue())
        end
    else
        self:SetUserDefined(false)
        self:SetTeamImage(model:GetTeamLogoId())
    end

    GameObjectHelper.FastSetActive(self.base, isShowBase)
    GameObjectHelper.FastSetActive(self.shadow, isShowBase)
    GameObjectHelper.FastSetActive(self.image1.gameObject, isShowBase)
end

function TeamLogoView:PlayAppearAnimationWithImageOnly()
    self.transform.localRotation = Quaternion.Euler(Vector3.zero)
    self.transform.localScale = Vector3(1, 1, 1)
    self.animator.enabled = true
    self.animator:Play("TeamLogoImageOnlyAnimation")
end

function TeamLogoView:PlayAppearAnimation()
    self.transform.localRotation = Quaternion.Euler(Vector3.zero)
    self.transform.localScale = Vector3(1, 1, 1)
    self.animator.enabled = true
    self.animator:Play("TeamLogoAnimation")
end

function TeamLogoView:PlayDisappearAnimation()
    self.transform.localRotation = Quaternion.Euler(Vector3.zero)
    self.transform.localScale = Vector3(1, 1, 1)
    self.animator.enabled = true
    self.animator:Play("TeamLogoLeaveAnimation")
end

function TeamLogoView:SetTeamImage(id)
    self.image.overrideSprite = AssetFinder.GetTeamIcon(id)
    self.image1.overrideSprite = AssetFinder.GetTeamIcon(id)
end

function TeamLogoView:SetBoard(id)
    if type(id) == "string" and id ~= "" then
        self.board.overrideSprite = res.LoadRes(format(ImagePaths.board, id))
        self.board.gameObject:SetActive(true)
    else
        self.board.gameObject:SetActive(false)
    end
end

function TeamLogoView:SetBoardColor(r, g, b)
    self.mask.enabled = false
    if r then
        self.material:SetColor("_RColor", r)
    end
    if g then
        self.material:SetColor("_GColor", g)
    end
    if b then
        self.material:SetColor("_BColor", b)
    end
    self.board.material = self.material
    self.mask.enabled = true
end

function TeamLogoView:SetBorder(id)
    if type(id) == "string" and id ~= "" then
        self.border.overrideSprite = res.LoadRes(format(ImagePaths.border, id))
        local index = string.find(id, "_")
        if index ~= nil then
            maskName = string.sub(id, 1, index - 1)
        else
            maskName = id
        end
        self.maskImage.overrideSprite = res.LoadRes(format(ImagePaths.mask, maskName))
        self.border.gameObject:SetActive(true)
        self.maskImage.gameObject:SetActive(true)
    else
        self.border.gameObject:SetActive(false)
        self.maskImage.gameObject:SetActive(false)
    end
end

function TeamLogoView:SetIcon(id)
    if type(id) == "string" and id ~= "" then
        self.icon.overrideSprite = res.LoadRes(format(ImagePaths.icon, id))
        self.icon.gameObject:SetActive(true)
    else
        self.icon.gameObject:SetActive(false)
    end
end

function TeamLogoView:SetRibbon(id)
    if type(id) == "string" and id ~= "" then
        self.ribbon.overrideSprite = res.LoadRes(format(ImagePaths.ribbon, id))
        self.ribbon.gameObject:SetActive(true)
    else
        self.ribbon.gameObject:SetActive(false)
    end
end

return TeamLogoView
