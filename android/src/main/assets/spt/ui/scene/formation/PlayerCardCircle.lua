local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Input = UnityEngine.Input
local RectTransformUtility = UnityEngine.RectTransformUtility
local Vector3 = UnityEngine.Vector3
local Vector2 = UnityEngine.Vector2
local Time = UnityEngine.Time
local Color = UnityEngine.Color
local LuaButton = require("ui.control.button.LuaButton")
local Helper = require("ui.scene.formation.Helper")
local PlayerCardModel = require("ui.models.cardDetail.PlayerCardModel")
local FormationConstants = require("ui.scene.formation.FormationConstants")
local AssetFinder = require("ui.common.AssetFinder")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local CardColorConfig = require("ui.common.card.CardColorConfig")
local PasterMainType = require("ui.scene.paster.PasterMainType")
local UISoundManager = require("ui.control.manager.UISoundManager")
local CardBuilder = require("ui.common.card.CardBuilder")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local PlayerTeamsModel = require("ui.models.PlayerTeamsModel")

local PlayerCardCircle = class(unity.base)
-- 确定是要进行拖拽的间隔时间
local TIME_OF_ENSURE_DRAG = 0.3
-- 确定是要进行拖拽的距离
local DISTANCE_OF_ENSURE_DRAG = 1

local POS_MISMATCH_DISCOUNT = PlayerTeamsModel.POS_MISMATCH_DISCOUNT

local MAX_DISCOUNT = 99

function PlayerCardCircle:ctor()
    -- 名称
    self.nameTxt = self.___ex.name
    self.nameColorComponent = self.___ex.nameColorComponent
    -- 名称框
    self.nameBox = self.___ex.nameBox
    -- 品级框
    self.quality = self.___ex.quality
    -- 球员Icon头像
    self.icon = self.___ex.icon
    -- 头像框
    self.iconBox = self.___ex.iconBox
    -- 等级
    self.level = self.___ex.level
    -- 球员位置
    self.pos = self.___ex.pos
    -- 遮罩
    self.mask = self.___ex.mask
    -- self.mask2 = self.___ex.mask2
    -- 战力
    self.power = self.___ex.power
    -- 球员属性下降标识
    self.downFlag = self.___ex.downFlag
    -- 添加图标
    self.addFlag = self.___ex.addFlag
    self.addFlagCircleImage = self.___ex.addFlagCircleImage
    self.addFlagAddImage = self.___ex.addFlagAddImage
    -- 球员头像节点
    self.player = self.___ex.player
    self.noPlayer = self.___ex.noPlayer
    -- 画布组
    self.canvasGroup = self.___ex.canvasGroup
    self.rectTrans = self.___ex.rectTrans
    -- 换人动画
    self.swapPlayerImage = self.___ex.swapPlayerImage
    self.swapPlayerAnimator = self.___ex.swapPlayerAnimator
    -- 底部的倒三角
    self.bottomBox = self.___ex.bottomBox
    -- 品质标志
    self.qualitySignIcon = self.___ex.qualitySignIcon
    -- 转生标志
    self.ascendArea = self.___ex.ascendArea
    self.ascend = self.___ex.ascend
    --球员特训标志
    self.trainingArea = self.___ex.trainingArea
    self.training = self.___ex.training
    -- 当前卡牌显示状态
    self.nowShowType = 0
    -- 卡牌数据模型
    self.playerCardModel = nil
    -- ScrollRect组件
    self.scrollRectInParent = nil
    -- 记录时间
    self.recordTime = 0
    -- 是否延时创建拖拽物体
    self.isCreateDragNodeDelayed = true
    -- 是否已创建拖拽物体
    self.hasCreateDragNode = false
    -- 是否已开始进行拖拽
    self.isBeginDrag = false
    -- 创建拖拽的物体
    self.draggingNode = nil
    -- 数据索引
    self.dataIndex = nil
    -- 球员分类，具体查看FormationConstants.PlayersClassifyInFormation
    self.playerClassify = nil
    -- 球员当前的位置和自身擅长的位置是否匹配
    self.posIsMatch = false
    -- 是否是被替换下的球员，仅用于比赛中
    self.isSubstituted = false
    -- 是否禁用触摸
    self.isDisableTouch = false
    -- 是否禁止被拖动
    self.isDisableBeDraged = false
    self.luaEventTrigger = self.___ex.luaEventTrigger
    -- 上一次的位置
    self.lastPos = nil
    -- 显示的上一个球员的Model
    self.lastPlayerCardModel = nil
    -- 最佳拍档图标
    self.chemicalSign1 = self.___ex.chemicalSign1
    self.chemicalSign2 = self.___ex.chemicalSign2
    self.chemicalSign3 = self.___ex.chemicalSign3
    self.chemicalText1 = self.___ex.chemicalText1
    self.chemicalText2 = self.___ex.chemicalText2
    self.chemicalText3 = self.___ex.chemicalText3
    self.chemicalAnimator = self.___ex.chemicalAnimator
    self.decorate = self.___ex.decorate
    self.noFlag = self.___ex.noFlag
    self.suggestedBox = self.___ex.suggestedBox
    self.suggestedText = self.___ex.suggestedText
    self.downFlagText = self.___ex.downFlagText

    self.coupleIsActivated = false
    self.coupleIndexList = {}
    self.coupleID = 0
    self.coupleState = 0
    self.coupleCanActivate = false

    -- PlayerCardCircle资源路径
    self.playerCardCirclePath = "Assets/CapstonesRes/Game/UI/Scene/Formation/PlayerCardCircle.prefab"
