local AssetFinder = require("ui.common.AssetFinder")
local UnityEngine = clr.UnityEngine
local Text = UnityEngine.UI.Text
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DreamLeagueCardHelper = require("ui.scene.dreamLeague.DreamLeagueCardHelper")
local DialogManager = require("ui.control.manager.DialogManager")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local EventSystem = require("EventSystem")

local DreamLeagueCardView = class(unity.base)

function DreamLeagueCardView:ctor()
    self.positionLabel = self.___ex.positionLabel
    self.portraitImg = self.___ex.portraitImg
    self.nationImg = self.___ex.nationImg
    self.nameLabel = self.___ex.nameLabel
    self.skillGroup = self.___ex.skillGroup
    self.boardImg = self.___ex.boardImg
    self.lock = self.___ex.lock
    self.lockBtn = self.___ex.lockBtn
    self.decompose = self.___ex.decompose
    self.newFlag = self.___ex.newFlag
    self.checkBtn = self.___ex.checkBtn
    self.checkObj = self.___ex.checkObj
    self.selectObj = self.___ex.selectObj
    EventSystem.AddEvent("DreamLeagueCardView_HideSelect", self, self.HideSelect)
end

-- 部分页面不能显示拆解按钮，特加notShowDecomposeBtn参数
function DreamLeagueCardView:InitView(model, notShowDecomposeBtn)
    self.model = model
    self.positionLabel.text = model:GetMainPosition()

	local avatarRes = AssetFinder.GetPlayerIcon(model:GetPlayerIcon())
    self.portraitImg.overrideSprite = avatarRes

    local nationRes = AssetFinder.GetNationIcon(model:GetNationIcon())
    self.nationImg.overrideSprite = nationRes
    local quality = model:GetQuality()
    self.nameLabel.text = model:GetName()
    self.nameLabel.color = DreamLeagueCardHelper.CardColorSign[tonumber(quality)]
    local qualityRes = "Assets/CapstonesRes/Game/UI/Scene/DreamLeague/Images/Card_Board_".. tostring(quality).. ".png"
    self.boardImg.overrideSprite = res.LoadRes(qualityRes)

    self.dcid = model:GetDcid()
    
    self:SetSkills(self.model:GetSkills())
    self:RegOnLockClick()

    local newState = model:IsNew()
    GameObjectHelper.FastSetActive(self.newFlag, newState)

    if model.decomposeCallBack then
        self:RegOnDecomposeClick(model.decomposeCallBack)
    end

    if model.checkBoxCallBack then
        self:RegOnCheckBoxClick(model.checkBoxCallBack)
        self.selectState = false
        self.selectMode = model.selectMode
        GameObjectHelper.FastSetActive(self.selectObj, model.selectState)
        GameObjectHelper.FastSetActive(self.decompose.gameObject, false)
    end

    self.notShowDecomposeBtn = notShowDecomposeBtn
    if notShowDecomposeBtn ~= nil then
        GameObjectHelper.FastSetActive(self.decompose.gameObject, not notShowDecomposeBtn)
    end

    self:ChangeLockStatus()
end

function DreamLeagueCardView:ChangeLockStatus()
    for k,v in pairs(self.lock) do
        GameObjectHelper.FastSetActive(v, false)
    end
    local lockSystem = self.model:IsLockedBySystem()
    local lockPlayer = self.model:IsLockedByPlayer()
    if self.model:IsLockedBySystem() then
        GameObjectHelper.FastSetActive(self.lock["2"], true)
        GameObjectHelper.FastSetActive(self.decompose.gameObject, false)
    elseif self.model:IsLockedByPlayer() then
        GameObjectHelper.FastSetActive(self.lock["1"], true)
        GameObjectHelper.FastSetActive(self.decompose.gameObject, false)
    else
        GameObjectHelper.FastSetActive(self.lock["0"], true)
        GameObjectHelper.FastSetActive(self.decompose.gameObject, true)

        if self.notShowDecomposeBtn ~= nil then
            GameObjectHelper.FastSetActive(self.decompose.gameObject, false)
        end
    end
    self:ChangeCheckBoxState(lockSystem, lockPlayer)

end

