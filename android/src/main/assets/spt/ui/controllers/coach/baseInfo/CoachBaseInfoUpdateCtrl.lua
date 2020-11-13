local BaseCtrl = require("ui.controllers.BaseCtrl")
local DialogManager = require("ui.control.manager.DialogManager")
local CoachBaseInfoFormationModel = require("ui.models.coach.baseInfo.CoachBaseInfoFormationModel")
local CoachBaseInfoTacticsModel = require("ui.models.coach.baseInfo.CoachBaseInfoTacticsModel")
local CurrencyNameMap = require("ui.models.itemList.CurrencyNameMap")
local BoardType = require("ui.models.coach.baseInfo.CoachBaseInfoUpdateBoardType")

local CoachBaseInfoUpdateCtrl = class(BaseCtrl, "CoachBaseInfoUpdateCtrl")

CoachBaseInfoUpdateCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Coach/BaseInfo/CoachBaseInfoUpdate.prefab"

CoachBaseInfoUpdateCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function CoachBaseInfoUpdateCtrl:ctor()
    CoachBaseInfoUpdateCtrl.super.ctor(self)
end

function CoachBaseInfoUpdateCtrl:Init()
    CoachBaseInfoUpdateCtrl.super.Init(self)
    self.view.onClickBtnArrowLeft = function() self:OnClickBtnArrowLeft() end
    self.view.onClickBtnArrowRight = function() self:OnClickBtnArrowRight() end
    self.view.onItemBtnChangeClick = function(itemData) self:OnItemBtnChangeClick(itemData) end
    self.view.onItemBtnUpdateClick = function(itemData) self:OnItemBtnUpdateClick(itemData) end
    self.view.onChangeSelectedFormation = function(formationData) self:OnChangeSelectedFormation(formationData) end
end

function CoachBaseInfoUpdateCtrl:Refresh(coachBaseInfoUpdateModel)
    CoachBaseInfoUpdateCtrl.super.Refresh(self)
    if not coachBaseInfoUpdateModel then
        local CoachBaseInfoUpdateModel = require("ui.models.coach.baseInfo.CoachBaseInfoUpdateModel")
        self.model = CoachBaseInfoUpdateModel.new()
    else
        self.model = coachBaseInfoUpdateModel
    end
    self.view:InitView(self.model)
end

function CoachBaseInfoUpdateCtrl:OnEnterScene()
    self.view:OnEnterScene()
end

function CoachBaseInfoUpdateCtrl:OnExitScene()
    self.view:OnExitScene()
end

-- 左右箭头
function CoachBaseInfoUpdateCtrl:OnClickBtnArrowLeft()
    self.view.scrollView:scrollToPreviousGroup()
end

function CoachBaseInfoUpdateCtrl:OnClickBtnArrowRight()
    self.view.scrollView:scrollToNextGroup()
end

-- 切换阵型或切换战术
function CoachBaseInfoUpdateCtrl:OnItemBtnChangeClick(itemData)
    if self.model:IsFormationBoard() then
        local coachBaseInfoFormationModel = CoachBaseInfoFormationModel.new()
        coachBaseInfoFormationModel:InitWithParent(self.model:GetFormations(), itemData)
        res.PushDialog("ui.controllers.coach.baseInfo.CoachBaseInfoFormationCtrl", coachBaseInfoFormationModel)
    elseif self.model:IsTacticsBoard() then
        local coachBaseInfoTacticsModel = CoachBaseInfoTacticsModel.new()
        coachBaseInfoTacticsModel:InitWithParent(itemData)
        res.PushDialog("ui.controllers.coach.baseInfo.CoachBaseInfoTacticsCtrl", coachBaseInfoTacticsModel)
    else
    end
end

-- 选择阵型后更新
function CoachBaseInfoUpdateCtrl:OnChangeSelectedFormation(formationData)
    self.model:UpdateSelectedFormation(formationData)
    self.view:InitView(self.model)
end

-- 升级
function CoachBaseInfoUpdateCtrl:OnItemBtnUpdateClick(itemData)
    if itemData.isMaxLvl and itemData.isCoachMaxLvl then
        DialogManager.ShowToastByLang("hero_hall_upgrade_max_level") -- 已满级
        return
    elseif not itemData.isMaxLvl and itemData.isCoachMaxLvl then
        DialogManager.ShowToastByLang("coach_baseInfo_coach_max_hint") -- 请升级教练解锁更高等级
        return
    end

    local ctiAmount = self.model:GetCtiAmount(itemData.ctiId)
    if ctiAmount < itemData.ctiAmount then
        DialogManager.ShowToast(lang.trans("lack_item_tips", itemData.ctiConfig.name)) -- XX不足
        return
    end

    if itemData.m ~= nil then
        local money = self.model:GetMoney()
        if money < itemData.m then
            DialogManager.ShowToast(lang.trans("lack_item_tips", lang.transstr(CurrencyNameMap.m))) -- 欧元不足
            return
        end
    end

    if itemData.d ~= nil then
        local diamond = self.model:GetDiamond()
        if diamond < itemData.d then
            DialogManager.ShowToast(lang.trans("lack_item_tips", lang.transstr(CurrencyNameMap.d))) -- 钻石不足
            return
        end
    end

    local confirmCallback = function()
        if itemData.boardType == BoardType.Formation then
            -- 阵型升级
            self.view:coroutine(function()
                local respone = req.coachBaseInfoFormationUpgrade(itemData.formationId)
                if api.success(respone) then
                    local data = respone.val
                    if type(data) == "table" and next(data) then
                        self.view:SendUpdateAfterFormationUpgrade(self.model:GetIdx(), itemData.formationId, data)
                        self.model:UpdateAfterUpgradeFormation(data)
                        self.view.scrollView:UpdateItem(1, self.model:GetFormationScrollData()[1])
                        self.view:UpdateCtiItem()
                    end
                end
            end)
        elseif itemData.boardType == BoardType.Tactics then
            -- 战术升级
            self.view:coroutine(function()
                local id = tonumber(itemData.id)
                local respone = req.coachBaseInfoTacticUpgrade(itemData.tacticsType, id)
                if api.success(respone) then
                    local data = respone.val
                    if type(data) == "table" and next(data) then
                        self.view:SendUpdateAfterTacticUpgrade(self.model:GetIdx(), itemData.tacticsType, id, data)
                        self.model:UpdateAfterUpgradeTactic(itemData.tacticsType, id, data)
                        self.view.scrollView:UpdateItem(id, self.model:GetTacticsScrollData()[tonumber(id)])
                        self.view:UpdateCtiItem()
                    end
                end
            end)
        else
            dump("wrong board type! " .. self.boardType)
        end
    end

    local title = lang.transstr("levelUp")
    local msg = lang.transstr("activation_code_confirm") .. lang.transstr("levelUp")
    if itemData.boardType == BoardType.Formation then
        title = lang.transstr("menu_formation") .. title -- 阵型升级
        msg = msg .. itemData.formationName -- 确认升级XX
    elseif itemData.boardType == BoardType.Tactics then
        title = lang.transstr("match_tactics") .. title -- 战术升级
        msg = msg .. itemData.tacticName -- 确认升级XX
    else
        dump("wrong board type!")
    end
    DialogManager.ShowConfirmPop(title, msg, confirmCallback)
end

return CoachBaseInfoUpdateCtrl