end

function PlayerCardCircle:SetCardResCache(cardResourceCache)
    self.cardResourceCache = cardResourceCache
end

--- 初始化数据
-- @param dataIndex 球员数据索引，在首发和替补阵容中对应的是球员位置，在候补阵容中对应的是索引index
-- @param pcId 卡牌Id
-- @param showType 卡牌的显示状态，据此决定卡牌上要显示的信息
-- @param playerClassify 在阵型中球员的分类：首发、替补、候补
-- @param isSubstituted 是否是被替换下的球员，仅用于比赛中
function PlayerCardCircle:initData(dataIndex, pcId, showType, playerClassify, formationDataModel, isSubstituted, isDisableTouch, isDisableBeDraged)
    local playerCardModel
    if showType ~= FormationConstants.CardShowType.EMPTY then
        playerCardModel = CardBuilder.GetFormationCardModel(pcId, formationDataModel)
    end
    local specialEventsMatchId = formationDataModel and formationDataModel.specialEventsMatchId or nil
    self:initDataByModel(dataIndex, playerCardModel, showType, playerClassify, isSubstituted, isDisableTouch, isDisableBeDraged, specialEventsMatchId)
end

--- 根据PlayerCardModel初始化数据
-- @param dataIndex 球员数据索引，在首发和替补阵容中对应的是球员位置，在候补阵容中对应的是索引index
-- @param playerCardModel 卡牌模型
-- @param showType 卡牌的显示状态，据此决定卡牌上要显示的信息
-- @param playerClassify 在阵型中球员的分类：首发、替补、候补
-- @param isSubstituted 是否是被替换下的球员，仅用于比赛中
function PlayerCardCircle:initDataByModel(dataIndex, playerCardModel, showType, playerClassify, isSubstituted, isDisableTouch, isDisableBeDraged, specialEventsMatchId)
    self.dataIndex = dataIndex
    self.playerCardModel = playerCardModel
    self.nowShowType = tonumber(showType)
    self.playerClassify = playerClassify
    self.isSubstituted = isSubstituted or false
    self.isDisableTouch = isDisableTouch or false
    self.isDisableBeDraged = isDisableBeDraged or false
    self.specialEventsMatchId = specialEventsMatchId
    self:CheckPosIsMatch()
end

function PlayerCardCircle:start()
    self:BuildPage()
end

--- 设置父节点中ScrollRect组件
-- @param scrollRect ScrollRect组件
function PlayerCardCircle:SetScrollRectParent(scrollRect)
    self.scrollRectInParent = scrollRect
end

