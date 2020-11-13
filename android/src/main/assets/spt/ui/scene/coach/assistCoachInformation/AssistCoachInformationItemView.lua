local AssetFinder = require("ui.common.AssetFinder")
local GameObjectHelper = require("ui.common.GameObjectHelper")

local AssistCoachInformationItemView = class(unity.base, "AssistCoachInformationItemView")

function AssistCoachInformationItemView:ctor()
    -- 图标
    self.icon = self.___ex.icon
    -- 情报名字
    self.txtName = self.___ex.txtName
    -- 星级
    self.sptStars = self.___ex.sptStars
    -- 选中标记
    self.objSelect = self.___ex.objSelect
    -- 详细按钮
    self.btnView = self.___ex.btnView
    -- 操作按钮
    self.btnOperate = self.___ex.btnOperate
    self.txtOperate = self.___ex.txtOperate
    -- 选择按钮
    self.btnSelect = self.___ex.btnSelect
    -- 加入槽位之后的背景
    self.bgInGroove = self.___ex.bgInGroove

    -- 助理教练头像脚本
    self.portraitSpt = nil
end

function AssistCoachInformationItemView:start()
end

function AssistCoachInformationItemView:InitView(assistCoachInfoModel, assistCoachInformationModel)
    self.aciModel = assistCoachInfoModel
    self.acInfoModel = assistCoachInformationModel
    local quality = self.aciModel:GetAssistantInfoQuailty()
    local superInfomation = self.aciModel:GetSuperInformation()
    self.icon.overrideSprite = AssetFinder.GetAssistantCoachInformationIcon(superInfomation, quality)
    self.txtName.text = self.aciModel:GetName()
    self.sptStars:InitView(quality)

    GameObjectHelper.FastSetActive(self.objSelect.gameObject, self.acInfoModel:GetChooseState()[self.aciModel.fixId] ~= nil)
    if self.aciModel.grooveIdx ~= nil then
        GameObjectHelper.FastSetActive(self.bgInGroove.gameObject, true)
        self.txtOperate.text = lang.trans("assistant_coach_info_item_2") -- 移除情报
    else
        GameObjectHelper.FastSetActive(self.bgInGroove.gameObject, false)
        self.txtOperate.text = lang.trans("assistant_coach_info_item_1") -- 添加情报
    end
end

return AssistCoachInformationItemView
