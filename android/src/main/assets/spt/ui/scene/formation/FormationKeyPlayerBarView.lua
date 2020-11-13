local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local GameObjectHelper = require("ui.common.GameObjectHelper")
local FormationKeyPlayerBoardView = require("ui.scene.formation.FormationKeyPlayerBoardView")
local FormationConstants = require("ui.scene.formation.FormationConstants")

local FormationKeyPlayerBarView = class(unity.base)

local FormationKeyPlayerSkillsTable = {
    [FormationConstants.KeyPlayerType.CAPTAIN] = "F01",
    [FormationConstants.KeyPlayerType.FREEKICKSHOOT] = "F02",
    [FormationConstants.KeyPlayerType.FREEKICKPASS] = "F02",
    [FormationConstants.KeyPlayerType.SPOTKICK] = "F03",
    [FormationConstants.KeyPlayerType.CORNER] = "F04"
}

local FormationKeyPlayerNormalAttrLangKeyMap = {
    shoot = "formation_keyPlayer_shoot_attr",
    pass = "formation_keyPlayer_pass_attr",
    dribble = "formation_keyPlayer_dribble_attr",
    intercept = "formation_keyPlayer_intercept_attr",
    steal = "formation_keyPlayer_steal_attr",
}

function FormationKeyPlayerBarView:ctor()
    self.nameTxt = self.___ex.name
    self.position = self.___ex.position
    self.bgImage = self.___ex.bgImage
    self.keyPlayerInfoBoard = self.___ex.keyPlayerInfoBoard

    self.captainAttrArea = self.___ex.captainAttrArea
    self.freeKickShootAttrArea = self.___ex.freeKickShootAttrArea
    self.freeKickPassAttrArea = self.___ex.freeKickPassAttrArea
    self.spotKickAttrArea = self.___ex.spotKickAttrArea
    self.cornerAttrArea = self.___ex.cornerAttrArea

    self.captainSkillAttr = self.___ex.captainSkillAttr
    self.freeKickShootNormalAttr = self.___ex.freeKickShootNormalAttr
    self.freeKickShootSkillAttr = self.___ex.freeKickShootSkillAttr
    self.freeKickPassNormalAttr = self.___ex.freeKickPassNormalAttr
    self.freeKickPassSkillAttr = self.___ex.freeKickPassSkillAttr
    self.spotKickNormalAttr = self.___ex.spotKickNormalAttr
    self.spotKickSkillAttr = self.___ex.spotKickSkillAttr
    self.cornerNormalAttr = self.___ex.cornerNormalAttr
    self.cornerSkillAttr = self.___ex.cornerSkillAttr

    self.FormationKeyPlayerAttrsAreaTable = {
        [FormationConstants.KeyPlayerType.CAPTAIN] = self.captainAttrArea,
        [FormationConstants.KeyPlayerType.FREEKICKSHOOT] = self.freeKickShootAttrArea,
        [FormationConstants.KeyPlayerType.FREEKICKPASS] = self.freeKickPassAttrArea,
        [FormationConstants.KeyPlayerType.SPOTKICK] = self.spotKickAttrArea,
        [FormationConstants.KeyPlayerType.CORNER] = self.cornerAttrArea
    }

end

function FormationKeyPlayerBarView:InitView(index, position, playerCardModel)
    if index % 2 == 0 then
        self.bgImage.color = Color(0, 0, 0, 0)
    end
    if position and playerCardModel then
        self.playerCardModel = playerCardModel
        self.nameTxt.text = self.playerCardModel:GetName()
        self.position.text = position
        self:InitKeyPlayerAttr()
    end
end

function FormationKeyPlayerBarView:InitKeyPlayerAttr()  
    self:InitKeyPlayerAttrs(FormationConstants.KeyPlayerType.CAPTAIN, nil, self.captainSkillAttr)
    self:InitKeyPlayerAttrs(FormationConstants.KeyPlayerType.FREEKICKSHOOT, self.freeKickShootNormalAttr, self.freeKickShootSkillAttr)
    self:InitKeyPlayerAttrs(FormationConstants.KeyPlayerType.FREEKICKPASS, self.freeKickPassNormalAttr, self.freeKickPassSkillAttr)
    self:InitKeyPlayerAttrs(FormationConstants.KeyPlayerType.SPOTKICK, self.spotKickNormalAttr, self.spotKickSkillAttr)
    self:InitKeyPlayerAttrs(FormationConstants.KeyPlayerType.CORNER, self.cornerNormalAttr, self.cornerSkillAttr)
end

function FormationKeyPlayerBarView:InitKeyPlayerAttrs(keyPlayerType, normalAttrText, skillAttrText)
    local isSkillExisted = false
    local skillItemModel = self:GetSkillItemModelWithSkillId(FormationKeyPlayerSkillsTable[keyPlayerType])
    if skillItemModel then
        local level = skillItemModel:GetLevel() + skillItemModel:GetLevelEx()
        skillAttrText.text = skillItemModel:GetName() .. " LV" .. level
        isSkillExisted = true
    else
        skillAttrText.text = ""
    end
    local normalAttrValue, normalAttrType = self:GetKeyPlayerNormalAttr(keyPlayerType, isSkillExisted)
    if normalAttrValue and normalAttrType then
        if normalAttrText then
            normalAttrText.text = lang.trans(FormationKeyPlayerNormalAttrLangKeyMap[normalAttrType], normalAttrValue)
        end
    end
end