function PlayerCardCircle:SetChemical(coupleInfo)
    self.coupleID = coupleInfo.coupleID
    self.coupleIndexList = coupleInfo.coupleIndexList
    self.coupleIsActivated = coupleInfo.coupleIsActivated
    self.coupleCanActivate = coupleInfo.coupleCanActivate
end

function PlayerCardCircle:SetCoupleState(coupleState)
    self.coupleState = coupleState
end

--- 构建界面
function PlayerCardCircle:BuildPage()
    self:BuildCard()

    if self.nowShowType == FormationConstants.CardShowType.MAIN_INFO then
        self:ShowCardType1()
    elseif self.nowShowType == FormationConstants.CardShowType.LEVEL_INFO then
        self:ShowCardType2()
    elseif self.nowShowType == FormationConstants.CardShowType.EMPTY then
        self:ShowCardType4()
    end
end

--- 检测球员当前的位置和自身擅长的位置是否匹配
function PlayerCardCircle:CheckPosIsMatch()
    if self.nowShowType ~= FormationConstants.CardShowType.EMPTY then
        self.posIsMatch = self:CheckPosIsMatchInList(self.dataIndex, self.playerCardModel:GetPosition())
    end
end
--- 构建卡牌
function PlayerCardCircle:BuildCard()
    if self.nowShowType ~= FormationConstants.CardShowType.EMPTY then
        if self.isDisableBeDraged then
            self:DisableBeDraged()
        else
            self:EnableBeDraged()
        end

        local isSameCardQuality = false
        local isSameAvatar = false
        local isSameLevel = false
        local cardQuality = self.playerCardModel:GetCardQuality()
        local avatar = self.playerCardModel:GetAvatar()
        local level = self.playerCardModel:GetLevel()
        local ascend = self.playerCardModel:GetAscend()
        local training = self.playerCardModel:GetTrainingLevel()

        if self.lastPlayerCardModel ~= nil then
            local lastCardQuality = self.lastPlayerCardModel:GetCardQuality()
            isSameCardQuality = lastCardQuality == cardQuality

            local lastAvatar = self.lastPlayerCardModel:GetAvatar()
            isSameAvatar = lastAvatar == avatar

            local lastLevel = self.lastPlayerCardModel:GetLevel()
            isSameLevel = lastLevel == level
        end

        local fixQuality = self.playerCardModel:GetCardFixQuality()
        if not isSameCardQuality then
            self.quality.overrideSprite = self.cardResourceCache:GetCircleQualityRes(fixQuality)
            self.nameBox.overrideSprite = self.cardResourceCache:GetCircleQualityRibbonRes(fixQuality)
            self.qualitySignIcon.overrideSprite = self.cardResourceCache:GetCircleCardSignRes(fixQuality)
            self:SetCardAscend(ascend)
            self:SetCardTraining(training)

            local nameGradientColor = CardColorConfig.GetNameGradientColorWithCircleCard(cardQuality)
            self.nameColorComponent:ResetPointColors(table.nums(nameGradientColor))
            for i, v in ipairs(nameGradientColor) do
                self.nameColorComponent:AddPointColors(v.percent, v.color)
            end

            local levelAndPowerColor = CardColorConfig.GetFormationCardLevelAndPowerColor(cardQuality)
            self.level.color = Color(levelAndPowerColor.r, levelAndPowerColor.g, levelAndPowerColor.b, levelAndPowerColor.a)
            self.power.color = Color(levelAndPowerColor.r, levelAndPowerColor.g, levelAndPowerColor.b, levelAndPowerColor.a)
        end

        -- 贴纸
        local hasPaster = self.playerCardModel:HasPaster()
        GameObjectHelper.FastSetActive(self.decorate.gameObject, hasPaster)
        if hasPaster then 
            local mainType = self.playerCardModel:GetPasterMainType()
            self:PasterShowOnType(fixQuality, mainType)
        end

        if not isSameAvatar then
            -- 头像
            self.icon.overrideSprite = self.cardResourceCache:GetAvatarRes(avatar)
        end

        if not isSameLevel then
            self.level.text = "Lv." .. level
        end

        self.nameTxt.text = self.playerCardModel:GetName()
        self.power.text = tostring(self:GetPower())
        self.pos.text = self.playerCardModel:GetPosition()[1]
        self:ToggleEnabled(self.isSubstituted)

        -- 是首发球员并且位置不匹配
        if self.playerClassify == FormationConstants.PlayersClassifyInFormation.INIT and self.posIsMatch == false then
            self:ToggleDownFlag(true)
        else
            self:ToggleDownFlag(false)
        end
        self:ToggleBottomBox(true)
    else
        self:DisableBeDraged()
        self:ToggleEnabled(false)
        self:ToggleDownFlag(false)
        self:ToggleBottomBox(false)
    end
    if self.playerClassify == FormationConstants.PlayersClassifyInFormation.INIT then
        if GuideManager.GuideIsOnGoing("main") then
            self:DisableBeDraged()
        end
    end

    self:BuildForSpecialEvents()
