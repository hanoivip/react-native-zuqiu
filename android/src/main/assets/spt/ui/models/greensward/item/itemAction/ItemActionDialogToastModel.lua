local BaseModel = require("ui.models.greensward.item.itemAction.GreenswardItemActionBaseModel")

local ItemActionDialogToastModel = class(BaseModel, "ItemActionDialogToastModel")

local paramsKey = {
    msg = "msg", -- 提示的主要内容
}

-- 绿茵征途使用道具，奖励结果行为model
function ItemActionDialogToastModel:Init(id, greenswardItemModel, greenswardBuildModel)
    ItemActionDialogToastModel.super.Init(self, id, greenswardItemModel, greenswardBuildModel)
end


-- 解析配置弹框参数
function ItemActionDialogToastModel:ParseConfig(config)
    local actionParam = config.actionParam
    if not actionParam then return config end

    self.msg = actionParam[paramsKey.msg] or ""

    return config
end

-- 获得当前道具行为的加工后参数
function ItemActionDialogToastModel:GetActionCookedParam()
    return self:GetMsg()
end

-- 获得提示内容
function ItemActionDialogToastModel:GetMsg()
    return self.msg
end

return ItemActionDialogToastModel
