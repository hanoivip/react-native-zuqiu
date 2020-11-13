local BaseModel = require("ui.models.greensward.item.itemAction.GreenswardItemActionBaseModel")

local ItemActionDialogRewardModel = class(BaseModel, "ItemActionDialogRewardModel")

local paramsKey = {
    title = "title", -- 提示的标题
    msg = "msg", -- 提示的主要内容
}

-- 绿茵征途使用道具，奖励结果行为model
function ItemActionDialogRewardModel:Init(id, greenswardItemModel, greenswardBuildModel, contents)
    ItemActionDialogRewardModel.super.Init(self, id, greenswardItemModel, greenswardBuildModel)
    self.contents = contents
end

-- 获得奖励
function ItemActionDialogRewardModel:GetContents()
    return self.contents
end

-- 解析配置弹框参数
function ItemActionDialogRewardModel:ParseConfig(config)
    local actionParam = config.actionParam
    if not actionParam then return config end

    local title = actionParam[paramsKey.title] or lang.transstr("tips")
    local msg = actionParam[paramsKey.msg] or ""

    self.title = title
    self.msg = msg
    return config
end

-- 获得当前道具行为的加工后参数
function ItemActionDialogRewardModel:GetActionCookedParam()
    return self:GetTitle(), self:GetMsg()
end

-- 获得对话框标题
function ItemActionDialogRewardModel:GetTitle()
    return self.title
end

-- 获得对话框提示内容
function ItemActionDialogRewardModel:GetMsg()
    return self.msg
end

return ItemActionDialogRewardModel