end

function PlayerCardCircle:SetCardAscend(ascend)
    local isShowAscend = tobool(ascend > 0)
    if isShowAscend then 
        self.ascend.overrideSprite = self.cardResourceCache:GetAscendRes(ascend)
        self.ascend:SetNativeSize()
    end
    GameObjectHelper.FastSetActive(self.ascendArea, isShowAscend)
end

function PlayerCardCircle:SetCardTraining(train)
    local isShowTraining = tobool(train)
    if isShowTraining then 
        local trainingRes = self.cardResourceCache:GetCircleCardTrainingSignRes(train)
        self.training.overrideSprite = trainingRes
        self.training:SetNativeSize()
    end
    GameObjectHelper.FastSetActive(self.trainingArea, isShowTraining)
end

--- 显示卡牌状态1
function PlayerCardCircle:ShowCardType1()
    GameObjectHelper.FastSetActive(self.player, true)
    GameObjectHelper.FastSetActive(self.noPlayer, false)
    GameObjectHelper.FastSetActive(self.addFlag.gameObject, false)
    GameObjectHelper.FastSetActive(self.nameBox.gameObject, true)
    GameObjectHelper.FastSetActive(self.iconBox, true)
    GameObjectHelper.FastSetActive(self.qualitySignIcon.gameObject, true)
    self:SetChemicalSign()
end

--- 显示卡牌状态2
function PlayerCardCircle:ShowCardType2()
    GameObjectHelper.FastSetActive(self.noPlayer, true)
    GameObjectHelper.FastSetActive(self.player, false)
    GameObjectHelper.FastSetActive(self.addFlag.gameObject, false)
    GameObjectHelper.FastSetActive(self.nameBox.gameObject, true)
    GameObjectHelper.FastSetActive(self.iconBox, true)
    GameObjectHelper.FastSetActive(self.qualitySignIcon.gameObject, false)
    GameObjectHelper.FastSetActive(self.ascendArea, false)
	GameObjectHelper.FastSetActive(self.trainingArea, false)
    self:SetChemicalSign()
end

--- 显示卡牌状态4
function PlayerCardCircle:ShowCardType4()
    GameObjectHelper.FastSetActive(self.addFlag.gameObject, true)
    GameObjectHelper.FastSetActive(self.nameBox.gameObject, false)
    GameObjectHelper.FastSetActive(self.iconBox, false)
    GameObjectHelper.FastSetActive(self.qualitySignIcon.gameObject, false)
    GameObjectHelper.FastSetActive(self.ascendArea, false)
	GameObjectHelper.FastSetActive(self.trainingArea, false)
    GameObjectHelper.FastSetActive(self.chemicalSign1, false)
    GameObjectHelper.FastSetActive(self.chemicalSign2, false)   
    GameObjectHelper.FastSetActive(self.chemicalSign3, false)  
    self:ToggleDownFlag(false)
end

function PlayerCardCircle:PasterShowOnType(quality, pasterMainType)
     -- 争霸贴纸不显示效果
    if pasterMainType == PasterMainType.Compete then
        GameObjectHelper.FastSetActive(self.decorate.gameObject, false)
        return
    end

    local decorateRes = self.cardResourceCache:GetCirclePasterDecorateOnTypeRes(quality, pasterMainType)
    self.decorate.overrideSprite = decorateRes