function DreamLeagueCardView:ChangeCheckBoxState(lockSystem, lockPlayer)
    if lockSystem then
        GameObjectHelper.FastSetActive(self.checkObj, self.selectMode == DreamLeagueCardHelper.CardSelectMode.SELECT)
        GameObjectHelper.FastSetActive(self.selectObj, false)
        if self.model.checkBoxCallBack then
            self.model.checkBoxCallBack(false, self.dcid)
        end
        return
    end
    if self.selectMode == DreamLeagueCardHelper.CardSelectMode.REWARD then
        if lockPlayer then
            self.model.checkBoxCallBack(false, self.dcid)
            GameObjectHelper.FastSetActive(self.checkObj, false)
            GameObjectHelper.FastSetActive(self.selectObj, false)
        else
            GameObjectHelper.FastSetActive(self.checkObj, true)
        end
        GameObjectHelper.FastSetActive(self.decompose.gameObject, false)
    elseif self.selectMode == DreamLeagueCardHelper.CardSelectMode.SELECT then
        GameObjectHelper.FastSetActive(self.decompose.gameObject, false)
        GameObjectHelper.FastSetActive(self.checkObj, true)
    else
        GameObjectHelper.FastSetActive(self.checkObj, self.model.checkBoxCallBack)
    end
end

-- skillsT 技能列表
function DreamLeagueCardView:SetSkills(skillsT)
	for i=1,self.skillGroup.transform.childCount do
		self.skillGroup.transform:GetChild(i - 1).gameObject:SetActive(false)
	end
    local index = 0
    for k,v in pairs(skillsT) do
        self.skillGroup.transform:GetChild(index).gameObject:SetActive(true)
        self.skillGroup.transform:GetChild(index):GetComponentInChildren(Text).text = v
        index = index + 1
    end
end

function DreamLeagueCardView:RegOnDecomposeClick(func)
    self.decompose:regOnButtonClick(function()
        if self.model:IsLockedBySystem() then
            DialogManager.ShowToast(lang.trans("dream_lock_by_system"))
        else
            local pLockState = self.model:IsLockedByPlayer()
            if pLockState then
                DialogManager.ShowToast(lang.trans("dream_lock_by_self"))
            else
                self:DecomposeCard(func)
            end
        end
    end)
end

function DreamLeagueCardView:RegOnCheckBoxClick(func)
    self.checkBtn:regOnButtonClick(function()
        self.selectState = not self.selectObj.activeSelf
        GameObjectHelper.FastSetActive(self.selectObj, not self.selectObj.activeSelf)
        if func then
            func(self.selectState, self.dcid)
        end
        EventSystem.SendEvent("DreamLeagueCardView_SetSelectCard", self.selectObj, self.model)
    end)
end

function DreamLeagueCardView:RegOnLockClick()
    self.lockBtn:regOnButtonClick(function()
        if self.model:IsLockedBySystem() then
            DialogManager.ShowToast(lang.trans("dream_lock_by_system"))
        else
            local pLockState = self.model:IsLockedByPlayer()
            if pLockState then
                self:UnlockCard()
            else
                self:LockCard()
            end
        end
    end)
end

function DreamLeagueCardView:LockCard()
    local lockCardFunc = function()
        clr.coroutine(function()
            local response = req.dreamCardLock(self.dcid)
            if api.success(response) then
                local data = response.val
                self.model:SetLockStatus(data.dreamCard.lock)
                self:ChangeLockStatus()
                if self.model.lockCallBack then
                    self.model.lockCallBack(true)
                    GameObjectHelper.FastSetActive(self.selectObj, false)
                end
            end
        end)
    end
    local tipText = lang.trans("dream_confirm_lock")
    DialogManager.ShowConfirmPop(lang.trans("tips"), tipText, 
    function() 
        lockCardFunc() 
    end)
end

function DreamLeagueCardView:UnlockCard()
    local unlockCardFunc = function()
        clr.coroutine(function()
            local response = req.dreamCardUnlock(self.dcid)
            if api.success(response) then
                local data = response.val
                self.model:SetLockStatus(data.dreamCard.lock)
                self:ChangeLockStatus()
                if self.model.lockCallBack then
                    self.model.lockCallBack(false)
                end
            end
        end)
    end
    local tipText = lang.trans("dream_confirm_unlock")
    DialogManager.ShowConfirmPop(lang.trans("tips"), tipText, 
    function() 
        unlockCardFunc() 
    end)
end

function DreamLeagueCardView:DecomposeCard(decomposeCallBack)
    local decomposeCardFunc = function()
        clr.coroutine(function()
            local response = req.dreamCardDecomposition(self.dcid)
            if api.success(response) then
                local data = response.val
                CongratulationsPageCtrl.new(data.contents)
                if decomposeCallBack then
                    decomposeCallBack(self.dcid)
                end
            end
        end)
    end
    local tipText = lang.trans("dream_confirm_reslove")
    DialogManager.ShowConfirmPop(lang.trans("tips"), tipText, 
    function() 
        decomposeCardFunc()
    end)
end

function DreamLeagueCardView:HideSelect(dcid)
        GameObjectHelper.FastSetActive(self.selectObj, false)
end

function DreamLeagueCardView:onDestroy()
    EventSystem.RemoveEvent("DreamLeagueCardView_HideSelect", self, self.HideSelect)
end

return DreamLeagueCardView
