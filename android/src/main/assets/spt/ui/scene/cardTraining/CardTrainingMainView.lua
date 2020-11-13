local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local Vector3 = UnityEngine.Vector3
local EventSystem = require("EventSystem")
local CardDetailPageType = require("ui.scene.cardDetail.CardDetailPageType")
local CardConfig = require("ui.common.card.CardConfig")
local CardDialogType = require("ui.controllers.cardDetail.CardDialogType")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")

local CardTrainingMainView = class(unity.base)

function CardTrainingMainView:ctor()
    self.closeBtn = self.___ex.closeBtn
    self.menuScrollView = self.___ex.menuScrollView
    self.levelStateView = self.___ex.levelStateView
    self.resultView = self.___ex.resultView
    self.questionBtn = self.___ex.questionBtn
    self.cardArea = self.___ex.cardArea
    self.letterContentRect = self.___ex.letterContentRect
    self.levelMenuGroup = self.___ex.levelMenuGroup
    self.notOpenView = self.___ex.notOpenView
    self.finishView = self.___ex.finishView
    self.titleTxt = self.___ex.titleTxt
end

function CardTrainingMainView:start()
    self.closeBtn:regOnButtonClick(function ()
        self:Close()
    end)

    self.questionBtn:regOnButtonClick(function ()
        if self.questionBtnClick then
            self.questionBtnClick()
        end
    end)
end

function CardTrainingMainView:InitView(cardTrainingMainModel)
    self.cardTrainingMainModel = cardTrainingMainModel
    self:InitScrollView(self.cardTrainingMainModel)
    self.levelStateView:InitView(self.cardTrainingMainModel)
    self.resultView:InitView(self.cardTrainingMainModel)
    self.notOpenView:InitView(self.cardTrainingMainModel)
    self.finishView:InitView(self.cardTrainingMainModel)

    local cid = self.cardTrainingMainModel:GetCid()
    local info = {}
    info.card = {}
    table.insert(info.card, {cid = cid, num = 0})
    res.ClearChildren(self.cardArea)
    local rewardParams = {
        parentObj = self.cardArea,
        rewardData = info,
        isShowName = false,
        isReceive = true,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = false,
        hideCount = true,
        isHideLvl = true
    }
    RewardDataCtrl.new(rewardParams)

    local isTrainingUseSelf = self.cardTrainingMainModel:IsTrainingUseSelf()
    if isTrainingUseSelf then
        self.titleTxt.text = lang.trans("support_self_training_title")
    else
        self.titleTxt.text = lang.trans("support_other_training_title")
    end
end

function CardTrainingMainView:InitScrollView(cardTrainingMainModel)
    self.levelMenuGroup.menu = {}
    self.menuScrollView:regOnCreateItem(function (scrollSelf, index)
        local prefab = "Assets/CapstonesRes/Game/UI/Scene/CardTraining/Prefabs/MenuItem.prefab"
        local obj, spt = res.Instantiate(prefab)
        scrollSelf:resetItem(spt, index)
        return obj
    end)

    self.menuScrollView:regOnResetItem(function (scrollSelf, spt, index)
        local data = scrollSelf.itemDatas[index]
        local tag = data.sortOrder
        self.levelMenuGroup.menu[tag] = spt
        self.levelMenuGroup:BindMenuItem(tag, function()
            if self.onClickMenu then
                self.onClickMenu(tag)
            end
        end)
        spt:InitView(data)
        scrollSelf:updateItemIndex(spt, index)
    end)

    local levelInfo = cardTrainingMainModel:GetOpenTrainingLevelInfo()
    self.menuScrollView:refresh(levelInfo)
end

function CardTrainingMainView:GotoCellImmediate()
    self.menuScrollView:scrollToCellImmediate(tonumber(self.cardTrainingMainModel:GetCurrLevelSelected()))
    self:SaveScrollPos()
end

function CardTrainingMainView:SaveScrollPos()
    self.cardTrainingMainModel:SetMenuScrollPos(self.menuScrollView:getScrollNormalizedPos())
end

-- 根据保存的scrollPos设置左侧menuScrollView内容
function CardTrainingMainView:GotoScrollPosImmediate()
    local scrollPos = self.cardTrainingMainModel:GetMenuScrollPos()
    self.menuScrollView:scrollToPosImmediate(self.cardTrainingMainModel:GetMenuScrollPos())
end

function CardTrainingMainView:Close()
    res.PopSceneImmediate()
end

function CardTrainingMainView:EnterScene()

end

function CardTrainingMainView:ExitScene()

end

function CardTrainingMainView:onDestroy()

end

return CardTrainingMainView