end

-- 切换卡牌框的禁用状态
function PlayerCardCircle:ToggleEnabled(isEnabled)
    GameObjectHelper.FastSetActive(self.mask.gameObject, isEnabled)
    local isDisabled = not isEnabled
    if self.canvasGroup.blocksRaycasts ~= isDisabled then
        self.canvasGroup.blocksRaycasts = isDisabled
    end
    if self.isDisableTouch and isDisabled == true then
        self.canvasGroup.blocksRaycasts = false
    end
end

function PlayerCardCircle:SetChemicalSign()
    if self.coupleState == FormationConstants.CoupleState.SHOW then
        if tonumber(self.coupleID) ~= 0 then
            if self.coupleIsActivated then
                GameObjectHelper.FastSetActive(self.chemicalSign1, true)
                GameObjectHelper.FastSetActive(self.chemicalSign2, false)
                self.chemicalText1.text = tostring(self.coupleID)
            else
                GameObjectHelper.FastSetActive(self.chemicalSign1, false)
                GameObjectHelper.FastSetActive(self.chemicalSign2, true)
                self.chemicalText2.text = tostring(self.coupleID)
                if self.coupleCanActivate then
                    self.chemicalAnimator:Play("Couple2ReadyToActive")
                else
                    self.chemicalAnimator:Play("None")
                end
            end
        else
            GameObjectHelper.FastSetActive(self.chemicalSign1, false)
            GameObjectHelper.FastSetActive(self.chemicalSign2, false)    
        end 
        if next(self.coupleIndexList) then
            local text = ""
            for i, v in ipairs(self.coupleIndexList) do
                if i == 1 then
                    text = text .. tostring(v)
                else
                    text = text .. "/" .. tostring(v)
                end
            end
            local  len =  string.len(text)
            if #self.coupleIndexList == 1 then
                self.chemicalSign3.transform.sizeDelta = Vector2(26, 26) 
                self.chemicalSign3.transform.anchoredPosition = Vector2(26, -42)
                self.chemicalText3.fontSize = 18
            elseif #self.coupleIndexList == 2 then
                self.chemicalSign3.transform.sizeDelta = Vector2(12 * len, 26) 
                self.chemicalText3.fontSize = 18
                self.chemicalSign3.transform.anchoredPosition = Vector2(26, -42)
            elseif #self.coupleIndexList > 2 then 
                self.chemicalSign3.transform.sizeDelta = Vector2(8.5 * len, 26) 
                self.chemicalText3.fontSize = 14
                self.chemicalSign3.transform.anchoredPosition = Vector2(0, -42)
            end
            GameObjectHelper.FastSetActive(self.chemicalSign3, true)
            self.chemicalText3.text = text
        else
            GameObjectHelper.FastSetActive(self.chemicalSign3, false)
        end
    else
        GameObjectHelper.FastSetActive(self.chemicalSign1, false)
        GameObjectHelper.FastSetActive(self.chemicalSign2, false)   
        GameObjectHelper.FastSetActive(self.chemicalSign3, false)  
    end
end
-- 切换球员属性下降标识显示状态
function PlayerCardCircle:ToggleDownFlag(isShow)
    GameObjectHelper.FastSetActive(self.downFlag.gameObject, isShow)
    if isShow and self.downFlagText then
        self.downFlagText.text = string.format("%d%%", math.ceil(self:GetPowerDiscount()))
    end
end

function PlayerCardCircle:GetPowerDiscount()
    local discount = 0
    if self.posIsMatch == false then
        discount = POS_MISMATCH_DISCOUNT
    end

    if self.specialEventsMatchId ~= nil then
        local discount1 = self.playerCardModel:GetSpecialEventDiscount()
        discount = (1 - (1 - discount * 0.01) * (1 - discount1 * 0.01)) * 100
    end
    
    return math.min(discount, MAX_DISCOUNT)
end