function FormationKeyPlayerBarView:GetKeyPlayerNormalAttr(keyPlayerType, isSkillExisted)
    if keyPlayerType == FormationConstants.KeyPlayerType.CAPTAIN then
        return nil
    end
    local baseNum, plusNum, trainNum, totalNum
    if isSkillExisted then
        local normalAttrs = {}
        baseNum, plusNum, trainNum, totalNum = self.playerCardModel:GetAbility("shoot")
        table.insert(normalAttrs, {value = baseNum + plusNum + trainNum, type = "shoot"})

        baseNum, plusNum, trainNum, totalNum = self.playerCardModel:GetAbility("pass")
        table.insert(normalAttrs, {value = baseNum + plusNum + trainNum, type = "pass"})

        baseNum, plusNum, trainNum, totalNum = self.playerCardModel:GetAbility("dribble")
        table.insert(normalAttrs, {value = baseNum + plusNum + trainNum, type = "dribble"})

        baseNum, plusNum, trainNum, totalNum = self.playerCardModel:GetAbility("intercept")
        table.insert(normalAttrs, {value = baseNum + plusNum + trainNum, type = "intercept"})

        baseNum, plusNum, trainNum, totalNum = self.playerCardModel:GetAbility("steal")
        table.insert(normalAttrs, {value = baseNum + plusNum + trainNum, type = "steal"})

        table.sort(normalAttrs, function(a, b) return a.value > b.value end)
        return normalAttrs[1].value, normalAttrs[1].type
    else
        if keyPlayerType == FormationConstants.KeyPlayerType.FREEKICKSHOOT or keyPlayerType == FormationConstants.KeyPlayerType.SPOTKICK then
            baseNum, plusNum, trainNum, totalNum = self.playerCardModel:GetAbility("shoot")
            return baseNum + plusNum + trainNum, "shoot"
        elseif keyPlayerType == FormationConstants.KeyPlayerType.FREEKICKPASS or keyPlayerType == FormationConstants.KeyPlayerType.CORNER then
            baseNum, plusNum, trainNum, totalNum = self.playerCardModel:GetAbility("pass")
            return baseNum + plusNum + trainNum, "pass"
        end
    end
    return nil
end

function FormationKeyPlayerBarView:GetSkillItemModelWithSkillId(skillId)
    local skillCount = self.playerCardModel:GetSkillAmount()
    for slot = 1, skillCount do
        local skillItemModel = self.playerCardModel:GetSkillItemModelBySlot(slot)
        if skillItemModel and skillItemModel:GetSkillID() == skillId and skillItemModel:IsOpen() then
            return skillItemModel
        end
    end
    return nil
end

function FormationKeyPlayerBarView:ShowKeyPlayerInfoBoard(keyPlayerType)
    local data = {
        keyPlayerName = "",
        keyPlayerTypeName = "",
        skillAttr = "",
        normalAttr = ""
    }
    data.keyPlayerName = "  " .. self.playerCardModel:GetName()
    if keyPlayerType == FormationConstants.KeyPlayerType.CAPTAIN then
        data.keyPlayerTypeName = clr.unwrap(lang.trans("formation_keyPlayer_captain_detail")) .. ":"
    elseif keyPlayerType == FormationConstants.KeyPlayerType.FREEKICKSHOOT then
        data.keyPlayerTypeName = clr.unwrap(lang.trans("formation_keyPlayer_freeKickShoot_detail")) .. ":"
    elseif keyPlayerType == FormationConstants.KeyPlayerType.FREEKICKPASS then
        data.keyPlayerTypeName = clr.unwrap(lang.trans("formation_keyPlayer_freeKickPass_detail")) .. ":"
    elseif keyPlayerType == FormationConstants.KeyPlayerType.SPOTKICK then
        data.keyPlayerTypeName = clr.unwrap(lang.trans("formation_keyPlayer_spotKick_detail")) .. ":"
    elseif keyPlayerType == FormationConstants.KeyPlayerType.CORNER then
        data.keyPlayerTypeName = clr.unwrap(lang.trans("formation_keyPlayer_corner_detail")) .. ":"
    end

    local isSkillExisted = false
    local skillItemModel = self:GetSkillItemModelWithSkillId(FormationKeyPlayerSkillsTable[keyPlayerType])
    if skillItemModel then
        local level = skillItemModel:GetLevel() + skillItemModel:GetLevelEx()
        data.skillAttr = skillItemModel:GetName() .. " Lv." .. level
        isSkillExisted = true
    end
    local normalAttrValue, normalAttrType = self:GetKeyPlayerNormalAttr(keyPlayerType, isSkillExisted)
    if normalAttrValue and normalAttrType then
        data.normalAttr = lang.trans(FormationKeyPlayerNormalAttrLangKeyMap[normalAttrType], normalAttrValue)
    end

    self.keyPlayerInfoBoard:InitView(data)
    GameObjectHelper.FastSetActive(self.keyPlayerInfoBoard.gameObject, true)
end

function FormationKeyPlayerBarView:HideKeyPlayerInfoBoard()
    GameObjectHelper.FastSetActive(self.keyPlayerInfoBoard.gameObject, false)
end

function FormationKeyPlayerBarView:ShowOrHideKeyPlayerAttr(keyPlayerType, isShow)
    GameObjectHelper.FastSetActive(self.FormationKeyPlayerAttrsAreaTable[keyPlayerType], isShow)
end

return FormationKeyPlayerBarView