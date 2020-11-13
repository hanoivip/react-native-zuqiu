local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector3 = UnityEngine.Vector3
local Vector2 = UnityEngine.Vector2

local GameObjectHelper = require("ui.common.GameObjectHelper")

local LoseGuideOptionView = class(unity.base)

function LoseGuideOptionView:ctor()
    -- 标题
    self.title = self.___ex.title
    -- 引导图片
    self.guideImg = self.___ex.guideImg
    -- 描述
    self.desc = self.___ex.desc
    -- 前往按钮
    self.gotoBtn = self.___ex.gotoBtn
    self.gotoBtnTrans = self.___ex.gotoBtnTrans
    -- 失败引导选项模板
    self.loseGuideOptionModel = nil
    -- 该失败引导选项是否在左侧
    self.isLeft = false
end

function LoseGuideOptionView:InitView(loseGuideOptionModel, isLeft)
    self.loseGuideOptionModel = loseGuideOptionModel
    self.isLeft = isLeft
    self:BuildView()
end

function LoseGuideOptionView:start()
    self:BindAll()
end

function LoseGuideOptionView:BindAll()
    -- 前往按钮
    self.gotoBtn:regOnButtonClick(function ()
        EventSystem.SendEvent("LoseGuide_Destroy")
        self:GotoTargetPage()
    end)
end

function LoseGuideOptionView:BuildView()
    local guideImgIndex = self.loseGuideOptionModel:GetPicIndex()
    local targetPageName = self.loseGuideOptionModel:GetTargetPageName()
    self.title.text = self.loseGuideOptionModel:GetTitle()
    self.desc.text = self.loseGuideOptionModel:GetDesc()
    self.guideImg.sprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/LoseGuide/Images/GuideImgs/" .. guideImgIndex .. ".png")
    GameObjectHelper.FastSetActive(self.gotoBtn.gameObject, targetPageName ~= "")
    if targetPageName ~= "" then
        if self.isLeft then
            self.gotoBtnTrans.anchoredPosition = Vector2(-241, 12)
            self.gotoBtnTrans.localScale = Vector3(-1, 1, 1)
        else
            self.gotoBtnTrans.anchoredPosition = Vector2(241, 12)
            self.gotoBtnTrans.localScale = Vector3.one
        end
    end
end

function LoseGuideOptionView:GotoTargetPage()
    local targetPageName = self.loseGuideOptionModel:GetTargetPageName()
    if targetPageName == "PlayerList" then
        res.PushScene("ui.controllers.playerList.PlayerListMainCtrl", nil, nil, nil, nil, true)
    elseif targetPageName == "PlayerLetter" then
        res.PushDialog("ui.controllers.playerLetter.PlayerLetterCtrl")
    elseif targetPageName == "TransferMarket" then
        res.PushScene("ui.controllers.transferMarket.TransferMarketCtrl", {})
    elseif targetPageName == "Store" then
        res.PushSceneImmediate("ui.controllers.store.StoreCtrl", require("ui.models.store.StoreModel").MenuTags.GACHA)
    elseif targetPageName == "Formation" then
        res.PushScene("ui.controllers.formation.FormationPageCtrl")
    elseif targetPageName == "Training" then
        res.PushScene("ui.controllers.training.TrainCtrl")
    end
end

return LoseGuideOptionView