-- 切换底部倒影显示状态
function PlayerCardCircle:ToggleBottomBox(isShow)
    GameObjectHelper.FastSetActive(self.bottomBox.gameObject, isShow)
end

-- 设置位置
function PlayerCardCircle:SetPos(pos, formationId, formationWidth, formationHeight, formationRotateX, isPortrait, scale)
    self.lastPos = pos
    local posCoords = Helper.GetTrapezoidFormationCoord(pos, formationId, formationWidth, formationHeight, formationRotateX, isPortrait)
    scale = scale or 1
    self.transform.localPosition = Vector3(posCoords.x, posCoords.y, 0)
    self.transform.localScale = Vector3(posCoords.scale * scale, posCoords.scale * scale, 1)
    self:CheckIsMatchForSpecialEvents()
end

function PlayerCardCircle:SetPosInPlane(pos, formationId, formationWidth, formationHeight, isPortrait, scale)
    if self.lastPos ~= pos then
        self.lastPos = pos
        local posCoords = Helper.GetPos(pos, formationId, isPortrait)
        self.transform.localPosition = Vector3(formationWidth * posCoords.x, formationHeight * posCoords.y)
        self.transform.localScale = Vector3(scale, scale, 1)
    end
    self:CheckIsMatchForSpecialEvents()
end

function PlayerCardCircle:GetPos()
    return self.dataIndex
end

-- 获取战力
function PlayerCardCircle:GetPower()
    if self.nowShowType ~= FormationConstants.CardShowType.EMPTY then
        -- 是首发球员
        if self.playerClassify == FormationConstants.PlayersClassifyInFormation.INIT then
            local power = math.floor(self.playerCardModel:GetPower() * (100 - self:GetPowerDiscount()) / 100)
            return power
        else
            return self.playerCardModel:GetPower()
        end

    else
        return 0
    end
end

-- 更新首发球员在主场特性改变的数据更新
function PlayerCardCircle:UpdateStartersHomeCourt()
    if self.nowShowType ~= FormationConstants.CardShowType.EMPTY then
        -- 是首发球员
        if self.playerClassify == FormationConstants.PlayersClassifyInFormation.INIT then
            self.playerCardModel:InitHomeCourtImprove()
        end
    end
end

-- 获取球员属性
function PlayerCardCircle:GetAbility(index)
    if self.nowShowType ~= FormationConstants.CardShowType.EMPTY then
        return self.playerCardModel:GetAbility(index)
    else
        return 0, 0
    end
end

function PlayerCardCircle:GetDataIndex()
    return self.dataIndex
end

-- 设置当前卡牌显示状态
function PlayerCardCircle:SetShowType(nowShowType)
    self.nowShowType = tonumber(nowShowType)
end

-- 获取当前卡牌显示状态
function PlayerCardCircle:GetShowType()
    return self.nowShowType
end

-- 获取球员ID
function PlayerCardCircle:GetPcId()
    if self.playerCardModel then
        return self.playerCardModel:GetPcid()
    else
        return 0
    end
end

function PlayerCardCircle:GetModel()
    return self.playerCardModel
end

-- 获取世界坐标
function PlayerCardCircle:GetWorldPosition()
    return self.transform.position
end

-- 设置世界坐标
function PlayerCardCircle:SetWorldPosition(newPosition)
    local oldPosition = self:GetWorldPosition()
    oldPosition.x = newPosition.x
    oldPosition.y = newPosition.y
    oldPosition.z = newPosition.z
end

-- 在父节点中查找特定组件
function PlayerCardCircle:FindComponentInParents(type)
    local parent = self.transform
    local component = nil
    while parent ~= nil and (component == nil or component == clr.null) do  --Lua assist checked flag
        component = parent:GetComponent(type)
        parent = parent.parent
    end

    if component ~= nil and component == clr.null then  --Lua assist checked flag
        component = nil
    end

    return component
end

-- 创建拖拽的物体
function PlayerCardCircle:CreateDraggingNode()
    self.hasCreateDragNode = true
    self.canvasGroup.alpha = 0.5
    local node = Object.Instantiate(res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Formation/PlayerCardCircle.prefab"))
    local nodeScript = node:GetComponent(clr.CapsUnityLuaBehav)
    nodeScript:SetCardResCache(self.cardResourceCache)
    nodeScript:initDataByModel(self.dataIndex, self.playerCardModel, self.nowShowType, self.playerClassify, self.isSubstituted, true)
    self.draggingNode = node.transform
    self.draggingNode:SetParent(self.transform.root, false)
    self.draggingNode:SetAsLastSibling()
    self.draggingNode.position = Input.mousePosition

    EventSystem.SendEvent("FormationPageView.ShowPlayerArea", self.playerCardModel:GetPosition())
end

-- 销毁拖拽的物体
function PlayerCardCircle:DestroyDraggingNode()
    self.hasCreateDragNode = false
    self.canvasGroup.alpha = 1
    Object.Destroy(self.draggingNode.gameObject)
    EventSystem.SendEvent("FormationPageView.HidePlayerArea", self.playerCardModel:GetPosition())
end

function PlayerCardCircle:onPointerUp(eventData)
    if LuaButton.clickSpeedValid() then
        LuaButton.frameCount = Time.frameCount
        if self.isCreateDragNodeDelayed and self.nowShowType ~= FormationConstants.CardShowType.EMPTY and not self.isBeginDrag then
            if not GuideManager.GuideIsOnGoing("main") then
                UISoundManager.play("Card/cardClick")
                EventSystem.SendEvent("ClickPlayerCardCircle", self.playerCardModel:GetPcid(), self)
            end
        end
        self.isCreateDragNodeDelayed = false

        if self.hasCreateDragNode == true and not self.isBeginDrag then
            self:DestroyDraggingNode()
        end
    end
end

function PlayerCardCircle:onInitializePotentialDrag(eventData)
    if self.scrollRectInParent then
        self.scrollRectInParent:OnInitializePotentialDrag(eventData)
    end

    self.recordTime = Time.unscaledTime
    self.isBeginDrag = false
    self.hasCreateDragNode = false
    self.isCreateDragNodeDelayed = true
    self:coroutine( function()
        while self.isCreateDragNodeDelayed == true do
            if Time.unscaledTime - self.recordTime > TIME_OF_ENSURE_DRAG then
                self.isCreateDragNodeDelayed = false
                self:CreateDraggingNode()
                self:FollowFinger(eventData)
            end
            coroutine.yield()
        end
    end )
end

function PlayerCardCircle:FollowFinger(eventData)
    if eventData.pointerEnter ~= nil then
        local success, globalMousePos = RectTransformUtility.ScreenPointToWorldPointInRectangle(self.draggingNode.parent, eventData.position, eventData.pressEventCamera, Vector3.zero)
        if success then
            self.draggingNode.position = globalMousePos
        end
    end
end

function PlayerCardCircle:onBeginDrag(eventData)
    if not self.hasCreateDragNode then 
        if math.abs(eventData.delta.x) / math.abs(eventData.delta.y) > DISTANCE_OF_ENSURE_DRAG then
            self:CreateDraggingNode()
            self.isCreateDragNodeDelayed = false
        elseif self.scrollRectInParent then
            if self.playerClassify == FormationConstants.PlayersClassifyInFormation.REPLACE or self.playerClassify == FormationConstants.PlayersClassifyInFormation.WAIT then
                self.isCreateDragNodeDelayed = false
            end
            self.scrollRectInParent:OnBeginDrag(eventData)
        end
    end

    self.isBeginDrag = true
end

function PlayerCardCircle:onDrag(eventData)
    if self.hasCreateDragNode then
        self:FollowFinger(eventData)
    elseif self.scrollRectInParent then
        self.scrollRectInParent:OnDrag(eventData)
    end
end

function PlayerCardCircle:onEndDrag(eventData)
    self.isBeginDrag = false
    if self.scrollRectInParent then
        self.scrollRectInParent:OnEndDrag(eventData)
    end

    if self.hasCreateDragNode then
        self:DestroyDraggingNode()
        local isContainsSelf = RectTransformUtility.RectangleContainsScreenPoint(self.rectTrans, eventData.position, eventData.pressEventCamera)
        if not isContainsSelf then
            EventSystem.SendEvent("FormationPageView.ReceiveEndDragPlayer", self, self.dataIndex, self.playerClassify, eventData)
        end
    end
end

function PlayerCardCircle:onDrop(eventData)
    EventSystem.SendEvent("FormationPageView.ReceiveDropPlayer", self, self.dataIndex, self.playerClassify)
end

function PlayerCardCircle:DisableBeDraged()
    self.luaEventTrigger.TrigBeginDrag = false
    self.luaEventTrigger.TrigDrag = false
    self.luaEventTrigger.TrigInitializePotentialDrag = false
end

function PlayerCardCircle:EnableBeDraged()
    self.luaEventTrigger.TrigBeginDrag = true
    self.luaEventTrigger.TrigDrag = true
    self.luaEventTrigger.TrigInitializePotentialDrag = true
end

function PlayerCardCircle:ShowOrHideAddFlag(isShow)
    if self.nowShowType == FormationConstants.CardShowType.EMPTY then
        if isShow then
            self.addFlagCircleImage.color = Color(1, 1, 1, 1)
            self.addFlagAddImage.color = Color(1, 1, 1, 1)
        else
            self.addFlagCircleImage.color = Color(1, 1, 1, 0)
            self.addFlagAddImage.color = Color(1, 1, 1, 0)
        end
    end
end

function PlayerCardCircle:ShowOrHideSwapPlayerEffect(isShow)
    if self.nowShowType ~= FormationConstants.CardShowType.EMPTY then
        GameObjectHelper.FastSetActive(self.swapPlayerImage, isShow)
        if self.swapPlayerAnimator.enabled ~= isShow then
            self.swapPlayerAnimator.enabled = isShow
        end
    end
end

--- 检测球员当前的位置和自身擅长的位置是否匹配
-- @param pos 球员在球场上的位置
-- @param positionList 球员自身擅长的位置名称缩写列表
-- @return boolean
function PlayerCardCircle:CheckPosIsMatchInList(pos, positionList)
    pos = tostring(pos)

    for i, positionName in ipairs(positionList) do
        local posList = FormationConstants.PositionToNumber[positionName]
        for j, pos2 in ipairs(posList) do
            if pos == pos2 then
                return true
            end
        end
    end

    return false
end

function PlayerCardCircle:CheckIsMatchForSpecialEvents()
    if self.specialEventsMatchId ~= nil and self.playerCardModel ~= nil then
        local position = self.playerClassify == FormationConstants.PlayersClassifyInFormation.INIT and self.lastPos or nil
        self.playerCardModel:CheckIsMatchForSpecialEvents(self.specialEventsMatchId, position)
    end
end

function PlayerCardCircle:BuildForSpecialEvents()
    if self.specialEventsMatchId ~= nil then
        GameObjectHelper.FastSetActive(self.suggestedBox, false)
        GameObjectHelper.FastSetActive(self.noFlag, false)
        self:ToggleDownFlag(false)
        if self.nowShowType ~= FormationConstants.CardShowType.EMPTY then
            self:CheckIsMatchForSpecialEvents()
            if self.playerClassify == FormationConstants.PlayersClassifyInFormation.INIT then
                if not self.playerCardModel:IsSuitForSpecialEvent() then
                    GameObjectHelper.FastSetActive(self.noFlag, true)
                    self:ToggleDownFlag(true)
                elseif self.posIsMatch == false then
                    self:ToggleDownFlag(true)
                end
            else
                if self.playerCardModel:IsSuitForSpecialEventsNationMatch() then
                    GameObjectHelper.FastSetActive(self.suggestedBox, true)
                    self.suggestedText.text = lang.trans("special_events_suggested_nation")
                elseif self.playerCardModel:IsSuitForSpecialEventsSkillMatch() then
                    GameObjectHelper.FastSetActive(self.suggestedBox, true)
                    self.suggestedText.text = lang.trans("special_events_suggested_skill")
                end
            end
        end
    end
end

return PlayerCardCircle
